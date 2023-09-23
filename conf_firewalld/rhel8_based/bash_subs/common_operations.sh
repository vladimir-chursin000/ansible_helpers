function check_inv_limit_func() {
    local local_inv_limit_str=$1;
    
    local local_result_str='ok';
    
    if [[ "$local_inv_limit_str" =~ "all" && "$local_inv_limit_str" != "all" ]]; then
	# if INV_LIMIT contains 'all', but not eq 'all' -> exit!
	local_result_str="fail. INV_LIMIT not eq 'all'. Exit!";
    elif [[ "$local_inv_limit_str" =~ "gr_" && "$local_inv_limit_str" =~ "," ]]; then
	# if INV_LIMIT contains 'gr_', but also contains ',' -> exit!
	local_result_str="fail. INV_LIMIT contains 'gr_', but also contains ','. Exit!";
    fi;
    
    echo $local_result_str;
}

function check_ipset_tmplt_name_func() {
    local local_ipset_tmplt_name_str=$1;
    local local_conf_ipset_templates_fpath_str=$2;
    
    local local_exec_res_str='';
    local local_result_str='ok';
    
    local_exec_res_str=$(grep "\[$local_ipset_tmplt_name_str:BEGIN\]" $local_conf_ipset_templates_fpath_str | grep -v "#" | wc -l);
    
    if [[ "$local_exec_res_str" -ne "1" ]]; then
	local_result_str="fail. TMPLT_NAME='$local_ipset_tmplt_name_str' not configured at '$local_conf_ipset_templates_fpath_str'";
    fi;
    
    echo $local_result_str;
}

function is_ipset_tmplt_configured_at_66_func() {
    local local_inv_limit_str=$1;
}

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
