#!/usr/bin/bash

SELF_DIR="$(dirname $(readlink -f $0))";

ansible-playbook -i "$SELF_DIR/nfs_server_hosts" -u root --private-key=~/.ssh/id_rsa "$SELF_DIR/playbooks/check_nfs_serv_exports_is_changed_playbook.yml";
