###DEPENDENCIES: read_conf_fwrules_common.pl

sub read_02_2_conf_allowed_ports_sets {
    my ($file_l,$inv_hosts_href_l,$divisions_for_inv_hosts_href_l,$res_href_l)=@_;
    #file_l=$f02_2_conf_allowed_ports_sets_path_g
    #inv_hosts_href_l=hash-ref for %inventory_hosts_g
    #$divisions_for_inv_hosts_href_l=hash-ref for %h00_conf_divisions_for_inv_hosts_hash_g
        #$h00_conf_divisions_for_inv_hosts_hash_g{group_name}{inv-host}=1;
    #res_href_l=hash-ref for %h02_2_conf_allowed_ports_sets_hash_g
    my $proc_name_l=(caller(0))[3];
    #[ports_set1:BEGIN]
    #all=1122/tcp,1133/udp
    #gr_some_example_group=1122/tcp,1133/tcp,1133/udp
    #192.168.144.12,192.168.100.14,192.110.144.16=11221/tcp,11331/udp
    #192.168.144.12=11222-11333/tcp
    #[ports_set1:END]
    ###
    #$h02_2_conf_allowed_ports_sets_hash_g{inv-host}{set_name}->
    	#{'port-0'}=1
    	#{'port-1'}=1
    	#etc
    	#{'seq'}=[val-0,val-1] (val=port)
    
    my $exec_res_l=undef;
    my ($arr_el0_l,$arr_el1_l)=(undef,undef);
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my ($hkey1_l,$hval1_l)=(undef,undef);
    my @tmp_arr0_l=();
    my @host_list_l=();
    my @params_arr_l=();
    my @ports_l=();
    my $return_str_l='OK';
    
    my %res_tmp_lv0_l=();
        #key=set_tmplt_name, value=
            #{'string with rule params-1'}
            #{'string with rule params-2'}
            #etc
            #{'seq'}=['string with rule params-1', 'string with rule params-2', etc]
    my %res_tmp_lv1_l=(); # like '%h02_2_conf_allowed_ports_sets_hash_g'
    
    $exec_res_l=&read_param_only_templates_from_config($file_l,\%res_tmp_lv0_l);
    #$file_l,$res_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }
    
    # check rules and save res to '%res_tmp_lv1_l' (begin)
    while ( ($hkey0_l,$hval0_l)=each %res_tmp_lv0_l ) { # cycle 0
        #hkey0_l=set_name, hval0_l=hash ref where key=string with rule params
	
        delete($res_tmp_lv0_l{$hkey0_l}{'seq'}); # seq-array don't need here
	
        # block for checks of strings with rule params (begin)   
        while ( ($hkey1_l,$hval1_l)=each %{$hval0_l} ) {
            #hkey1_l=string with rule params
	    #string with rule params="host=param1,param2,etc"
	    
	    @tmp_arr0_l=split(/\=/,$hkey1_l);
	    # 0 - host-id (all/group/list_of_hosts/single_host), 1 - str with params
	    
	    @params_arr_l=split(/\,/,$tmp_arr0_l[1]);
	    
            if ( $#tmp_arr0_l!=1 ) {
                $return_str_l="fail [$proc_name_l]. String with rule params ('$hkey1_l') is incorrect. It should be like 'host=params'";
                last;
            }
	    
            ###
            $exec_res_l=&check_inv_host_by_type($tmp_arr0_l[0],$inv_hosts_href_l,$divisions_for_inv_hosts_href_l);
            #$inv_host_l,$inv_hosts_href_l,$divisions_for_inv_hosts_href_l
            if ( $exec_res_l=~/^fail/ ) {
                $return_str_l="fail [$proc_name_l] -> ".$exec_res_l;
                last;
            }
            $exec_res_l=undef;
            ###
	    
	    ###
	    foreach $arr_el0_l ( @params_arr_l ) {
		#$arr_el0_l=port
		
		$exec_res_l=&check_port_for_apply_to_fw_conf($arr_el0_l);
        	#$port_str_l
        	if ( $exec_res_l=~/^fail/ ) {
            	    $return_str_l="fail [$proc_name_l] -> ".$exec_res_l;
            	    last;
        	}
		$exec_res_l=undef;
	    }
	    
	    if ( $return_str_l!~/^OK$/ ) { last; }
	    ###
	    
            # clear vars
            @tmp_arr0_l=();
	    @params_arr_l=();
            ###
        }
	
        if ( $return_str_l!~/^OK$/ ) { last; }
        # block for checks of strings with rule params (end)
	
        # block for 'single_host' (prio >= 2/high) (begin)
        while ( ($hkey1_l,$hval1_l)=each %{$hval0_l} ) {
            #hkey1_l=string with rule params
            #string with rule params="host=param1,param2,etc"
	    
            @tmp_arr0_l=split(/\=/,$hkey1_l);
            # 0 - host-id (all/group/list_of_hosts/single_host), 1 - str with params
	    
            if ( $tmp_arr0_l[0]=~/^\S+$/ && $tmp_arr0_l[0]!~/\,|^all|^gr_/ ) {
		@params_arr_l=split(/\,/,$tmp_arr0_l[1]);
		
                foreach $arr_el0_l ( @params_arr_l ) {
                    if ( !exists($res_tmp_lv1_l{$tmp_arr0_l[0]}{$hkey0_l}{$arr_el0_l}) ) {
                        $res_tmp_lv1_l{$tmp_arr0_l[0]}{$hkey0_l}{$arr_el0_l}=1;
                        push(@{$res_tmp_lv1_l{$tmp_arr0_l[0]}{$hkey0_l}{'seq'}},$arr_el0_l);
                    }
                }
		
		delete($res_tmp_lv0_l{$hkey0_l}{$hkey1_l});
		
                # clear vars
                @params_arr_l=();
                ###
            }
            
            # clear vars
            @tmp_arr0_l=();
            ###
        }
        # block for 'single_host' (end)
	
        # block for 'host_list' (prio = 2) (begin)
        while ( ($hkey1_l,$hval1_l)=each %{$hval0_l} ) {
            #hkey1_l=string with rule params
            #string with rule params="host=param1,param2,etc"
	    
            @tmp_arr0_l=split(/\=/,$hkey1_l);
            # 0 - host-id (all/group/list_of_hosts/single_host), 1 - str with params
	    
            if ( $tmp_arr0_l[0]=~/^\S+\,\S+/ ) {
                @host_list_l=split(/\,/,$tmp_arr0_l[0]);
                @params_arr_l=split(/\,/,$tmp_arr0_l[1]);
	    
                foreach $arr_el0_l ( @host_list_l ) {
                    #$arr_el0_l=inv-host
                    if ( !exists($res_tmp_lv1_l{$arr_el0_l}) ) {
                        foreach $arr_el1_l ( @params_arr_l ) {
                            if ( !exists($res_tmp_lv1_l{$arr_el0_l}{$hkey0_l}{$arr_el1_l}) ) {
                                #$res_tmp_lv1_l{inv-host}{set_name}
                                $res_tmp_lv1_l{$arr_el0_l}{$hkey0_l}{$arr_el1_l}=1;
                                push(@{$res_tmp_lv1_l{$arr_el0_l}{$hkey0_l}{'seq'}},$arr_el1_l);
                            }
                        }
                    }
                }
	    	
	    	delete($res_tmp_lv0_l{$hkey0_l}{$hkey1_l});
	    
                # clear vars
	    	($arr_el0_l,$arr_el1_l)=(undef,undef);
                @host_list_l=();
                @params_arr_l=();
                ###
            }
            
            # clear vars
            @tmp_arr0_l=();
            ###
        }
        # block for 'host_list' (end)
	
        # block for 'groups' (prio = 1) (begin)
        while ( ($hkey1_l,$hval1_l)=each %{$hval0_l} ) {
            #hkey1_l=string with rule params
            #string with rule params="host=param1,param2,etc"
	    
            @tmp_arr0_l=split(/\=/,$hkey1_l);
            # 0 - host-id (all/group/list_of_hosts/single_host), 1 - str with params
	    
            if ( $tmp_arr0_l[0]=~/^gr_\S+$/ ) {
		
		delete($res_tmp_lv0_l{$hkey0_l}{$hkey1_l});
            }
	    
            # clear vars
            @tmp_arr0_l=();
            ###
        }
        # block for 'groups' (end)
	
        # block for 'all' (prio = 0/min) (begin)
        while ( ($hkey1_l,$hval1_l)=each %{$hval0_l} ) {
            #hkey1_l=string with rule params
            #string with rule params="host=param1,param2,etc"
	
            @tmp_arr0_l=split(/\=/,$hkey1_l);
            # 0 - host-id (all/group/list_of_hosts/single_host), 1 - str with params
	
            if ( $tmp_arr0_l[0]=~/^all$/ ) {
		
		delete($res_tmp_lv0_l{$hkey0_l}{$hkey1_l});
            }
	
            # clear vars
            @tmp_arr0_l=();
            ###
        }
        # block for 'all' (end)
	
        # clear vars
        $exec_res_l=undef;
        ($hkey1_l,$hval1_l)=(undef,undef);
        @tmp_arr0_l=();
        ###
    } # cycle 0
    
    # clear vars
    $exec_res_l=undef;
    ($hkey0_l,$hval0_l)=(undef,undef);
    ($hkey1_l,$hval1_l)=(undef,undef);
    @tmp_arr0_l=();
    ###
    
    if ( $return_str_l!~/^OK$/ ) { return $return_str_l; }
    # check rules and save res to '%res_tmp_lv1_l' (end)
    
    return $return_str_l;
}

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )