#!/usr/bin/bash

SELF_DIR="$(dirname $(readlink -f $0))";

###ARGV
INV_FILE=$1;
PLAYBOOK=$2;
LOG_DIR=$3;
IS_NEED_RUN_GEN_DYN_EXPORTS=$4;
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
if [[ ! -z "$IS_NEED_RUN_GEN_DYN_EXPORTS" ]] && [[ "$IS_NEED_RUN_GEN_DYN_EXPORTS" == "YES" ]]; then
    $SELF_DIR/generate_dynamic_exports.sh;
    echo "Run script (before playbook): $SELF_DIR/generate_dynamic_exports.sh" | tee -a $LOG_FILE;
fi;
echo "#########" | tee -a $LOG_FILE;

/usr/bin/ansible-playbook -i $INV_FILE -u root --private-key=~/.ssh/id_rsa "$SELF_DIR/playbooks/$PLAYBOOK" | tee -a $LOG_FILE;
###MAIN


#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
