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
    ###
    
    # detect 'local_inv_limit_type_str'
    if [[ "$local_inv_limit_str" =~ ^"gr_" && "$local_inv_limit_str" != "all" ]]; then
	# if limit = some group from 'local_conf_divisions_fpath_str'
	local_inv_limit_type_str='group';
    elif [[ ! "$local_inv_limit_str" =~ ^"gr_" && "$local_inv_limit_str" != "all" ]]; then
	# if limit = list of hosts or single host
	local_inv_limit_type_str='host_list';
    fi;
    ###
    
    # check inv-limit if 'inv-limit-type=group' or 'inv-limit-type=group'
    if [[ "$local_inv_limit_type_str" == "group" ]]; then
	# check for "is exists group at 'local_conf_divisions_fpath_str'"
	local_exec_res_str=$(grep "$local_inv_limit_str" "$local_conf_divisions_fpath_str" | grep -v "^#" | wc -l);
	if [[ "$local_exec_res_str" -lt "1" ]]; then
    	    local_result_str="fail. GROUP='$local_inv_limit_str' is not configured at '00_conf_divisions_for_inv_hosts'";
	fi;
    elif [[ "$local_inv_limit_type_str" == "host_list" ]]; then
	# check for "is exists hosts at 'local_inv_file_path_str'"
	local_inv_limit_arr=($(echo "$local_inv_limit_str" | sed 's/,/\n/g'));

	for local_arr_el0_str in "${local_inv_limit_arr[@]}"; # local_arr_el0_str = inv-host
	do
	    local_exec_res_str=$(grep "$local_arr_el0_str" "$local_inv_file_path_str" | grep -v "^#" | wc -l);
	    if [[ "$local_exec_res_str" -lt "1" ]]; then
    		local_result_str="fail. Host='$local_arr_el0_str' is not exists at inventory 'conf_firewall_hosts'";
		break;
	    fi;
	done;
    fi;
    ###

    echo $local_result_str;
}

function check_ipset_tmplt_name_func() {
    local local_ipset_tmplt_name_str=$1;
    local local_conf_ipset_templates_fpath_str=$2;
    
    local local_exec_res_str='';
    local local_result_str='ok';
    
    local_exec_res_str=$(grep "\[$local_ipset_tmplt_name_str:BEGIN\]" "$local_conf_ipset_templates_fpath_str" | grep -v "^#" | wc -l);
    if [[ "$local_exec_res_str" -lt "1" ]]; then
	local_result_str="fail. TMPLT_NAME='$local_ipset_tmplt_name_str' not configured at '01_conf_ipset_templates'";
    fi;
    
    echo $local_result_str;
}

function is_ipset_tmplt_configured_at_66_func() {
    local local_inv_limit_str=$1;
    local local_ipset_tmplt_name_str=$2;
    local local_conf_divisions_fpath_str=$3;
    local local_conf_ipset_66_fpath_str=$4;
    
    local local_inv_limit_type_str='all';
    local local_exec_res_str='';
    local local_inv_limit_arr=();
    local local_host_list_case_str='';
	# '0' - not configured at '66'
	# '1' - inv-host+tmplt configured for inv-host at '66'
	# '2' - inv-host+tmplt configured for group at '66'
	# '3' - inv-host+tmplt configured for all at '66'
    local local_is_tmplt_for_all_str='';
    local local_get_inv_host_group_str='';
    local local_result_str='ok';

    # detect 'local_inv_limit_type_str'
    if [[ "$local_inv_limit_str" =~ ^"gr_" && "$local_inv_limit_str" != "all" ]]; then
	# if limit = some group from 'local_conf_divisions_fpath_str'
	local_inv_limit_type_str='group';
    elif [[ ! "$local_inv_limit_str" =~ ^"gr_" && "$local_inv_limit_str" != "all" ]]; then
	# if limit = list of hosts or single host
	local_inv_limit_type_str='host_list';
    fi;
    ###

    # check inv-limit is conf at 'local_conf_ipset_66_fpath_str'
    if [[ "$local_inv_limit_type_str" == "group" ]]; then
	# check for "is configured group at 'local_conf_ipset_66_fpath_str' for tmplt"
	local_exec_res_str=$(grep "$local_inv_limit_str" "$local_conf_ipset_66_fpath_str" | grep "$local_ipset_tmplt_name_str" | grep -v "^#" | wc -l);
	if [[ "$local_exec_res_str" -lt "1" ]]; then
	    local_result_str="fail. TMPLT_NAME='$local_ipset_tmplt_name_str' is not configured for INV_LIMIT='$local_inv_limit_str' at '66_conf_ipsets_FIN'";
	fi;
	
	# clear vars
	local_exec_res_str='';
	#
    elif [[ "$local_inv_limit_type_str" == "host_list" ]]; then
    	# check for "is configured single hosts at 'local_conf_ipset_66_fpath_str' for tmplt"
    	local_host_list_case_str='0';
    	
    	local_is_tmplt_for_all_str=$(grep "^all" "$local_conf_ipset_66_fpath_str" | grep "$local_ipset_tmplt_name_str" | grep -v "^#" | wc -l);
    	
    	if [[ "$local_is_tmplt_for_all_str" -ge "1" ]]; then
    	    # if tmplt_name configured for all -> no need to check each inv-host
    	    local_host_list_case_str='3';
    	else
    	    local_inv_limit_arr=($(echo "$local_inv_limit_str" | sed 's/,/\n/g'));
    	    
    	    for local_arr_el0_str in "${local_inv_limit_arr[@]}"; # local_arr_el0_str = inv-host
    	    do
    		local_host_list_case_str='0';
    		
    	    	local_exec_res_str=$(grep "$local_arr_el0_str" "$local_conf_ipset_66_fpath_str" | grep "$local_ipset_tmplt_name_str" | grep -v "^#" | wc -l);
    	    	if [[ "$local_exec_res_str" == "1" ]]; then
    	    	    local_host_list_case_str='1';
    	    	    continue;
    	    	fi;
    		
    		# clear vars
    	    	local_exec_res_str='';
    		#
    	    	
    		local_get_inv_host_group_str=$(grep "$local_arr_el0_str" "$local_conf_divisions_fpath_str" | grep -v "^#" | awk '{print $1;}');
    		
    		if [[ "$local_get_inv_host_group_str" != "" ]]; then
    		    local_exec_res_str=$(grep "$local_get_inv_host_group_str" "$local_conf_ipset_66_fpath_str" | grep -v "^#" | wc -l);
    		    if [[ "$local_exec_res_str" == "1" ]]; then
    		    	local_host_list_case_str='2';
            	    	continue;
    		    fi;
    
    		    # clear vars
    	    	    local_exec_res_str='';
    		    #
    		fi;
    		
    		if [[ "$local_host_list_case_str" == "0" ]]; then
    		    local_result_str="fail. INV-HOST='$local_arr_el0_str' is not configured at '66_conf_ipsets_FIN' directly / via 'all' or group (at '00_conf_divisions_for_inv_hosts')";
    		    break;
    		fi;
    		
    	    	# clear vars
    	    	local_exec_res_str='';
    		local_get_inv_host_group_str='';
    	    	#
    	    done;
    	    
    	    # clear vars
    	    local_inv_limit_arr=();
    	    #
    	fi;
    elif [[ "$local_inv_limit_type_str" == "all" ]]; then
	# check for "is configured 'all' at 'local_conf_ipset_66_fpath_str' for tmplt"
	local_exec_res_str=$(grep "all" "$local_conf_ipset_66_fpath_str" | grep "$local_ipset_tmplt_name_str" | grep -v "^#" | wc -l);
	if [[ "$local_exec_res_str" -lt "1" ]]; then
	    local_result_str="fail. TMPLT_NAME='$local_ipset_tmplt_name_str' is not configured for INV_LIMIT='all' at '66_conf_ipsets_FIN'";
	fi;
	
	# clear vars
	local_exec_res_str='';
	#
    fi;
    ###

    echo $local_result_str;
}

function check_expire_dt_func() {
    local local_dt=$1;
    
    local local_result_str='ok';
    
    echo $local_result_str;
}

function create_input_file_func() {
    local local_operation_str=$1;
    local local_ipset_input_dir_str=$2;
    local local_inv_limit_str=$3;
    local local_ipset_tmplt_name_str=$4;
    local local_ipset_list_str=$5;
    local local_ipsets_expire_dt_str=$6;

    local local_arr_el0_str='';
    local local_arr_el1_str='';
    local local_inv_limit_arr=();
    local local_ipset_list_arr=();

    local_inv_limit_arr=($(echo "$local_inv_limit_str" | sed 's/,/\n/g'));
    local_ipset_list_arr=($(echo "$local_ipset_list_str" | sed 's/,/\n/g'));
}

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
