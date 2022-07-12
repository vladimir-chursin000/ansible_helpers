#!/usr/bin/bash

#FOR APPLY NEW MOUNTS change CONFIG = 'dyn_mount_config'

SELF_DIR="$(dirname $(readlink -f $0))";
INV_FILE="$SELF_DIR/nfs_client_hosts";
PLAYBOOK='dynamic_playbooks/dynamic_loader.yml';
LOG_DIR="$SELF_DIR/run_history";
GEN_DYN_MOUNT_RUN_TYPE="just_run";
PLAYBOOK_NEXT="no";

$SELF_DIR/main.sh "$INV_FILE" "$PLAYBOOK" "$LOG_DIR" "$GEN_DYN_MOUNT_RUN_TYPE" "$PLAYBOOK_NEXT";
