#!/usr/bin/bash

SELF_DIR="$(dirname $(readlink -f $0))";
INV_FILE="$SELF_DIR/conf_network_scripts_hosts";
PLAYBOOK='no';
LOG_DIR="$SELF_DIR/run_history";
PLAYBOOK_BEFORE='ifcfg_backup_playbook.yml';
GEN_DYN_IFCFG_RUN='yes';

$SELF_DIR/main.sh "$INV_FILE" "$PLAYBOOK" "$LOG_DIR" "$PLAYBOOK_BEFORE" "$GEN_DYN_IFCFG_RUN";
