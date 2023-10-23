#!/usr/bin/bash

SELF_DIR_str="$(dirname $(readlink -f $0))";

INVENTORY_DIR_str="$SELF_DIR_str/..";

INVENTORY_FILE_str="$TST_INFR_ROOT_str/inventory";

ansible-playbook -i $INVENTORY_FILE_str -u root --private-key=~/.ssh/id_rsa "$INVENTORY_DIR_str/01_playbooks/example_playbook.yml" --extra-vars "@example_bash_script-vars.json";
