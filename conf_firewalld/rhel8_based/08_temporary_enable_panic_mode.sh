#!/usr/bin/bash

# Do not change this variables
SELF_DIR_str="$(dirname $(readlink -f $0))";
INV_LIMIT_str='no';
PLAYBOOK_str='08_temporary_enable_panic_mode_pb.yml';
LOG_DIR_str="$SELF_DIR_str/run_history";
PLAYBOOK_BEFORE_str='no'; #for run before script 'generate_dynamic_fwrules.pl' and/or PLAYBOOK
GEN_DYN_FWRULES_RUN_str='no';
TIMEOUT_str='1';

###VARS
TMP_VAR_str='';
###VARS

###READ ARGV array
for TMP_VAR_str in "$@"
do
    if [[ "$TMP_VAR_str" =~ ^"limit=" ]]; then
	INV_LIMIT_str=$(echo $TMP_VAR_str | sed s/^"limit="//);
    elif [[ "$TMP_VAR_str" =~ ^"timeout=" ]]; then
	TIMEOUT_str=$(echo $TMP_VAR_str | sed s/^"timeout="//);
    fi;
done;
###READ ARGV array

mkdir -p "$SELF_DIR_str/playbooks/tmp_vars";

echo $TIMEOUT_str > "$SELF_DIR_str/playbooks/tmp_vars/panic_timeout";

$SELF_DIR_str/main.sh "$INV_LIMIT_str" "$PLAYBOOK_str" "$LOG_DIR_str" "$PLAYBOOK_BEFORE_str" "$GEN_DYN_FWRULES_RUN_str";

rm -rf "$SELF_DIR_str/playbooks/tmp_vars";
