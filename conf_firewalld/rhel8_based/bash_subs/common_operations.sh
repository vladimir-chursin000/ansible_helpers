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
    
    echo $local_result_str;
}


#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
