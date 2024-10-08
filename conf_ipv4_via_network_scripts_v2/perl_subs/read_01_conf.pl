sub read_01a_conf_int_hwaddr {
    my ($file_l,$inv_hosts_href_l,$inv_hosts_network_data_href_l,$res_href_l)=@_;
    #file_l='01_configs/01a_conf_int_hwaddr_inf'
    #inv_hosts_href_l=hash-ref for %inventory_hosts_g
    #inv_hosts_network_data_href_l=hash ref for %inv_hosts_network_data_g
    	#v1) key0='hwaddr_all', key1=hwaddr, value=inv_host
    	#v2) key0='inv_host', key1=inv_host, key2=interface_name, key3=hwaddr
    ###
    #res_href_l = hash ref for %h01a_conf_int_hwaddr_inf_hash_g
    my $proc_name_l=(caller(0))[3];
    
    my ($exec_res_l)=(undef);
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my ($inv_host_l,$interface_name_l,$hwaddr_l)=(undef,undef,undef);
    my $return_str_l='OK';
    
    my %hwaddr_uniq_check_l=();
    	#key0=hwaddr, value=inv-host
    my %int_name_uniq_check_for_one_host_l=();
    	#key0=inv-host, key1=interface_name, value=hwaddr
    my %res_tmp_lv0_l=();
        #key=string with params from cfg, value=1
    my %res_tmp_lv1_l=(); # result hash
    #INV_HOST       #INT            #HWADDR
    #key0=inv-host, key1=interface, key2=hwaddr, value=1
    
    $exec_res_l=&read_uniq_lines_with_params_from_config($file_l,3,\%res_tmp_lv0_l);
    #$file_l,$file_l,$prms_per_line_l,$res_href_l,$res_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }
    $exec_res_l=undef;
    
    while ( ($hkey0_l,$hval0_l)=each %res_tmp_lv0_l ) {
    	#hval0_l = arryaref for (#INV_HOST-0 #INT-1 #HWADDR-2)
    	
    	($inv_host_l,$interface_name_l,$hwaddr_l)=@{$hval0_l};
    	$hwaddr_l=lc($hwaddr_l);
    	
    	$exec_res_l=&inv_host_simple_check($inv_host_l,$inv_hosts_href_l,$file_l);
    	#$inv_host_l,$inv_hosts_href_l,$conf_file_l
    	if ( $exec_res_l=~/^fail/ ) {
    	    $return_str_l="fail [$proc_name_l] -> ".$exec_res_l;
    	    last;
    	}
    
    	$exec_res_l=&hwaddr_check($inv_host_l,$interface_name_l,$hwaddr_l,$inv_hosts_network_data_href_l);
    	#$inv_host_l,$interface_name_l,$hwaddr_l,$inv_hosts_network_data_href_l
    	if ( $exec_res_l=~/^fail/ ) {
    	    $return_str_l="fail [$proc_name_l] -> ".$exec_res_l;
    	    last;
    	}
    	
    	# uniq checks (begin)
    	if ( exists($hwaddr_uniq_check_l{$hwaddr_l}) ) {
    	    $return_str_l="fail [$proc_name_l]. Hwaddr='$hwaddr_l' is already used at inv-host='$hwaddr_uniq_check_l{$hwaddr_l}'. Fix it at conf-file='$file_l'!";
    	    last;
    	}
    	
    	if ( exists($int_name_uniq_check_for_one_host_l{$inv_host_l}{$interface_name_l}) ) {
    	    $return_str_l="fail [$proc_name_l]. Interface='$interface_name_l' (conf-file='$file_l') for inv-host='$inv_host_l' is already configured for hwaddr='$int_name_uniq_check_for_one_host_l{$inv_host_l}{$interface_name_l}'. Fix it!";
    	    last;
    	}
    	# uniq checks (end)
    	
    	# fill uniq-check hashes
    	$hwaddr_uniq_check_l{$hwaddr_l}=$inv_host_l;
    	$int_name_uniq_check_for_one_host_l{$inv_host_l}{$interface_name_l}=$hwaddr_l;
    	###
    	
    	# WRITE to %h01a_conf_int_hwaddr_inf_hash_g
    	$res_tmp_lv1_l{$inv_host_l}{$interface_name_l}{$hwaddr_l}=1;
    	###
    		
    	# clear vars
    	($inv_host_l,$interface_name_l,$hwaddr_l)=(undef,undef,undef);
    	###
    }
    
    # clear vars
    ($hkey0_l,$hval0_l)=(undef,undef);
    %hwaddr_uniq_check_l=();
    ###
    
    if ( $return_str_l!~/^OK$/ ) { return $return_str_l; }
    
    # fill result hash
    %{$res_href_l}=%res_tmp_lv1_l;
    ###
    
    %res_tmp_lv1_l=();
    
    return $return_str_l;
}

sub read_01b_conf_main {
    my ($file_l,$inv_hosts_href_l,$inv_hosts_network_data_href_l,$h01a_conf_int_hwaddr_inf_hash_l,$res_href_l)=@_;
    #file_l='01_configs/01b_conf_main'
    #inv_hosts_href_l=hash-ref for %inventory_hosts_g
    #inv_hosts_network_data_href_l=hash ref for %inv_hosts_network_data_g
    	#v1) key0='hwaddr_all', key1=hwaddr, value=inv_host
    	#v2) key0='inv_host', key1=inv_host, key2=interface_name, key3=hwaddr
    #h01a_conf_int_hwaddr_inf_hash_l=hash-ref for %h01a_conf_int_hwaddr_inf_hash_g
    	#key0=inv-host, key1=interface, key2=hwaddr, value=1
    #res_href_l = hash ref for %h01b_conf_main_hash_g
    my $proc_name_l=(caller(0))[3];
    
    my ($exec_res_l)=(undef);
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my ($inv_host_l,$conf_id_l,$conf_type_l,$interface_list_l,$vlan_id_l,$bond_name_l,$bridge_name_l,$defroute_l)=(undef,undef,undef,undef,undef,undef,undef,undef);
    my @int_list_arr_l=();
    my $return_str_l='OK';
    
    my %conf_id_uniq_check_hash_l=();
    	#key0=conf_id, value=1
    my %defroute_uniq_check_by_inv_host_hash_l=(); # for using at procedure 'defroute_check' via ref
    	#key0=inv-host, value=defroute (yes/no)
    my %res_tmp_lv0_l=();
        #key=string with params from cfg, value=1
    my %res_tmp_lv1_l=(); # result hash
    #INV_HOST    #CONF_ID   #CONF_TYPE       #INT_LIST      #VLAN_ID    #BOND_NAME   #BRIDGE_NAME   #DEFROUTE
    #h01b_conf_main_hash_g{inv-host}{conf-id}{'conf_type'}=conf-type-value
    #h01b_conf_main_hash_g{inv-host}{conf-id}{'bond_name'}=bond-name-value
    #h01b_conf_main_hash_g{inv-host}{conf-id}{'bridge_name'}=bridge-name-value
    #h01b_conf_main_hash_g{inv-host}{conf-id}{'defroute'}=no/yes
    #h01b_conf_main_hash_g{inv-host}{conf-id}{'vlan_id'}=vlan-id-value
    #h01b_conf_main_hash_g{inv-host}{conf-id}{'int_list'}=[interface0,interface1...etc]
    
    $exec_res_l=&read_uniq_lines_with_params_from_config($file_l,8,\%res_tmp_lv0_l);
    #$file_l,$file_l,$prms_per_line_l,$res_href_l,$res_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }
    $exec_res_l=undef;
    
    while ( ($hkey0_l,$hval0_l)=each %res_tmp_lv0_l ) {
    	#hval0_l = arrayref for (#INV_HOST-0 #CONF_ID-1 #CONF_TYPE-2 #INT_LIST-3 #VLAN_ID-4 #BOND_NAME-5 #BRIDGE_NAME-6 #DEFROUTE-7)
    	
    	($inv_host_l,$conf_id_l,$conf_type_l,$interface_list_l,$vlan_id_l,$bond_name_l,$bridge_name_l,$defroute_l)=@{$hval0_l};
    	@int_list_arr_l=split(/\,/);
    	
    	### simple checks (begin)
    	$exec_res_l=&inv_host_simple_check($inv_host_l,$inv_hosts_href_l,$file_l);
    	#$inv_host_l,$inv_hosts_href_l,$conf_file_l
    	if ( $exec_res_l=~/^fail/ ) {
    	    $return_str_l="fail [$proc_name_l] -> ".$exec_res_l;
    	    last;
    	}
    	
    	$exec_res_l=&conf_id_simple_check($conf_id_l,$file_l);
    	#$conf_id_l,$conf_file_l
    	if ( $exec_res_l=~/^fail/ ) {
    	    $return_str_l="fail [$proc_name_l] -> ".$exec_res_l;
    	    last;
    	}
    	
    	$exec_res_l=&conf_type_simple_check($conf_type_l,$file_l);
    	#$conf_type_l,$conf_file_l
    	if ( $exec_res_l=~/^fail/ ) {
    	    $return_str_l="fail [$proc_name_l] -> ".$exec_res_l;
    	    last;
    	}
    		
    	$exec_res_l=&int_list_simple_check($inv_host_l,\@int_list_arr_l,$inv_hosts_network_data_href_l,$file_l);
    	#$inv_host_l,$int_list_aref_l,$inv_hosts_network_data_href_l,$conf_file_l
    	if ( $exec_res_l=~/^fail/ ) {
    	    $return_str_l="fail [$proc_name_l] -> ".$exec_res_l;
    	    last;
    	}
    	
    	$exec_res_l=&vlan_id_simple_check($vlan_id_l,$file_l);
    	#$vlan_id_l,$conf_file_l
    	if ( $exec_res_l=~/^fail/ ) {
    	    $return_str_l="fail [$proc_name_l] -> ".$exec_res_l;
    	    last;
    	}
    	
    	$exec_res_l=&bond_name_simple_check($bond_name_l,$file_l);
    	#$bond_name_l,$conf_file_l
    	if ( $exec_res_l=~/^fail/ ) {
    	    $return_str_l="fail [$proc_name_l] -> ".$exec_res_l;
    	    last;
    	}
    	
    	$exec_res_l=&bridge_name_simple_check($bridge_name_l,$file_l);
    	#$bridge_name_l,$conf_file_l
    	if ( $exec_res_l=~/^fail/ ) {
    	    $return_str_l="fail [$proc_name_l] -> ".$exec_res_l;
    	    last;
    	}
    	
    	$exec_res_l=&defroute_simple_check($defroute_l,$file_l);
    	#$defroute_l,$conf_file_l
    	if ( $exec_res_l=~/^fail/ ) {
    	    $return_str_l="fail [$proc_name_l] -> ".$exec_res_l;
    	    last;
    	}
    	### simple checks (end)
    	
    	### additional checks (begin)
    	$exec_res_l=&conf_id_additional_check($conf_id_l,\%conf_id_uniq_check_hash_l,$file_l);
    	#$conf_id_l,$conf_id_uniq_check_href_l,$conf_file_l
    	if ( $exec_res_l=~/^fail/ ) {
    	    $return_str_l="fail [$proc_name_l] -> ".$exec_res_l;
    	    last;
    	}
    	
    	$exec_res_l=&conf_type_additional_check($conf_type_l,$vlan_id,$file_l);
    	#$conf_type_l,$vlan_id,$conf_file_l
    	if ( $exec_res_l=~/^fail/ ) {
    	    $return_str_l="fail [$proc_name_l] -> ".$exec_res_l;
    	    last;
    	}
    	
    	$exec_res_l=&defroute_additional_check($defroute_l,$inv_host_l,$conf_id_l,\%defroute_uniq_check_by_inv_host_hash_l,$file_l);
    	#$defroute_l,$inv_host_l,$conf_id_l,$defroute_uniq_check_by_inv_host_href_l,$conf_file_l
    	if ( $exec_res_l=~/^fail/ ) {
    	    $return_str_l="fail [$proc_name_l] -> ".$exec_res_l;
    	    last;
    	}
    	### additional checks (end)
    	
    	# WRITE to %res_tmp_lv1_l
    	$res_tmp_lv1_l{$inv_host_l}{$conf_id_l}{'conf_type'}=$conf_type_l;
    	$res_tmp_lv1_l{$inv_host_l}{$conf_id_l}{'bond_name'}=$bond_name_l;
    	$res_tmp_lv1_l{$inv_host_l}{$conf_id_l}{'bridge_name'}=$bridge_name_l;
    	$res_tmp_lv1_l{$inv_host_l}{$conf_id_l}{'defroute'}=$defroute_l;
    	$res_tmp_lv1_l{$inv_host_l}{$conf_id_l}{'vlan_id'}=$vlan_id_l;
    	$res_tmp_lv1_l{$inv_host_l}{$conf_id_l}{'int_list'}=[@int_list_arr_l];
    	###
    	
    	# clear vars
    	($inv_host_l,$conf_id_l,$conf_type_l,$interface_list_l,$vlan_id_l,$bond_name_l,$bridge_name_l,$defroute_l)=(undef,undef,undef,undef,undef,undef,undef,undef);
    	@int_list_arr_l=();
    	###
    }
    
    # clear vars
    ($hkey0_l,$hval0_l)=(undef,undef);
    ###
    
    if ( $return_str_l!~/^OK$/ ) { return $return_str_l; }
    
    # fill result hash
    %{$res_href_l}=%res_tmp_lv1_l;
    ###
    
    %res_tmp_lv1_l=();
    
    return $return_str_l;
}

sub read_01c_conf_ip_addr {
    my ($file_l,$inv_hosts_href_l,$h01b_conf_main_href_l,$res_href_l)=@_;
    #file_l='01_configs/01c_conf_ip_addr'
    #inv_hosts_href_l=hash-ref for %inventory_hosts_g
    #$h01b_conf_main_href_l=hash-ref for %h01b_conf_main_hash_g
    #res_href_l = hash ref for %h01c_conf_ip_addr_hash_g
    my $proc_name_l=(caller(0))[3];
    
    my ($exec_res_l)=(undef);
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my ($hkey1_l,$hval1_l)=(undef,undef);
    my ($inv_host_l,$conf_id_l,$ipv4_addr_opts_l)=(undef,undef,undef);
    my ($ipv4_addr_l,$gw_ipv4_l,$prefix_ipv4_l)=(undef,undef,undef);
    my $return_str_l='OK';
    
    my %ipv4_uniq_check_hash_l=();
    	#key=ipv4, value=conf_id
    my %res_tmp_lv0_l=();
        #key=string with params from cfg, value=1
    my %res_tmp_lv1_l=(); # result hash
    #INV_HOST    #CONF_ID           #IPv4_ADDR_OPTS (ip,gw,prefix)
    #h01c_conf_ip_addr_hash_g{inv-host}{conf-id}{'ipv4'}=ip-value (or 'dhcp')
    #h01c_conf_ip_addr_hash_g{inv-host}{conf-id}{'gw_ipv4'}=gw-value (empty if 'dhcp')
    #h01c_conf_ip_addr_hash_g{inv-host}{conf-id}{'prefix_ipv4'}=prefix-value (empty if 'dhcp')
    
    $exec_res_l=&read_uniq_lines_with_params_from_config($file_l,3,\%res_tmp_lv0_l);
    #$file_l,$file_l,$prms_per_line_l,$res_href_l,$res_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }
    $exec_res_l=undef;
    
    while ( ($hkey0_l,$hval0_l)=each %res_tmp_lv0_l ) {
    	#hval0_l = arrayref for (#INV_HOST-0 #CONF_ID-1 #IPv4_ADDR_OPTS-2)
    	
    	($inv_host_l,$conf_id_l,$ipv4_addr_opts_l)=@{$hval0_l};
    	($ipv4_addr_l,$gw_ipv4_l,$prefix_ipv4_l)=split(/\,/,$ipv4_addr_opts_l);
    	
    	### simple checks (begin)
    	$exec_res_l=&inv_host_simple_check($inv_host_l,$inv_hosts_href_l,$file_l);
    	#$inv_host_l,$inv_hosts_href_l,$conf_file_l
    	if ( $exec_res_l=~/^fail/ ) {
    	    $return_str_l="fail [$proc_name_l] -> ".$exec_res_l;
    	    last;
    	}
    	
    	$exec_res_l=&conf_id_simple_check($conf_id_l,$file_l);
    	#$conf_id_l,$conf_file_l
    	if ( $exec_res_l=~/^fail/ ) {
    	    $return_str_l="fail [$proc_name_l] -> ".$exec_res_l;
    	    last;
    	}
    
    	$exec_res_l=&ipv4_addr_opts_check($ipv4_addr_l,$gw_ipv4_l,$prefix_ipv4_l,$file_l);
    	#$ipv4_addr_l,$gw_ipv4_l,$prefix_ipv4_l,$conf_file_l
    	if ( $exec_res_l=~/^fail/ ) {
    	    $return_str_l="fail [$proc_name_l] -> ".$exec_res_l;
    	    last;
    	}
    	### simple checks (end)
    	
    	### additional checks (begin)
    	$exec_res_l=&conf_id_is_exists_at_01b_main_check($conf_id_l,$inv_host_l,$h01b_conf_main_href_l,$file_l);
    	#$conf_id_l,$inv_host_l,$h01b_conf_main_href_l,$conf_file_l
    	if ( $exec_res_l=~/^fail/ ) {
    	    $return_str_l="fail [$proc_name_l] -> ".$exec_res_l;
    	    last;
    	}
    
    	$exec_res_l=&ipv4_additional_check($ipv4_addr_l,$conf_id_l,\%ipv4_uniq_check_hash_l,$file_l);
    	#$ipv4_addr_l,$conf_id_l,$ipv4_uniq_check_href_l,$conf_file_l
    	if ( $exec_res_l=~/^fail/ ) {
    	    $return_str_l="fail [$proc_name_l] -> ".$exec_res_l;
    	    last;
    	}
    	### additional checks (end)
    	
    	# WRITE to %res_tmp_lv1_l
    	$res_tmp_lv1_l{$inv_host_l}{$conf_id_l}{'ipv4'}=$ipv4_addr_l;
    	
    	if ( $ipv4_addr_l ne 'dhcp' ) {
    	    $res_tmp_lv1_l{$inv_host_l}{$conf_id_l}{'gw_ipv4'}=$gw_ipv4_l;
    	    $res_tmp_lv1_l{$inv_host_l}{$conf_id_l}{'prefix_ipv4'}=$prefix_ipv4_l;
    	}
    	###
    	
    	# clear vars
    	($inv_host_l,$conf_id_l,$ipv4_addr_opts_l)=(undef,undef,undef);
    	($ipv4_addr_l,$gw_ipv4_l,$prefix_ipv4_l)=(undef,undef,undef);
    	###
    }
    
    # clear vars
    ($hkey0_l,$hval0_l)=(undef,undef);
    ###
    
    if ( $return_str_l!~/^OK$/ ) { return $return_str_l; }
    
    # check if some conf-ids from %h01b_conf_main_hash_g is not configured at %res_tmp_lv1_l (begin)
    while ( ($hkey0_l,$hval0_l)=each %{$h01b_conf_main_href_l} ) {
    	#$hkey0_l=inv-host
    	
    	while ( ($hkey1_l,$hval1_l)=each %{$hval0_l} ) {
    	    #$hkey1_l=conf-id
    	    
    	    if ( !exists($res_tmp_lv1_l{$hkey0_l}{$hkey1_l}) ) {
    	    	$return_str_l="fail [$proc_name_l]. Conf_id='$hkey1_l' exists at '01b_conf_main', but not configured at '$file_l'. Fix it!";
    	    	last;
    	    }
    	}
    	
    	# clear vars
    	($hkey1_l,$hval1_l)=(undef,undef);
    	###
    	
    	if ( $return_str_l=~/^fail/ ) { last; }
    }
    
    # clear vars
    ($hkey0_l,$hval0_l)=(undef,undef);
    ($hkey1_l,$hval1_l)=(undef,undef);
    ###
    # check if some conf-ids from %h01b_conf_main_hash_g is not configured at %res_tmp_lv1_l (end)
    
    if ( $return_str_l!~/^OK$/ ) { return $return_str_l; }
    
    # fill result hash
    %{$res_href_l}=%res_tmp_lv1_l;
    ###
    
    %res_tmp_lv1_l=();
    
    return $return_str_l;
}

sub read_01d_conf_bond_opts {
    my ($file_l,$inv_hosts_href_l,$h01b_conf_main_href_l,$res_href_l)=@_;
    #file_l='01_configs/01d_conf_bond_opts'
    #inv_hosts_href_l=hash-ref for %inventory_hosts_g
    #$h01b_conf_main_href_l=hash-ref for %h01b_conf_main_hash_g
    #res_href_l = hash ref for %h01d_conf_bond_opts_hash_g
    my $proc_name_l=(caller(0))[3];
    
    my ($exec_res_l)=(undef);
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my ($hkey1_l,$hval1_l)=(undef,undef);
    my ($inv_host_l,$conf_id_l,$bond_opts_l)=(undef,undef,undef);
    my $return_str_l='OK';
    
    my %res_tmp_lv0_l=();
        #key=string with params from cfg, value=1
    my %res_tmp_lv1_l=(); # result hash
    #INV_HOST       #CONF_ID        #BOND_OPTS
    #h01d_conf_bond_opts_hash_g{inv-host}{conf-id}=bond-opts-value
    #If bond-opts-value=def -> 'mode=4,xmit_hash_policy=2,lacp_rate=1,miimon=100'.
    #Else -> 'bond-opts-value'.
    
    $exec_res_l=&read_uniq_lines_with_params_from_config($file_l,3,\%res_tmp_lv0_l);
    #$file_l,$file_l,$prms_per_line_l,$res_href_l,$res_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }
    $exec_res_l=undef;
    
    while ( ($hkey0_l,$hval0_l)=each %res_tmp_lv0_l ) {
    	#hval0_l = arrayref for (#INV_HOST-0 #CONF_ID-1 #BOND_OPTS-2)
    	
    	($inv_host_l,$conf_id_l,$bond_opts_l)=@{$hval0_l};
    	
    	### simple checks (begin)
    	$exec_res_l=&inv_host_simple_check($inv_host_l,$inv_hosts_href_l,$file_l);
    	#$inv_host_l,$inv_hosts_href_l,$conf_file_l
    	if ( $exec_res_l=~/^fail/ ) {
    	    $return_str_l="fail [$proc_name_l] -> ".$exec_res_l;
    	    last;
    	}
    	
    	$exec_res_l=&conf_id_simple_check($conf_id_l,$file_l);
    	#$conf_id_l,$conf_file_l
    	if ( $exec_res_l=~/^fail/ ) {
    	    $return_str_l="fail [$proc_name_l] -> ".$exec_res_l;
    	    last;
    	}
    	### simple checks (end)
    	
    	### additional checks (begin)
    	$exec_res_l=&conf_id_is_exists_at_01b_main_check($conf_id_l,$inv_host_l,$h01b_conf_main_href_l,$file_l);
    	#$conf_id_l,$inv_host_l,$h01b_conf_main_href_l,$conf_file_l
    	if ( $exec_res_l=~/^fail/ ) {
    	    $return_str_l="fail [$proc_name_l] -> ".$exec_res_l;
    	    last;
    	}
    	### additional checks (end)
    	
    	# WRITE to %res_tmp_lv1_l
    	if ( $bond_opts_l eq 'def' ) { $res_tmp_lv1_l{$inv_host_l}{$conf_id_l}='mode=4,xmit_hash_policy=2,lacp_rate=1,miimon=100'; }
    	else { $res_tmp_lv1_l{$inv_host_l}{$conf_id_l}=$bond_opts_l; }
    	###
    	
    	# clear vars
    	($inv_host_l,$conf_id_l,$bond_opts_l)=(undef,undef,undef);
    	###
    }
    
    # clear vars
    ($hkey0_l,$hval0_l)=(undef,undef);
    ###
    
    if ( $return_str_l!~/^OK$/ ) { return $return_str_l; }
    
    # check if some conf-ids from %h01b_conf_main_hash_g is not configured at %res_tmp_lv1_l (for bond-conns) (begin)
    while ( ($hkey0_l,$hval0_l)=each %{$h01b_conf_main_href_l} ) {
    	#$hkey0_l=inv-host
    	
    	while ( ($hkey1_l,$hval1_l)=each %{$hval0_l} ) {
    	    #$hkey1_l=conf-id
    	    
    	    if ( ${$hval1_l}{'conf_type'}=~/bond/ && !exists($res_tmp_lv1_l{$hkey0_l}{$hkey1_l}) ) {
    	    	$return_str_l="fail [$proc_name_l]. Conf_id='$hkey1_l' (for bond-connection) exists at '01b_conf_main', but not configured at '$file_l'. Fix it!";
    	    	last;
    	    }
    	}
    	
    	# clear vars
    	($hkey1_l,$hval1_l)=(undef,undef);
    	###
    	
    	if ( $return_str_l=~/^fail/ ) { last; }
    }
    
    # clear vars
    ($hkey0_l,$hval0_l)=(undef,undef);
    ($hkey1_l,$hval1_l)=(undef,undef);
    ###
    # check if some conf-ids from %h01b_conf_main_hash_g is not configured at %res_tmp_lv1_l (for bond-conns) (end)
    
    if ( $return_str_l!~/^OK$/ ) { return $return_str_l; }
    
    # fill result hash
    %{$res_href_l}=%res_tmp_lv1_l;
    ###
    
    %res_tmp_lv1_l=();
    
    return $return_str_l;
}

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
