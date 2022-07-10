#!/usr/bin/bash

SELF_DIR="$(dirname $(readlink -f $0))";
INV_FILE="$SELF_DIR/nfs_client_hosts";
PLAYBOOK='full_uninstall_nfs_cli_playbook.yml';
LOG_DIR="$SELF_DIR/run_history";

$SELF_DIR/generate_dynamic_mount_playbooks.sh "before_remove";
$SELF_DIR/main.sh "$INV_FILE" "$PLAYBOOK" "$LOG_DIR";
