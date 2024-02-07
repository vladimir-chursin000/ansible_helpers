#!/usr/bin/bash

######DEFAULT INPUT VARS (for main.sh)
# Do not change this variables manually
SELF_DIR="$(dirname $(readlink -f $0))";
INV_FILE="$SELF_DIR/lxc_server_hosts";
PLAYBOOK='check_lxc_serv_conf_is_changed_playbook.yml';
LOG_DIR="$SELF_DIR/run_history";
######DEFAULT INPUT VARS

######VARS
TMP_VAR_str='';
######VARS

$SELF_DIR/main.sh "$INV_FILE" "$PLAYBOOK" "$LOG_DIR";
