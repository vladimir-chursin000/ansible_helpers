#!/usr/bin/bash

SELF_DIR=`pwd -P`;

ansible-playbook -i "$SELF_DIR/nfs_server_hosts" -u root --private-key=~/.ssh/id_rsa "$SELF_DIR/check_nfs_serv_conf_is_changed_playbook.yml";
