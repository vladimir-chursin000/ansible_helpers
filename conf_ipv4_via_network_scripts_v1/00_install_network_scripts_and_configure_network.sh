#!/usr/bin/bash

######DEFAULT INPUT VARS (for main.sh)
# Do not change this variables manually
SELF_DIR="$(dirname $(readlink -f $0))";
INV_FILE="$SELF_DIR/conf_network_scripts_hosts";
PLAYBOOK='full_install_network_scripts_and_configure_network_playbook.yml';
LOG_DIR="$SELF_DIR/run_history";
PLAYBOOK_BEFORE='ifcfg_backup_playbook.yml';
GEN_DYN_IFCFG_RUN='yes';
######DEFAULT INPUT VARS

######VARS
TMP_VAR_str='';
######VARS

######READ ARGV array
for TMP_VAR_str in "$@"
do
    if [[ "$TMP_VAR_str" =~ ^"limit=" ]]; then
        # possible argv values: host_name, "host_name1,host_name2,..." (host names from inventory = "conf_network_scripts_hosts"),
            # group name from "00_conf_divisions_for_inv_hosts" (for example, gr_some_group).
        INV_LIMIT_str=$(echo $TMP_VAR_str | sed s/^"limit="//);
    fi;
done;
######READ ARGV array

$SELF_DIR/main.sh "$INV_FILE" "$PLAYBOOK" "$LOG_DIR" "$PLAYBOOK_BEFORE" "$GEN_DYN_IFCFG_RUN";
