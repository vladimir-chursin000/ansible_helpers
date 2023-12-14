###DEPENDENCIES: read_conf_fwrules_common.pl

sub read_02_conf_custom_firewall_zones_templates {
    my ($file_l,$input_hash4proc_href_l,$res_href_l)=@_;
    #file_l=$f02_conf_custom_firewall_zones_templates_path_g
    #$input_hash4proc_href_l=hash-ref for %input_hash4proc_g (hash with hash refs for input)
    #res_href_l=hash-ref for %h02_conf_custom_firewall_zones_templates_hash_g
    my $proc_name_l=(caller(0))[3];
    
    my $allowed_services_sets_href_l=${$input_hash4proc_href_l}{'h02_1_conf_allowed_services_sets_href'};
    #inv_hosts_href_l=hash-ref for %h02_1_conf_allowed_services_sets_hash_g
    
    my $allowed_ports_sets_href_l=${$input_hash4proc_href_l}{'h02_2_conf_allowed_ports_sets_href'};
    #inv_hosts_href_l=hash-ref for %h02_2_conf_allowed_ports_sets_hash_g
    
    my $allowed_protocols_sets_href_l=${$input_hash4proc_href_l}{'h02_3_conf_allowed_protocols_sets_href'};
    #inv_hosts_href_l=hash-ref for %h02_3_conf_allowed_protocols_sets_hash_g
    
    my $icmp_blocks_sets_href_l=${$input_hash4proc_href_l}{'h02_4_conf_icmp_blocks_sets_href'};
    #inv_hosts_href_l=hash-ref for %h02_4_conf_icmp_blocks_sets_hash_g
    
    #[some_zone--TMPLT:BEGIN]
    #zone_name=some_zone--custom
    #zone_description=
    #zone_short_description=
    #zone_target=
    #zone_allowed_services=
    #zone_allowed_ports=
    #zone_allowed_protocols=
    #zone_forward=
    #zone_masquerade_general=
    #zone_allowed_source_ports=
    #zone_icmp_block_inversion=
    #zone_icmp_block=
    #[some_zone--TMPLT:END]
    ###
    #$h02_conf_custom_firewall_zones_templates_hash_g{zone_teplate_name--TMPLT}->
    #{'zone_name'}=some_zone--custom
    #{'zone_description'}=empty|value
    #{'zone_short_description'}=empty|value
    #{'zone_target'}=ACCEPT|REJECT|DROP|default
    #{'zone_allowed_services'}->
        #{'empty'}=1 or
        #{'list'}->
            #{'service-0'}=1
            #{'service-1'}=1
            #etc
        #{'seq'}=[val-0,val-1] (val=service)
    #{'zone_allowed_ports'}->
        #{'empty'}=1 or
        #{'list'}->
            #{'port-0'}=1
            #{'port-1'}=1
            #etc
        #{'seq'}=[val-0,val-1] (val=port)
    #{'zone_allowed_protocols'}->
        #{'empty'}=1 or
        #{'list'}->
            #{'proto-0'}=1
            #{'proto-1'}=1
            #etc
        #{'seq'}=[val-0,val-1] (val=proto)
    #{'zone_forward'}=yes|no
    #{'zone_masquerade_general'}=yes|no
    #{'zone_allowed_source_ports'}->
        #{'empty'}=1 or
        #{'list'}->
            #{'port-0'}=1
            #{'port-1'}=1
            #etc
        #{'seq'}=[val-0,val-1] (val=port)
    #{'zone_icmp_block_inversion'}=yes|no
    #{'zone_icmp_block'}->
        #{'empty'}=1 or
        #{'list'}->
            #{'icmptype-0'}=1
            #{'icmptype-1'}=1
            #etc
        #{'seq'}=[val-0,val-1] (val=icmptype)

    my $exec_res_l=undef;
    my $arr_el0_l=undef;
    my $tmp_str0_l=undef;
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my ($hkey1_l,$hval1_l)=(undef,undef);
    my @split_arr0_l=();
    my @tmp_arr0_l=();
    my $return_str_l='OK';
    my $param_list_regex_l='^zone_allowed_services$|^zone_allowed_protocols$|^zone_icmp_block$|^zone_allowed_ports$|^zone_allowed_source_ports$';

    my %res_tmp_lv0_l=();
        #key0=tmplt_name,key1=param, value=value filtered by regex
    my %res_tmp_lv1_l=();

    my %cfg_params_and_regex_l=(
        'zone_name'=>'^\S{1,9}\-\-custom$',
        'zone_description'=>'^empty$|^.{1,100}',
        'zone_short_description'=>'^empty$|^.{1,20}',
        'zone_target'=>'^ACCEPT$|^REJECT$|^DROP$|^default$',
        'zone_allowed_services'=>'^empty$|^.*$',
        'zone_allowed_ports'=>'^empty$|^.*$',
        'zone_allowed_protocols'=>'^empty$|^.*$',
        'zone_forward'=>'^yes$|^no$',
        'zone_masquerade_general'=>'^yes$|^no$',
        'zone_allowed_source_ports'=>'^empty$|^.*$',
        'zone_icmp_block_inversion'=>'^yes$|^no$',
        'zone_icmp_block'=>'^empty$|^.*$',
    );

    $exec_res_l=&read_param_value_templates_from_config($file_l,\%cfg_params_and_regex_l,\%res_tmp_lv0_l);
    #$file_l,$regex_href_l,$res_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }

    # fill %res_tmp_lv1_l (postprocessing_v1_after_read_param_value_templates_from_config)
    $exec_res_l=&postprocessing_v1_after_read_param_value_templates_from_config($file_l,$param_list_regex_l,\%res_tmp_lv0_l,\%res_tmp_lv1_l);
    #$file_l,$param_list_regex_for_postproc_l,$src_href_l,$res_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }
    ###
    
    # params special checks at '%res_tmp_lv1_l' (begin)
    while ( ($hkey0_l,$hval0_l)=each %res_tmp_lv1_l ) { # cycle 0 (begin)
    	#$hkey0_l=zone_teplate_name, $hval0_l = hashref
    	
    	while ( ($hkey1_l,$hval1_l)=each %{$hval0_l} ) { # cycle 1 (begin)
    	    #$hkey1_l=fwzone-param (zone_name, zone_description, etc), $hval1_l=param value
    	    
    	    if ( $hkey1_l=~/(^zone_allowed_ports$|^zone_allowed_source_ports$)/ ) {
    	    	$tmp_str0_l=$1; # fwzone-param (tmp)
    	    	
    	    	if ( exists(${$hval1_l}{$tmp_str0_l}{'seq'}) ) {
    	    	    @tmp_arr0_l=@{${$hval1_l}{$tmp_str0_l}{'seq'}};
    	    	    
    	    	    if ( $#tmp_arr0_!=0 && "@tmp_arr0_l"=~/set\:\S+/ ) {
    	    	    	$return_str_l="fail [$proc_name_l]. Value of param '$tmp_str0_l' must be 'empty' or 'list of ports' or 'set:some_set_name'";
    	    	    	last;
    	    	    }
    	    	    
    	    	    foreach $arr_el0_l ( @tmp_arr0_l ) {
    	    	    	#$arr_el0_l=port in format 'port/proto' or 'set:set_name'
    	    	    	
    	    	    	if ( $arr_el0_l!~/^set\:\S+$/ ) {
    	    	    	    $exec_res_l=&check_port_for_apply_to_fw_conf($arr_el0_l);
    	    	    	    #$port_str_l
                    	    if ( $exec_res_l=~/^fail/ ) {
                    	    	$return_str_l="fail [$proc_name_l] -> ".$exec_res_l;
                    	    	last;
                    	    }
    	    	    	    $exec_res_l=undef;
    	    	    	}
    	    	    	elsif ( $arr_el0_l=~/^set\:(\S+)$/ ) {
    	    	    	    
    	    	    	}
    	    	    }
    	    	    
    	    	    # clear vars
    	    	    $arr_el0_l=undef;
    	    	    @tmp_arr0_l=();
    	    	    ###
    	    	}
    	    	
    	    	# clear vars
    	    	$tmp_str0_l=undef;
    	    	###
    	    }
    	    elsif ( $hkey1_l=~/^zone_allowed_services$/ ) {
    	    	if ( exists(${$hval1_l}{$hkey1_l}{'seq'}) ) {
                    @tmp_arr0_l=@{${$hval1_l}{$hkey1_l}{'seq'}};
    	    	    
    	    	    if ( $#tmp_arr0_!=0 && "@tmp_arr0_l"=~/set\:\S+/ ) {
    	    	    	$return_str_l="fail [$proc_name_l]. Value of param '$hkey1_l' must be 'empty' or 'list of services' or 'set:some_set_name'";
    	    	    	last;
    	    	    }
		    
    	    	    foreach $arr_el0_l ( @tmp_arr0_l ) {
    	    	    	#$arr_el0_l=service name or 'set:set_name'
    	    	    	
    	    	    	if ( $arr_el0_l!~/^set\:\S+$/ ) {
    	    	    	    # check service names (maybe. in future)
    	    	    	}
    	    	    	elsif ( $arr_el0_l=~/^set\:(\S+)$/ ) {
    	    	    	    
    	    	    	}
    	    	    }
		    
    	    	    # clear vars
    	    	    $arr_el0_l=undef;
    	    	    @tmp_arr0_l=();
    	    	    ###
    	    	}
    	    }
    	    elsif ( $hkey1_l=~/^zone_allowed_protocols$/ ) {
    	    	if ( exists(${$hval1_l}{$hkey1_l}{'seq'}) ) {
                    @tmp_arr0_l=@{${$hval1_l}{$hkey1_l}{'seq'}};
    	    	    
    	    	    if ( $#tmp_arr0_!=0 && "@tmp_arr0_l"=~/set\:\S+/ ) {
    	    	    	$return_str_l="fail [$proc_name_l]. Value of param '$hkey1_l' must be 'empty' or 'list of protocols' or 'set:some_set_name'";
    	    	    	last;
    	    	    }
    	    	    
    	    	    foreach $arr_el0_l ( @tmp_arr0_l ) {
    	    	    	#$arr_el0_l=service name or 'set:set_name'
    	    	    	
    	    	    	if ( $arr_el0_l!~/^set\:\S+$/ ) {
    	    	    	    # check service names (maybe. in future)
    	    	    	}
    	    	    	elsif ( $arr_el0_l=~/^set\:(\S+)$/ ) {
    	    	    	    
    	    	    	}
    	    	    }
    	    	    
    	    	    # clear vars
    	    	    $arr_el0_l=undef;
    	    	    @tmp_arr0_l=();
    	    	    ###
    	    	}
    	    }
    	    elsif ( $hkey1_l=~/^zone_icmp_block$/ ) {
    	    	if ( exists(${$hval1_l}{$hkey1_l}{'seq'}) ) {
                    @tmp_arr0_l=@{${$hval1_l}{$hkey1_l}{'seq'}};
    	    	    
    	    	    if ( $#tmp_arr0_!=0 && "@tmp_arr0_l"=~/set\:\S+/ ) {
    	    	    	$return_str_l="fail [$proc_name_l]. Value of param '$hkey1_l' must be 'empty' or 'list of icmp-blocks' or 'set:some_set_name'";
    	    	    	last;
    	    	    }
    	    	    
    	    	    foreach $arr_el0_l ( @tmp_arr0_l ) {
    	    	    	#$arr_el0_l=service name or 'set:set_name'
    	    	    	
    	    	    	if ( $arr_el0_l!~/^set\:\S+$/ ) {
    	    	    	    # check service names (maybe. in future)
    	    	    	}
    	    	    	elsif ( $arr_el0_l=~/^set\:(\S+)$/ ) {
    	    	    	    
    	    	    	}
    	    	    }
    	    	    
    	    	    # clear vars
    	    	    $arr_el0_l=undef;
    	    	    @tmp_arr0_l=();
    	    	    ###
    	    	}
    	    }
    	    
    	    if ( $return_str_l!~/^OK$/ ) { last; }
    	} # cycle 1 (end)
    	
    	if ( $return_str_l!~/^OK$/ ) { last; }
    } # cycle 0 (end)
    
    # clear vars
    ($hkey0_l,$hval0_l)=(undef,undef);
    ($hkey1_l,$hval1_l)=(undef,undef);
    ###
    
    if ( $return_str_l!~/^OK$/ ) { return $return_str_l; }
    # params special checks at '%res_tmp_lv1_l' (end)
    
    # fill result hash
    %{$res_href_l}=%res_tmp_lv1_l;
    ###
    
    %res_tmp_lv1_l=();
    
    return $return_str_l;
}

sub read_02_conf_standard_firewall_zones_templates {
    my ($file_l,$input_hash4proc_href_l,$res_href_l)=@_;
    #file_l=$f02_conf_standard_firewall_zones_templates_path_g
    #$input_hash4proc_href_l=hash-ref for %input_hash4proc_g (hash with hash refs for input)
    #res_href_l=hash-ref for %h02_conf_standard_firewall_zones_templates_hash_g
    my $proc_name_l=(caller(0))[3];
    
    my $allowed_services_sets_href_l=${$input_hash4proc_href_l}{'h02_1_conf_allowed_services_sets_href'};
    #inv_hosts_href_l=hash-ref for %h02_1_conf_allowed_services_sets_hash_g
    
    my $allowed_ports_sets_href_l=${$input_hash4proc_href_l}{'h02_2_conf_allowed_ports_sets_href'};
    #inv_hosts_href_l=hash-ref for %h02_2_conf_allowed_ports_sets_hash_g
    
    my $allowed_protocols_sets_href_l=${$input_hash4proc_href_l}{'h02_3_conf_allowed_protocols_sets_href'};
    #inv_hosts_href_l=hash-ref for %h02_3_conf_allowed_protocols_sets_hash_g
    
    my $icmp_blocks_sets_href_l=${$input_hash4proc_href_l}{'h02_4_conf_icmp_blocks_sets_href'};
    #inv_hosts_href_l=hash-ref for %h02_4_conf_icmp_blocks_sets_hash_g
    
    #[public--TMPLT:BEGIN]
    #zone_name=public
    #zone_target=default
    #zone_allowed_services=cockpit,dhcpv6-client,ssh
    #zone_allowed_ports=empty
    #zone_allowed_protocols=empty
    #zone_forward=no
    #zone_masquerade_general=no
    #zone_allowed_source_ports=empty
    #zone_icmp_block_inversion=no
    #zone_icmp_block=empty
    #[public--TMPLT:END]
    ###
    #$h02_conf_standard_firewall_zones_templates_hash_g{zone_teplate_name--TMPLT}->
    #{'zone_name'}=std_zone_name
    #{'zone_target'}=ACCEPT|REJECT|DROP|default
    #{'zone_allowed_services'}->
        #{'empty'}=1 or
        #{'list'}->
            #{'service-0'}=1
            #{'service-1'}=1
            #etc
        #{'seq'}=[val-0,val-1] (val=service)
    #{'zone_allowed_ports'}->
        #{'empty'}=1 or
        #{'list'}->
            #{'port-0'}=1
            #{'port-1'}=1
            #etc
        #{'seq'}=[val-0,val-1] (val=port)
    #{'zone_allowed_protocols'}->
        #{'empty'}=1 or
        #{'list'}->
            #{'proto-0'}=1
            #{'proto-1'}=1
            #etc
        #{'seq'}=[val-0,val-1] (val=proto)
    #{'zone_forward'}=yes|no
    #{'zone_masquerade_general'}=yes|no
    #{'zone_allowed_source_ports'}->
        #{'empty'}=1 or
        #{'list'}->
            #{'port-0'}=1
            #{'port-1'}=1
            #etc
        #{'seq'}=[val-0,val-1] (val=port)
    #{'zone_icmp_block_inversion'}=yes|no
    #{'zone_icmp_block'}->
        #{'empty'}=1 or
        #{'list'}->
            #{'icmptype-0'}=1
            #{'icmptype-1'}=1
            #etc
        #{'seq'}=[val-0,val-1] (val=icmptype)
        
    my $exec_res_l=undef;
    my $arr_el0_l=undef;
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my ($hkey1_l,$hval1_l)=(undef,undef);
    my @split_arr0_l=();
    my $return_str_l='OK';
    my $param_list_regex_l='^zone_allowed_services$|^zone_allowed_protocols$|^zone_icmp_block$|^zone_allowed_ports$|^zone_allowed_source_ports$';
            
    my %res_tmp_lv0_l=();
        #key0=tmplt_name,key1=param, value=value filtered by regex
    my %res_tmp_lv1_l=();
    
    my %cfg_params_and_regex_l=(
        'zone_name'=>'^block$|^dmz$|^drop$|^external$|^internal$|^public$|^trusted$|^work$|^home$',
        'zone_target'=>'^ACCEPT$|^REJECT$|^DROP$|^default$',
        'zone_allowed_services'=>'^empty$|^.*$',
        'zone_allowed_ports'=>'^empty$|^.*$',
        'zone_allowed_protocols'=>'^empty$|^.*$',
        'zone_forward'=>'^yes$|^no$',
        'zone_masquerade_general'=>'^yes$|^no$',
        'zone_allowed_source_ports'=>'^empty$|^.*$',
        'zone_icmp_block_inversion'=>'^yes$|^no$',
        'zone_icmp_block'=>'^empty$|^.*$',
    );
            
    $exec_res_l=&read_param_value_templates_from_config($file_l,\%cfg_params_and_regex_l,\%res_tmp_lv0_l);
    #$file_l,$regex_href_l,$res_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }

    # fill %res_tmp_lv1_l (postprocessing_v1_after_read_param_value_templates_from_config)
    $exec_res_l=&postprocessing_v1_after_read_param_value_templates_from_config($file_l,$param_list_regex_l,\%res_tmp_lv0_l,\%res_tmp_lv1_l);
    #$file_l,$param_list_regex_for_postproc_l,$src_href_l,$res_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }
    ###

    # fill result hash
    %{$res_href_l}=%res_tmp_lv1_l;
    ###

    %res_tmp_lv1_l=();

    return $return_str_l;
}

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
