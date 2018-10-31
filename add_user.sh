#!/bin/sh
###Create user in DB.
export PGPASSWORD=$(base64 -d ~/.pgs)
USNM=$1
DBNAME="db1 db2"
PSQLCMD="psql -Uuser -h KUBEIP -p KUBEPORT"

echo "CREATE ROLE $USNM LOGIN PASSWORD '$USNM';" | $PSQLCMD
echo "GRANT CONNECT ON DATABASE db1,db2 TO $USNM;" | $PSQLCMD
echo "GRANT epamsupport TO $USNM;" | $PSQLCMD

for NAME in $DBNAME;
do
export PGPASSWORD="$USNM"
PSQLCMD="psql -U"$USNM" -h DBIP -p DBPORT -d $NAME"
if [ "$NAME" = "db1" ];
	then
	 echo "select * from db1.developer_card limit 1;" | $PSQLCMD
	elif [ "$NAME" = "db2" ];
		then
		 echo "select * from metric_statistics limit 1;" | $PSQLCMD
fi
done

###Check that user does not exist already and then add it.
KUBEHOST="KUBEIP"
SSHPASS=$(base64 -d ~/.kps)
export SSHPASS
BPOD=$(sshpass -e ssh $KUBEHOST "kubectl get pods -n services-infr | grep 'dl-slave' | awk '/Running/ {print \$1}'")

uschk() {
sshpass -e ssh $KUBEHOST "grep -q "\\\"$USNM\\\"" /secret.txt"
EXCHK=$?
}

uschk

if [ "$EXCHK" = "1" ];
then
	sshpass -e ssh $KUBEHOST "echo "\"\\\"$USNM\\\"\" \"\\\"$USNM\\\"\"" >> /secret.txt; kubectl create secret generic ulist --from-file=/secret.txt -n services-infr --dry-run -o yaml | kubectl apply -f - -n services-infr"
	echo "User sucessfully added"
	sshpass -e ssh $KUBEHOST "kubectl delete pods -n services-infr $BPOD --grace-period=5 --force"
else
	echo "User already exists"
fi

