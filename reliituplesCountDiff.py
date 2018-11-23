#!/usr/bin/python

import psycopg2
import getpass

pswd=getpass.getpass('Enter password for $DBUSER:')
pswd="'%s'" % pswd

connpars=str("dbname='$DBNAME' user='$DBUSER' host='$HOSTNAME ' port='$PORT' password=" + pswd)
conn=psycopg2.connect(connpars)

ccursor=conn.cursor()
ccursor.execute("""SELECT nspname AS schemaname,relname,reltuples::numeric FROM pg_class C LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace) WHERE nspname NOT IN ('pg_catalog', 'information_schema') AND relkind='r' ORDER BY reltuples DESC""")

data=ccursor.fetchall()
conn.commit()

for row in data:
 if row[2] >= 0:
  if row[0] == 'SCHEMANAME':
   table=str('%(schema)s."%(table)s"' % {"schema": row[0], "table": row[1]})
  else:
   table=str('%(schema)s.%(table)s' % {"schema": row[0], "table": row[1]})
  try:
   ccursor.execute("""SELECT count (*) from %s;""" %str(table))
   valcnt=ccursor.fetchone()
  except psycopg2.ProgrammingError:
   print('Error when getting table: %(table)s in SCHEMA: %(schema)s' % {"table": str(table), "schema": row[0]})
   pass
  conn.commit()
  if valcnt[0] != 0:
   print('Values from reftuple and count are differ for table %(table)s %(reftuple)s:%(count)s' % {"reftuple": row[2], "count": valcnt[0], "table": str(table)})
