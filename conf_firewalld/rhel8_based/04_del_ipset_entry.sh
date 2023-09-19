#!/usr/bin/bash

###DEFAULT INPUT VARS (for main.sh)
# Do not change this variables manually
SELF_DIR_str="$(dirname $(readlink -f $0))";
INV_LIMIT_str='all'; # only for '04_add_ipset_entry.sh' or '04_del_ipset_entry.sh'
PLAYBOOK_str='03_IMPORT_fwrules_apply_immediately_pb.yml'; # def
LOG_DIR_str="$SELF_DIR_str/run_history";
PLAYBOOK_BEFORE_str='02_fwrules_backup_pb.yml'; #for run before script 'generate_dynamic_fwrules.pl' and/or PLAYBOOK
GEN_DYN_FWRULES_RUN_str='yes'; # def
###DEFAULT INPUT VARS

###STATIC VARS
OPERATION_str='del';
###STATIC VARS

###VARS
TMP_VAR_str='';
IPSET_TMPLT_NAME_str='no';
IPSET_LIST_str='no';
NEED_ROLLBACK_str='no';

declare -a INV_LIMIT_arr;

NOW_DT_str=`date '+%Y%m%d%H%M%S'`;
CUR_USER_str=`id -u -n`;
LOG_FILE_str="$LOG_DIR_str/$NOW_DT_str-$CUR_USER_str.log";
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
	# special value = "all" (only for '04_add_ipset_entry.sh' and '04_del_ipset_entry.sh').
        INV_LIMIT_str=$(echo $TMP_VAR_str | sed s/^"limit="//);
    elif [[ "$TMP_VAR_str" =~ ^"ipset_tmplt_name=" ]]; then
        IPSET_TMPLT_NAME_str=$(echo $TMP_VAR_str | sed s/^"ipset_tmplt_name="//);
    elif [[ "$TMP_VAR_str" =~ ^"ipset_list=" ]]; then
        IPSET_LIST_str=$(echo $TMP_VAR_str | sed s/^"ipset_list="//);
    elif [[ "$TMP_VAR_str" =~ ^"rollback=" ]]; then
	# possible values: no, yes
        NEED_ROLLBACK_str=$(echo $TMP_VAR_str | sed s/^"rollback="//);
    fi;
done;
###READ ARGV array

###CORRECT DEFAULT INPUT VARS (if need)
if [[ "$NEED_ROLLBACK_str" == "yes" ]]; then
    PLAYBOOK_str='03_IMPORT_fwrules_apply_temporary_pb.yml';
    GEN_DYN_FWRULES_RUN_str='yes_with_rollback';
fi;
###CORRECT DEFAULT INPUT VARS

###CHECK INPUT VARS
###CHECK INPUT VARS

###CREATE INPUT FILE for DEL (at dir '02_ipset_input')
INV_LIMIT_arr=($(echo "$INV_LIMIT_str" | sed 's/,/\n/g'));
###CREATE INPUT FILE for DEL

exit; # for test

$SELF_DIR_str/main.sh "$INV_LIMIT_str" "$PLAYBOOK_str" "$LOG_DIR_str" "$PLAYBOOK_BEFORE_str" "$GEN_DYN_FWRULES_RUN_str";
