#!/usr/bin/bash

SELF_DIR="$(dirname $(readlink -f $0))";

###ARGV
INV_FILE=$1;
PLAYBOOK=$2;
LOG_DIR=$3;
###ARGV

###VARS
NOW_DT=`date '+%Y%m%d%H%M%S'`;
CUR_USER=`id -u -n`;
LOG_FILE="$LOG_DIR/$NOW_DT-$CUR_USER.log";
###VARS

###MAIN
/usr/bin/mkdir -p "$LOG_DIR";

echo "User: $CUR_USER" > $LOG_FILE;
echo "Used inventory file: $INV_FILE" >> $LOG_FILE;
echo "Used playbook: $SELF_DIR/playbooks/$PLAYBOOK" >> $LOG_FILE;
echo "Start time: $NOW_DT" >> $LOG_FILE;
echo "#########" >> $LOG_FILE;

/usr/bin/ansible-playbook -i $INV_FILE -u root --private-key=~/.ssh/id_rsa "$SELF_DIR/playbooks/$PLAYBOOK" | tee -a $LOG_FILE;
###MAIN
