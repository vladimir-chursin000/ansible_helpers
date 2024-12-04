sub read_06_conf_temp_apply {
    my ($file_l,$inv_hosts_href_l,$divisions_for_inv_hosts_href_l,$res_href_l)=@_;
    #$file_l=$f06_conf_temp_apply_path_g
    #inv_hosts_href_l=hash-ref for %inventory_hosts_g
    #$divisions_for_inv_hosts_href_l=hash-ref for %h00_conf_divisions_for_inv_hosts_hash_g
        #$h00_conf_divisions_for_inv_hosts_hash_g{group-name}{inv-host}=1;
    #$res_href_l=hash ref for %h06_conf_temp_apply_hash_g
        #key=inv_host, value=rollback_timeout
    ###############
    # INVENTORY_HOST = all / list of inventory hosts separated by "," / group name from conf '00_conf_divisions_for_inv_hosts'.
    	# If "all" -> the configuration will be applied to all inventory hosts.
    	# Priority (from lower to higher): all (0), group name from conf '00_conf_divisions_for_inv_hosts' (1),
    	# list of inventory hosts separated by "," or individual hosts (2).
    ###
    # TEMP_APPLY_TIMEOUT - temp apply timeout (in minutes).
    ###
    #INVENTORY_HOST                         #TEMP_APPLY_TIMEOUT
    ###############
    
    my $proc_name_l=(caller(0))[3];
        
    my ($exec_res_l)=(undef);
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my $return_str_l='OK';
    
    my %res_tmp_lv0_l=();
        #key=inv-host, value=['timeout'] #array with one element
    my %res_tmp_lv1_l=(); # result hash
        #key=inv_host, value='timeout'
    
    $exec_res_l=&read_conf_lines_with_priority_by_first_param($file_l,$inv_hosts_href_l,$divisions_for_inv_hosts_href_l,2,0,\%res_tmp_lv0_l);
    #$file_l,$inv_hosts_href_l,$divisions_for_inv_hosts_href_l,$needed_elements_at_line_arr_l,$add_ind4key_l,$res_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }
    $exec_res_l=undef;
    
    # check %res_tmp_lv0_l and fill %res_tmp_lv1_l (begin)
    while ( ($hkey0_l,$hval0_l)=each %res_tmp_lv0_l ) {
    	#key=inv-host, value=['timeout']
    	
        if ( ${$hval0_l}[0]!~/^\d+$/ ) {
            $return_str_l="fail [$proc_name_l]. Incorrect TEMP_APPLY_TIMEOUT='${$hval0_l}[0]' (conf='$file_l'). Fix it!";
            last;
        }
        
        # Fill %res_tmp_lv1_l
        $res_tmp_lv1_l{$hkey0_l}=${$hval0_l}[0];
        ###
    }
    
    # clear vars
    ($hkey0_l,$hval0_l)=(undef,undef);
    ###
    # check %res_tmp_lv0_l and fill %res_tmp_lv1_l (end)
    
    if ( $return_str_l!~/^OK$/ ) { return $return_str_l; }
    
    # fill result hash
    %{$res_href_l}=%res_tmp_lv1_l;
    ###
    
    %res_tmp_lv1_l=();
    
    return $return_str_l;
}

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
