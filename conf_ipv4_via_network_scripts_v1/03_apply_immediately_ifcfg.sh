#!/usr/bin/bash

######DEFAULT INPUT VARS (for main.sh)
# Do not change this variables manually
SELF_DIR="$(dirname $(readlink -f $0))";
INV_FILE="$SELF_DIR/conf_network_scripts_hosts";
PLAYBOOK='dyn_ifcfg_playbooks/dynamic_ifcfg_loader.yml';
LOG_DIR="$SELF_DIR/run_history";
PLAYBOOK_BEFORE='ifcfg_backup_playbook.yml';
GEN_DYN_IFCFG_RUN='yes';
######DEFAULT INPUT VARS

######VARS
TMP_VAR_str='';
######VARS

$SELF_DIR/main.sh "$INV_FILE" "$PLAYBOOK" "$LOG_DIR" "$PLAYBOOK_BEFORE" "$GEN_DYN_IFCFG_RUN";
