###NO DEPENDENCIES

sub check_port_for_apply_to_fw_conf {
    my ($port_str_l)=@_;
    #port=NUM/udp, NUM/tcp, NUM_begin-NUM_end/tcp, NUM_begin-NUM_end/udp (sctp and dccp)
    my $proc_name_l=(caller(0))[3];
    
    my ($port_num0_l,$port_num1_l)=(undef,undef);
    my $return_str_l='OK';
    
    if ( $port_str_l=~/^(\d+)\/tcp$|^(\d+)\/udp$|^(\d+)\/sctp$|^(\d+)\/dccp$/ ) {
	($port_num0_l)=$port_str_l=~/^(\d+)\//;
	$port_num0_l=int($port_num0_l);
	if ( $port_num0_l<1 or $port_num0_l>65535 ) {
	    return "fail [$proc_name_l]. Port number must be >= 1 and <= 65535";
	}
    }
    elsif ( $port_str_l=~/^\d+\-\d+\/tcp$|^\d+\-\d+\/udp$|^\d+\-\d+\/sctp$|^\d+\-\d+\/dccp$/ ) {
	($port_num0_l,$port_num1_l)=$port_str_l=~/^(\d+)\-(\d+)\//;
	$port_num0_l=int($port_num0_l);
	$port_num1_l=int($port_num1_l);
	if ( $port_num0_l<1 or $port_num0_l>65535 ) { return "fail [$proc_name_l]. Port number must be >= 1 and <= 65535"; }
	if ( $port_num1_l<1 or $port_num1_l>65535 ) { return "fail [$proc_name_l]. Port number must be >= 1 and <= 65535"; }
	if ( $port_num0_l>=$port_num1_l ) { return "fail [$proc_name_l]. Begin_port can not be >= end_port"; }
    }
    else {
	return "fail [$proc_name_l]. Port (or port range)='$port_str_l' is not correct. It must be like 'NUM/port_type' or 'NUMbegin-NUMend/port_type' where port_type='udp/tcp/sctp/dccp'";
    }
    
    return $return_str_l;
}

sub check_ipset_input {
    my ($ipset_val_l,$ipset_type_l,$ipset_family_l)=@_;
    
    #FOR FUTURE USING (maybe)
    my %ipset_types_regex_l=(
	###
	# can used for fwzones src
	'hash:ip' => {
	    'inet' => '',
    	    # Examples:
        	# 192.168.10.67
        	# 192.168.11.0/24
	    'inet6' => ''
	},
	'hash:ip,port' => {
	    'inet' => '',
    		# Examples:
        	    # 192.168.12.12,udp:53
        	    # 192.168.1.0/24,80-82
        	    # 192.168.1.1,vrrp:0
        	    # 192.168.1.1,80
	    'inet6' => ''
	},
	'hash:ip,mark' => {
	    'inet' => '',
    		# Examples:
        	    # 192.168.1.0/24,555
        	    # 192.168.1.1,0x63
        	    # 192.168.1.1,111236
	    'inet6' => ''
	},
	'hash:net' => {
	    'inet' => '',
    		# Examples:
        	    # 192.168.0.0/24
        	    # 10.1.0.0/16
        	    # 192.168.0/24
	    'inet6' => ''
	},
	'hash:net,port' => {
	    'inet' => '',
    		# Examples:
        	    # 192.168.0/24,25
        	    # 10.1.0.0/16,80
        	    # 192.168.0/24,25
        	    # 192.168.1.0/24,tcp:8081
	    'inet6' => ''
	},
	'hash:net,iface' => {
	    'inet' => '',
    		# Examples:
        	    # 192.168.0/24,eth0
        	    # 10.1.0.0/16,eth1
            	    # 192.168.0/24,eth0
	    'inet6' => ''
	},
	'hash:mac' => {
	    'inet' => '',
    		# Examples:
        	    # 01:02:03:04:05:06
	    'inet6' => ''
	},
	# can used for fwzones src
	###
	'hash:ip,port,ip' => {
	    'inet' => '',
        	# Examples:
            	    # 192.168.1.1,80,10.0.0.1
            	    # 192.168.1.1,udp:53,10.0.0.1
	    'inet6' => '',
	},
	'hash:ip,port,net' => {
	    'inet' => '',
		# Examples:
            	    # 192.168.1,tcp:8080,10.0.0/24
            	    # 192.168.2,25,10.1.0.0/16
            	    # 192.168.1,80.10.0.0/24
	    'inet6' => '',
	},
	'hash:net,net' => {
	    'inet' => '',
        	# Examples:
            	    # 192.168.0.0/24,10.0.1.0/24
            	    # 10.1.0.0/16,10.255.0.0/24
            	    # 192.168.0/24,192.168.54.0-192.168.54.255
	    'inet6' => '',
	},
	'hash:net,port,net' => {
	    'inet' => '',
        	# Examples:
            	    # 192.168.1.0/24,0,10.0.0/24
            	    # 192.168.2.0/24,25,10.1.0.0/16
            	    # 192.168.1.1,80,10.0.0.1
            	    # 192.168.1.2,tcp:8081,10.0.0.2
	    'inet6' => '',
	},
    );
    
    my $return_str_l='OK';
    
    return $return_str_l;    
}

sub check_inv_host_by_type {
    my ($inv_host_l,$inv_hosts_href_l,$divisions_for_inv_hosts_href_l)=@_;
    #inv_host_l = all/group_name/list_of_hosts/single_host
    #inv_hosts_href_l=hash-ref for %inventory_hosts_g
    #$divisions_for_inv_hosts_href_l=hash-ref for %h00_conf_divisions_for_inv_hosts_hash_g
        #$h00_conf_divisions_for_inv_hosts_hash_g{group_name}{inv-host}=1;
        
    my $proc_name_l=(caller(0))[3];

    my $arr_el0_l=undef;
    my @tmp_arr0_l=();

    my $return_str_l='OK';
    
    if ( $inv_host_l=~/^all$/i && $inv_host_l=~/A|L/ ) {
	$return_str_l="fail [$proc_name_l]. Incorrect inv-host='$inv_host_l'. It must be 'all'";
	return $return_str_l;
    }
    
    if ( $inv_host_l=~/^all\,|\,all\,|\,all$/ ) {
	$return_str_l="fail [$proc_name_l]. Incorrect inv-host='$inv_host_l'. It must be witout ','";
	return $return_str_l;
    }

    if ( $inv_host_l=~/gr_\S+/ && $inv_host_l=~/\,/ ) {
	$return_str_l="fail [$proc_name_l]. Incorrect inv-host/group='$inv_host_l'. It must be witout ','";
	return $return_str_l;
    }
    
    if ( $inv_host_l=~/^gr_\S+$/ && !exists(${$divisions_for_inv_hosts_href_l}{$inv_host_l}) ) {
	$return_str_l="fail [$proc_name_l]. Incorrect inv-host/group='$inv_host_l'. Group is not exists at '00_conf_divisions_for_inv_hosts'";
	return $return_str_l;
    }
    
    if ( $inv_host_l!~/^all$|^gr_\S+$/ ) {
	@tmp_arr0_l=split(/\,/,$inv_host_l);
	
	foreach $arr_el0_l ( @tmp_arr0_l ) {
	    if ( !exists(${$inv_hosts_href_l}{$arr_el0_l}) ) {
		$return_str_l="fail [$proc_name_l]. Incorrect inv-host/inv-host-list='$inv_host_l'. '$arr_el0_l' is not exists at inventory";
		return $return_str_l;
	    }
	}
	
	# clear vars
	$arr_el0_l=undef;
	@tmp_arr0_l=();
	###
    }
    
    return $return_str_l;
}
#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
