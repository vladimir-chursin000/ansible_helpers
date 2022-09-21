#!/usr/bin/bash

SELF_DIR="$(dirname $(readlink -f $0))";

###ARGV
INV_FILE=$1;
PLAYBOOK=$2;
LOG_DIR=$3;
GEN_DYN_MOUNT_RUN_TYPE=$4; #possible values: before_remove (for generate absent tasks), before_update (for generate unmount tasks), just_run
PLAYBOOK_NEXT=$5;
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
if [[ ! -z "$GEN_DYN_MOUNT_RUN_TYPE" ]] && [[ "$GEN_DYN_MOUNT_RUN_TYPE" == "before_remove" ]]; then
    $SELF_DIR/generate_dynamic_mount_playbooks.sh "before_remove";
    echo "Run script (before playbook): $SELF_DIR/generate_dynamic_mount_playbooks.sh (with 'before_remove' option)" | tee -a $LOG_FILE;
fi;

if [[ ! -z "$GEN_DYN_MOUNT_RUN_TYPE" ]] && [[ "$GEN_DYN_MOUNT_RUN_TYPE" == "before_update" ]]; then
    $SELF_DIR/generate_dynamic_mount_playbooks.sh "before_update";
    echo "Run script (before playbook): $SELF_DIR/generate_dynamic_mount_playbooks.sh (with 'before_update' option)" | tee -a $LOG_FILE;
fi;

if [[ ! -z "$GEN_DYN_MOUNT_RUN_TYPE" ]] && [[ "$GEN_DYN_MOUNT_RUN_TYPE" == "just_run" ]]; then
    $SELF_DIR/generate_dynamic_mount_playbooks.sh;
    echo "Run script (before playbook): $SELF_DIR/generate_dynamic_mount_playbooks.sh" | tee -a $LOG_FILE;
fi;
echo "#########" | tee -a $LOG_FILE;

/usr/bin/ansible-playbook -i $INV_FILE -u root --private-key=~/.ssh/id_rsa "$SELF_DIR/playbooks/$PLAYBOOK" | tee -a $LOG_FILE;

if [[ ! -z "$PLAYBOOK_NEXT" ]] && [[ "$PLAYBOOK_NEXT" != "no" ]]; then
    echo " " | tee -a $LOG_FILE;
    echo "#########" | tee -a $LOG_FILE;
    echo "Playbook_next: $SELF_DIR/playbooks/$PLAYBOOK_NEXT" | tee -a $LOG_FILE;
    $SELF_DIR/generate_dynamic_mount_playbooks.sh;
    echo "Run script (before playbook_next): $SELF_DIR/generate_dynamic_mount_playbooks.sh" | tee -a $LOG_FILE;
    /usr/bin/ansible-playbook -i $INV_FILE -u root --private-key=~/.ssh/id_rsa "$SELF_DIR/playbooks/$PLAYBOOK_NEXT" | tee -a $LOG_FILE;
fi;
###MAIN
