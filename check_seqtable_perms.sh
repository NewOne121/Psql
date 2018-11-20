#!/bin/sh
#RO CHECK
SCHEMA="$1"
DBNAME="$2"
PGUSER="$3"
DBHOST="$4"
DBPORT="$5"
PGPASSWORD=$PGUSER
export PGPASSWORD


PSQLCMD="psql -U $PGUSER -h $DBHOST -p $DBPORT -d $DBNAME"


echo "CHECKING TABLES ACCESS IN SCHEMA $SCHEMA FOR USER $PGUSER"

for TABLE in $(echo "select schemaname,tablename,tableowner from pg_tables where schemaname in ('$SCHEMA');" | $PSQLCMD | awk -F '|' '{print $2}' | grep '^\ [a-Z]' | grep -v 'tablename' | tr -d ' ');
do
echo "CHECKING TABLE $TABLE"
echo "SELECT * FROM "$SCHEMA"."$TABLE" limit 1;" | $PSQLCMD | grep -q "permission" || echo "OK"
done

echo "CHECKING SEQUENCE ACCESS IN SCHEMA $SCHEMA FOR USER $PGUSER"
ROWCOUNT=$(echo "SELECT sequence_schema,sequence_name FROM information_schema.sequences where sequence_schema = '$SCHEMA';" | $PSQLCMD | sed -rn 's/^\(([0-9]+)\ rows\)/\1/p')

if [ "$ROWCOUNT" = "0" ];
then
        echo "USER $PGUSER DOES NOT HAVE PERMISSIONS TO VIEW SEQUENCES"
        exit 0
else
        for SEQUENCE in $(echo "SELECT sequence_schema,sequence_name FROM information_schema.sequences where sequence_schema = '$SCHEMA';" | $PSQLCMD | awk -F '|' '{print $2}' | grep -v 'tablename' | grep '^\ [a-Z]' | tr -d ' ')
        do
        echo "CHECKING SEQUENCE $SEQUENCE"
        echo "SELECT * FROM "$SCHEMA"."$SEQUENCE" limit 1;" | $PSQLCMD | grep -q "permission" || echo "OK"
        done
fi
