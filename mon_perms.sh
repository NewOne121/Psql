#!/bin/sh
CFILE="/home/postgres/perms.current"
LFILE="/home/postgres/perms.last"
DFILE="/home/postgres/perms.diff"
CSCR="/home/postgres/check_permissions.sh"

$CSCR | sort > $CFILE

DTABLES=$(diff --side-by-side --suppress-common-lines $CFILE $LFILE | sort | awk '{print $1}' | xargs)
for TABLE in $DTABLES;
do
echo "$(date +"%m.%d.%y-%T") Permissions for table $TABLE were dropped." >> $DFILE
done

cp $CFILE $LFILE
