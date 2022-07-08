#!/usr/bin/bash

#FOR APPLY NEW MOUNTS change CONFIG = 'dyn_mount_config'

SELF_DIR="$(dirname $(readlink -f $0))";
INV_FILE="$SELF_DIR/nfs_client_hosts";
PLAYBOOK='dynamic_playbooks/dynamic_loader.yml';
LOG_DIR="$SELF_DIR/run_history";

$SELF_DIR/generate_dynamic_mount_playbooks.sh;
$SELF_DIR/main.sh "$INV_FILE" "$PLAYBOOK" "$LOG_DIR";
