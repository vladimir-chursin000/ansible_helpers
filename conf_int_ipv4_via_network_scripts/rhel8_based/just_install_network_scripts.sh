#!/usr/bin/bash

SELF_DIR="$(dirname $(readlink -f $0))";
INV_FILE="$SELF_DIR/conf_network_scripts_hosts";
PLAYBOOK='just_install_network_scripts_playbook.yml';
LOG_DIR="$SELF_DIR/run_history";

$SELF_DIR/main.sh "$INV_FILE" "$PLAYBOOK" "$LOG_DIR";
