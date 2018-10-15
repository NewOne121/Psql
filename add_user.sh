#!/bin/sh
export PGPASSWORD=$(base64 -d ~/.pgs)
USNM=$1
DBNAME="databse1 databse2"
PSQLCMD="psql -Upostgres -h IPADDRESS -p PORT"

echo "CREATE ROLE $USNM LOGIN PASSWORD '$USNM';" | $PSQLCMD
echo "GRANT CONNECT ON DATABASE databse1,databse2 TO $USNM;" | $PSQLCMD
echo "GRANT support TO $USNM;" | $PSQLCMD

for NAME in $DBNAME;
do
export PGPASSWORD="$USNM"
PSQLCMD="psql -U"$USNM" -h IPADDRESS -p PORT -d $NAME"
if [ "$NAME" = "databse1" ];
	then
	 echo "select * from databse1.developer_card limit 1;" | $PSQLCMD
	elif [ "$NAME" = "databse2" ];
		then
		 echo "select * from metric_statistics limit 1;" | $PSQLCMD
fi
done
