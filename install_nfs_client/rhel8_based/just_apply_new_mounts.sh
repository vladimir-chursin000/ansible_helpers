#!/usr/bin/bash

#FOR APPLY NEW MOUNTS change CONFIG = 'dyn_mount_config'

SELF_DIR="$(dirname $(readlink -f $0))";

$SELF_DIR/generate_dynamic_mount_playbooks.sh;

ansible-playbook -i "$SELF_DIR/nfs_client_hosts" -u root --private-key=~/.ssh/id_rsa "$SELF_DIR/playbooks/dynamic_playbooks/dynamic_loader.yml";
