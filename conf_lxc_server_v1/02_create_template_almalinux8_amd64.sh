#!/usr/bin/bash

######DEFAULT INPUT VARS (for main.sh)
# Do not change this variables manually
SELF_DIR="$(dirname $(readlink -f $0))";
INV_FILE="$SELF_DIR/lxc_server_hosts";
PLAYBOOK='create_template_almalinux8_amd64.yml';
LOG_DIR="$SELF_DIR/run_history";
######DEFAULT INPUT VARS

######VARS
TMP_VAR_str='';
######VARS

$SELF_DIR/main.sh "$INV_FILE" "$PLAYBOOK" "$LOG_DIR";
