#!/usr/bin/bash

SELF_DIR="$(dirname $(readlink -f $0))";
INV_FILE="$SELF_DIR/nfs_client_hosts";
PLAYBOOK='update_nfs_cli_playbook.yml';
LOG_DIR="$SELF_DIR/run_history";
GEN_DYN_MOUNT_RUN_TYPE="before_update"; # for generate unmount tasks
PLAYBOOK_NEXT="dynamic_playbooks/dynamic_loader.yml"; # for remount after update

$SELF_DIR/main.sh "$INV_FILE" "$PLAYBOOK" "$LOG_DIR" "$GEN_DYN_MOUNT_RUN_TYPE" "$PLAYBOOK_NEXT";
