#!/bin/bash
PGPASSWORD=$(base64 -d ~/.chp)
export PGPASSWORD
echo "select extract(epoch from now()) - extract (epoch from pg_last_xact_replay_timestamp ()) AS replication_delay;" | psql -t -UUSER -h HOSTNAME -p PORT -d DB | sed -rn 's/^\ *?-?([0-9]+)\.?[0-9]+.*/\1/p'
