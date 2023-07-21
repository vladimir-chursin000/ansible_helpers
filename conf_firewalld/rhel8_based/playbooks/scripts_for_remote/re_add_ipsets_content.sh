#!/usr/bin/bash

###GENERATED BY ansible_helpers/conf_firewalld (https://github.com/vladimir-chursin000/ansible_helpers)

SELF_DIR_str="$(dirname $(readlink -f $0))";

###VARS
OPERATION_IPSET_TYPE_str=$1;
CONTENT_DIR_str='no';
PREV_CONTENT_DIR_str='no';
###VARS

###MAIN
if [[ "$OPERATION_IPSET_TYPE_str" == "permanent" ]]; then
    CONTENT_DIR_str="$SELF_DIR_str/permanent_ipsets";
    PREV_CONTENT_DIR_str="$SELF_DIR_str/prev_permanent_ipsets";
elif [[ "$OPERATION_IPSET_TYPE_str" == "temporary" ]]; then
    CONTENT_DIR_str="$SELF_DIR_str/temporary_ipsets";
    PREV_CONTENT_DIR_str="$SELF_DIR_str/prev_temporary_ipsets";
fi;
###MAIN