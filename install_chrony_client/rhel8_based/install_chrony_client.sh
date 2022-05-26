#!/usr/bin/bash

SELF_DIR=`pwd -P`;

ansible-playbook -i "$SELF_DIR/chrony_client_hosts" -u root --private-key=~/.ssh/id_rsa "$SELF_DIR/install_chrony_cli_playbook.yml";
