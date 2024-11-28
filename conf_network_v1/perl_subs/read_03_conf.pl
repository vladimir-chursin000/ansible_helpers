sub read_03_conf_routes {
    my ($file_l,$inv_hosts_href_l,$divisions_for_inv_hosts_href_l,$res_href_l)=@_;
    #$file_l=$f03_conf_routes_path_g
    #inv_hosts_href_l=hash-ref for %inventory_hosts_g
    #$divisions_for_inv_hosts_href_l=hash-ref for %h00_conf_divisions_for_inv_hosts_hash_g
        #$h00_conf_divisions_for_inv_hosts_hash_g{group-name}{inv-host}=1;
    #$res_href_l=hash ref for %h03_conf_routes_hash_g
    	#key=inv-host, value=[array of routes]
    ###############
    # INVENTORY_HOST = all / list of inventory hosts separated by "," / group name from conf '00_conf_divisions_for_inv_hosts'.
    	# If "all" -> the configuration will be applied to all inventory hosts.
        # Priority (from lower to higher): all (0), group name from conf '00_conf_divisions_for_inv_hosts' (1),
        # list of inventory hosts separated by "," or individual hosts (2).
    ###
    # LIST_OF_ROUTES - list of routes separated by ";". Format for one route = "IP/SUBNET-addr,PREFIX,GW,METRIC".
    ###
    #INVENTORY_HOST                 #LIST_OF_ROUTES
    ###############
    
    my $proc_name_l=(caller(0))[3];
        
    my ($exec_res_l)=(undef);
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my ($arr_el0_l)=(undef);
    my ($ip_addr_l,$gw_l,$prefix_l,$metric_l)=(undef,undef,undef,undef);
    my @routes_arr_l=();
    my @one_route_arr_l=();
    my $return_str_l='OK';
    
    my %res_tmp_lv0_l=();
    	#key=inv-host, value=[list-of-routes(via ';')] (array with one element)
    my %res_tmp_lv1_l=(); # result hash
        #key=inv_host, value=[array of routes]. Route='IP/SUBNET-addr,GW,PREFIX,METRIC'
    
    $exec_res_l=&read_conf_lines_with_priority_by_first_param($file_l,$inv_hosts_href_l,$divisions_for_inv_hosts_href_l,2,0,\%res_tmp_lv0_l);
    #$file_l,$inv_hosts_href_l,$divisions_for_inv_hosts_href_l,$needed_elements_at_line_arr_l,$add_ind4key_l,$res_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }
    $exec_res_l=undef;
    
    # check %res_tmp_lv0_l and fill %res_tmp_lv1_l (begin)
    while ( ($hkey0_l,$hval0_l)=each %res_tmp_lv0_l ) {
	#hkey0_l=inv-host, hval0_l=[list-of-routes(via ';')] (array with one element).
	    #Route='IP/SUBNET-addr,GW,PREFIX,METRIC'
	
	@routes_arr_l=split(/\;/,${$hval0_l}[0]);
	
	foreach $arr_el0_l ( @routes_arr_l ) {
	    #$arr_el0_l='IP/SUBNET-addr,GW,PREFIX,METRIC'
	    
	    @one_route_arr_l=split(/\,/,$arr_el0_l);
	    
	    if ( $#one_route_arr_l!=3 ) {
	    	$return_str_l="fail [$proc_name_l]. Incorrect route = '$arr_el0_l'. The route must contain 4 parameters and look like this 'IP/SUBNET-addr,GW,PREFIX,METRIC'. Fix it!";
	    	last;
	    }
	    
	    ($ip_addr_l,$gw_l,$prefix_l,$metric_l)=@one_route_arr_l;
	    
	    $exec_res_l=&ipv4_addr_opts_check($ip_addr_l,$gw_l,$prefix_l);
	    #$ipv4_addr_l,$gw_ipv4_l,$prefix_ipv4_l,$conf_file_l
	    if ( $exec_res_l=~/^fail/ ) {
	    	$return_str_l="fail [$proc_name_l] -> ".$exec_res_l;
	    	last;
	    }
	    $exec_res_l=undef;
	    
	    if ( $metric_l!~/^\d+$/ ) {
	    	$return_str_l="fail [$proc_name_l]. Metric='$metric_l' is not correct. Fix it!";
	    	last;
	    }
	    
	    # Fill %res_tmp_lv1_l
	    push(@{$res_tmp_lv1_l{$hkey0_l}},$arr_el0_l);
	    ###
	    
	    # clear vars
	    ($ip_addr_l,$gw_l,$prefix_l,$metric_l)=(undef,undef,undef,undef);
	    @one_route_arr_l=();
	    ###
	}
	
	if ( $return_str_l!~/^OK$/ ) { last; }
	
	# clear vars
	@routes_arr_l=();
	###
    }
    
    # clear vars
    ($hkey0_l,$hval0_l)=(undef,undef);
    @routes_arr_l=();
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
