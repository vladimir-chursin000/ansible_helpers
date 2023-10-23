#!/usr/bin/bash

SELF_DIR_str="$(dirname $(readlink -f $0))";

INVENTORY_DIR_str="$SELF_DIR_str/..";

INVENTORY_FILE_str="$INVENTORY_DIR_str/inventory";

ansible-playbook -i $INVENTORY_FILE_str -u root --private-key=~/.ssh/id_rsa "$INVENTORY_DIR_str/02_playbooks/example_playbook.yml" --extra-vars "@$SELF_DIR_str/example_bash_script-vars.json";
