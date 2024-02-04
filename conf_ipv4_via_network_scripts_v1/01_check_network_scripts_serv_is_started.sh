#!/usr/bin/bash

# For start and enable services (at remote): network.service.

SELF_DIR="$(dirname $(readlink -f $0))";
INV_FILE="$SELF_DIR/conf_network_scripts_hosts";
PLAYBOOK='check_network_scripts_serv_is_started_playbook.yml';
LOG_DIR="$SELF_DIR/run_history";
PLAYBOOK_BEFORE='no';
GEN_DYN_IFCFG_RUN='no';

$SELF_DIR/main.sh "$INV_FILE" "$PLAYBOOK" "$LOG_DIR" "$PLAYBOOK_BEFORE" "$GEN_DYN_IFCFG_RUN";
