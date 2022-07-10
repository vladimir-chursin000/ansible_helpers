#!/usr/bin/bash

SELF_DIR="$(dirname $(readlink -f $0))";
INV_FILE="$SELF_DIR/nfs_server_hosts";
PLAYBOOK='update_nfs_serv_playbook.yml';
LOG_DIR="$SELF_DIR/run_history";

$SELF_DIR/generate_dynamic_exports.sh;
$SELF_DIR/main.sh "$INV_FILE" "$PLAYBOOK" "$LOG_DIR";
