#!/usr/bin/bash

###DEFAULT INPUT VARS (for main.sh)
# Do not change this variables manually
SELF_DIR_str="$(dirname $(readlink -f $0))";
INV_LIMIT_str='no';
PLAYBOOK_str='03_IMPORT_fwrules_apply_immediately_pb.yml'; # def
LOG_DIR_str="$SELF_DIR_str/run_history";
PLAYBOOK_BEFORE_str='no'; #for run before script 'generate_dynamic_fwrules.pl' and/or PLAYBOOK
GEN_DYN_FWRULES_RUN_str='yes'; # def
###DEFAULT INPUT VARS

###VARS
TMP_VAR_str='';
###VARS

###IMPORT FUNCTIONS
source "$SELF_DIR_str/bash_subs/common_operations.sh";
###IMPORT FUNCTIONS

###READ ARGV array
for TMP_VAR_str in "$@"
do
    if [[ "$TMP_VAR_str" =~ ^"limit=" ]]; then
        # possible argv values: host_name, "host_name1,host_name2,..." (host names from inventory = "conf_firewall_hosts"),
            # group name from "00_conf_divisions_for_inv_hosts" (for example, gr_some_group).
	# special value = "all" (only for '04_add_ipset_entry.sh' and '05_del_ipset_entry.sh').
        INV_LIMIT_str=$(echo $TMP_VAR_str | sed s/^"limit="//);
    fi;
done;
###READ ARGV array

###CORRECT DEFAULT INPUT VARS (if need)
###CORRECT DEFAULT INPUT VARS

$SELF_DIR_str/main.sh "$INV_LIMIT_str" "$PLAYBOOK_str" "$LOG_DIR_str" "$PLAYBOOK_BEFORE_str" "$GEN_DYN_FWRULES_RUN_str";
