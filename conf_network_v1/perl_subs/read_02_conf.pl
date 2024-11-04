sub read_02_conf_dns {
    my ($file_l,$inv_hosts_href_l,$divisions_for_inv_hosts_href_l,$res_href_l)=@_;
    #$file_l=$f02_conf_dns_path_g
    #inv_hosts_href_l=hash-ref for %inventory_hosts_g
    #$divisions_for_inv_hosts_href_l=hash-ref for %h00_conf_divisions_for_inv_hosts_hash_g
        #$h00_conf_divisions_for_inv_hosts_hash_g{group-name}{inv-host}=1;
    #$res_href_l=hash ref for %h02_conf_dns_hash_g
    	#key=inv_host, value=[search-domain(optional), array of nameservers] or ['no-name-servers/do-not-touch']
    ###############
    # INVENTORY_HOST = all/list of inventory hosts separated by "," / group name from conf '00_conf_divisions_for_inv_hosts'.
    	# If "all" -> the configuration will be applied to all inventory hosts.
    	# Priority (from lower to higher): all (0), group name from conf '00_conf_divisions_for_inv_hosts' (1),
    	# list of inventory hosts separated by "," or individual hosts (2).
    ###
    # LIST_OF_NAME_SERVERS - list of params for 'resolv.conf'. Format = "search-domain=somedomain.org,nameserver1,nameserver2,etc"
    # or "nameserver1,nameserver2,etc" (without param 'search-domain')
    # or "no-name-servers" (remove all name servers and search domain from 'resolv.conf')
    # or "do-not-touch" (do not modify the file 'resolv.conf').
    ###
    #INVENTORY_HOST                 #LIST_OF_NAME_SERVERS
    ###############
    
    my $proc_name_l=(caller(0))[3];
    
    my ($exec_res_l)=(undef);
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my ($search_domain_l)=(undef);
    my $cnt_l=0;
    my @nameservers_l=();
    my $return_str_l='OK';
    
    my %res_tmp_lv0_l=();
        #key=inv-host, value=[list-of-name-servers(via ',')] (array with one element)
    my %res_tmp_lv1_l=(); # result hash
    	#key=inv_host, value=[search-domain(optional), array of nameservers] or ['no-name-servers/do-not-touch']
    
    $exec_res_l=&read_conf_lines_with_priority_by_first_param($file_l,$inv_hosts_href_l,$divisions_for_inv_hosts_href_l,2,0,\%res_tmp_lv0_l);
    #$file_l,$inv_hosts_href_l,$divisions_for_inv_hosts_href_l,$needed_elements_at_line_arr_l,$add_ind4key_l,$res_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }
    $exec_res_l=undef;
    
    # check %res_tmp_lv0_l and fill %res_tmp_lv1_l (begin)
    while ( ($hkey0_l,$hval0_l)=each %res_tmp_lv0_l ) {
    	#hkey0_l=inv-host, hval0_l="search-domain=somedomain.org,nameserver1,nameserver2,etc" or "nameserver1,nameserver2,etc"
    	
    	if ( ${$hval0_l}[0]!~/^no\-name\-servers$|^do\-not\-touch$/ ) {
    	    if ( ${$hval0_l}[0]=~/\,search\-domain\=/ ) {
    	    	$return_str_l="fail [$proc_name_l]. The parameter 'search-domain' must be at the beginning of the string '${$hval0_l}[0]' (conf='$file_l')";
    	    	last;
    	    }
    	    
    	    @nameservers_l=split(/\,/,${$hval0_l}[0]);
    	    
    	    if ( $nameservers_l[0]=~/search\-domain\=/ ) {
    	    	$search_domain_l=$nameservers_l[0];
    	    	$search_domain_l=~s/search\-domain\=//;
    	    	$search_domain_l='search '.$nameservers_l[0];
    	        
    	    	shift(@nameservers_l);
    	    }
    	    else { $search_domain_l='no'; }
    	    
    	    for ( $cnt_l=0; $cnt_l<=$#nameservers_l; $cnt_l++ ) { $nameservers_l[$cnt_l]='nameserver '.$nameservers_l[$cnt_l]; }
    	    
    	    if ( $search_domain_l!~/^no$/ ) { @nameservers_l=($search_domain_l,@nameservers_l); }
    	    
    	    # fill %res_tmp_lv1_l
    	    $res_tmp_lv1_l{$hkey0_l}=[@nameservers_l];
    	    ###
    	    
    	    # clear vars
    	    @nameservers_l=();
    	    $search_domain_l=undef;
    	    $cnt_l=0;
    	    ###
    	}
    	else { # if 'no-name-servers' or 'do-not-touch'
    	    # fill %res_tmp_lv1_l
    	    $res_tmp_lv1_l{$hkey0_l}=[${$hval0_l}[0]];
    	    ###
    	}
    }
    
    # clear vars
    ($hkey0_l,$hval0_l)=(undef,undef);
    $cnt_l=undef;
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