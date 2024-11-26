sub read_04_conf_remote_backend {
    my ($file_l,$inv_hosts_href_l,$divisions_for_inv_hosts_href_l,$res_href_l)=@_;
    #$file_l=$f04_conf_remote_backend_path_g
    #inv_hosts_href_l=hash-ref for %inventory_hosts_g
    #$divisions_for_inv_hosts_href_l=hash-ref for %h00_conf_divisions_for_inv_hosts_hash_g
        #$h00_conf_divisions_for_inv_hosts_hash_g{group-name}{inv-host}=1;
    #$res_href_l=hash ref for %h04_conf_remote_backend_hash_g
        #Key=inv_host, value=network-scripts/NetworkManager
    ###############
    
    my $proc_name_l=(caller(0))[3];
        
    my ($exec_res_l)=(undef);
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my $return_str_l='OK';
    
    my %res_tmp_lv0_l=();
    	#key=inv-host, value=['network-scripts/NetworkManager'] #array with one element
    my %res_tmp_lv1_l=(); # result hash
        #key=inv_host, value='network-scripts/NetworkManager'
    
    $exec_res_l=&read_conf_lines_with_priority_by_first_param($file_l,$inv_hosts_href_l,$divisions_for_inv_hosts_href_l,2,0,\%res_tmp_lv0_l);
    #$file_l,$inv_hosts_href_l,$divisions_for_inv_hosts_href_l,$needed_elements_at_line_arr_l,$add_ind4key_l,$res_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }
    $exec_res_l=undef;
    
    # check %res_tmp_lv0_l and fill %res_tmp_lv1_l (begin)
    while ( ($hkey0_l,$hval0_l)=each %res_tmp_lv0_l ) {
	#hkey0_l=inv-host, hval0_l=['network-scripts/NetworkManager']
	
	if ( ${$hval0_l}[0]!~/^network\-scripts$|^NetworkManager$/ ) {
	    $return_str_l="fail [$proc_name_l]. Incorrect REMOTE_BACKEND='${$hval0_l}[0]'. Possible values: network-scripts, NetworkManager. Fix it!";
	    last;
	}
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