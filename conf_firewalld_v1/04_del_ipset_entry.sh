#!/usr/bin/bash

######DEFAULT INPUT VARS (for main.sh)
# Do not change this variables manually
SELF_DIR_str="$(dirname $(readlink -f $0))";
INV_LIMIT_str='all'; # only for '04_add_ipset_entry.sh' or '04_del_ipset_entry.sh'
PLAYBOOK_str='03_IMPORT_fwrules_apply_immediately_pb.yml'; # def
LOG_DIR_str="$SELF_DIR_str/run_history";
PLAYBOOK_BEFORE_str='02_fwrules_backup_pb.yml'; #for run before script 'generate_dynamic_fwrules.pl' and/or PLAYBOOK
GEN_DYN_FWRULES_RUN_str='yes'; # def
######DEFAULT INPUT VARS

######STATIC VARS
OPERATION_str='del';
IPSET_INPUT_DIR_str="$SELF_DIR_str/02_ipset_input";
INV_FILE_PATH_str="$SELF_DIR_str/conf_firewall_hosts";
CONF_DIVISIONS_PATH_str="$SELF_DIR_str/01_fwrules_configs/00_conf_divisions_for_inv_hosts";
CONF_IPSETS_TEMPLATES_PATH_str="$SELF_DIR_str/01_fwrules_configs/01_conf_ipset_templates";
CONF_IPSETS_FIN_PATH_str="$SELF_DIR_str/01_fwrules_configs/66_conf_ipsets_FIN";
######STATIC VARS

######VARS
TMP_VAR_str='';
EXEC_RES_str='';
IPSET_TMPLT_NAME_str='no';
IPSET_LIST_str='no';
IPSETS_EXPIRE_DT_str='no';
NEED_ROLLBACK_str='no';

declare -a INV_LIMIT_arr;

NOW_DT_str=`date '+%Y%m%d%H%M%S'`;
CUR_USER_str=`id -u -n`;
LOG_FILE_str="$LOG_DIR_str/$NOW_DT_str-$CUR_USER_str.log";
######VARS

######CREATE LOG_DIR
/usr/bin/mkdir -p "$LOG_DIR_str";
######CREATE LOG_DIR

######IMPORT FUNCTIONS
source "$SELF_DIR_str/bash_subs/common_operations.sh";
######IMPORT FUNCTIONS

######READ ARGV array
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
    elif [[ "$TMP_VAR_str" =~ ^"expire_dt=" ]]; then
        IPSETS_EXPIRE_DT_str=$(echo $TMP_VAR_str | sed s/^"expire_dt="//);
    elif [[ "$TMP_VAR_str" =~ ^"rollback=" ]]; then
	# possible values: no, yes
        NEED_ROLLBACK_str=$(echo $TMP_VAR_str | sed s/^"rollback="//);
    fi;
done;
######READ ARGV array

######CORRECT DEFAULT INPUT VARS (if need)
if [[ "$NEED_ROLLBACK_str" == "yes" ]]; then
    PLAYBOOK_str='03_IMPORT_fwrules_apply_temporary_pb.yml';
    GEN_DYN_FWRULES_RUN_str='yes_with_rollback';
fi;
######CORRECT DEFAULT INPUT VARS

######CHECK INPUT VARS
# check IPSET_LIST_str
if [[ "$IPSET_LIST_str" == "no" ]]; then
    echo "IPSET_LIST is not defined. Exit!";
    exit;
fi;
#

# check INV_LIMIT_str
EXEC_RES_str=$(check_inv_limit_func "$INV_LIMIT_str" "$INV_FILE_PATH_str" "$CONF_DIVISIONS_PATH_str");
if [[ "$EXEC_RES_str" != 'ok' ]]; then
    echo "$EXEC_RES_str" | tee -a $LOG_FILE_str;
    exit;
fi;
EXEC_RES_str=''; # clear
#

# check IPSET_TMPLT_NAME_str
EXEC_RES_str=$(check_ipset_tmplt_name_func "$IPSET_TMPLT_NAME_str" "$CONF_IPSETS_TEMPLATES_PATH_str");
if [[ "$EXEC_RES_str" != 'ok' ]]; then
    echo "$EXEC_RES_str" | tee -a $LOG_FILE_str;
    exit;
fi;
EXEC_RES_str=''; # clear
#

# check IPSET_TMPLT_NAME_str + INV_LIMIT_arr is configured at '66_conf_ipsets_FIN'
EXEC_RES_str=$(is_ipset_tmplt_configured_at_66_func "$INV_LIMIT_str" "$IPSET_TMPLT_NAME_str" "$CONF_DIVISIONS_PATH_str" "$CONF_IPSETS_FIN_PATH_str");
if [[ "$EXEC_RES_str" != 'ok' ]]; then
    echo "$EXEC_RES_str" | tee -a $LOG_FILE_str;
    exit;
fi;
EXEC_RES_str=''; # clear
#

# check IPSETS_EXPIRE_DT_str
EXEC_RES_str=$(check_expire_dt_func "$IPSETS_EXPIRE_DT_str");
if [[ "$EXEC_RES_str" != 'ok' ]]; then
    echo "$EXEC_RES_str" | tee -a $LOG_FILE_str;
    exit;
fi;
EXEC_RES_str=''; # clear
#
######CHECK INPUT VARS

######CREATE INPUT FILE for DEL (at dir '02_ipset_input')
create_input_file_func "$OPERATION_str" "$IPSET_INPUT_DIR_str" "$INV_LIMIT_str" "$IPSET_TMPLT_NAME_str" "$IPSET_LIST_str" "$IPSETS_EXPIRE_DT_str";
######CREATE INPUT FILE for DEL

$SELF_DIR_str/main.sh "$INV_LIMIT_str" "$PLAYBOOK_str" "$LOG_DIR_str" "$PLAYBOOK_BEFORE_str" "$GEN_DYN_FWRULES_RUN_str";
