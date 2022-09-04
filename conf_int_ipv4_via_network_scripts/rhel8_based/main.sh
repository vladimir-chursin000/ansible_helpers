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

echo "User: $CUR_USER" > $LOG_FILE;
echo "Used inventory file: $INV_FILE" >> $LOG_FILE;
echo "Used playbook: $SELF_DIR/playbooks/$PLAYBOOK" >> $LOG_FILE;
echo "Start time: $NOW_DT" >> $LOG_FILE;
echo "#########" >> $LOG_FILE;

if [[ ! -z "$PLAYBOOK_BEFORE" ]] && [[ "$PLAYBOOK_BEFORE" != "no" ]]; then
    rm -rf "$SELF_DIR/playbooks/ifcfg_backup_from_remote/now/"; #remove prev downloaded backup of ifcfg for now-dir
    ###
    echo " " >> $LOG_FILE;
    echo "#########" >> $LOG_FILE;
    echo "Playbook_before: $SELF_DIR/playbooks/$PLAYBOOK_BEFORE" >> $LOG_FILE;
    /usr/bin/ansible-playbook -i $INV_FILE -u root --private-key=~/.ssh/id_rsa "$SELF_DIR/playbooks/$PLAYBOOK_BEFORE" | tee -a $LOG_FILE;
fi;

if [[ ! -z "$GEN_DYN_IFCFG_RUN" ]] && [[ "$GEN_DYN_IFCFG_RUN" == "yes" ]]; then
    $SELF_DIR/generate_dynamic_ifcfg.pl "gen_dyn_playbooks";
    echo "Run script (before playbook): $SELF_DIR/generate_dynamic_ifcfg.pl" >> $LOG_FILE;

    if [[ ! -f "$SELF_DIR/GEN_DYN_IFCFG_STATUS" ]]; then
	echo "File with status of execution of 'generate_dynamic_ifcfg.pl' is not exists. Exit!";
	echo "File with status of execution of 'generate_dynamic_ifcfg.pl' is not exists. Exit!" >> $LOG_FILE;
	exit;
    fi;
    
    if [[ $(grep -L 'OK' "$SELF_DIR/GEN_DYN_IFCFG_STATUS") ]]; then
	echo "Status of execution of 'generate_dynamic_ifcfg.pl' is not OK. Exit!";
	echo "Status of execution of 'generate_dynamic_ifcfg.pl' is not OK. Exit!" >> $LOG_FILE; 
	exit;
    fi;
fi;

/usr/bin/ansible-playbook -i $INV_FILE -u root --private-key=~/.ssh/id_rsa "$SELF_DIR/playbooks/$PLAYBOOK" | tee -a $LOG_FILE;
###MAIN
