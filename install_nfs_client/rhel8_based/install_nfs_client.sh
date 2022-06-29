#!/usr/bin/bash

SELF_DIR=`pwd -P`;

ansible-playbook -i "$SELF_DIR/nfs_client_hosts" -u root --private-key=~/.ssh/id_rsa "$SELF_DIR/playbooks/full_install_nfs_cli_playbook.yml";
