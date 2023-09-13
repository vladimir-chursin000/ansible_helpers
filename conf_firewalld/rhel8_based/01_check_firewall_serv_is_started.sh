#!/usr/bin/bash

###DEFAULT INPUT VARS (for main.sh)
# Do not change this variables manually
SELF_DIR_str="$(dirname $(readlink -f $0))";
INV_LIMIT_str='no';
PLAYBOOK_str='01_check_firewall_serv_is_started_pb.yml';
LOG_DIR_str="$SELF_DIR_str/run_history";
PLAYBOOK_BEFORE_str='no'; #for run before script 'generate_dynamic_fwrules.pl' and/or PLAYBOOK
GEN_DYN_FWRULES_RUN_str='no';
###DEFAULT INPUT VARS

###VARS
TMP_VAR_str='';
###VARS

###READ ARGV array
for TMP_VAR_str in "$@"
do
    if [[ "$TMP_VAR_str" =~ ^"limit=" ]]; then
        INV_LIMIT_str=$(echo $TMP_VAR_str | sed s/^"limit="//);
    fi;
done;
###READ ARGV array

$SELF_DIR_str/main.sh "$INV_LIMIT_str" "$PLAYBOOK_str" "$LOG_DIR_str" "$PLAYBOOK_BEFORE_str" "$GEN_DYN_FWRULES_RUN_str";
