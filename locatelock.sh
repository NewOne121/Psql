export PGPASSWORD=$(base64 -d ~/.pgs)
PSQLCMD="psql -Upostgres -d BASEHERE -h IPADDRESS -p PORT"

echo "select
sa.pid,
sa.usename,
sa.client_addr,
sa.client_port,
sa.query_start,
sa.state_change,
sa.state,
sa.wait_event_type,
sa.wait_event,
l.relation::regclass,
l.locktype,
l.mode,
sa.query
from
pg_catalog.pg_stat_activity sa
left outer join pg_catalog.pg_locks l
on l.pid = sa.pid
where
sa.state_change <= (current_timestamp - interval '1 MINUTE')
and sa.state = 'active'
order by
sa.query_start;" | $PSQLCMD
