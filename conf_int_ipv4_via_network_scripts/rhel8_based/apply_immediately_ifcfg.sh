#!/usr/bin/bash

SELF_DIR="$(dirname $(readlink -f $0))";
INV_FILE="$SELF_DIR/conf_network_scripts_hosts";
PLAYBOOK='apply_now_ifcfg_playbook.yml';
LOG_DIR="$SELF_DIR/run_history";
GEN_DYN_IFCFG_RUN='yes';

$SELF_DIR/main.sh "$INV_FILE" "$PLAYBOOK" "$LOG_DIR" "$GEN_DYN_IFCFG_RUN";
