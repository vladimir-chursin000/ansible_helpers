###DEPENDENCIES: read_conf_fwrules_common.pl

sub read_05_conf_rich_rules_sets_v2 {
    my ($file_l,$inv_hosts_href_l,$divisions_for_inv_hosts_href_l,$res_href_l)=@_;
    #file_l=$f05_conf_rich_rules_sets_path_g
    #inv_hosts_href_l=hash-ref for %inventory_hosts_g
    #$divisions_for_inv_hosts_href_l=hash-ref for %h00_conf_divisions_for_inv_hosts_hash_g
        #$h00_conf_divisions_for_inv_hosts_hash_g{group_name}{inv-host}=1;
    #res_href_l=hash-ref for %h05_conf_rich_rules_sets_hash_g
    my $proc_name_l=(caller(0))[3];

    #[some_rich_rules_set_name:BEGIN]
    ##INVENTORY_HOST                #RICH_RULE
    #all                    "some_rich_rule_N1-content" (example, prio = 0)
    #gr_some_example_group  "some_rich_rule_N1-content" (example, prio = 1)
    #10.1.2.2,10.1.2.4      "some_rich_rule_N1-content" (example, prio = 2)
    #10.1.2.2               "some_rich_rule_N1-content" (example, prio => 2)
    #[some_rich_rules_set_name:END]
    ###
    #$h05_conf_rich_rules_sets_hash_g{inv_host}{set_name}->
        #{'rule-0'}=1 # rule like 'rule family=ipv4 source address=192.168.55.4/32 destination address=10.10.7.0/24 masquerade'
        #{'rule-1'}=1
        #etc
        #{'seq'}=[val-0,val-1] (val=rule)

    my $exec_res_l=undef;
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my ($hkey1_l,$hval1_l)=(undef,undef);
    my ($hkey2_l,$hval2_l)=(undef,undef);
    my @rule_params_l=();
    my $return_str_l='OK';

    my %res_tmp_lv0_l=();
        #key=set_tmplt_name, value=
            #{'string with rule params-1'}
            #{'string with rule params-2'}
            #etc
            #{'seq'}=['string with rule params-1', 'string with rule params-2', etc]
    my %res_tmp_lv1_l=(); # like '$h05_conf_rich_rules_sets_hash_g'

    $exec_res_l=&read_param_only_templates_from_config($file_l,\%res_tmp_lv0_l);
    #$file_l,$res_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }
    
    # check rules and save res to '%res_tmp_lv1_l' (begin)
    while ( ($hkey0_l,$hval0_l)=each %res_tmp_lv0_l ) { # cycle 0
        #hkey0_l=tmplt_name, hval0_l=hash ref where key=string with rule params
    	
	delete($res_tmp_lv0_l{$hkey0_l}{'seq'}); # seq-array don't need here
	
	# block for checks of strings with rule params (begin)
        while ( ($hkey1_l,$hval1_l)=each %{$hval0_l} ) {
            #hkey1_l=string with rule params
	    #string with rule params = #INVENTORY_HOST	#RICH_RULE
	    
	    (@rule_params_l)=$hkey1_l=~/^(\S+) \"(.*)\"$/;
            # 0=INVENTORY_HOST, 1=RICH_RULE
	
	    if ( $#rule_params_l!=1 ) {
                $return_str_l="fail [$proc_name_l]. String with rule params ('$hkey1_l') is incorrect. It should contain 2 parameters";
                last;
            }
	
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
	    # CHECK 'RICH_RULE' (maybe, future functionality)
	    ###
	    
	    # clear vars
            $exec_res_l=undef;
            @rule_params_l=();
            ###
        }
       
        if ( $return_str_l!~/^OK$/ ) { last; }
	# block for checks of strings with rule params (end)
	
	# block for 'single_host' (prio >= 2/high) (begin)
        while ( ($hkey1_l,$hval1_l)=each %{$hval0_l} ) {
            #hkey1_l=string with rule params
	    #string with rule params = #INVENTORY_HOST  #RICH_RULE
	    
	    (@rule_params_l)=$hkey1_l=~/^(\S+) \"(.*)\"$/;
	    # 0=INVENTORY_HOST, 1=RICH_RULE
	
            if ( $rule_params_l[0]=~/^\S+$/ && $rule_params_l[0]!~/\,|^all|^gr_/ ) {
		if ( !exists($res_tmp_lv1_l{$rule_params_l[0]}{$hkey0_l}{$rule_params_l[0]}) ) {
            	    $res_tmp_lv1_l{$rule_params_l[0]}{$hkey0_l}{$rule_params_l[0]}=1;
            	    push(@{$res_tmp_lv1_l{$rule_params_l[0]}{$hkey0_l}{'seq'}},$rule_params_l[0]);
		}
		
		delete($res_tmp_lv0_l{$hkey0_l}{$hkey1_l});
            }
            
            # clear vars
            @rule_params_l=();
            ###
	}
	# block for 'single_host' (prio >= 2/high) (end)
	
	# block for 'host_list' (prio = 2) (begin)
        while ( ($hkey1_l,$hval1_l)=each %{$hval0_l} ) {
            #hkey1_l=string with rule params
	    #string with rule params = #INVENTORY_HOST  #RICH_RULE
	    
	    (@rule_params_l)=$hkey1_l=~/^(\S+) \"(.*)\"$/;
	    # 0=INVENTORY_HOST, 1=RICH_RULE
	    
            if ( $rule_params_l[0]=~/^\S+\,\S+/ ) {
                @tmp_arr0_l=split(/\,/,$rule_params_l[0]); # array of hosts
	    
                foreach $arr_el0_l ( @tmp_arr0_l ) {
                    #$arr_el0_l=inv-host from host_list
	    
                    if ( !exists($res_tmp_lv1_l{$arr_el0_l}) ) {
			if ( !exists($res_tmp_lv1_l{$arr_el0_l}{$hkey0_l}{$rule_params_l[1]}) ) {
                    	    $res_tmp_lv1_l{$arr_el0_l}{$hkey0_l}{$rule_params_l[1]}=1;
                    	    push(@{$res_tmp_lv1_l{$arr_el0_l}{$hkey0_l}{'seq'}},$rule_params_l[1]);
			}
                    }
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
	# block for 'host_list' (prio = 2) (end)
	
	# block for 'groups' (prio = 1) (begin)
        while ( ($hkey1_l,$hval1_l)=each %{$hval0_l} ) {
            #hkey1_l=string with rule params
	    #string with rule params = #INVENTORY_HOST  #RICH_RULE
	    
	    (@rule_params_l)=$hkey1_l=~/^(\S+) \"(.*)\"$/;
	    # 0=INVENTORY_HOST, 1=RICH_RULE
	    
            if ( $rule_params_l[0]=~/^gr_\S+$/ ) {
                while ( ($hkey2_l,$hval2_l)=each %{${$divisions_for_inv_hosts_href_l}{$rule_params_l[0]}} ) {
                    #$hkey2_l=inv-host from '00_conf_divisions_for_inv_hosts' by group name
		
                    if ( !exists($res_tmp_lv1_l{$hkey2_l}) ) {
			if ( !exists($res_tmp_lv1_l{$hkey2_l}{$hkey0_l}{$rule_params_l[1]}) ) {
                    	    $res_tmp_lv1_l{$hkey2_l}{$hkey0_l}{$rule_params_l[1]}=1;
                    	    push(@{$res_tmp_lv1_l{$hkey2_l}{$hkey0_l}{'seq'}},$rule_params_l[1]);
			}
                    }
                }
                
		delete($res_tmp_lv0_l{$hkey0_l}{$hkey1_l});
		
                # clear vars
                ($hkey2_l,$hval2_l)=(undef,undef);
                ###
            }
	
            # clear vars
            @rule_params_l=();
            ###
        }
	# block for 'groups' (prio = 1) (end)
	
	# block for 'all' (prio = 0/min) (begin)
        while ( ($hkey1_l,$hval1_l)=each %{$hval0_l} ) {
            #hkey1_l=string with rule params
	    #string with rule params = #INVENTORY_HOST  #RICH_RULE
	    
	    (@rule_params_l)=$hkey1_l=~/^(\S+) \"(.*)\"$/;
	    # 0=INVENTORY_HOST, 1=RICH_RULE
	    
            if ( $rule_params_l[0]=~/^all$/ ) {
                while ( ($hkey2_l,$hval2_l)=each %{$inv_hosts_href_l} ) {
                    #$hkey2_l=inv-host from inventory
		
                    if ( !exists($res_tmp_lv1_l{$hkey2_l}) ) {
			if ( !exists($res_tmp_lv1_l{$hkey2_l}{$hkey0_l}{$rule_params_l[1]}) ) {
                    	    $res_tmp_lv1_l{$hkey2_l}{$hkey0_l}{$rule_params_l[1]}=1;
                    	    push(@{$res_tmp_lv1_l{$hkey2_l}{$hkey0_l}{'seq'}},$rule_params_l[1]);
			}
                    }
                }
                
		delete($res_tmp_lv0_l{$hkey0_l}{$hkey1_l});
		
                # clear vars
                ($hkey2_l,$hval2_l)=(undef,undef);
                ###
            }
	    
            # clear vars
            @rule_params_l=();
            ###
        }
	# block for 'all' (prio = 0/min) (end)
	
	# clear vars
        $exec_res_l=undef;
        ($hkey1_l,$hval1_l)=(undef,undef);
        @rule_params_l=();
        ###
    } # cycle 0
    
    # clear vars
    $exec_res_l=undef;
    ($hkey0_l,$hval0_l)=(undef,undef);
    ($hkey1_l,$hval1_l)=(undef,undef);
    ($hkey2_l,$hval2_l)=(undef,undef);
    @rule_params_l=();
    ###
    
    if ( $return_str_l!~/^OK$/ ) { return $return_str_l; }
    # check rules and save res to '%res_tmp_lv1_l' (end)

    # fill result hash
    %{$res_href_l}=%res_tmp_lv1_l;
    ###

    %res_tmp_lv0_l=();
    %res_tmp_lv1_l=();

    return $return_str_l;
}

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
