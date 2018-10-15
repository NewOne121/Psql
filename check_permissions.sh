export PGPASSWORD=$(base64 -d ~/.pgs)
PSQLCMD="psql -Upostgres -d BASEHERE -h IPADDRESS -p PORT"

echo "SELECT DISTINCT relname
  FROM pg_roles CROSS JOIN pg_class
 WHERE pg_has_role('epamsupport', rolname, 'MEMBER')
   AND has_table_privilege(rolname, pg_class.oid, 'SELECT');" | $PSQLCMD | egrep -v 'row|=|-|relname'
