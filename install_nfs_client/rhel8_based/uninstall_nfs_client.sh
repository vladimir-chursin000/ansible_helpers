#!/usr/bin/bash

SELF_DIR="$(dirname $(readlink -f $0))";
INV_FILE="$SELF_DIR/nfs_client_hosts";
PLAYBOOK='full_uninstall_nfs_cli_playbook.yml';
LOG_DIR="$SELF_DIR/run_history";
GEN_DYN_MOUNT_RUN_TYPE="before_remove";
PLAYBOOK_NEXT="no";

$SELF_DIR/main.sh "$INV_FILE" "$PLAYBOOK" "$LOG_DIR" "$GEN_DYN_MOUNT_RUN_TYPE" "$PLAYBOOK_NEXT";
