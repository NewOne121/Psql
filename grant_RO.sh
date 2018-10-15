#!/bin/sh
export PGPASSWORD="$(cat /root/.pgs | base64 -d)"
DBNAME="databse1 databse2"

for NAME in $DBNAME;
do
PSQLCMD="psql -Upostgres -h IPADDRESS -p PORT -d $NAME"
echo "DBNAME is $NAME"

for SCHEMA in $(echo "select nspname from pg_catalog.pg_namespace" | $PSQLCMD | egrep -v 'toast|temp|nspname' | egrep '^\ ' | tr -d '\ ');
do

echo "GRANT USAGE ON SCHEMA $SCHEMA to support;" | $PSQLCMD
echo "GRANT SELECT ON ALL TABLES IN SCHEMA $SCHEMA TO support;" | $PSQLCMD
done
done
