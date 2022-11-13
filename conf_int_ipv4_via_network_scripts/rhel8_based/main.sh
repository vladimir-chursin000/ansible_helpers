#!/usr/bin/bash

SELF_DIR="$(dirname $(readlink -f $0))";

###ARGV
INV_FILE=$1;
PLAYBOOK=$2;
LOG_DIR=$3;
PLAYBOOK_BEFORE=$4; #playbook for run before all
GEN_DYN_IFCFG_RUN=$5; #possible values: yes (run 'generate_dynamic_ifcfg.pl' before  playbook), no
###ARGV

###VARS
NOW_DT=`date '+%Y%m%d%H%M%S'`;
CUR_USER=`id -u -n`;
LOG_FILE="$LOG_DIR/$NOW_DT-$CUR_USER.log";
###VARS

###MAIN
/usr/bin/mkdir -p "$LOG_DIR";

echo "User: $CUR_USER" | tee -a $LOG_FILE;
echo "Used inventory file: $INV_FILE" | tee -a $LOG_FILE;
echo "Used playbook: $SELF_DIR/playbooks/$PLAYBOOK" | tee -a $LOG_FILE;
echo "Start time: $NOW_DT" | tee -a $LOG_FILE;
echo "#########" | tee -a $LOG_FILE;

if [[ ! -z "$PLAYBOOK_BEFORE" ]] && [[ "$PLAYBOOK_BEFORE" != "no" ]]; then
    if [[ "$PLAYBOOK_BEFORE" =~ "ifcfg_backup" ]]; then
	rm -rf "$SELF_DIR/playbooks/ifcfg_backup_from_remote/now/"; #remove prev downloaded backup of ifcfg from now-dir
	rm -rf "$SELF_DIR/playbooks/ifcfg_backup_from_remote/network_data/"; #remove prev downloaded data from network_data
	echo "Remove prev downloaded data from '$SELF_DIR/playbooks/ifcfg_backup_from_remote/now' and '$SELF_DIR/playbooks/ifcfg_backup_from_remote/network_data'" | tee -a $LOG_FILE;
    fi;
    ###
    echo " " | tee -a $LOG_FILE;
    echo "#########" | tee -a $LOG_FILE;
    echo "Playbook_before: $SELF_DIR/playbooks/$PLAYBOOK_BEFORE" | tee -a $LOG_FILE;
    /usr/bin/ansible-playbook -i $INV_FILE -u root --private-key=~/.ssh/id_rsa "$SELF_DIR/playbooks/$PLAYBOOK_BEFORE" | tee -a $LOG_FILE;
    
    if [[ "$PLAYBOOK_BEFORE" =~ "ifcfg_backup" ]]; then
	/usr/bin/perl "$SELF_DIR/playbooks/scripts_for_local/convert_raw_network_data_to_normal.pl" "$SELF_DIR/playbooks/ifcfg_backup_from_remote/network_data";
	echo "Run script (after playbook '$PLAYBOOK_BEFORE'): $SELF_DIR/playbooks/scripts_for_local/convert_raw_network_data_to_normal.pl" | tee -a $LOG_FILE;
    fi;
fi;

if [[ ! -z "$GEN_DYN_IFCFG_RUN" ]] && [[ "$GEN_DYN_IFCFG_RUN" =~ "yes" ]]; then
    if [[ "$GEN_DYN_IFCFG_RUN" == "yes" ]]; then
	$SELF_DIR/generate_dynamic_ifcfg.pl "gen_dyn_playbooks";
	echo "Run script (before playbook): $SELF_DIR/generate_dynamic_ifcfg.pl \"gen_dyn_playbooks\"" | tee -a $LOG_FILE;
    elif [[ "$GEN_DYN_IFCFG_RUN" == "yes_with_rollback" ]]; then
	$SELF_DIR/generate_dynamic_ifcfg.pl "gen_dyn_playbooks_with_rollback";
	echo "Run script (before playbook '$PLAYBOOK'): $SELF_DIR/generate_dynamic_ifcfg.pl \"gen_dyn_playbooks_with_rollback\"" | tee -a $LOG_FILE;
    fi;

    if [[ ! -f "$SELF_DIR/GEN_DYN_IFCFG_STATUS" ]]; then
	echo "File with status of execution of 'generate_dynamic_ifcfg.pl' is not exists. Exit!" | tee -a $LOG_FILE;
	exit;
    fi;
    
    if [[ $(grep -L 'OK' "$SELF_DIR/GEN_DYN_IFCFG_STATUS") ]]; then
	echo "Status of execution of 'generate_dynamic_ifcfg.pl' is not OK. Exit!" | tee -a $LOG_FILE; 
	exit;
    fi;
fi;

if [[ "$PLAYBOOK" =~ "ifcfg_backup" ]]; then
    rm -rf "$SELF_DIR/playbooks/ifcfg_backup_from_remote/now/"; #remove prev downloaded backup of ifcfg from now-dir
    rm -rf "$SELF_DIR/playbooks/ifcfg_backup_from_remote/network_data/"; #remove prev downloaded data from network_data
    echo "Remove prev downloaded data from '$SELF_DIR/playbooks/ifcfg_backup_from_remote/now' and '$SELF_DIR/playbooks/ifcfg_backup_from_remote/network_data'" | tee -a $LOG_FILE;
fi;

#main playbook
if [[ ! -z "$PLAYBOOK" ]] && [[ "$PLAYBOOK" != "no" ]]; then
    /usr/bin/ansible-playbook -i $INV_FILE -u root --private-key=~/.ssh/id_rsa "$SELF_DIR/playbooks/$PLAYBOOK" | tee -a $LOG_FILE;
fi;
#main playbook

if [[ "$PLAYBOOK" =~ "ifcfg_backup" ]]; then
    /usr/bin/perl "$SELF_DIR/playbooks/scripts_for_local/convert_raw_network_data_to_normal.pl" "$SELF_DIR/playbooks/ifcfg_backup_from_remote/network_data";
    echo "Run script (after playbook '$PLAYBOOK'): $SELF_DIR/playbooks/scripts_for_local/convert_raw_network_data_to_normal.pl" | tee -a $LOG_FILE;
fi;

if [[ -f "$SELF_DIR/playbooks/ifcfg_backup_from_remote/network_data/WARNINGS.txt" ]]; then
    echo " " | tee -a $LOG_FILE;
    echo "########################################" | tee -a $LOG_FILE;
    echo "PROBABLY YOU HAVE some mac duplicate WARNINGS at '$SELF_DIR/playbooks/ifcfg_backup_from_remote/network_data/WARNINGS.txt'" | tee -a $LOG_FILE;
fi;
###MAIN


#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
