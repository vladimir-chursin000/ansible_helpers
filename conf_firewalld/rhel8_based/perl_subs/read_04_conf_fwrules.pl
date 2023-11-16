###DEPENDENCIES: read_conf_fwrules_common.pl, value_check.pl

sub read_04_conf_forward_ports_sets {
    my ($file_l,$res_href_l)=@_;
    #file_l=$f04_conf_forward_ports_sets_path_g
    #res_href_l=hash-ref for %h04_conf_forward_ports_sets_hash_g
    my $proc_name_l=(caller(0))[3];

    #[some_forward_ports_set_name:BEGIN]
    #port=80:proto=tcp:toport=8080:toaddr=192.168.1.60 (example)
    #port=80:proto=tcp:toport=8080 (example)
    #[some_forward_ports_set_name:END]
    ###
    #$h04_conf_forward_ports_sets_hash_g{set_name}->
        #{'rule-0'}=1
        #{'rule-1'}=1
        #etc
        #{'seq'}=[val-0,val-1] (val=rule)

    my $exec_res_l=undef;
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my ($hkey1_l,$hval1_l)=(undef,undef);
    my ($from_port_l,$to_port_l,$proto_l,$to_addr_l)=(undef,undef,undef,'localhost');
    my ($port_str4check0_l,$port_str4check1_l)=(undef,undef);
    my $return_str_l='OK';

    my %res_tmp_lv0_l=();
        #key=rule, value=value filtered by regex

    $exec_res_l=&read_param_only_templates_from_config($file_l,\%res_tmp_lv0_l);
    #$file_l,$res_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }

    # check rules with regex
    while ( ($hkey0_l,$hval0_l)=each %res_tmp_lv0_l ) { # cycle 0
        #hkey0_l=tmplt_name, hval0_l=hash ref where key=rule
        ###
        while ( ($hkey1_l,$hval1_l)=each %{$hval0_l} ) { # cycle 1
            #hkey1_l=rule
            #port=80:proto=tcp:toport=8080:toaddr=192.168.1.60 (example)
            #port=80:proto=tcp:toport=8080 (example)
            if ( $hkey1_l!~/^seq$/ ) {
                if ( $hkey1_l=~/^port\=(\d+)\:proto\=(\S+)\:toport\=(\d+)$/ ) {
                    $from_port_l=$1; $proto_l=$2; $to_port_l=$3;
                    $port_str4check0_l=$from_port_l.'/'.$proto_l;
                    $port_str4check1_l=$to_port_l.'/'.$proto_l;
                    $to_addr_l='localhost';
                }
                elsif ( $hkey1_l=~/^port\=(\d+)\:proto\=(\S+)\:toport\=(\d+)\:toaddr\=(\S+)$/ ) {
                    $from_port_l=$1; $proto_l=$2; $to_port_l=$3; $to_addr_l=$4;
                    $port_str4check0_l=$from_port_l.'/'.$proto_l;
                    $port_str4check1_l=$to_port_l.'/'.$proto_l;
                }
                else {
                    $return_str_l="fail [$proc_name_l]. Rule for port forwarding must be like 'port=80:proto=tcp:toport=8080:toaddr=192.168.1.60' or 'port=80:proto=tcp:toport=8080' (for example)";
                    last;
                }

                if ( $proto_l!~/^tcp$|^udp$|^sctp$|^dccp$/ ) {
                    $return_str_l="fail [$proc_name_l]. Proto must be like 'tcp/udp/sctp/dccp'";
                    last;
                }
                
                $exec_res_l=&check_port_for_apply_to_fw_conf($port_str4check0_l);
                #$port_str_l
                if ( $exec_res_l=~/^fail/ ) {
                    $return_str_l="fail [$proc_name_l] -> ".$exec_res_l;
                    last;
                }
                
                $exec_res_l=&check_port_for_apply_to_fw_conf($port_str4check1_l);
                #$port_str_l
                if ( $exec_res_l=~/^fail/ ) {
                    $return_str_l="fail [$proc_name_l] -> ".$exec_res_l;
                    last;
                }
                
                if ( $to_addr_l!~/^localhost$/ && $to_addr_l=~/^\d{1,3}\./ && $to_addr_l!~/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/ ) { #check ipv4
                    $return_str_l="fail [$proc_name_l]. The IPv4 addr must be like 'xxx.yyy.zzz.qqq'";
                    last;
                }
            }
            
            ($from_port_l,$to_port_l,$proto_l,$to_addr_l)=(undef,undef,undef,undef);

        } # cycle 1

        $exec_res_l=undef;
        ($hkey1_l,$hval1_l)=(undef,undef);
        ($from_port_l,$to_port_l,$proto_l,$to_addr_l)=(undef,undef,undef,undef);

        if ( $return_str_l!~/^OK$/ ) { last; }
    } # cycle 0

    $exec_res_l=undef;
    ($hkey0_l,$hval0_l)=(undef,undef);
    ($hkey1_l,$hval1_l)=(undef,undef);
    ($from_port_l,$to_port_l,$proto_l,$to_addr_l)=(undef,undef,undef,undef);

    if ( $return_str_l!~/^OK$/ ) { return $return_str_l; }
    ###

    # fill result hash
    %{$res_href_l}=%res_tmp_lv0_l;
    ###

    %res_tmp_lv0_l=();

    return $return_str_l;
}

sub read_04_conf_forward_ports_sets_v2 {
    my ($file_l,$inv_hosts_href_l,$divisions_for_inv_hosts_href_l,$res_href_l)=@_;
    #file_l=$f04_conf_forward_ports_sets_path_g
    #inv_hosts_href_l=hash-ref for %inventory_hosts_g
    #$divisions_for_inv_hosts_href_l=hash-ref for %h00_conf_divisions_for_inv_hosts_hash_g
        #$h00_conf_divisions_for_inv_hosts_hash_g{group_name}{inv-host}=1;
    #res_href_l=hash-ref for %h04_conf_forward_ports_sets_hash_g
    my $proc_name_l=(caller(0))[3];

    #[some_forward_ports_set_name:BEGIN]
    #INVENTORY_HOST         #fw_port        #fw_proto       #fw_toport      #fw_toaddr
    #all                    80              tcp             8080            192.168.1.60 (example, prio = 0)
    #gr_some_example_group  80              tcp             8080            192.168.1.60 (example, prio = 1)
    #10.1.2.2,10.1.2.4      80              tcp             8080            192.168.1.60 (example, prio = 2)
    #10.1.2.2               80              tcp             8080            192.168.1.60 (example, prio => 2)
    #[some_forward_ports_set_name:END]
    ###
    #$h04_conf_forward_ports_sets_hash_g{inv_host}{set_name}->
        #{'rule-0'}=1 # rule like 'port=80:proto=tcp:toport=8080:toaddr=192.168.1.60'
        #{'rule-1'}=1
        #etc
        #{'seq'}=[val-0,val-1] (val=rule)

    my $exec_res_l=undef;
    my $arr_el0_l=undef;
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my ($hkey1_l,$hval1_l)=(undef,undef);
    my ($hkey2_l,$hval2_l)=(undef,undef);
    my ($from_port_l,$to_port_l,$proto_l,$to_addr_l)=(undef,undef,undef,'localhost');
    my ($port_str4check0_l,$port_str4check1_l)=(undef,undef);
    my @rule_params_l=();
    my @tmp_arr0_l=();
    my $return_str_l='OK';

    my %res_tmp_lv0_l=();
        #key=set_tmplt_name, value=
	    #{'string with rule params-1'}
	    #{'string with rule params-2'}
	    #etc
	    #{'seq'}=['string with rule params-1', 'string with rule params-2', etc]
    my %res_tmp_lv1_l=(); # like '$h04_conf_forward_ports_sets_hash_g'

    $exec_res_l=&read_param_only_templates_from_config($file_l,\%res_tmp_lv0_l);
    #$file_l,$res_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }

    # check rules and save res to '%res_tmp_lv0_l' (begin)
    while ( ($hkey0_l,$hval0_l)=each %res_tmp_lv0_l ) { # cycle 0
        #hkey0_l=set_tmplt_name, hval0_l=hash ref where key=string with rule params
        
	delete($res_tmp_lv0_l{$hkey0_l}{'seq'}); # seq-array don't need here
	
	# block for checks of strings with rule params (begin)
        while ( ($hkey1_l,$hval1_l)=each %{$hval0_l} ) {
	    #hkey1_l=string with rule params
	    #string with rule params = #INVENTORY_HOST         #fw_port        #fw_proto       #fw_toport      #fw_toaddr
	    
	    (@rule_params_l)=$hkey1_l=~/(\S+)/g;
	    # 0=INVENTORY_HOST, 1=fw_port, 2=fw_proto, 3=fw_toport, 4=fw_toaddr
	    
	    ###
	    $exec_res_l=&check_inv_host_by_type($rule_params_l[0],$inv_hosts_href_l,$divisions_for_inv_hosts_href_l);
	    #$inv_host_l,$inv_hosts_href_l,$divisions_for_inv_hosts_href_l
	    if ( $exec_res_l=~/^fail/ ) {
		$return_str_l="fail [$proc_name_l] -> ".$exec_res_l;
		last;
	    }
	    $exec_res_l=undef;
	    ###
	    
	    ###
	    $exec_res_l=&simple_port_check($rule_params_l[1],'fw_port');
	    #$port_l,$port_name_l
	    if ( $exec_res_l=~/^fail/ ) {
		$return_str_l="fail [$proc_name_l] -> ".$exec_res_l;
		last;
	    }
	    $exec_res_l=undef;
	    ###

	    ###
	    $exec_res_l=&check_forward_port_protocol($rule_params_l[2]);
	    #$proto_l
	    if ( $exec_res_l=~/^fail/ ) {
		$return_str_l="fail [$proc_name_l] -> ".$exec_res_l;
		last;
	    }
	    $exec_res_l=undef;
	    ###

	    ###
	    $exec_res_l=&simple_port_check($rule_params_l[3],'fw_toport');
	    #$port_l,$port_name_l
	    if ( $exec_res_l=~/^fail/ ) {
		$return_str_l="fail [$proc_name_l] -> ".$exec_res_l;
		last;
	    }
	    $exec_res_l=undef;
	    ###

	    ###
	    $exec_res_l=&check_ipv4_addr_for_port_forwarding($rule_params_l[4]);
	    #$port_l,$port_name_l
	    if ( $exec_res_l=~/^fail/ ) {
		$return_str_l="fail [$proc_name_l] -> ".$exec_res_l;
		last;
	    }
	    $exec_res_l=undef;
	    ###

	    # clear vars
	    $exec_res_l=undef;
	    @rule_params_l=();
	    ###
        }
	
	if ( $return_str_l!~/^OK$/ ) { last; }
	# block for checks of strings with rule params (end)
	
	# block for 'all' (begin)
        while ( ($hkey1_l,$hval1_l)=each %{$hval0_l} ) {
	    #hkey1_l=string with rule params
	    #string with rule params = #INVENTORY_HOST         #fw_port        #fw_proto       #fw_toport      #fw_toaddr
	    
	    (@rule_params_l)=$hkey1_l=~/(\S+)/g;
	    # 0=INVENTORY_HOST, 1=fw_port, 2=fw_proto, 3=fw_toport, 4=fw_toaddr
	    
	    if ( $rule_params_l[0]=~/^all$/ ) {
		while ( ($hkey2_l,$hval2_l)=each %{$inv_hosts_href_l} ) {
		    #$hkey2_l=inv-host from inventory
		    
		}

		# clear vars
		($hkey2_l,$hval2_l)=(undef,undef);
		###
		
		delete($res_tmp_lv0_l{$hkey0_l}{$hkey1_l});
	    }
	    
	    # clear vars
	    @rule_params_l=();
	    ###
        }
	
	if ( $return_str_l!~/^OK$/ ) { last; }
	# block for 'all' (end)

	# block for 'groups' (begin)
        while ( ($hkey1_l,$hval1_l)=each %{$hval0_l} ) {
	    #hkey1_l=string with rule params
	    #string with rule params = #INVENTORY_HOST         #fw_port        #fw_proto       #fw_toport      #fw_toaddr
	    
	    (@rule_params_l)=$hkey1_l=~/(\S+)/g;
	    # 0=INVENTORY_HOST, 1=fw_port, 2=fw_proto, 3=fw_toport, 4=fw_toaddr
	    
	    if ( $rule_params_l[0]=~/^(gr_\S+)$/ ) {
		while ( ($hkey2_l,$hval2_l)=each %{${$divisions_for_inv_hosts_href_l}{$rule_params_l[0]}} ) {
		    #$hkey2_l=inv-host from '00_conf_divisions_for_inv_hosts' by group name
		    
		}
		
		# clear vars
		($hkey2_l,$hval2_l)=(undef,undef);
		###

		delete($res_tmp_lv0_l{$hkey0_l}{$hkey1_l});
	    }
	    
	    # clear vars
	    @rule_params_l=();
	    ###
        }
	
	if ( $return_str_l!~/^OK$/ ) { last; }
	# block for 'groups' (end)

	# block for 'host_list' (begin)
        while ( ($hkey1_l,$hval1_l)=each %{$hval0_l} ) {
	    #hkey1_l=string with rule params
	    #string with rule params = #INVENTORY_HOST         #fw_port        #fw_proto       #fw_toport      #fw_toaddr
	    
	    (@rule_params_l)=$hkey1_l=~/(\S+)/g;
	    # 0=INVENTORY_HOST, 1=fw_port, 2=fw_proto, 3=fw_toport, 4=fw_toaddr
	    
	    if ( $rule_params_l[0]=~/^\S+\,\S+/ ) {
		@tmp_arr0_l=split(/\,/,$rule_params_l[0]); # array of hosts
		
		foreach $arr_el0_l ( @tmp_arr0_l ) {
		    #$arr_el0_l=inv-host from host_list
		    
		}
		
		delete($res_tmp_lv0_l{$hkey0_l}{$hkey1_l});
		
		# clear vars
		$arr_el0_l=undef;
		@tmp_arr0_l=();
		###
	    }
	    
	    # clear vars
	    @rule_params_l=();
	    ###
        }
	
	if ( $return_str_l!~/^OK$/ ) { last; }
	# block for 'host_list' (end)

	# block for 'single_host' (begin)
        while ( ($hkey1_l,$hval1_l)=each %{$hval0_l} ) {
	    #hkey1_l=string with rule params
	    #string with rule params = #INVENTORY_HOST         #fw_port        #fw_proto       #fw_toport      #fw_toaddr
	    
	    (@rule_params_l)=$hkey1_l=~/(\S+)/g;
	    # 0=INVENTORY_HOST, 1=fw_port, 2=fw_proto, 3=fw_toport, 4=fw_toaddr
	    
	    if ( $rule_params_l[0]=~/^\S+\$/ && $rule_params_l[0]!~/\,|^all|^gr_/ ) {
		
		delete($res_tmp_lv0_l{$hkey0_l}{$hkey1_l});
	    }
	    
	    # clear vars
	    @rule_params_l=();
	    ###
        }
	# block for 'single_host' (end)
	
	# clear vars
        $exec_res_l=undef;
        ($hkey1_l,$hval1_l)=(undef,undef);
        ($from_port_l,$to_port_l,$proto_l,$to_addr_l)=(undef,undef,undef,undef);
	@rule_params_l=();
	###

        if ( $return_str_l!~/^OK$/ ) { last; }
    } # cycle 0
    
    # clear vars
    $exec_res_l=undef;
    ($hkey0_l,$hval0_l)=(undef,undef);
    ($hkey1_l,$hval1_l)=(undef,undef);
    ($from_port_l,$to_port_l,$proto_l,$to_addr_l)=(undef,undef,undef,undef);
    @rule_params_l=();
    ###

    if ( $return_str_l!~/^OK$/ ) { return $return_str_l; }
    # check rules and save res to '%res_tmp_lv0_l' (end)

    # fill result hash
    %{$res_href_l}=%res_tmp_lv0_l;
    ###

    %res_tmp_lv0_l=();

    return $return_str_l;
}



#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
