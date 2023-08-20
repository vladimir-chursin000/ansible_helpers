#!/usr/bin/bash

SELF_DIR_str="$(dirname $(readlink -f $0))";

###ARGV
INV_LIMIT_str=$1;
PLAYBOOK_str=$2;
LOG_DIR_str=$3;
PLAYBOOK_BEFORE_str=$4; #for run before script 'generate_dynamic_fwrules.pl' and/or PLAYBOOK
GEN_DYN_FWRULES_RUN_str=$5; #possible values: yes (run 'generate_dynamic_fwrules.pl' before  playbook), no
###ARGV

###CFG
INV_FILE_str="$SELF_DIR_str/conf_firewall_hosts";
CONF_DIVISIONS_FOR_INV_HOSTS_FILE_str="$SELF_DIR_str/fwrules_configs/00_conf_divisions_for_inv_hosts";
###CFG

###VARS
TMP_VAR_str='';
NOW_DT_str=`date '+%Y%m%d%H%M%S'`;
CUR_USER_str=`id -u -n`;
LOG_FILE_str="$LOG_DIR_str/$NOW_DT_str-$CUR_USER_str.log";
###VARS

###MAIN
/usr/bin/mkdir -p "$LOG_DIR_str/from_remote";

echo "User: $CUR_USER_str" | tee -a $LOG_FILE_str;
echo "Used inventory file: $INV_FILE_str" | tee -a $LOG_FILE_str;
echo "Used playbook: $SELF_DIR_str/playbooks/$PLAYBOOK_str" | tee -a $LOG_FILE_str;
echo "Start time: $NOW_DT_str" | tee -a $LOG_FILE_str;
echo "#########" | tee -a $LOG_FILE_str;

if [[ "$INV_LIMIT_str" == "no" ]]; then
    INV_LIMIT_str='';
    echo "INV_LIMIT = not defined" | tee -a $LOG_FILE_str;
elif [[ "$INV_LIMIT_str" =~ ^"gr_" ]]; then
    echo "INV_LIMIT = '$INV_LIMIT_str' (group_name from cfg='00_conf_divisions_for_inv_hosts')" | tee -a $LOG_FILE_str;
    TMP_VAR_str=$(grep ^"gr_" $CONF_DIVISIONS_FOR_INV_HOSTS_FILE_str | grep $INV_LIMIT_str | sed 's/\t//g' | sed 's/\s//g' | sed s/"$INV_LIMIT_str"//);
    INV_LIMIT_str=$TMP_VAR_str;
    echo "GROUP content='$INV_LIMIT_str'" | tee -a $LOG_FILE_str;
    
    TMP_VAR_str='';
else
    echo "INV_LIMIT = '$INV_LIMIT_str'" | tee -a $LOG_FILE_str;
fi;

if [[ ! -z "$PLAYBOOK_BEFORE_str" ]] && [[ "$PLAYBOOK_BEFORE_str" != "no" ]]; then
    if [[ "$PLAYBOOK_BEFORE_str" =~ "02_fwrules_backup" ]]; then
	rm -rf "$SELF_DIR_str/playbooks/fwrules_backup_from_remote/now/"; #remove prev downloaded backup of fwrules (content of '/etc/firewalld/zones' and output of 'firewall-cmd --list-all-zones') from now-dir
	rm -rf "$SELF_DIR_str/playbooks/fwrules_backup_from_remote/network_data/"; #remove prev downloaded data (output of 'ip link') from network_data
	echo "Remove prev downloaded data from '$SELF_DIR_str/playbooks/fwrules_backup_from_remote/now' and '$SELF_DIR_str/playbooks/fwrules_backup_from_remote/network_data'" | tee -a $LOG_FILE_str;
    fi;
    ###
    echo " " | tee -a $LOG_FILE_str;
    echo "#########" | tee -a $LOG_FILE_str;
    echo "Playbook_before: $SELF_DIR_str/playbooks/$PLAYBOOK_BEFORE_str" | tee -a $LOG_FILE_str;
    /usr/bin/ansible-playbook -i $INV_FILE_str -l "$INV_LIMIT_str" -u root --private-key=~/.ssh/id_rsa "$SELF_DIR_str/playbooks/$PLAYBOOK_BEFORE_str" | tee -a $LOG_FILE_str;
    # --limit "host" (or "group" from cfg '00_conf_divisions_for_inv_hosts') - for apply to one host (or several hosts)
    
    if [[ "$PLAYBOOK_BEFORE_str" =~ "02_fwrules_backup" ]]; then
	/usr/bin/perl "$SELF_DIR_str/playbooks/scripts_for_local/convert_raw_network_data_to_normal.pl" "$SELF_DIR_str/playbooks/fwrules_backup_from_remote/network_data";
	echo "Run script (after playbook '$PLAYBOOK_BEFORE_str'): $SELF_DIR_str/playbooks/scripts_for_local/convert_raw_network_data_to_normal.pl" | tee -a $LOG_FILE_str;
    fi;
fi;

if [[ ! -z "$GEN_DYN_FWRULES_RUN_str" ]] && [[ "$GEN_DYN_FWRULES_RUN_str" =~ "yes" ]]; then
    if [[ "$GEN_DYN_FWRULES_RUN_str" == "yes" ]]; then
	$SELF_DIR_str/generate_dynamic_fwrules.pl;
	echo "Run script (before playbook): $SELF_DIR_str/generate_dynamic_fwrules.pl" | tee -a $LOG_FILE_str;
    elif [[ "$GEN_DYN_FWRULES_RUN_str" == "yes_with_rollback" ]]; then
	$SELF_DIR_str/generate_dynamic_fwrules.pl "with_rollback";
	echo "Run script (before playbook): $SELF_DIR_str/generate_dynamic_fwrules.pl \"with_rollback\"" | tee -a $LOG_FILE_str;
    fi;

    if [[ ! -f "$SELF_DIR_str/GEN_DYN_FWRULES_STATUS" ]]; then
	echo "File with status of execution of 'generate_dynamic_fwrules.pl' is not exists. Exit!" | tee -a $LOG_FILE_str;
	exit;
    fi;
    
    if [[ $(grep -L 'OK' "$SELF_DIR_str/GEN_DYN_FWRULES_STATUS") ]]; then
	echo "Status of execution of 'generate_dynamic_fwrules.pl' is not OK. Exit!" | tee -a $LOG_FILE_str; 
	exit;
    fi;
fi;

if [[ "$PLAYBOOK_str" =~ "02_fwrules_backup" ]]; then
    rm -rf "$SELF_DIR_str/playbooks/fwrules_backup_from_remote/now/"; #remove prev downloaded backup of fwrules (content of '/etc/firewalld/zones' and output of 'firewall-cmd --list-all-zones') from now-dir
    rm -rf "$SELF_DIR_str/playbooks/fwrules_backup_from_remote/network_data/"; #remove prev downloaded data (output of 'ip link') from network_data
    echo "Remove prev downloaded data from '$SELF_DIR_str/playbooks/fwrules_backup_from_remote/now' and '$SELF_DIR_str/playbooks/fwrules_backup_from_remote/network_data'" | tee -a $LOG_FILE_str;
fi;

#main playbook
if [[ ! -z "$PLAYBOOK_str" ]] && [[ "$PLAYBOOK_str" != "no" ]]; then
    /usr/bin/ansible-playbook -i $INV_FILE_str -l "$INV_LIMIT_str" -u root --private-key=~/.ssh/id_rsa "$SELF_DIR_str/playbooks/$PLAYBOOK_str" | tee -a $LOG_FILE_str;
    # --limit "host" (or "group" from cfg '00_conf_divisions_for_inv_hosts') - for apply to one host (or several hosts)
fi;
#main playbook

if [[ "$PLAYBOOK_str" =~ "02_fwrules_backup" ]]; then
    #for get interface names (eth, br, bond, etc) = output of 'ip link'
    /usr/bin/perl "$SELF_DIR_str/playbooks/scripts_for_local/convert_raw_network_data_to_normal.pl" "$SELF_DIR_str/playbooks/fwrules_backup_from_remote/network_data";
    echo "Run script (after playbook '$PLAYBOOK_str'): $SELF_DIR_str/playbooks/scripts_for_local/convert_raw_network_data_to_normal.pl" | tee -a $LOG_FILE_str;
fi;
###MAIN


#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
