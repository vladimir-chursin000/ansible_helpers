#!/usr/bin/bash

SELF_DIR_str="$(dirname $(readlink -f $0))";

###ARGV
INV_LIMIT_str=$1;
PLAYBOOK_str=$2;
LOG_DIR_str=$3;
PLAYBOOK_BEFORE_str=$4; #playbook for run before all
GEN_DYN_IFCFG_RUN_str=$5; #possible values: yes (run 'generate_dynamic_ifcfg.pl' before  playbook), no
###ARGV

###CFG
INV_FILE_str="$SELF_DIR_str/conf_network_scripts_hosts";
CONF_DIVISIONS_FOR_INV_HOSTS_FILE_str="$SELF_DIR_str/01_configs/00_conf_divisions_for_inv_hosts";
###CFG

###VARS
NOW_DT_str=`date '+%Y%m%d%H%M%S'`;
CUR_USER_str=`id -u -n`;
LOG_FILE_str="$LOG_DIR_str/$NOW_DT_str-$CUR_USER_str.log";
###VARS

###MAIN (begin)
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


if [[ ! -z "$PLAYBOOK_BEFORE_str" ]] && [[ "$PLAYBOOK_BEFORE_str" != "no" ]]; then
    if [[ "$PLAYBOOK_BEFORE_str" =~ "ifcfg_backup" ]]; then
	rm -rf "$SELF_DIR_str/playbooks/ifcfg_backup_from_remote/now/"; #remove prev downloaded backup of ifcfg from now-dir
	rm -rf "$SELF_DIR_str/playbooks/ifcfg_backup_from_remote/network_data/"; #remove prev downloaded data from network_data
	echo "Remove prev downloaded data from '$SELF_DIR_str/playbooks/ifcfg_backup_from_remote/now' and '$SELF_DIR_str/playbooks/ifcfg_backup_from_remote/network_data'" | tee -a $LOG_FILE_str;
    fi;
    ###
    echo " " | tee -a $LOG_FILE_str;
    echo "#########" | tee -a $LOG_FILE_str;
    echo "Playbook_before: $SELF_DIR_str/playbooks/$PLAYBOOK_BEFORE_str" | tee -a $LOG_FILE_str;
    /usr/bin/ansible-playbook -i $INV_FILE_str -l "$INV_LIMIT_str" -u root --private-key=~/.ssh/id_rsa "$SELF_DIR_str/playbooks/$PLAYBOOK_BEFORE_str" | tee -a $LOG_FILE_str;
    
    if [[ "$PLAYBOOK_BEFORE_str" =~ "ifcfg_backup" ]]; then
	/usr/bin/perl "$SELF_DIR_str/playbooks/scripts_for_local/convert_raw_network_data_to_normal.pl" "$SELF_DIR_str/playbooks/ifcfg_backup_from_remote/network_data";
	echo "Run script (after playbook '$PLAYBOOK_BEFORE_str'): $SELF_DIR_str/playbooks/scripts_for_local/convert_raw_network_data_to_normal.pl" | tee -a $LOG_FILE_str;
    fi;
fi;

if [[ ! -z "$GEN_DYN_IFCFG_RUN_str" ]] && [[ "$GEN_DYN_IFCFG_RUN_str" =~ "yes" ]]; then
    if [[ "$GEN_DYN_IFCFG_RUN_str" == "yes" ]]; then
	$SELF_DIR_str/generate_dynamic_ifcfg.pl "gen_dyn_playbooks";
	echo "Run script (before playbook): $SELF_DIR_str/generate_dynamic_ifcfg.pl \"gen_dyn_playbooks\"" | tee -a $LOG_FILE_str;
    elif [[ "$GEN_DYN_IFCFG_RUN_str" == "yes_with_rollback" ]]; then
	$SELF_DIR_str/generate_dynamic_ifcfg.pl "gen_dyn_playbooks_with_rollback";
	echo "Run script (before playbook '$PLAYBOOK_str'): $SELF_DIR_str/generate_dynamic_ifcfg.pl \"gen_dyn_playbooks_with_rollback\"" | tee -a $LOG_FILE_str;
    fi;

    if [[ ! -f "$SELF_DIR_str/GEN_DYN_IFCFG_STATUS" ]]; then
	echo "File with status of execution of 'generate_dynamic_ifcfg.pl' is not exists. Exit!" | tee -a $LOG_FILE_str;
	exit;
    fi;
    
    if [[ $(grep -L 'OK' "$SELF_DIR_str/GEN_DYN_IFCFG_STATUS") ]]; then
	echo "Status of execution of 'generate_dynamic_ifcfg.pl' is not OK. Exit!" | tee -a $LOG_FILE_str;
	exit;
    fi;
fi;

if [[ "$PLAYBOOK_str" =~ "ifcfg_backup" ]]; then
    rm -rf "$SELF_DIR_str/playbooks/ifcfg_backup_from_remote/now/"; #remove prev downloaded backup of ifcfg from now-dir
    rm -rf "$SELF_DIR_str/playbooks/ifcfg_backup_from_remote/network_data/"; #remove prev downloaded data from network_data
    echo "Remove prev downloaded data from '$SELF_DIR_str/playbooks/ifcfg_backup_from_remote/now' and '$SELF_DIR_str/playbooks/ifcfg_backup_from_remote/network_data'" | tee -a $LOG_FILE_str;
fi;

#main playbook
if [[ ! -z "$PLAYBOOK_str" ]] && [[ "$PLAYBOOK_str" != "no" ]]; then
    /usr/bin/ansible-playbook -i $INV_FILE_str -l "$INV_LIMIT_str" -u root --private-key=~/.ssh/id_rsa "$SELF_DIR_str/playbooks/$PLAYBOOK_str" | tee -a $LOG_FILE_str;
fi;
#main playbook

if [[ "$PLAYBOOK_str" =~ "ifcfg_backup" ]]; then
    /usr/bin/perl "$SELF_DIR_str/playbooks/scripts_for_local/convert_raw_network_data_to_normal.pl" "$SELF_DIR_str/playbooks/ifcfg_backup_from_remote/network_data";
    echo "Run script (after playbook '$PLAYBOOK_str'): $SELF_DIR_str/playbooks/scripts_for_local/convert_raw_network_data_to_normal.pl" | tee -a $LOG_FILE_str;
fi;

if [[ -f "$SELF_DIR_str/playbooks/ifcfg_backup_from_remote/network_data/WARNINGS.txt" ]]; then
    echo " " | tee -a $LOG_FILE_str;
    echo "########################################" | tee -a $LOG_FILE_str;
    echo "PROBABLY YOU HAVE some mac duplicate WARNINGS at '$SELF_DIR_str/playbooks/ifcfg_backup_from_remote/network_data/WARNINGS.txt'" | tee -a $LOG_FILE_str;
fi;
###MAIN (end)

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
