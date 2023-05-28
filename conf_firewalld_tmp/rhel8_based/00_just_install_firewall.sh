#!/usr/bin/bash

SELF_DIR="$(dirname $(readlink -f $0))";
INV_FILE="$SELF_DIR/conf_firewall_hosts";
PLAYBOOK='just_install_firewall_playbook.yml';
LOG_DIR="$SELF_DIR/run_history";
PLAYBOOK_BEFORE='no';
GEN_DYN_FWRULES_RUN='no';

$SELF_DIR/main.sh "$INV_FILE" "$PLAYBOOK" "$LOG_DIR" "$PLAYBOOK_BEFORE" "$GEN_DYN_FWRULES_RUN";
