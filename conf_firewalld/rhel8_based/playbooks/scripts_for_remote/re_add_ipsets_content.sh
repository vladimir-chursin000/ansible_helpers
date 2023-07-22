#!/usr/bin/bash

###GENERATED BY ansible_helpers/conf_firewalld (https://github.com/vladimir-chursin000/ansible_helpers)

SELF_DIR_str="$(dirname $(readlink -f $0))";

######VARS
OPERATION_IPSET_TYPE_str=$1;
#
CONTENT_DIR_str='no';
PREV_CONTENT_DIR_str='no';
#
LIST_FILE_str='no';
PREV_LIST_FILE_str='no';
#
NO_LIST_FILE_str='no';
PREV_NO_LIST_FILE_str='no';
#
###
MAIN_SCENARIO_str='no';
# possible values: delete_all (delete all entries for all ipsets), re_add (delete all entries for all ipsets and add new entries), 
######VARS

######MAIN
if [[ "$OPERATION_IPSET_TYPE_str" == "permanent" ]]; then
    CONTENT_DIR_str="$SELF_DIR_str/permanent_ipsets";
    PREV_CONTENT_DIR_str="$SELF_DIR_str/prev_permanent_ipsets";
elif [[ "$OPERATION_IPSET_TYPE_str" == "temporary" ]]; then
    CONTENT_DIR_str="$SELF_DIR_str/temporary_ipsets";
    PREV_CONTENT_DIR_str="$SELF_DIR_str/prev_temporary_ipsets";
fi;

LIST_FILE_str="$CONTENT_DIR_str/LIST";
PREV_LIST_FILE_str="$PREV_CONTENT_DIR_str/LIST";

NO_LIST_FILE_str="$CONTENT_DIR_str/NO_LIST";
PREV_NO_LIST_FILE_str="$PREV_CONTENT_DIR_str/NO_LIST";

if [[ -f "$NO_LIST_FILE_str" ]] && [[ "$OPERATION_IPSET_TYPE_str" == "permanent" ]]; then
    # Delete all entries for all ipsets
    echo 'Delete all ipset entries if exists!' > $NO_LIST_FILE_str;
    MAIN_SCENARIO_str='delete_all';
if [[ -f "$NO_LIST_FILE_str" ]] && [[ "$OPERATION_IPSET_TYPE_str" == "temporary" ]]; then
    # Delete all entries for all ipsets
    echo 'Delete all ipset entries if exists!' > $NO_LIST_FILE_str;
    MAIN_SCENARIO_str='delete_all';
elif [[ -f "$LIST_FILE_str" ]] && [[ "$OPERATION_IPSET_TYPE_str" == "permanent" ]]; then
    # Delete all entries for all ipsets and add new entries
    MAIN_SCENARIO_str='re_add';
elif [[ -f "$LIST_FILE_str" ]] && [[ "$OPERATION_IPSET_TYPE_str" == "temporary" ]]; then
    # Delete all entries for all ipsets and add new entries
    MAIN_SCENARIO_str='re_add';
fi;
######MAIN
