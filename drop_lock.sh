export PGPASSWORD=$(base64 -d ~/.pgs)
PSQLCMD="psql -Upostgres -d BASEHERE -h IPADDRESS -p PORT"
for LCK in $(echo "SELECT
pid
,datname
,usename
,application_name
,backend_start
,query_start,
substring(query,0,40),
state
FROM pg_stat_activity
WHERE state <> 'idle' and query like '%drop%'
AND pid<>pg_backend_pid();" | $PSQLCMD | awk '/\ [0-9]+/ {print $1}');
do
echo "SELECT pg_cancel_backend('$LCK');" #| $PSQLCMD
done
