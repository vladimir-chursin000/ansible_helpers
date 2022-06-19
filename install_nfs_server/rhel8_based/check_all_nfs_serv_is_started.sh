#!/usr/bin/bash

SELF_DIR=`pwd -P`;

ansible-playbook -i "$SELF_DIR/nfs_server_hosts" -u root --private-key=~/.ssh/id_rsa "$SELF_DIR/playbooks/check_all_nfs_serv_is_started_playbook.yml";
