#  Copyright (C) 2003-2007 Tresys Technology, LLC
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

namespace eval Apol_Analysis_transflow {
    variable vals
    variable widgets
    Apol_Analysis::registerAnalysis "Apol_Analysis_transflow" "Transitive Information Flow"
}

proc Apol_Analysis_transflow::create {options_frame} {
    variable vals
    variable widgets

    _reinitializeVals

    set dir_tf [TitleFrame $options_frame.dir -text "Direction"]
    pack $dir_tf -side left -padx 2 -pady 2 -expand 0 -fill y
    set dir_to [radiobutton [$dir_tf getframe].to -text "To" \
                    -value $::APOL_INFOFLOW_IN \
                    -variable Apol_Analysis_transflow::vals(dir)]
    set dir_from [radiobutton [$dir_tf getframe].from -text "From" \
                      -value $::APOL_INFOFLOW_OUT \
                      -variable Apol_Analysis_transflow::vals(dir)]
    pack $dir_to $dir_from -anchor w

    set req_tf [TitleFrame $options_frame.req -text "Required Parameters"]
    pack $req_tf -side left -padx 2 -pady 2 -expand 0 -fill y
    set l [label [$req_tf getframe].l -text "Starting type"]
    pack $l -anchor w
    set widgets(type) [Apol_Widget::makeTypeCombobox [$req_tf getframe].type]
    pack $widgets(type)

    set filter_tf [TitleFrame $options_frame.filter -text "Optional Result Filters"]
    pack $filter_tf -side left -padx 2 -pady 2 -expand 1 -fill both
    set advanced_f [frame [$filter_tf getframe].advanced]
    pack $advanced_f -side left -anchor nw
    set widgets(advanced_enable) [checkbutton $advanced_f.enable -text "Use advanced filters" \
                                      -variable Apol_Analysis_transflow::vals(advanced:enable)]
    pack $widgets(advanced_enable) -anchor w
    set widgets(advanced) [button $advanced_f.b -text "Advanced Filters" \
                               -command Apol_Analysis_transflow::_createAdvancedDialog \
                               -state disabled]
    pack $widgets(advanced) -anchor w -padx 4
    trace add variable Apol_Analysis_transflow::vals(advanced:enable) write \
        Apol_Analysis_transflow::_toggleAdvancedSelected
    set widgets(regexp) [Apol_Widget::makeRegexpEntry [$filter_tf getframe].end]
    $widgets(regexp).cb configure -text "Filter result types using regular expression"
    pack $widgets(regexp) -side left -anchor nw -padx 8
}

proc Apol_Analysis_transflow::open {} {
    variable vals
    variable widgets
    Apol_Widget::resetTypeComboboxToPolicy $widgets(type)
    set vals(intermed:inc) [Apol_Types::getTypes]
    set vals(intermed:inc_all) $vals(intermed:inc)
    set vals(classes:displayed) {}
    foreach class [Apol_Class_Perms::getClasses] {
        foreach perm [Apol_Class_Perms::getPermsForClass $class] {
            set vals(perms:$class:$perm) 1
        }
        lappend vals(classes:displayed) $class
    }
}

proc Apol_Analysis_transflow::close {} {
    variable widgets
    _reinitializeVals
    _reinitializeWidgets
    Apol_Widget::clearTypeCombobox $widgets(type)
}

proc Apol_Analysis_transflow::getInfo {} {
    return "This analysis generates the results of a Transitive Information Flow
analysis beginning from the starting type selected.  The results of
the analysis are presented in tree form with the root of the tree
being the start point for the analysis.

\nEach child node in the tree represents a type in the current policy
for which there is a transitive information flow to or from its parent
node.  If flow 'To' is selected the information flows from the child
to the parent.  If flow 'From' is selected then information flows from
the parent to the child.

\nThe results of the analysis may be optionally filtered by object
classes and/or permissions, intermediate types, or an end type regular
expression.

\nNOTE: For any given generation, if the parent and the child are the
same, the child cannot be opened.  This avoids cyclic analyses.

\nFor additional help on this topic select \"Information Flow Analysis\"
from the help menu."
}

proc Apol_Analysis_transflow::newAnalysis {} {
    if {[set rt [_checkParams]] != {}} {
        return $rt
    }
    set results [_analyze]
    set f [_createResultsDisplay]
    _renderResults $f $results
    $results -acquire
    $results -delete
    return {}
}

proc Apol_Analysis_transflow::updateAnalysis {f} {
    if {[set rt [_checkParams]] != {}} {
        return $rt
    }
    set results [_analyze]
    _clearResultsDisplay $f
    _renderResults $f $results
    $results -acquire
    $results -delete
    return {}
}

proc Apol_Analysis_transflow::reset {} {
    _reinitializeVals
    _reinitializeWidgets
    open
}

proc Apol_Analysis_transflow::switchTab {query_options} {
    variable vals
    variable widgets
    array set vals $query_options
    _reinitializeWidgets
}

proc Apol_Analysis_transflow::saveQuery {channel} {
    variable vals
    variable widgets
    foreach {key value} [array get vals] {
        switch -glob -- $key {
            find_more:* -
            intermed:inc* -
            intermed:exc -
            classes:title {}
            classes:displayed {}
            perms:* {
                # only write permissions that have been excluded
                if {$value == 0} {
                    puts $channel "$key $value"
                }
            }
            default {
                puts $channel "$key $value"
            }
        }
    }
    set type [Apol_Widget::getTypeComboboxValueAndAttrib $widgets(type)]
    puts $channel "type [lindex $type 0]"
    puts $channel "type:attrib [lindex $type 1]"
    set use_regexp [Apol_Widget::getRegexpEntryState $widgets(regexp)]
    set regexp [Apol_Widget::getRegexpEntryValue $widgets(regexp)]
    puts $channel "regexp:enable $use_regexp"
    puts $channel "regexp $regexp"
}

proc Apol_Analysis_transflow::loadQuery {channel} {
    variable vals
    set intermed_exc {}
    set perms_disabled {}
    while {[gets $channel line] >= 0} {
        set line [string trim $line]
        # Skip empty lines and comments
        if {$line == {} || [string index $line 0] == "#"} {
            continue
        }
        set key {}
        set value {}
        regexp -line -- {^(\S+)( (.+))?} $line -> key --> value
        switch -glob -- $key {
            intermed:exc_all {
                set intermed_exc $value
            }
            perms:* {
                set perms_disabled [concat $perms_disabled $key $value]
            }
            default {
                set vals($key) $value
            }
        }
    }

    # fill in only types and classes found within the current policy
    open

    set vals(intermed:exc_all) {}
    set vals(intermed:exc) {}
    foreach t $intermed_exc {
        set i [lsearch $vals(intermed:inc_all) $t]
        if {$i >= 0} {
            lappend vals(intermed:exc_all) $t
            lappend vals(intermed:exc) $t
            set vals(intermed:inc_all) [lreplace $vals(intermed:inc_all) $i $i]
            set i [lsearch $vals(intermed:inc) $t]
            set vals(intermed:inc) [lreplace $vals(intermed:inc) $i $i]
        }
    }
    set vals(intermed:exc_all) [lsort $vals(intermed:exc_all)]
    set vals(intermed:exc) [lsort $vals(intermed:exc)]

    foreach {key value} $perms_disabled {
        if {[info exists vals($key)]} {
            set vals($key) $value
        }
    }
    set vals(classes:displayed) {}
    foreach class [Apol_Class_Perms::getClasses] {
        set all_disabled 1
        foreach perm_key [array names vals perms:$class:*] {
            if {$vals($perm_key)} {
                set all_disabled 0
                break
            }
        }
        if {$all_disabled} {
            lappend vals(classes:displayed) "$class (excluded)"
        } else {
            lappend vals(classes:displayed) $class
        }
    }
    _reinitializeWidgets
}

proc Apol_Analysis_transflow::getTextWidget {tab} {
    return [$tab.right getframe].res.tb
}

proc Apol_Analysis_transflow::appendResultsNodes {tree parent_node results} {
    _createResultsNodes $tree $parent_node $results 0
}

proc Apol_Analysis_transflow::renderPath {res path_num path} {
    _renderPath $res $path_num $path
}

#################### private functions below ####################

proc Apol_Analysis_transflow::_reinitializeVals {} {
    variable vals

    set vals(dir) $::APOL_INFOFLOW_IN
    array set vals {
        type {}  type:attrib {}

        regexp:enable 0
        regexp {}

        advanced:enable 0

        classes:title {}
        classes:displayed {}
        classes:threshold_enable 0
        classes:threshold 1

        intermed:inc {}   intermed:inc_all {}
        intermed:exc {}   intermed:exc_all {}
        intermed:attribenable 0  intermed:attrib {}

        find_more:hours 0   find_more:minutes 0   find_more:seconds 30
        find_more:limit 20
    }
    array unset vals perms:*
    foreach class [Apol_Class_Perms::getClasses] {
        foreach perm [Apol_Class_Perms::getPermsForClass $class] {
            set vals(perms:$class:$perm) 1
        }
    }
}

proc Apol_Analysis_transflow::_reinitializeWidgets {} {
    variable vals
    variable widgets

    if {$vals(type:attrib) != {}} {
        Apol_Widget::setTypeComboboxValue $widgets(type) [list $vals(type) $vals(type:attrib)]
    } else {
        Apol_Widget::setTypeComboboxValue $widgets(type) $vals(type)
    }
    Apol_Widget::setRegexpEntryValue $widgets(regexp) $vals(regexp:enable) $vals(regexp)
}

proc Apol_Analysis_transflow::_toggleAdvancedSelected {name1 name2 op} {
    variable vals
    variable widgets
    if {$vals(advanced:enable)} {
        $widgets(advanced) configure -state normal
    } else {
        $widgets(advanced) configure -state disabled
    }
}

################# functions that do advanced filters #################

proc Apol_Analysis_transflow::_createAdvancedDialog {} {
    destroy .transflow_adv
    variable vals

    # if a permap is not loaded then load the default permap
    if {[ApolTop::is_policy_open] && ![Apol_Perms_Map::is_pmap_loaded]} {
        if {![ApolTop::openDefaultPermMap]} {
            return "This analysis requires that a permission map is loaded."
	}
    }

    set d [Dialog .transflow_adv -modal local -separator 1 -title "Transitive Information Flow Advanced Filters" -parent .]
    $d add -text "Close"

    set tf [TitleFrame [$d getframe].classes -text "Filter By Object Class Permissions"]
    pack $tf -side top -expand 1 -fill both -padx 2 -pady 4
    _createClassFilter [$tf getframe]

    set tf [TitleFrame [$d getframe].types -text "Filter By Intermediate Types"]
    pack $tf -side top -expand 1 -fill both -padx 2 -pady 4
    _createIntermedFilter [$tf getframe]
    set inc [$tf getframe].inc
    set exc [$tf getframe].exc

    set attrib [frame [$tf getframe].a]
    grid $attrib - -
    set attrib_enable [checkbutton $attrib.ae -anchor w \
                           -text "Filter by attribute" \
                           -variable Apol_Analysis_transflow::vals(intermed:attribenable)]
    set attrib_box [ComboBox $attrib.ab -autopost 1 -entrybg white -width 16 \
                        -values $Apol_Types::attriblist \
                        -textvariable Apol_Analysis_transflow::vals(intermed:attrib)]
    $attrib_enable configure -command \
        [list Apol_Analysis_transflow::_attribEnabled $attrib_box]
    # remove any old traces on the attribute before adding new ones
    trace remove variable Apol_Analysis_transflow::vals(intermed:attrib) write \
        [list Apol_Analysis_transflow::_attribChanged]
    trace add variable Apol_Analysis_transflow::vals(intermed:attrib) write \
        [list Apol_Analysis_transflow::_attribChanged]
    pack $attrib_enable -side top -expand 0 -fill x -anchor sw -padx 5 -pady 2
    pack $attrib_box -side top -expand 1 -fill x -padx 10
    _attribEnabled $attrib_box

    $d draw
}

proc Apol_Analysis_transflow::_createClassFilter {f} {
    variable vals

    set l1 [label $f.l1 -text "Object Classes"]
    set l [label $f.l]
    set vals(classes:title) "Permissions"
    set l2 [label $f.l2 -textvariable Apol_Analysis_transflow::vals(classes:title)]
    grid $l1 $l $l2 -sticky w

    set classes [Apol_Widget::makeScrolledListbox $f.c -selectmode extended \
                     -height 12 -width 24 -listvar Apol_Analysis_transflow::vals(classes:displayed)]
    set sw [ScrolledWindow $f.sw -auto both -bd 2 -relief groove]
    set perms [ScrollableFrame $sw.perms -height 150 -width 250]
    $sw setwidget $perms
    bind $classes.lb <<ListboxSelect>> \
        [list Apol_Analysis_transflow::_refreshPerm $classes $perms]
    grid $classes x $sw -sticky nsew
    update
    grid propagate $sw 0

    set bb [ButtonBox $f.bb -homogeneous 1 -spacing 4]
    $bb add -text "Include All Perms" -width 16 -command [list Apol_Analysis_transflow::_setAllPerms $classes $perms 1]
    $bb add -text "Exclude All Perms" -width 16 -command [list Apol_Analysis_transflow::_setAllPerms $classes $perms 0]
    grid ^ x $bb -pady 4

    set f [frame $f.f]
    grid ^ x $f
    grid configure $f -sticky ew
    set cb [checkbutton $f.cb -text "Exclude permissions with weights below:" \
                -variable Apol_Analysis_transflow::vals(classes:threshold_enable)]
    set weight [spinbox $f.threshold -from 1 -to 10 -increment 1 \
                    -width 2 -bg white -justify right \
                    -textvariable Apol_Analysis_transflow::vals(classes:threshold)]
    # remove any old traces on the threshold checkbutton befored adding new one
    trace remove variable Apol_Analysis_transflow::vals(classes:threshold_enable) write \
        [list Apol_Analysis_transflow::_thresholdChanged $weight]
    trace add variable Apol_Analysis_transflow::vals(classes:threshold_enable) write \
        [list Apol_Analysis_transflow::_thresholdChanged $weight]
    pack $cb $weight -side left
    _thresholdChanged $weight {} {} {}

    grid columnconfigure $f 0 -weight 0
    grid columnconfigure $f 1 -weight 0 -pad 4
    grid columnconfigure $f 2 -weight 1
}

proc Apol_Analysis_transflow::_refreshPerm {classes perms} {
    variable vals
    focus $classes.lb
    if {[$classes.lb curselection] == {}} {
        return
    }
    set pf [$perms getframe]
    foreach w [winfo children $pf] {
        destroy $w
    }

    foreach {class foo} [$classes.lb get anchor] {break}
    set i [$classes.lb index anchor]
    set vals(classes:title) "Permissions for $class"

    foreach perm_key [lsort [array names vals perms:$class:*]] {
        foreach {foo bar perm} [split $perm_key :] {break}
        set weight [$::ApolTop::policy get_permmap_weight $class $perm]
        set l [label $pf.$perm:l -text $perm -anchor w]
        set inc [checkbutton $pf.$perm:i -text "Include" \
                     -command [list Apol_Analysis_transflow::_togglePerm $class $i] \
                     -variable Apol_Analysis_transflow::vals(perms:$class:$perm)]
        set w [label $pf.$perm:w -text "Weight: $weight"]
        grid $l $inc $w -padx 2 -sticky w -pady 4
        grid configure $w -ipadx 10
    }
    grid columnconfigure $pf 0 -minsize 100 -weight 1
    $perms xview moveto 0
    $perms yview moveto 0
}

proc Apol_Analysis_transflow::_togglePerm {class i} {
    variable vals
    set all_disabled 1
    foreach perm_key [array names vals perms:$class:*] {
        if {$vals($perm_key)} {
            set all_disabled 0
            break
        }
    }
    if {$all_disabled} {
        set vals(classes:displayed) [lreplace $vals(classes:displayed) $i $i "$class (excluded)"]
    } else {
        set vals(classes:displayed) [lreplace $vals(classes:displayed) $i $i $class]
    }
}

proc Apol_Analysis_transflow::_setAllPerms {classes perms newValue} {
    variable vals
    foreach i [$classes.lb curselection] {
        foreach {class foo} [split [$classes.lb get $i]] {break}
        foreach perm_key [array names vals perms:$class:*] {
            set vals($perm_key) $newValue
        }
        if {$newValue == 1} {
            set vals(classes:displayed) [lreplace $vals(classes:displayed) $i $i $class]
        } else {
            set vals(classes:displayed) [lreplace $vals(classes:displayed) $i $i "$class (excluded)"]
        }
    }
}

proc Apol_Analysis_transflow::_thresholdChanged {w name1 name2 op} {
    variable vals
    if {$vals(classes:threshold_enable)} {
        $w configure -state normal
    } else {
        $w configure -state disabled
    }
}

proc Apol_Analysis_transflow::_createIntermedFilter {f} {
    set l1 [label $f.l1 -text "Included Intermediate Types"]
    set l2 [label $f.l2 -text "Excluded Intermediate Types"]
    grid $l1 x $l2 -sticky w

    set inc [Apol_Widget::makeScrolledListbox $f.inc -height 10 -width 24 \
                 -listvar Apol_Analysis_transflow::vals(intermed:inc) \
                 -selectmode extended -exportselection 0]
    set exc [Apol_Widget::makeScrolledListbox $f.exc -height 10 -width 24 \
                 -listvar Apol_Analysis_transflow::vals(intermed:exc) \
                 -selectmode extended -exportselection 0]
    set inc_lb [Apol_Widget::getScrolledListbox $inc]
    set exc_lb [Apol_Widget::getScrolledListbox $exc]
    set bb [ButtonBox $f.bb -homogeneous 1 -orient vertical -spacing 4]
    $bb add -text "-->" -width 10 -command [list Apol_Analysis_transflow::_moveToExclude $inc_lb $exc_lb]
    $bb add -text "<--" -width 10 -command [list Apol_Analysis_transflow::_moveToInclude $inc_lb $exc_lb]
    grid $inc $bb $exc -sticky nsew

    set inc_bb [ButtonBox $f.inc_bb -homogeneous 1 -spacing 4]
    $inc_bb add -text "Select All" -command [list $inc_lb selection set 0 end]
    $inc_bb add -text "Unselect" -command [list $inc_lb selection clear 0 end]
    set exc_bb [ButtonBox $f.exc_bb -homogeneous 1 -spacing 4]
    $exc_bb add -text "Select All" -command [list $exc_lb selection set 0 end]
    $exc_bb add -text "Unselect" -command [list $exc_lb selection clear 0 end]
    grid $inc_bb x $exc_bb -pady 4

    grid columnconfigure $f 0 -weight 1 -uniform 0 -pad 2
    grid columnconfigure $f 1 -weight 0 -pad 8
    grid columnconfigure $f 2 -weight 1 -uniform 0 -pad 2
}

proc Apol_Analysis_transflow::_moveToExclude {inc exc} {
    variable vals
    if {[set selection [$inc curselection]] == {}} {
        return
    }
    foreach i $selection {
        lappend types [$inc get $i]
    }
    set vals(intermed:exc) [lsort [concat $vals(intermed:exc) $types]]
    set vals(intermed:exc_all) [lsort [concat $vals(intermed:exc_all) $types]]
    foreach t $types {
        set i [lsearch $vals(intermed:inc) $t]
        set vals(intermed:inc) [lreplace $vals(intermed:inc) $i $i]
        set i [lsearch $vals(intermed:inc_all) $t]
        set vals(intermed:inc_all) [lreplace $vals(intermed:inc_all) $i $i]
    }
    $inc selection clear 0 end
    $exc selection clear 0 end
}

proc Apol_Analysis_transflow::_moveToInclude {inc exc} {
    variable vals
    if {[set selection [$exc curselection]] == {}} {
        return
    }
    foreach i $selection {
        lappend types [$exc get $i]
    }
    set vals(intermed:inc) [lsort [concat $vals(intermed:inc) $types]]
    set vals(intermed:inc_all) [lsort [concat $vals(intermed:inc_all) $types]]
    foreach t $types {
        set i [lsearch $vals(intermed:exc) $t]
        set vals(intermed:exc) [lreplace $vals(intermed:exc) $i $i]
        set i [lsearch $vals(intermed:exc_all) $t]
        set vals(intermed:exc_all) [lreplace $vals(intermed:exc_all) $i $i]
    }
    $inc selection clear 0 end
    $exc selection clear 0 end
}

proc Apol_Analysis_transflow::_attribEnabled {cb} {
    variable vals
    if {$vals(intermed:attribenable)} {
        $cb configure -state normal
        _filterTypeLists $vals(intermed:attrib)
    } else {
        $cb configure -state disabled
        _filterTypeLists ""
    }
}

proc Apol_Analysis_transflow::_attribChanged {name1 name2 op} {
    variable vals
    if {$vals(intermed:attribenable)} {
        _filterTypeLists $vals(intermed:attrib)
    }
}

proc Apol_Analysis_transflow::_filterTypeLists {attrib} {
    variable vals
    if {$attrib != {}} {
        set typesList {}
        if {[Apol_Types::isAttributeInPolicy $attrib]} {
            set qpol_type_datum [new_qpol_type_t $::ApolTop::qpolicy $attrib]
            set i [$qpol_type_datum get_type_iter $::ApolTop::qpolicy]
            foreach t [iter_to_list $i] {
                set t [qpol_type_from_void $t]
                lappend typesList [$t get_name $::ApolTop::qpolicy]
            }
            $i -acquire
            $i -delete
        }
        if {$typesList == {}} {
            # unknown attribute, so don't change listboxes
            return
        }
        set vals(intermed:inc) {}
        set vals(intermed:exc) {}
        foreach t $typesList {
            if {[lsearch $vals(intermed:inc_all) $t] >= 0} {
                lappend vals(intermed:inc) $t
            }
            if {[lsearch $vals(intermed:exc_all) $t] >= 0} {
                lappend vals(intermed:exc) $t
            }
        }
        set vals(intermed:inc) [lsort $vals(intermed:inc)]
        set vals(intermed:exc) [lsort $vals(intermed:exc)]
    } else {
        set vals(intermed:inc) $vals(intermed:inc_all)
        set vals(intermed:exc) $vals(intermed:exc_all)
    }
}

#################### functions that do analyses ####################

proc Apol_Analysis_transflow::_checkParams {} {
    variable vals
    variable widgets
    if {![ApolTop::is_policy_open]} {
        return "No current policy file is opened."
    }
    set type [Apol_Widget::getTypeComboboxValueAndAttrib $widgets(type)]
    if {[lindex $type 0] == {}} {
        return "No type was selected."
    }
    if {![Apol_Types::isTypeInPolicy [lindex $type 0]]} {
        return "[lindex $type 0] is not a type within the policy."
    }
    set vals(type) [lindex $type 0]
    set vals(type:attrib) [lindex $type 1]
    set use_regexp [Apol_Widget::getRegexpEntryState $widgets(regexp)]
    set regexp [Apol_Widget::getRegexpEntryValue $widgets(regexp)]
    if {$use_regexp && $regexp == {}} {
            return "No regular expression provided."
    }
    set vals(regexp:enable) $use_regexp
    set vals(regexp) $regexp

    # if a permap is not loaded then load the default permap
    if {![Apol_Perms_Map::is_pmap_loaded]} {
        if {![ApolTop::openDefaultPermMap]} {
            return "This analysis requires that a permission map is loaded."
	}
        apol_tcl_clear_info_string
    }

    if {$vals(advanced:enable)} {
        if {$vals(intermed:inc_all) == {}} {
            return "At least one intermediate type must be selected."
        }
        if {[lsearch $vals(intermed:exc_all) $vals(type)] >= 0} {
            return "The starting type is on the excluded intermediate types list"
        }
        set num_perms 0
        foreach perm_key [array names vals perms:*] {
            if {$vals($perm_key)} {
                set num_perms 1
                break
            }
        }
        if {$num_perms == 0} {
            return "At least one permissions must be enabled."
        }
    }
    return {}  ;# all parameters passed, now ready to do search
}

proc Apol_Analysis_transflow::_analyze {} {
    variable vals
    if {$vals(regexp:enable)} {
        set regexp $vals(regexp)
    } else {
        set regexp {}
    }
    set threshold {}
    if {$vals(advanced:enable)} {
        set intermed $vals(intermed:inc_all)
        set classperms {}
        foreach perm_key [array names vals perms:*] {
            if {$vals($perm_key)} {
                foreach {foo class perm} [split $perm_key :] {break}
                lappend classperms $class $perm
            }
        }
        if {$vals(classes:threshold_enable)} {
            set threshold $vals(classes:threshold)
        }
    } else {
        set intermed {}
        set classperms {}
    }

    set q [new_apol_infoflow_analysis_t]
    $q set_mode $::ApolTop::policy $::APOL_INFOFLOW_MODE_TRANS
    $q set_dir $::ApolTop::policy $vals(dir)
    $q set_type $::ApolTop::policy $vals(type)
    foreach i $intermed {
        $q append_intermediate $::ApolTop::policy $i
    }
    foreach {c p} $classperms {
        $q append_class_perm $::ApolTop::policy $c $p
    }
    if {$threshold != {}} {
        $q set_min_weight $::ApolTop::policy $threshold
    }
    $q set_result_regex $::ApolTop::policy $regexp
    set results [$q run $::ApolTop::policy]
    $q -acquire
    $q -delete
    return $results
}

proc Apol_Analysis_transflow::_analyzeMore {tree node} {
    # disallow more analysis if this node is the same as its parent
    set new_start [$tree itemcget $node -text]
    if {[$tree itemcget [$tree parent $node] -text] == $new_start} {
        return {}
    }
    set g [lindex [$tree itemcget top -data] 0]
    $g do_more $::ApolTop::policy $new_start
}

################# functions that control analysis output #################

proc Apol_Analysis_transflow::_createResultsDisplay {} {
    variable vals

    set f [Apol_Analysis::createResultTab "Trans Flow" [array get vals]]

    set tree_tf [TitleFrame $f.left -text "Transitive Information Flow Tree"]
    pack $tree_tf -side left -expand 0 -fill y -padx 2 -pady 2
    set sw [ScrolledWindow [$tree_tf getframe].sw -auto both]
    set tree [Tree [$sw getframe].tree -width 24 -redraw 1 -borderwidth 0 \
                  -highlightthickness 0 -showlines 1 -padx 0 -bg white]
    $sw setwidget $tree
    pack $sw -expand 1 -fill both

    set res_tf [TitleFrame $f.right -text "Transitive Information Flow Results"]
    pack $res_tf -side left -expand 1 -fill both -padx 2 -pady 2
    set res [Apol_Widget::makeSearchResults [$res_tf getframe].res]
    $res.tb tag configure title -font {Helvetica 14 bold}
    $res.tb tag configure title_type -foreground blue -font {Helvetica 14 bold}
    $res.tb tag configure find_more -underline 1
    $res.tb tag configure subtitle -font {Helvetica 10 bold}
    $res.tb tag configure num -foreground blue -font {Helvetica 10 bold}
    $res.tb tag bind find_more <Button-1> [list Apol_Analysis_transflow::_findMore $res $tree]
    $res.tb tag bind find_more <Enter> [list $res.tb configure -cursor hand2]
    $res.tb tag bind find_more <Leave> [list $res.tb configure -cursor {}]
    pack $res -expand 1 -fill both

    $tree configure -selectcommand [list Apol_Analysis_transflow::_treeSelect $res]
    $tree configure -opencmd [list Apol_Analysis_transflow::_treeOpen $tree]
    return $f
}

proc Apol_Analysis_transflow::_treeSelect {res tree node} {
    if {$node != {}} {
        $res.tb configure -state normal
        $res.tb delete 0.0 end
        set data [$tree itemcget $node -data]
        if {[string index $node 0] == "y"} {
            _renderResultsTransFlow $res $tree $node [lindex $data 1]
        } else {
            # an informational node, whose data has already been rendered
            eval $res.tb insert end [lindex $data 1]
        }
        $res.tb configure -state disabled
    }
}

proc Apol_Analysis_transflow::_treeOpen {tree node} {
    foreach {is_expanded results} [$tree itemcget $node -data] {break}
    if {[string index $node 0] == "y" && !$is_expanded} {
        Apol_Progress_Dialog::wait "Transitive Information Flow Analysis" \
            "Performing Transitive Information Flow Analysis..." \
            {
                set new_results [_analyzeMore $tree $node]
                # mark this node as having been expanded
                $tree itemconfigure $node -data [list 1 $results]
                if {$new_results != {}} {
                    _createResultsNodes $tree $node $new_results 1
                    $new_results -acquire
                    $new_results -delete
                }
            }
    }
}

proc Apol_Analysis_transflow::_clearResultsDisplay {f} {
    variable vals

    set tree [[$f.left getframe].sw getframe].tree
    set res [$f.right getframe].res
    $tree delete [$tree nodes root]
    Apol_Widget::clearSearchResults $res
    Apol_Analysis::setResultTabCriteria [array get vals]
}


proc Apol_Analysis_transflow::_renderResults {f results} {
    variable vals

    set graph_handler [$results extract_graph]
    $graph_handler -acquire  ;# let Tcl's GC destroy graph when this tab closes
    set results_list [$results extract_result_vector]

    set tree [[$f.left getframe].sw getframe].tree
    set res [$f.right getframe].res

    $tree insert end root top -text $vals(type) -open 1 -drawcross auto
    set top_text [_renderTopText]
    $tree itemconfigure top -data [list $graph_handler $top_text]

    _createResultsNodes $tree top $results_list 1
    $tree selection set top
    $tree opentree top 0
    $tree see top

    $results_list -acquire
    $results_list -delete
}

proc Apol_Analysis_transflow::_renderTopText {} {
    variable vals

    set top_text [list "Transitive Information Flow Analysis: Starting type: " title]
    lappend top_text $vals(type) title_type \
        "\n\n" title \
        "This tab provides the results of a Transitive Information Flow
analysis beginning from the starting type selected above.  The results
of the analysis are presented in tree form with the root of the tree
(this node) being the start point for the analysis.

\nEach child node in the tree represents a type in the current policy
for which there is a transitive information flow to or from (depending
on your selection above) its parent node.

\nNOTE: For any given generation, if the parent and the child are the
same, you cannot open the child.  This avoids cyclic analyses." {}
}

# If do_expand is zero, then generate result nodes for only the first
# target type of $results.  This is needed by two types relationship
# analysis.
proc Apol_Analysis_transflow::_createResultsNodes {tree parent_node results do_expand} {
    set all_targets {}
    set info_list [infoflow_result_vector_to_list $results]
    set results_processed 0
    foreach r $info_list {
        apol_tcl_set_info_string $::ApolTop::policy "Processing result $results_processed of [llength $info_list]"

        if {$do_expand} {
            set target [[$r get_end_type] get_name $::ApolTop::qpolicy]
        } else {
            set first_target [[lindex $info_list 0] get_end_type]
            set target [$first_target get_name $::ApolTop::qpolicy]
        }
        set flow_dir [$r get_dir]
        set length [$r get_length]
        set steps_v [$r get_steps]

        lappend all_targets $target
        lappend paths($target) [list $length $steps_v]
        incr results_processed
    }

    set all_targets [lsort -uniq $all_targets]
    apol_tcl_set_info_string $::ApolTop::policy "Displaying [llength $all_targets] result(s)"
    update idle

    foreach t $all_targets {
        set sorted_paths {}
        foreach path [lsort -uniq [lsort -index 0 -integer $paths($t)]] {
            set step_v [lindex $path 1]
            set p {}
            if {$flow_dir == $::APOL_INFOFLOW_IN} {
                # flip the steps around
                for {set i [expr {[$step_v get_size] - 1}]} {$i >= 0} {incr i -1} {
                    set r [apol_infoflow_step_from_void [$step_v get_element $i]]
                    lappend p [_infoflow_step_to_list $r]
                }
            } else {
                for {set i 0} {$i < [$step_v get_size]} {incr i} {
                    set r [apol_infoflow_step_from_void [$step_v get_element $i]]
                    lappend p [_infoflow_step_to_list $r]
                }
            }
            lappend sorted_paths $p
        }
        set data [list $flow_dir $sorted_paths]
        $tree insert end $parent_node y\#auto -text $t -drawcross allways \
            -data [list 0 $data]
    }
}

proc Apol_Analysis_transflow::_infoflow_step_to_list {step} {
    set start [[$step get_start_type] get_name $::ApolTop::qpolicy]
    set end [[$step get_end_type] get_name $::ApolTop::qpolicy]
    set weight [$step get_weight]
    set rules [avrule_vector_to_list [$step get_rules]]
    list $start $end $weight $rules
}

proc Apol_Analysis_transflow::_renderResultsTransFlow {res tree node data} {
    set parent_name [$tree itemcget [$tree parent $node] -text]
    set name [$tree itemcget $node -text]
    foreach {flow_dir paths} $data {break}
    switch -- $flow_dir [list \
        $::APOL_INFOFLOW_IN {
            $res.tb insert end "Information flows to " title \
                $parent_name title_type \
                " from " title \
                $name title_type
        } \
        $::APOL_INFOFLOW_OUT {
            $res.tb insert end "Information flows from " title \
                $parent_name title_type \
                " to " title \
                $name title_type
        } \
                            ]
    $res.tb insert end "  (" title \
        "Find more flows" {title_type find_more} \
        ")\n\n" title \
        "Apol found the following number of information flows: " subtitle \
        [llength $paths] num \
        "\n" subtitle
    set path_num 1
    foreach path $paths {
        $res.tb insert end "\n" {}
        _renderPath $res $path_num $path
        incr path_num
    }
}

proc Apol_Analysis_transflow::_renderPath {res path_num path} {
    $res.tb insert end "Flow " subtitle \
        $path_num num \
        " requires " subtitle \
        [llength $path] num \
        " steps(s).\n" subtitle \
        "    " {}
    $res.tb insert end [lindex $path 0 0] subtitle \
        " -> " {} \
        [lindex $path 0 1] subtitle
    foreach step [lrange $path 1 end] {
        $res.tb insert end " -> " {} \
            [lindex $step 1] subtitle
    }
    $res.tb insert end \n {}
    foreach steps $path {
        set rules [lindex $steps 3]
        set v [new_apol_vector_t]
        $v append [lindex $rules 0]
        Apol_Widget::appendSearchResultRules $res 6 $v qpol_avrule_from_void
        $v -acquire
        $v -delete

        set v [new_apol_vector_t]
        foreach r [lrange $rules 1 end] {
            $v append $r
        }
        apol_tcl_avrule_sort $::ApolTop::policy $v
        Apol_Widget::appendSearchResultRules $res 10 $v qpol_avrule_from_void
        $v -acquire
        $v -delete
    }
}

#################### procedures to find further flows ####################

proc Apol_Analysis_transflow::_findMore {res tree} {
    set node [$tree selection get]
    set start [$tree itemcget [$tree parent $node] -text]
    set end [$tree itemcget $node -text]

    set d [Dialog .trans_more -cancel 1 -default 0 -modal local -parent . \
               -separator 1 -title "Find More Flows"]
    $d add -text Find -command [list Apol_Analysis_transflow::_verifyFindMore $d]
    $d add -text Cancel

    set f [$d getframe]
    set l1 [label $f.l1 -text "Source: $start"]
    set l2 [label $f.l2 -text "Target: $end"]
    set time_f [frame $f.time]
    set path_f [frame $f.path]
    pack $l1 $l2 $time_f $path_f -anchor w -padx 8 -pady 4

    set t1 [label $time_f.t1 -text "Time limit: "]
    set e1 [entry $time_f.e1 -textvariable Apol_Analysis_transflow::vals(find_more:hours) -width 5 -justify right -bg white]
    set t2 [label $time_f.t2 -text "Hour(s)  "]
    set e2 [entry $time_f.e2 -textvariable Apol_Analysis_transflow::vals(find_more:minutes) -width 5 -justify right -bg white]
    set t3 [label $time_f.t3 -text "Minute(s)  "]
    set e3 [entry $time_f.e3 -textvariable Apol_Analysis_transflow::vals(find_more:seconds) -width 5 -justify right -bg white]
    set t4 [label $time_f.t4 -text "Second(s)  "]
    pack $t1 $e1 $t2 $e2 $t3 $e3 $t4 -side left

    set t1 [label $path_f.t1 -text "Limit by these number of flows: "]
    set e1 [entry $path_f.e1 -textvariable Apol_Analysis_transflow::vals(find_more:limit) -width 5 -justify right -bg white]
    pack $t1 $e1 -side left

    set retval [$d draw]
    destroy .trans_more
    if {$retval == 0} {
        set graph_handler [lindex [$tree itemcget top -data] 0]
        $graph_handler trans_further_prepare $::ApolTop::policy $start $end
        _doFindMore $res $tree $node
    }
}

proc Apol_Analysis_transflow::_verifyFindMore {d} {
    variable vals
    set message {}
    if {[set hours [string trim $vals(find_more:hours)]] == {}} {
        set hours 0
    }
    if {[set minutes [string trim $vals(find_more:minutes)]] == {}} {
        set minutes 0
    }
    if {[set seconds [string trim $vals(find_more:seconds)]] == {}} {
        set seconds 0
    }
    set path_limit [string trim $vals(find_more:limit)]
    if {![string is integer $hours] || $hours > 24 || $hours < 0} {
        set message "Invalid hours limit input.  Must be between 0-24 inclusive."
    } elseif {![string is integer $minutes] || $minutes > 59 || $minutes < 0} {
        set message "Invalid minutes limit input.  Must be between 0-59 inclusive."
    } elseif {![string is integer $seconds] || $seconds > 59 || $seconds < 0} {
        set message "Invalid seconds limit input.  Must be between 0-59 inclusive."
    } elseif {$path_limit == {} && $hours == 0 && $minutes == 0 && $seconds == 0} {
        set message "You must specify a time limit."
    } elseif {$path_limit != {} && (![string is integer $path_limit] || $path_limit < 0)} {
        set message "Number of flows cannot be less than 1."
    }
    if {$message != {}} {
        tk_messageBox -icon error -type ok -title "Find More Flows" -message $message
    } else {
        $d enddialog 0
    }
}

proc Apol_Analysis_transflow::_doFindMore {res tree node} {
    variable vals
    if {[set hours [string trim $vals(find_more:hours)]] == {}} {
        set hours 0
    }
    if {[set minutes [string trim $vals(find_more:minutes)]] == {}} {
        set minutes 0
    }
    if {[set seconds [string trim $vals(find_more:seconds)]] == {}} {
        set seconds 0
    }
    set path_limit [string trim $vals(find_more:limit)]
    if {$hours != 0 || $minutes != 0 || $seconds != 0} {
        set time_limit [expr {$hours * 3600 + $minutes * 60 + $seconds}]
        set time_limit_str [format " elapsed out of %02d:%02d:%02d" $hours $minutes $seconds]
    } else {
        set time_limit {}
        set time_limit_str {}
    }
    if {$path_limit != {}} {
        set path_limit_str " out of $path_limit"
    } else {
        set path_limit 0
        set path_limit_str {}
    }
    set vals(find_more:abort) 0
    set vals(find_more:searches_text) {}
    set vals(find_more:searches_done) -1

    set d [ProgressDlg .trans_domore -parent . -title "Find Results" \
               -width 40 -height 5 \
               -textvariable Apol_Analysis_transflow::vals(find_more:searches_text) \
               -variable Apol_Analysis_transflow::vals(find_more:searches_done) \
               -stop Stop \
               -command [list set Apol_Analysis_transflow::vals(find_more:abort) 1]]
    set graph_handler [lindex [$tree itemcget top -data] 0]
    set start_time [clock seconds]
    set elapsed_time 0
    set path_found 0
    set v NULL
    while {1} {
        set elapsed_time [expr {[clock seconds] - $start_time}]
        set vals(find_more:searches_text) "Finding more flows:\n\n"
        append vals(find_more:searches_text) "    Time: [clock format $elapsed_time -format "%H:%M:%S" -gmt 1]$time_limit_str\n\n"
        append vals(find_more:searches_text) "    Flows: found $path_found$path_limit_str"
        update
        set v [$graph_handler trans_further_next $::ApolTop::policy $v]
        set path_found [$v get_size]
        if {($time_limit != {} && $elapsed_time >= $time_limit) || \
                ($path_limit != 0 && $path_found > $path_limit) || \
                $vals(find_more:abort)} {
            break
        }
    }
    set vals(find_more:searches_text) "Rendering $path_found flow(s)."
    update idletasks

    $res.tb configure -state normal
    $res.tb delete 0.0 end
    set parent_name [$tree itemcget [$tree parent $node] -text]
    set name [$tree itemcget $node -text]
    set flow_dir [lindex [$tree itemcget $node -data] 1 0]
    switch -- $flow_dir [list \
        $::APOL_INFOFLOW_IN {
            $res.tb insert end "More information flows to " title \
                $parent_name title_type \
                " from " title \
                $name title_type
        } \
        $::APOL_INFOFLOW_OUT {
            $res.tb insert end "More information flows from " title \
                $parent_name title_type \
                " to " title \
                $name title_type
        } \
                             ]
    $res.tb insert end "  (" title \
        "Find more flows" {title_type find_more} \
        ")\n\n" title \
        "Time: " subtitle \
        [clock format $elapsed_time -format "%H:%M:%S" -gmt 1] subtitle \
        [format " out of %02d:%02d:%02d" $hours $minutes $seconds] subtitle \
        "\n\nApol found the following number of information flows: " subtitle \
        $path_found num \
        " out of " subtitle \
        $path_limit num \
        "\n" subtitle

    set results {}
    foreach r [infoflow_result_vector_to_list $v] {
        set length [$r get_length]
        set steps_v [$r get_steps]
        lappend results [list $length $steps_v]
    }

    set path_num 1
    foreach r [lsort -index 0 -integer $results] {
        set steps_v [lindex $r 1]
        set sorted_path {}
        if {$flow_dir == $::APOL_INFOFLOW_IN} {
            # flip the steps around
            for {set i [expr {[$steps_v get_size] - 1}]} {$i >= 0} {incr i -1} {
                set s [apol_infoflow_step_from_void [$steps_v get_element $i]]
                lappend sorted_path [_infoflow_step_to_list $s]
            }
        } else {
            for {set i 0} {$i < [$steps_v get_size]} {incr i} {
                set s [apol_infoflow_step_from_void [$steps_v get_element $i]]
                lappend sorted_path [_infoflow_step_to_list $s]
            }
        }
        $res.tb insert end "\n" {}
        _renderPath $res $path_num $sorted_path
        incr path_num
    }

    $res.tb configure -state disabled
    destroy $d
    $v -acquire
    $v -delete
}
