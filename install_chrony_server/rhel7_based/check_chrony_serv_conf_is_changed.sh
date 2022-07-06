#!/usr/bin/bash

SELF_DIR="$(dirname $(readlink -f $0))";

ansible-playbook -i "$SELF_DIR/chrony_server_hosts" -u root --private-key=~/.ssh/id_rsa "$SELF_DIR/playbooks/check_chrony_serv_conf_is_changed_playbook.yml";
