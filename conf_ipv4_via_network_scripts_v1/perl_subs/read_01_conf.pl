sub generate_resolv_conf_files {
    my ($conf_dns_l,$dyn_resolv_common_dir_l,$res_inv_hosts_dns_href_l)=@_;
    #$conf_dns_l=$conf_dns_g
    #$dyn_resolv_common_dir_l=$dyn_resolv_common_dir_g
    #$res_inv_hosts_dns_href_l=hash ref for %inv_hosts_dns_h
    my $proc_name_l=(caller(0))[3];
    ###READ conf file '01_dns_settings' and generate resolv-conf-files
        #$dyn_resolv_common_dir_g=$self_dir_g.'playbooks/dyn_ifcfg_playbooks/dyn_resolv_conf' -> 
            #files: 'inv_host_resolv' or 'common_resolv'
        #%inv_hosts_dns_g=(); #key=inv_host/common, value=[array of nameservers]
           
    my ($line_l,$arr_el0_l)=(undef,undef);
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my $return_str_l='OK';
        
    open(CONF_DNS,'<',$conf_dns_l);
    while ( <CONF_DNS> ) {
        $line_l=$_;
        $line_l=~s/\n$|\r$|\n\r$|\r\n$//g;
        while ($line_l=~/\t/) { $line_l=~s/\t/ /g; }
        $line_l=~s/\s+/ /g;
        $line_l=~s/^ //g;
        if ( length($line_l)>0 && $line_l!~/^\#/ && $line_l=~/^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}|common) (\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})$/ ) {
            push(@{${$res_inv_hosts_dns_href_l}{$1}},$2);
        }
    }
    close(CONF_DNS);

    $line_l=undef;
    ######
    if ( -d $dyn_resolv_common_dir_l ) {
        system("cd $dyn_resolv_common_dir_l && ls | grep -v 'info' | xargs rm -rf");
    }
    
    while ( ($hkey0_l,$hval0_l)=each %{$res_inv_hosts_dns_href_l} ) {
        #hkey0_l=inv_host
        open(RESOLV,'>',$dyn_resolv_common_dir_l.'/'.$hkey0_l.'_resolv');
        print RESOLV "# Generated by ansible scenario 'conf_int_ipv4_via_network_scripts'\n";
        foreach $arr_el0_l ( @{$hval0_l} ) {
            print RESOLV "nameserver $arr_el0_l\n";
        }
        close(RESOLV);

        $arr_el0_l=undef;
    }

    $arr_el0_l=undef;
    ($hkey0_l,$hval0_l)=(undef,undef);
    ###READ conf file '01_dns_settings' and generate resolv-conf-files

    return $return_str_l;
}

######new. Not used yet (begin)
sub read_01a_conf_int_hwaddr {
    my ($file_l,$inv_hosts_network_data_href_l,$res_href_l)=@_;
    #file_l='01_configs/01a_conf_int_hwaddr_inf'
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
	
	$exec_res_l=&hwaddr_check($inv_host_l,$interface_name_l,$hwaddr_l,$inv_hosts_network_data_href_l);
	#$inv_host_l,$interface_name_l,$hwaddr_l,$inv_hosts_network_data_href_l
	if ( $exec_res_l=~/^fail/ ) {
	    $return_str_l="fail [$proc_name_l] -> ".$exec_res_l;
	    last;
	}
	
	# clear vars
	($inv_host_l,$interface_name_l,$hwaddr_l)=(undef,undef,undef);
	###
    }
    
    # clear vars
    ($hkey0_l,$hval0_l)=(undef,undef);
    ###
    
    if ( $return_str_l!~/^OK$/ ) { return $return_str_l; }

    # fill result hash
    %{$res_href_l}=%res_tmp_lv1_l;
    ###
    
    return $return_str_l;
}

sub read_01b_conf_main {
    my ($file_l,$res_href_l)=@_;
    #file_l='01_configs/01b_conf_main'
    #res_href_l = hash ref for %h01b_conf_main_hash_g
    my $proc_name_l=(caller(0))[3];

    my ($exec_res_l)=(undef);
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my $return_str_l='OK';

    my %res_tmp_lv0_l=();
        #key=string with params from cfg, value=1
    my %res_tmp_lv1_l=(); # result hash
    #INV_HOST    #CONF_ID   #CONF_TYPE       #INT_LIST      #VLAN_ID    #BOND_NAME   #BRIDGE_NAME   #DEFROUTE
    #h01b_conf_main_hash_g{inv-host}{conf-id}{'conf_type'}=conf-type-value
    #h01b_conf_main_hash_g{inv-host}{conf-id}{'bond_name'}=bond-name-value # if bond-name='no' -> no key
    #h01b_conf_main_hash_g{inv-host}{conf-id}{'bridge_name'}=bridge-name-value # if bridge-name='no' -> no key
    #h01b_conf_main_hash_g{inv-host}{conf-id}{'defroute'}=1 # if defroute='no' -> no key
    #h01b_conf_main_hash_g{inv-host}{conf-id}{'vlan_id'}=vlan-id-value # if vlan-id='no' -> no key
    #h01b_conf_main_hash_g{inv-host}{conf-id}{'int_list'}=[interface0,interface1...etc]

    $exec_res_l=&read_uniq_lines_with_params_from_config($file_l,8,\%res_tmp_lv0_l);
    #$file_l,$file_l,$prms_per_line_l,$res_href_l,$res_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }
    $exec_res_l=undef;

    while ( ($hkey0_l,$hval0_l)=each %res_tmp_lv0_l ) {
	#hval0_l = arrayref for (#INV_HOST-0 #CONF_ID-1 #CONF_TYPE-2 #INT_LIST-3 #VLAN_ID-4 #BOND_NAME-5 #BRIDGE_NAME-6 #DEFROUTE-7)
	
	# clear vars
	###
    }
    
    # clear vars
    ($hkey0_l,$hval0_l)=(undef,undef);
    ###
    
    if ( $return_str_l!~/^OK$/ ) { return $return_str_l; }
    
    # fill result hash
    %{$res_href_l}=%res_tmp_lv1_l;
    ###

    return $return_str_l;
}

sub read_01c_conf_ip_addr {
    my ($file_l,$res_href_l)=@_;
    #file_l='01_configs/01c_conf_ip_addr'
    #res_href_l = hash ref for %h01c_conf_ip_addr_hash_g
    my $proc_name_l=(caller(0))[3];

    my ($exec_res_l)=(undef);
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my $return_str_l='OK';

    my %res_tmp_lv0_l=();
        #key=string with params from cfg, value=1
    my %res_tmp_lv1_l=(); # result hash
    #INV_HOST    #CONF_ID           #IPv4_ADDR_OPTS (ip,gw,prefix)
    #h01c_conf_ip_addr_hash_g{inv-host}{conf-id}{'ip'}=ip-value
    #h01c_conf_ip_addr_hash_g{inv-host}{conf-id}{'gw'}=gw-value
    #h01c_conf_ip_addr_hash_g{inv-host}{conf-id}{'prefix'}=prefix-value

    $exec_res_l=&read_uniq_lines_with_params_from_config($file_l,3,\%res_tmp_lv0_l);
    #$file_l,$file_l,$prms_per_line_l,$res_href_l,$res_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }
    $exec_res_l=undef;

    while ( ($hkey0_l,$hval0_l)=each %res_tmp_lv0_l ) {
	#hval0_l = arrayref for (#INV_HOST-0 #CONF_ID-1 #IPv4_ADDR_OPTS-2)
	
	# clear vars
	###
    }
    
    # clear vars
    ($hkey0_l,$hval0_l)=(undef,undef);
    ###
    
    if ( $return_str_l!~/^OK$/ ) { return $return_str_l; }

    # fill result hash
    %{$res_href_l}=%res_tmp_lv1_l;
    ###
    
    return $return_str_l;
}

sub read_01d_conf_bond_opts {
    my ($file_l,$res_href_l)=@_;
    #file_l='01_configs/01d_conf_bond_opts'
    #res_href_l = hash ref for %h01d_conf_bond_opts_hash_g
    my $proc_name_l=(caller(0))[3];

    my ($exec_res_l)=(undef);
    my ($hkey0_l,$hval0_l)=(undef,undef);
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
	
	# clear vars
	###
    }
    
    # clear vars
    ($hkey0_l,$hval0_l)=(undef,undef);
    ###
    
    if ( $return_str_l!~/^OK$/ ) { return $return_str_l; }

    # fill result hash
    %{$res_href_l}=%res_tmp_lv1_l;
    ###
    
    return $return_str_l;
}
######new (end)

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
