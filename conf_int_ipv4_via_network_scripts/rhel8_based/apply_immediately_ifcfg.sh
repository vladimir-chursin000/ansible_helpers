#!/usr/bin/bash

SELF_DIR="$(dirname $(readlink -f $0))";
INV_FILE="$SELF_DIR/conf_network_scripts_hosts";
PLAYBOOK='dyn_ifcfg_playbooks/dynamic_ifcfg_loader.yml';
LOG_DIR="$SELF_DIR/run_history";
PLAYBOOK_BEFORE='ifcfg_backup_playbook.yml';
PLAYBOOK_AFTER='no';
GEN_DYN_IFCFG_RUN='yes';

$SELF_DIR/main.sh "$INV_FILE" "$PLAYBOOK" "$LOG_DIR" "$PLAYBOOK_BEFORE" "$PLAYBOOK_AFTER" "$GEN_DYN_IFCFG_RUN";
