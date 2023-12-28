###DEPENDENCIES: read_conf_fwrules_common.pl

sub read_66_conf_ipsets_FIN {
    my ($file_l,$inv_hosts_href_l,$divisions_for_inv_hosts_href_l,$ipset_templates_href_l,$res_href_l)=@_;
    #$file_l=$f66_conf_ipsets_FIN_path_g
    #inv_hosts_href_l=hash-ref for %inventory_hosts_g
    #$divisions_for_inv_hosts_href_l=hash-ref for %h00_conf_divisions_for_inv_hosts_hash_g
        #$h00_conf_divisions_for_inv_hosts_hash_g{group_name}{inv-host}=1;
    #$ipset_templates_href_l=hash-ref for %h01_conf_ipset_templates_hash_g
    #$res_href_l=hash ref for %h66_conf_ipsets_FIN_hash_g

    my $proc_name_l=(caller(0))[3];

    #INVENTORY_HOST         #IPSET_NAME_TMPLT_LIST
    #all                    ipset1--TMPLT,ipset4all_public--TMPLT (example)
    #10.3.2.2               ipset4public--TMPLT (example)
    ###
    #$h66_conf_ipsets_FIN_hash_g{'temporary/permanent'}{inventory_host}->
        #{ipset_name_tmplt-0}=1;
        #{ipset_name_tmplt-1}=1;
        #etc
    ###

    my $exec_res_l=undef;
    my $arr_el0_l=undef;
    my $ipset_type_l=undef; # temporary / permanent
    my $ipset_name_l=undef;
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my @arr0_l=();
    my $return_str_l='OK';

    my %ipset_uniq_check_l=();
        #key0=inv-host, key1=ipset_name (not tmplt-name), value=1

    my %res_tmp_lv0_l=();
        #key=inv-host, value=[array of values]. IPSET_NAME_TMPLT_LIST-0
    my %res_tmp_lv1_l=();
        #final hash

    $exec_res_l=&read_config_FIN_level0($file_l,$inv_hosts_href_l,$divisions_for_inv_hosts_href_l,2,0,\%res_tmp_lv0_l);
    #$file_l,$inv_hosts_href_l,$divisions_for_inv_hosts_href_l,$needed_elements_at_line_arr_l,$add_ind4key_l,$res_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }

    # fill %res_tmp_lv1_l
    while ( ($hkey0_l,$hval0_l)=each %res_tmp_lv0_l ) {
        #hkey0_l=inv-host
        @arr0_l=split(/\,/,${$hval0_l}[0]);
        foreach $arr_el0_l ( @arr0_l ) {
            #$arr_el0_l=ipset_template_name
            #$h01_conf_ipset_templates_hash_g{'temporary/permanent'}{ipset_template_name--TMPLT}->
                #{'ipset_name'}=value
                #{'ipset_description'}=empty|value
                #{'ipset_short_description'}=empty|value
                #{'ipset_create_option_timeout'}=num
                #{'ipset_create_option_hashsize'}=num
                #{'ipset_create_option_maxelem'}=num
                #{'ipset_create_option_family'}=inet|inet6
                #{'ipset_type'}=hash:ip|hash:ip,port|hash:ip,mark|hash:net|hash:net,port|hash:net,iface|hash:mac|hash:ip,port,ip|hash:ip,port,net|hash:net,net|hash:net,port,net

            # check ipset-tmpl for exists at 'h01_conf_ipset_templates_hash_g'
            if ( exists(${$ipset_templates_href_l}{'temporary'}{$arr_el0_l}) ) {
                $ipset_type_l='temporary';
                $ipset_name_l=${$ipset_templates_href_l}{'temporary'}{$arr_el0_l}{'ipset_name'};
            }
            elsif ( exists(${$ipset_templates_href_l}{'permanent'}{$arr_el0_l}) ) {
                $ipset_type_l='permanent';
                $ipset_name_l=${$ipset_templates_href_l}{'permanent'}{$arr_el0_l}{'ipset_name'};
            }
            else {
                $return_str_l="fail [$proc_name_l]. Template '$arr_el0_l' (used at '$file_l') is not exists at '01_conf_ipset_templates'";
                last;
            }
            ###

            # check for uniq inv-host+ipset_name
            if ( exists($ipset_uniq_check_l{$hkey0_l}{$ipset_name_l}) ) {
                $return_str_l="fail [$proc_name_l]. Duplicate ipset_name='$ipset_name_l' (tmplt_name='$arr_el0_l') for inv-host='$hkey0_l' at conf '66_conf_ipsets_FIN'. Check '01_conf_ipset_templates' and '66_conf_ipsets_FIN'";
                last;
            }
            $ipset_uniq_check_l{$hkey0_l}{$ipset_name_l}=1;
            ###
                
            if ( !exists($res_tmp_lv1_l{$ipset_type_l}{$hkey0_l}{$arr_el0_l}) ) {
                $res_tmp_lv1_l{$ipset_type_l}{$hkey0_l}{$arr_el0_l}=1;
            }
            else { # duplicated value
                $return_str_l="fail [$proc_name_l]. Duplicated template name value ('$arr_el0_l') at file='$file_l' at substring='${$hval0_l}[0]'. Fix it!";
                last;
            }
        }
        
        $arr_el0_l=undef;
        $ipset_type_l=undef;
        @arr0_l=();

        if ( $return_str_l!~/^OK$/ ) { last; }
    }
    
    ($hkey0_l,$hval0_l)=(undef,undef);
    $arr_el0_l=undef;
    @arr0_l=();

    if ( $return_str_l!~/^OK$/ ) { return $return_str_l; }
    ###

    # fill result hash
    %{$res_href_l}=%res_tmp_lv1_l;
    ###

    %res_tmp_lv1_l=();

    return $return_str_l;
}

sub read_66_conf_ipsets_FIN_v2 {
    my ($file_l,$inv_hosts_href_l,$divisions_for_inv_hosts_href_l,$ipset_templates_href_l,$res_href_l)=@_;
    #$file_l=$f66_conf_ipsets_FIN_path_g
    #inv_hosts_href_l=hash-ref for %inventory_hosts_g
    #$divisions_for_inv_hosts_href_l=hash-ref for %h00_conf_divisions_for_inv_hosts_hash_g
        #$h00_conf_divisions_for_inv_hosts_hash_g{group_name}{inv-host}=1;
    #$ipset_templates_href_l=hash-ref for %h01_conf_ipset_templates_hash_g
    #$res_href_l=hash ref for %h66_conf_ipsets_FIN_hash_g
    
    my $proc_name_l=(caller(0))[3];
    
    #INVENTORY_HOST         #IPSET_NAME_TMPLT_LIST
    #all                    ipset1--TMPLT,ipset4all_public--TMPLT (example)
    #10.3.2.2               ipset4public--TMPLT (example)
    ###
    #$h66_conf_ipsets_FIN_hash_g{'temporary/permanent'}{inventory_host}->
        #{ipset_name_tmplt-0}=1;
        #{ipset_name_tmplt-1}=1;
        #etc
    ###
    
    my $exec_res_l=undef;
    my ($arr_el0_l,$arr_el1_l)=(undef,undef);
    my $ipset_type_l=undef; # temporary / permanent
    my $ipset_name_l=undef;
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my ($hkey1_l,$hval1_l)=(undef,undef);
    my @tmp_arr0_l=();
    my @host_list_l=();
    my @params_arr_l=();
    my $return_str_l='OK';
    
    my %ipset_types_l=(); # key=ipset_tmplt-name, value=ipset_type (temporary/permanent)
    
    my %ipset_uniq_check_l=();
        #key0=inv-host, key1=ipset_name (not tmplt-name), value=1
    
    my %res_tmp_lv0_l=();
        #key=string with params, value=1
    my %res_tmp_lv1_l=();
        #final hash
    
    $exec_res_l=&read_uniq_lines_with_params_from_config($file_l,\%res_tmp_lv0_l);
    #$file_l,$res_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }
    
    ### FILL %res_tmp_lv1_l (BEGIN)
    
    # block for checks of strings with rule params (begin)
    while ( ($hkey0_l,$hval0_l)=each %res_tmp_lv0_l ) {
    	#$hkey0_l = sting like 'host-id some_set0_ipset--TMPLT,some_set1_ipset--TMPLT'
    	#host-id=all/gr_***/list of hosts/single_host
    		
    	@tmp_arr0_l=split(/ /,$hkey1_l);
        # 0 - host-id (all/group/list_of_hosts/single_host), 1 - str with params
    	
    	if ( $#tmp_arr0_l!=1 ) {
    	    $return_str_l="fail [$proc_name_l]. String with rule params ('$hkey1_l') is incorrect. It should be like 'host params'";
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
    	
	# ipset-templates checks (begin)
    	@params_arr_l=split(/\,/,$tmp_arr0_l[1]);	
    	foreach $arr_el0_l ( @params_arr_l ) {
    	    #$arr_el0_l=ipset_tmplt_name
            #$h01_conf_ipset_templates_hash_g{'temporary/permanent'}{ipset_template_name--TMPLT}->
                #{'ipset_name'}=value
                #{'ipset_description'}=empty|value
                #{'ipset_short_description'}=empty|value
                #{'ipset_create_option_timeout'}=num
                #{'ipset_create_option_hashsize'}=num
                #{'ipset_create_option_maxelem'}=num
                #{'ipset_create_option_family'}=inet|inet6
                #{'ipset_type'}=hash:ip|hash:ip,port|hash:ip,mark|hash:net|hash:net,port|hash:net,iface|hash:mac|hash:ip,port,ip|hash:ip,port,net|hash:net,net|hash:net,port,net
    	    
	    # check ipset-templates for exists at 'h01_conf_ipset_templates_hash_g' (begin)
            if ( exists(${$ipset_templates_href_l}{'temporary'}{$arr_el0_l}) ) {
	    	$ipset_types_l{$arr_el0_l}='temporary';
	    	$ipset_name_l=${$ipset_templates_href_l}{'temporary'}{$arr_el0_l}{'ipset_name'};
	    }
            elsif ( exists(${$ipset_templates_href_l}{'permanent'}{$arr_el0_l}) ) {
	    	$ipset_types_l{$arr_el0_l}='permanent';
	    	$ipset_name_l=${$ipset_templates_href_l}{'permanent'}{$arr_el0_l}{'ipset_name'};
	    }
            else {
                $return_str_l="fail [$proc_name_l]. Template '$arr_el0_l' (used at '$file_l') is not exists at '01_conf_ipset_templates'";
                last;
            }
	    # check ipset-templates for exists at 'h01_conf_ipset_templates_hash_g' (end)

            # check for uniq host-id+ipset_name (begin)
            if ( exists($ipset_uniq_check_l{$tmp_arr0_l[0]}{$ipset_name_l}) ) {
                $return_str_l="fail [$proc_name_l]. Duplicate ipset_name='$ipset_name_l' (tmplt_name='$arr_el0_l') for inv-host='$hkey0_l' at conf '66_conf_ipsets_FIN'. Check '01_conf_ipset_templates' and '66_conf_ipsets_FIN'";
                last;
            }
            $ipset_uniq_check_l{$tmp_arr0_l[0]}{$ipset_name_l}=1;
            # check for uniq host-id+ipset_name (end)
	    
	    # clear vars
	    $ipset_name_l=undef;
	    ###
    	}
    	
    	# clear vars
    	$arr_el0_l=undef;
    	@tmp_arr0_l=();
    	@params_arr_l=();
    	###
    	
    	if ( $return_str_l!~/^OK$/ ) { last; }
    	# ipset-templates checks (end)
    }

    # clear vars
    ($hkey0_l,$hval0_l)=(undef,undef);
    $arr_el0_l=undef;
    @tmp_arr0_l=();
    @host_list_l=();
    @params_arr_l=();
    ###
    
    if ( $return_str_l!~/^OK$/ ) { return $return_str_l; }
    # block for checks of strings with rule params (begin)

    # block for 'single_host' (prio >= 2/high) (begin)
    while ( ($hkey0_l,$hval0_l)=each %res_tmp_lv0_l ) {
        #$hkey0_l = sting like 'host-id some_set0_ipset--TMPLT,some_set1_ipset--TMPLT'
        #host-id=all/gr_***/list of hosts/single_host
    	
    	@tmp_arr0_l=split(/ /,$hkey0_l);
        # 0 - host-id (all/group/list_of_hosts/single_host), 1 - str with params
    
    	if ( $tmp_arr0_l[0]=~/^\S+$/ && $tmp_arr0_l[0]!~/\,|^all|^gr_/ ) {
    	    @params_arr_l=split(/\,/,$tmp_arr0_l[1]);	
    	    foreach $arr_el0_l ( @params_arr_l ) {
    		#$arr_el0_l=ipset_tmplt_name
    		$ipset_type_l=$ipset_types_l{$arr_el0_l};
    		$res_tmp_lv1_l{$ipset_type_l}{$tmp_arr0_l[0]}{$arr_el0_l}=1;
    		    #$res_tmp_lv1_l{ipset_type}{inv-host}{ipset_tmplt_name}
    		    #$tmp_arr0_l[0]=inv-host
    		
    		#clear vars
    		$ipset_type_l=undef;
    		###
    	    }
    	    
    	    # clear vars
    	    $arr_el0_l=undef;
    	    @params_arr_l=();
    	    ###
    	}
    	
    	# clear vars
    	@tmp_arr0_l=();
    	###
    }
    
    # clear vars
    ($hkey0_l,$hval0_l)=(undef,undef);
    ###
    # block for 'single_host' (prio >= 2/high) (end)
    
    # block for 'host_list' (prio = 2) (begin)
    while ( ($hkey0_l,$hval0_l)=each %res_tmp_lv0_l ) {
        #$hkey0_l = sting like 'host-id some_set0_ipset--TMPLT,some_set1_ipset--TMPLT'
        #host-id=all/gr_***/list of hosts/single_host
    	
    	@tmp_arr0_l=split(/ /,$hkey0_l);
        # 0 - host-id (all/group/list_of_hosts/single_host), 1 - str with params
    	
    	if ( $tmp_arr0_l[0]=~/^\S+\,\S+/ ) {
    	    @host_list_l=split(/\,/,$tmp_arr0_l[0]);
    	    @params_arr_l=split(/\,/,$tmp_arr0_l[1]);
    	    
    	    foreach $arr_el0_l ( @host_list_l ) {
                #$arr_el0_l=inv-host
    	    	
    	    	foreach $arr_el1_l ( @params_arr_l ) {
    	    	    #$arr_el1_l=ipset_tmplt_name
    	    	    $ipset_type_l=$ipset_types_l{$arr_el1_l};
    	    	    
    	    	    if ( !exists($res_tmp_lv1_l{$ipset_type_l}{$arr_el0_l}{$arr_el1_l}) ) {
    	    		$res_tmp_lv1_l{$ipset_type_l}{$arr_el0_l}{$arr_el1_l}=1;
    	    		    #$res_tmp_lv1_l{ipset_type}{inv-host}{ipset_tmplt_name}
    	    	    }
    	    	}
    	    	
    	    	# clear vars
    	    	$arr_el1_l=undef;
    	    	###
    	    }
    	    
    	    # clear vars
    	    $arr_el0_l=undef;
    	    @host_list_l=();
    	    @params_arr_l=();
    	    ###
    	}
    	
    	# clear vars
    	@tmp_arr0_l=();
    	###
    }
    
    # clear vars
    ($hkey0_l,$hval0_l)=(undef,undef);
    ###
    # block for 'host_list' (prio = 2) (end)
    
    # block for 'groups' (prio = 1) (begin)
    while ( ($hkey0_l,$hval0_l)=each %res_tmp_lv0_l ) {
        #$hkey0_l = sting like 'host-id some_set0_ipset--TMPLT,some_set1_ipset--TMPLT'
        #host-id=all/gr_***/list of hosts/single_host
    	
    	@tmp_arr0_l=split(/ /,$hkey0_l);
        # 0 - host-id (all/group/list_of_hosts/single_host), 1 - str with params
    	
    	if ( $tmp_arr0_l[0]=~/^gr_\S+$/ ) {
    	    @params_arr_l=split(/\,/,$tmp_arr0_l[1]);
    	    
    	    while ( ($hkey1_l,$hval1_l)=each %{${$divisions_for_inv_hosts_href_l}{$tmp_arr0_l[0]}} ) {
                #$hkey1_l=inv-host from '00_conf_divisions_for_inv_hosts' by group name
    	    	
    	    	foreach $arr_el0_l ( @params_arr_l ) {
                    #$arr_el0_l=ipset_tmplt_name
                    $ipset_type_l=$ipset_types_l{$arr_el0_l};
    	    	    
    	    	    if ( !exists($res_tmp_lv1_l{$ipset_type_l}{$hkey1_l}{$arr_el0_l}) ) {
    	    	    	$res_tmp_lv1_l{$ipset_type_l}{$hkey1_l_l}{$arr_el0_l}=1;
    	    	    	    #$res_tmp_lv1_l{ipset_type}{inv-host}{ipset_tmplt_name}
    	    	    }
    	    	    
    	    	    # clear vars
    	    	    $ipset_type_l=undef;
    	    	    ###
    	    	}
    	    	
    	    	# clear vars
    	    	$arr_el0_l=undef;
    	    	###
    	    }
    	    
    	    # clear vars
    	    ($hkey1_l,$hval1_l)=(undef,undef);
    	    @params_arr_l=();
    	    ###
    	}
    	
    	# clear vars
    	@tmp_arr0_l=();
    	###
    }
    
    # clear vars
    ($hkey0_l,$hval0_l)=(undef,undef);
    ###
    # block for 'groups' (prio = 1) (end)
    
    # block for 'all' (prio = 0/min) (begin)
    while ( ($hkey0_l,$hval0_l)=each %res_tmp_lv0_l ) {
        #$hkey0_l = sting like 'host-id some_set0_ipset--TMPLT,some_set1_ipset--TMPLT'
        #host-id=all/gr_***/list of hosts/single_host
    }
    
    # clear vars
    ($hkey0_l,$hval0_l)=(undef,undef);
    $arr_el0_l=undef;
    @tmp_arr0_l=();
    @params_arr_l=();
    ###
    # block for 'all' (prio = 0/min) (end)
    ### FILL %res_tmp_lv1_l (END)
    
    # fill result hash
    %{$res_href_l}=%res_tmp_lv1_l;
    ###
    
    %res_tmp_lv1_l=();
    
    return $return_str_l;
}

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
