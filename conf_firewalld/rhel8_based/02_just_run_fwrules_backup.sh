#!/usr/bin/bash

SELF_DIR_str="$(dirname $(readlink -f $0))";
INV_FILE_str="$SELF_DIR_str/conf_firewall_hosts";
PLAYBOOK_str='02_fwrules_backup_pb.yml';
LOG_DIR_str="$SELF_DIR_str/run_history";
PLAYBOOK_BEFORE_str='no'; #for run before script 'generate_dynamic_fwrules.pl' and/or PLAYBOOK
GEN_DYN_FWRULES_RUN_str='no';

$SELF_DIR_str/main.sh "$INV_FILE_str" "$PLAYBOOK_str" "$LOG_DIR_str" "$PLAYBOOK_BEFORE_str" "$GEN_DYN_FWRULES_RUN_str";
