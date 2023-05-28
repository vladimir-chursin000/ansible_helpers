#!/usr/bin/bash

SELF_DIR="$(dirname $(readlink -f $0))";
INV_FILE="$SELF_DIR/conf_firewall_hosts";
PLAYBOOK='fwrules_apply_temporary_playbook.yml';
LOG_DIR="$SELF_DIR/run_history";
PLAYBOOK_BEFORE='fwrules_backup_playbook_for_temp_apply.yml';
GEN_DYN_FWRULES_RUN='yes_with_rollback';

$SELF_DIR/main.sh "$INV_FILE" "$PLAYBOOK" "$LOG_DIR" "$PLAYBOOK_BEFORE" "$GEN_DYN_FWRULES_RUN";
