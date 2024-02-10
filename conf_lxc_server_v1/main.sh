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

if [[ "$INV_LIMIT_str" == "no" || "$INV_LIMIT_str" == "all" ]]; then
    INV_LIMIT_str='';
    echo "INV_LIMIT = not defined or 'all'" | tee -a $LOG_FILE_str;
elif [[ "$INV_LIMIT_str" =~ ^"gr_" ]]; then
    echo "INV_LIMIT = '$INV_LIMIT_str' (group_name from cfg='00_conf_divisions_for_inv_hosts')" | tee -a $LOG_FILE_str;
    TMP_VAR_str=$(grep ^"gr_" $CONF_DIVISIONS_FOR_INV_HOSTS_FILE_str | grep $INV_LIMIT_str | sed 's/\t//g' | sed 's/\s//g' | sed s/"$INV_LIMIT_str"//);
    INV_LIMIT_str=$TMP_VAR_str;
    echo "GROUP content='$INV_LIMIT_str'" | tee -a $LOG_FILE_str;
    TMP_VAR_str='';

    TMP_arr=($(echo "$INV_LIMIT_str" | sed 's/,/\n/g'));
    for TMP_VAR_str in "${TMP_arr[@]}"
    do
        if [[ `grep -Fx "$TMP_VAR_str" $INV_FILE_str | wc -l` != "1" ]]; then
            echo "Host='$TMP_VAR_str' is not exists at inv_file='$INV_FILE_str'. Exit!" | tee -a $LOG_FILE_str;
            exit;
        fi;
    done;

    TMP_VAR_str='';
    TMP_arr=();
else
    echo "INV_LIMIT = '$INV_LIMIT_str'" | tee -a $LOG_FILE_str;

    TMP_arr=($(echo "$INV_LIMIT_str" | sed 's/,/\n/g'));
    for TMP_VAR_str in "${TMP_arr[@]}"
    do
        if [[ `grep -Fx "$TMP_VAR_str" $INV_FILE_str | wc -l` != "1" ]]; then
            echo "Host='$TMP_VAR_str' is not exists at inv_file='$INV_FILE_str'. Exit!" | tee -a $LOG_FILE_str;
            exit;
        fi;
    done;

    TMP_VAR_str='';
    TMP_arr=();
fi;

/usr/bin/ansible-playbook -i $INV_FILE_str -u root --private-key=~/.ssh/id_rsa "$SELF_DIR_str/playbooks/$PLAYBOOK_str" | tee -a $LOG_FILE_str;
###MAIN


#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
