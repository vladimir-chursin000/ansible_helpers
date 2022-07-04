#!/usr/bin/bash

SELF_DIR="$(dirname $(readlink -f $0))";

$SELF_DIR/generate_dynamic_exports.sh;

ansible-playbook -i "$SELF_DIR/nfs_server_hosts" -u root --private-key=~/.ssh/id_rsa "$SELF_DIR/playbooks/full_install_nfs_serv_playbook.yml";
