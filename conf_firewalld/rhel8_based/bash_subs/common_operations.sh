function check_inv_limit_func() {
    local local_inv_limit_str=$1;
    local local_inv_file_path_str=$2;
    local local_conf_divisions_fpath_str=$3;
    
    local local_inv_limit_type_str='all';
    local local_exec_res_str='';
    local local_inv_limit_arr=();
    local local_arr_el0_str='';
    local local_result_str='ok';
    
    # check for 'all' and 'gr_'
    if [[ "$local_inv_limit_str" =~ "all" && "$local_inv_limit_str" != "all" ]]; then
	# if INV_LIMIT contains 'all', but not eq 'all' -> exit!
	local_result_str="fail. INV_LIMIT not eq 'all'. Exit!";
    elif [[ "$local_inv_limit_str" =~ "gr_" && "$local_inv_limit_str" =~ "," ]]; then
	# if INV_LIMIT contains 'gr_', but also contains ',' -> exit!
	local_result_str="fail. INV_LIMIT contains 'gr_', but also contains ','. Exit!";
    fi;
    #
    
    # detect 'local_inv_limit_type_str'
    if [[ "$local_inv_limit_str" =~ ^"gr_" && "$local_inv_limit_str" != "all" ]]; then
	# if limit = some group from 'local_conf_divisions_fpath_str'
	local_inv_limit_type_str='group';
    elif [[ ! "$local_inv_limit_str" =~ ^"gr_" && "$local_inv_limit_str" != "all" ]]; then
	# if limit = list of hosts or single host
	local_inv_limit_type_str='host_list';
    fi;
    #
    
    # check inv-limit if 'inv-limit-type=group' or 'inv-limit-type=group'
    if [[ "$local_inv_limit_type_str" == "group" ]]; then
	# check for "is exists group at 'local_conf_divisions_fpath_str'"
	local_exec_res_str=$(grep "$local_inv_limit_str" "$local_conf_divisions_fpath_str" | grep -v "^#" | wc -l);
	if [[ "$local_exec_res_str" -lt "1" ]]; then
    	    local_result_str="fail. GROUP='$local_inv_limit_str' is not configured at '$local_conf_divisions_fpath_str'";
	fi;
    elif [[ "$local_inv_limit_type_str" == "host_list" ]]; then
	# check for "is exists hosts at 'local_inv_file_path_str'"
	local_inv_limit_arr=($(echo "$local_inv_limit_str" | sed 's/,/\n/g'));

	for local_arr_el0_str in "${local_inv_limit_arr[@]}"
	do
	    local_exec_res_str=$(grep "$local_arr_el0_str" "$local_inv_file_path_str" | grep -v "^#" | wc -l);
	    if [[ "$local_exec_res_str" -lt "1" ]]; then
    		local_result_str="fail. Host='$local_arr_el0_str' is not exists at inventory '$local_inv_file_path_str'";
		break;
	    fi;
	done;
    fi;
    #

    echo $local_result_str;
}

function check_ipset_tmplt_name_func() {
    local local_ipset_tmplt_name_str=$1;
    local local_conf_ipset_templates_fpath_str=$2;
    
    local local_exec_res_str='';
    local local_result_str='ok';
    
    local_exec_res_str=$(grep "\[$local_ipset_tmplt_name_str:BEGIN\]" "$local_conf_ipset_templates_fpath_str" | grep -v "^#" | wc -l);
    if [[ "$local_exec_res_str" -lt "1" ]]; then
	local_result_str="fail. TMPLT_NAME='$local_ipset_tmplt_name_str' not configured at '$local_conf_ipset_templates_fpath_str'";
    fi;
    
    echo $local_result_str;
}

function is_ipset_tmplt_configured_at_66_func() {
    local local_inv_limit_str=$1;
    local local_ipset_tmplt_name_str=$2;
    local local_conf_ipset_66_fpath_str=$3;
    
    local local_inv_limit_type_str='all';
    local local_exec_res_str='';
    local local_inv_limit_arr=();
    local local_host_list_case_str='';
	# '0' - not configured at '66'
	# '1' - inv-host+tmplt configured for inv-host at '66'
	# '2' - inv-host+tmplt configured for group at '66'
	# '3' - inv-host+tmplt configured for all at '66'
    local local_result_str='ok';

    # detect 'local_inv_limit_type_str'
    if [[ "$local_inv_limit_str" =~ ^"gr_" && "$local_inv_limit_str" != "all" ]]; then
	# if limit = some group from 'local_conf_divisions_fpath_str'
	local_inv_limit_type_str='group';
    elif [[ ! "$local_inv_limit_str" =~ ^"gr_" && "$local_inv_limit_str" != "all" ]]; then
	# if limit = list of hosts or single host
	local_inv_limit_type_str='host_list';
    fi;
    #

    # check inv-limit is conf at 'local_conf_ipset_66_fpath_str'
    if [[ "$local_inv_limit_type_str" == "group" ]]; then
	# check for "is configured group at 'local_conf_ipset_66_fpath_str' for tmplt"
	local_exec_res_str=$(grep "$local_inv_limit_str" | grep "$local_ipset_tmplt_name_str" | grep -v "^#" | wc -l);
	if [[ "$local_exec_res_str" -lt "1" ]]; then
	    local_result_str="fail. TMPLT_NAME='$local_ipset_tmplt_name_str' is not configured for INV_LIMIT='$local_inv_limit_str' at '66_conf_ipsets_FIN'";
	fi;
    elif [[ "$local_inv_limit_type_str" == "host_list" ]]; then
	# check for "is configured single hosts at 'local_conf_ipset_66_fpath_str' for tmplt"
	local_inv_limit_arr=($(echo "$local_inv_limit_str" | sed 's/,/\n/g'));

	for local_arr_el0_str in "${local_inv_limit_arr[@]}"
        do
	    echo 'tst-tmp';
        done;

    elif [[ "$local_inv_limit_type_str" == "all" ]]; then
	# check for "is configured 'all' at 'local_conf_ipset_66_fpath_str' for tmplt"
	local_exec_res_str=$(grep "all" | grep "$local_ipset_tmplt_name_str" | grep -v "^#" | wc -l);
	if [[ "$local_exec_res_str" -lt "1" ]]; then
	    local_result_str="fail. TMPLT_NAME='$local_ipset_tmplt_name_str' is not configured for INV_LIMIT='all' at '66_conf_ipsets_FIN'";
	fi;
    fi;
    #

    echo $local_result_str;
}

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
