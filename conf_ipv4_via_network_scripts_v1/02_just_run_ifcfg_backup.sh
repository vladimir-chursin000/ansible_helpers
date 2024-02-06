#!/usr/bin/bash

######DEFAULT INPUT VARS (for main.sh)
# Do not change this variables manually
SELF_DIR="$(dirname $(readlink -f $0))";
INV_FILE="$SELF_DIR/conf_network_scripts_hosts";
PLAYBOOK='ifcfg_backup_playbook.yml';
LOG_DIR="$SELF_DIR/run_history";
PLAYBOOK_BEFORE='no';
GEN_DYN_IFCFG_RUN='no';
######DEFAULT INPUT VARS

$SELF_DIR/main.sh "$INV_FILE" "$PLAYBOOK" "$LOG_DIR" "$PLAYBOOK_BEFORE" "$GEN_DYN_IFCFG_RUN";
