#!/usr/bin/bash

SELF_DIR_str="$(dirname $(readlink -f $0))";

###ARGV
INV_LIMIT_str=$1;
PLAYBOOK_str=$2;
LOG_DIR_str=$3;
###ARGV

###CFG
INV_FILE_str="$SELF_DIR_str/lxc_server_hosts";
CONF_DIVISIONS_FOR_INV_HOSTS_FILE_str="$SELF_DIR_str/01_configs/00_conf_divisions_for_inv_hosts";
###CFG

###VARS
NOW_DT_str=`date '+%Y%m%d%H%M%S'`;
CUR_USER_str=`id -u -n`;
LOG_FILE_str="$LOG_DIR_str/$NOW_DT_str-$CUR_USER_str.log";
###VARS

###MAIN
/usr/bin/mkdir -p "$LOG_DIR_str";

echo "User: $CUR_USER_str" | tee -a $LOG_FILE_str;
echo "Used inventory file: $INV_FILE_str" | tee -a $LOG_FILE_str;
echo "Used limit for inventory file: $INV_LIMIT_str" | tee -a $LOG_FILE_str;
echo "Used playbook: $SELF_DIR_str/playbooks/$PLAYBOOK_str" | tee -a $LOG_FILE_str;
echo "Start time: $NOW_DT_str" | tee -a $LOG_FILE_str;
echo "#########" | tee -a $LOG_FILE_str;

/usr/bin/ansible-playbook -i $INV_FILE_str -u root --private-key=~/.ssh/id_rsa "$SELF_DIR_str/playbooks/$PLAYBOOK_str" | tee -a $LOG_FILE_str;
###MAIN


#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
