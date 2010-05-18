#! /bin/sh

# When apol is run on the installed policy (such as
# /etc/selinux/*/policy/policy.*) then it misses out on a lot of
# symbolic information (such as the types that are in attributes) and
# thus makes it impossible to determine the reason why some access is
# permitted.


set -e

. /etc/selinux/config

# Allow the user to override the SELINUXTYPE as a first argument
if [ "$1" = "-s" ]; then
    shift
    SELINUXTYPE=$2
    shift
fi

cd /etc/selinux/$SELINUXTYPE/modules/active

exec apol base.pp modules/*.pp $*
