###DEPENDENCIES: read_conf_fwrules_common.pl

sub read_77_conf_zones_FIN_v2 {
    my ($file_l,$input_hash4proc_href_l,$res_href_l)=@_;
    #$file_l=$f77_conf_zones_FIN_path_g
    #$input_hash4proc_href_l=hash-ref for %input_hash4proc_g (hash with hash refs for input)
    #$res_href_l=hash ref for %h77_conf_zones_FIN_hash_g
    
    my $inv_hosts_href_l=${$input_hash4proc_href_l}{'inventory_hosts_href'};
    #inv_hosts_href_l=hash-ref for %inventory_hosts_g
    
    my $divisions_for_inv_hosts_href_l=${$input_hash4proc_href_l}{'divisions_for_inv_hosts_href'};
    #$divisions_for_inv_hosts_href_l=hash-ref for %h00_conf_divisions_for_inv_hosts_hash_g
        #$h00_conf_divisions_for_inv_hosts_hash_g{group_name}{inv-host}=1;
    
    my $inv_hosts_nd_href_l=${$input_hash4proc_href_l}{'inv_hosts_network_data_href'};
    #$inv_hosts_nd_href_l=hash-ref for %inv_hosts_network_data_g
        #INV_HOST-0       #INT_NAME-1       #IPADDR-2
        #$inv_hosts_network_data_g{inv_host}{int_name}=ipaddr
    
    my $ipset_templates_href_l=${$input_hash4proc_href_l}{'h01_conf_ipset_templates_href'};
    #$ipset_templates_href_l=hash-ref for %h01_conf_ipset_templates_hash_g
        #$h01_conf_ipset_templates_hash_g{'temporary/permanent'}{ipset_template_name--TMPLT}->
    
    ######
    my $allowed_services_sets_href_l=${$input_hash4proc_href_l}{'h02_1_conf_allowed_services_sets_href'};
    #allowed_services_sets_href_l=hash-ref for %h02_1_conf_allowed_services_sets_hash_g
    #$h02_1_conf_allowed_services_sets_hash_g{set-name}{inv-host}->
        #{'serv-0'}=1
        #{'serv-1'}=1
        #etc
        #{'seq'}=[val-0,val-1] (val=serv)
    
    my $allowed_ports_sets_href_l=${$input_hash4proc_href_l}{'h02_2_conf_allowed_ports_sets_href'};
    #allowed_ports_sets_href_l=hash-ref for %h02_2_conf_allowed_ports_sets_hash_g
    #$h02_2_conf_allowed_ports_sets_hash_g{set-name}{inv-host}->
        #{'port-0'}=1
        #{'port-1'}=1
        #etc
        #{'seq'}=[val-0,val-1] (val=port)
    
    my $allowed_protocols_sets_href_l=${$input_hash4proc_href_l}{'h02_3_conf_allowed_protocols_sets_href'};
    #allowed_protocols_sets_href_l=hash-ref for %h02_3_conf_allowed_protocols_sets_hash_g
    #$h02_3_conf_allowed_protocols_sets_hash_g{set-name}{inv-host}->
        #{'proto-0'}=1
        #{'proto-1'}=1
        #etc
        #{'seq'}=[val-0,val-1] (val=proto)
    
    my $icmp_blocks_sets_href_l=${$input_hash4proc_href_l}{'h02_4_conf_icmp_blocks_sets_href'};
    #icmp_blocks_sets_href_l=hash-ref for %h02_4_conf_icmp_blocks_sets_hash_g
    #$h02_4_conf_icmp_blocks_sets_hash_g{set-name}{inv-host}->
        #{'icmp_block-0'}=1
        #{'icmp_block-1'}=1
        #etc
        #{'seq'}=[val-0,val-1] (val=icmp_block)
        #{'inversion'}=yes/no
    ######
    
    my $custom_zone_templates_href_l=${$input_hash4proc_href_l}{'h02_conf_custom_firewall_zones_templates_href'};
    #$custom_zone_templates_href_l=hash-ref for %h02_conf_custom_firewall_zones_templates_hash_g
    
    my $std_zone_templates_href_l=${$input_hash4proc_href_l}{'h02_conf_standard_firewall_zones_templates_href'};
    #$std_zone_templates_href_l=hash-ref for %h02_conf_standard_firewall_zones_templates_hash_g
    
    my $fw_ports_set_href_l=${$input_hash4proc_href_l}{'h04_conf_forward_ports_sets_href'};
    #$fw_ports_set_href_l=hash-ref for %h04_conf_forward_ports_sets_hash_g
        #$h04_conf_forward_ports_sets_hash_g{inv-host}{set_name}->
    
    my $rich_rules_set_href_l=${$input_hash4proc_href_l}{'h05_conf_rich_rules_sets_href'};
    #$rich_rules_set_href_l=hash-ref for %h05_conf_rich_rules_sets_hash_g
        #$h05_conf_rich_rules_sets_hash_g{inv-host}{set_name}->
    
    my $h66_conf_ipsets_FIN_href_l=${$input_hash4proc_href_l}{'h66_conf_ipsets_FIN_href'};
    #$h66_conf_ipsets_FIN_href_l=hash-ref for \%h66_conf_ipsets_FIN_hash_g
        #$h66_conf_ipsets_FIN_hash_g{'temporary/permanent'}{inventory_host}->
            #{ipset_name_tmplt-0}=1;
            #{ipset_name_tmplt-1}=1;
            #etc
    
    my $proc_name_l=(caller(0))[3];
    
    #INVENTORY_HOST         #FIREWALL_ZONE_NAME_TMPLT       #INTERFACE_LIST   #SOURCE_LIST          #IPSET_TMPLT_LIST               #FORWARD_PORTS_SET      #RICH_RULES_SET
    #all                    public--TMPLT                   ens1,ens2,ens3    10.10.16.0/24         ipset4all_public--TMPLT         empty                   empty (example)
    #10.3.2.2               public--TMPLT                   empty             10.10.15.0/24         ipset4public--TMPLT             fw_ports_set4public     rich_rules_set4public (example)
    #10.1.2.3,10.1.2.4      zone1--TMPLT                    eth0,eth1,ens01   empty                 empty                           fw_ports_set4zone1      rich_rules_set4zone1 (example)
    ###
    #$h77_conf_zones_FIN_hash_g{'custom/standard'}{inventory_host}{firewall_zone_name_tmplt}->
    #{'interface_list'}->;
        #{'empty'}=1
        #{'list'}->
            #{'interface-0'}=1
            #{'interface-1'}=1
            #etc
        #{'seq'}=[val-0,val-1] (val=interface)
    #{'source_list'}->
        #{'empty'}=1
        #{'list'}->
            #{'source-0'}=1
            #{'source-1'}=1
            #etc
        #{'seq'}=[val-0,val-1] (val=source)
    #{'ipset_tmplt_list'}->
        #{'epmty'}=1
        #{'list'}->
            #{'ipset_tmplt-0'}=1
            #{'ipset_tmplt-1'}=1
            #etc
        #{'seq'}=[val-0,val-1] (val=ipset_tmplt)
    #{'forward_ports_set'}=empty|fw_ports_set (FROM '04_conf_forward_ports_sets')
    #{'rich_rules_set'}=empty|rich_rules_set (FROM '05_conf_rich_rules_sets')
    #
    # ADDING not directly via '77_conf_zones_FIN'
    #{'allowed_services_set'}=[serv1,serv2,etc] (from '02_1_conf_allowed_services_sets')
        #Must exists if set defined for 'firewall_zone_name_tmplt'
    	    #at param 'zone_allowed_services' and set name defined at '02_1_conf_allowed_services_sets'
    #{'allowed_ports_set'}=[port1,port2,etc] (from '02_2_conf_allowed_ports_sets')
        #Must exists if set defined for 'firewall_zone_name_tmplt'
    	    #at param 'zone_allowed_ports' and set name defined at '02_2_conf_allowed_ports_sets'
    #{'allowed_source_ports_set'}=[port1,port2,etc] (from '02_2_conf_allowed_ports_sets')
        #Must exists if set defined for 'firewall_zone_name_tmplt'
    	    #at param 'zone_allowed_source_ports' and set name defined at '02_2_conf_allowed_ports_sets'
    #{'allowed_protocols_set'}=[proto1,proto2,etc] (from '02_3_conf_allowed_protocols_sets')
        #Must exists if set defined for 'firewall_zone_name_tmplt'
    	    #at param 'zone_allowed_protocols' and set name defined at '02_3_conf_allowed_protocols_sets'
    
    #{'icmp_blocks_set'}=[icmp-block1,icmp-block2,etc] (from '02_4_conf_icmp_blocks_sets')
    #{'icmp_blocks_inversion'}=yes/no (from '02_4_conf_icmp_blocks_sets')
        #Must exists if set defined for 'firewall_zone_name_tmplt'
    	    #at param 'zone_icmp_block' and set name defined at '02_4_conf_icmp_blocks_sets'
    ###
    
    my ($exec_res_l,$inv_host_l)=(undef,undef);
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my $arr_el0_l=undef;
    my @arr0_l=();
    my $zone_type_l=undef; # possible_values: custom, standard 
    my $fwzone_name_l=undef; # for fwzone_uniq_check
    my $actual_zone_templates_href_l=undef; # possible values: $custom_zone_templates_href_l, $std_zone_templates_href_l
    my $set_name_l=undef;
    my $return_str_l='OK';
    
    my %fwzone_uniq_check_l=(); # uniq for 'inv-host + firewall_zone_name(not tmplt)'
        #key=inv-host, key1=firewall_zone_name(not tmplt), value=firewall_zone_tmplt_name
    my %int_uniq_check_l=(); # uniq for 'inv-host + interface'
        #key0=inv-host, key1=interface, value=firewall_zone_tmplt_name
    my %src_uniq_check_l=(); # uniq for 'inv-host + source'
        #key0=inv-host, key1=source, value=firewall_zone_tmplt_name
    my %ipset_tmplt_uniq_check_l=(); # uniq for 'inv-host + impset-tmplt'
        #key0=inv-host, key1=ipset_tmplt_name, value=firewall_zone_tmplt_name
    my %res_tmp_lv0_l=();
        #key=inv-host, value=[array of values]. FIREWALL_ZONE_NAME_TMPLT-0, INTERFACE_LIST-1, etc
    my %res_tmp_lv1_l=();
        #final hash
        
    $exec_res_l=&read_config_FIN_level0($file_l,$inv_hosts_href_l,$divisions_for_inv_hosts_href_l,7,1,\%res_tmp_lv0_l); # protects from not uniq 'inv-host+fwzone-tmplt'
    #$file_l,$inv_hosts_href_l,$divisions_for_inv_hosts_href_l,$needed_elements_at_line_arr_l,$add_ind4key_l,$res_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }
    
    # fill %res_tmp_lv1_l (begin)
    while ( ($hkey0_l,$hval0_l)=each %res_tmp_lv0_l ) {
        #hval0_l=arr-ref for [FIREWALL_ZONE_NAME_TMPLT-0, INTERFACE_LIST-1, SOURCE_LIST-2, IPSET_TMPLT_LIST-3, FORWARD_PORTS_SET-4, RICH_RULES_SET-5]
        $inv_host_l=$hkey0_l;
        $inv_host_l=~s/\+\S+$//g;
    
        # FIREWALL_ZONE_NAME_TMPLT ops [0] (begin)
        #$h02_conf_custom_firewall_zones_templates_hash_g{zone_teplate_name--TMPLT}-> ... #{'zone_name'}
            #$custom_zone_templates_href_l
        #$h02_conf_standard_firewall_zones_templates_hash_g{zone_teplate_name--TMPLT}-> ... #{'zone_name'}
            #$std_zone_templates_href_l
        if ( exists(${$custom_zone_templates_href_l}{${$hval0_l}[0]}) ) {
            $zone_type_l='custom';
            $fwzone_name_l=${$custom_zone_templates_href_l}{${$hval0_l}[0]}{'zone_name'};
	    
	    $actual_zone_templates_href_l=$custom_zone_templates_href_l;
        }
        elsif ( exists(${$std_zone_templates_href_l}{${$hval0_l}[0]}) ) {
            $zone_type_l='standard';
            $fwzone_name_l=${$std_zone_templates_href_l}{${$hval0_l}[0]}{'zone_name'};
	    
	    $actual_zone_templates_href_l=$std_zone_templates_href_l;
        }
        else {
            $return_str_l="fail [$proc_name_l]. Fw-zone-tmplt='${$hval0_l}[0]' (conf='$file_l') is not exists at '02_conf_custom_firewall_zones_templates/02_conf_standard_firewall_zones_templates'";
            last;
        }
        # FIREWALL_ZONE_NAME_TMPLT ops [0] (end)
    
        # fwzone_name uniq check
        if ( exists($fwzone_uniq_check_l{$inv_host_l}{$fwzone_name_l}) ) {
            $return_str_l="fail [$proc_name_l]. Fwzone_name='$fwzone_name_l' (inv-host='$inv_host_l', fwzone-tmplt='${$hval0_l}[0]') is already assign to fwzone-tmplt='$fwzone_uniq_check_l{$inv_host_l}{$fwzone_name_l}' at conf='77_conf_zones_FIN'";
            last;
        }
        $fwzone_uniq_check_l{$inv_host_l}{$fwzone_name_l}=${$hval0_l}[0];
        ###
        
        # INTERFACE_LIST ops [1] (begin)
        if ( ${$hval0_l}[1]=~/^empty$/ ) { $res_tmp_lv1_l{$zone_type_l}{$inv_host_l}{${$hval0_l}[0]}{'interface_list'}{'empty'}=1; }
        else {
            @arr0_l=split(/\,/,${$hval0_l}[1]);
            foreach $arr_el0_l ( @arr0_l ) {
                #$arr_el0_l=interface name
                if ( !exists(${$inv_hosts_nd_href_l}{$inv_host_l}{$arr_el0_l}) ) {
                    $return_str_l="fail [$proc_name_l]. Interface='$arr_el0_l' is not exists at host='$inv_host_l' (conf='$file_l') at conf='77_conf_zones_FIN'";
                    last;
                }
            
                # check for 'interface is already belongs to fw-zone-tmplt'
                if ( !exists($int_uniq_check_l{$inv_host_l}{$arr_el0_l}) ) { $int_uniq_check_l{$inv_host_l}{$arr_el0_l}=${$hval0_l}[0]; }
                else {
                    $return_str_l="fail [$proc_name_l]. Interface='$arr_el0_l' is already used for fw-zone-tmplt='$int_uniq_check_l{$inv_host_l}{$arr_el0_l}' for inv-host='$inv_host_l' at conf='77_conf_zones_FIN'";
                    last;
                }
                ###
    
                if ( !exists($res_tmp_lv1_l{$zone_type_l}{$inv_host_l}{${$hval0_l}[0]}{'interface_list'}{'list'}{$arr_el0_l}) ) {
                    $res_tmp_lv1_l{$zone_type_l}{$inv_host_l}{${$hval0_l}[0]}{'interface_list'}{'list'}{$arr_el0_l}=1;
                    push(@{$res_tmp_lv1_l{$zone_type_l}{$inv_host_l}{${$hval0_l}[0]}{'interface_list'}{'seq'}},$arr_el0_l);
                }
                else { # duplicate interface name
                    $return_str_l="fail [$proc_name_l]. Duplicated interface_name='$arr_el0_l' (conf='$file_l') for inv-host='$inv_host_l' and fw-zone-tmplt-name='${$hval0_l}[0] at conf='77_conf_zones_FIN'";
                    last;
                }
            }
    
            @arr0_l=();
            $arr_el0_l=undef;
    
            if ( $return_str_l!~/^OK$/ ) { last; }
        }
        # INTERFACE_LIST ops [1] (end)
    
        # SOURCE_LIST ops [2] (begin)
        if ( ${$hval0_l}[2]=~/^empty$/ ) { $res_tmp_lv1_l{$zone_type_l}{$inv_host_l}{${$hval0_l}[0]}{'source_list'}{'empty'}=1; }
        else {
            @arr0_l=split(/\,/,${$hval0_l}[2]);
            foreach $arr_el0_l ( @arr0_l ) {
                #$arr_el0_l=source
                #if ( $arr_el0_l!~/some_regex/ ) {
                    #maybe need to add regex for check sources
                #}
    
                # check for 'source is already belongs to fw-zone-tmplt'
                if ( !exists($src_uniq_check_l{$inv_host_l}{$arr_el0_l}) ) { $src_uniq_check_l{$inv_host_l}{$arr_el0_l}=${$hval0_l}[0]; }
                else {
                    $return_str_l="fail [$proc_name_l]. Source='$arr_el0_l' is already used for fw-zone-tmplt='$src_uniq_check_l{$inv_host_l}{$arr_el0_l}' for inv-host='$inv_host_l' at conf='77_conf_zones_FIN'";
                    last;
                }
                ###
    
                if ( !exists($res_tmp_lv1_l{$zone_type_l}{$inv_host_l}{${$hval0_l}[0]}{'source_list'}{'list'}{$arr_el0_l}) ) {
                    $res_tmp_lv1_l{$zone_type_l}{$inv_host_l}{${$hval0_l}[0]}{'source_list'}{'list'}{$arr_el0_l}=1;
                    push(@{$res_tmp_lv1_l{$zone_type_l}{$inv_host_l}{${$hval0_l}[0]}{'source_list'}{'seq'}},$arr_el0_l);
                }
                else { # duplicate source
                    $return_str_l="fail [$proc_name_l]. Duplicated source='$arr_el0_l' (conf='$file_l') for inv-host='$inv_host_l' andfw-zone-tmplt-name='${$hval0_l}[0] at conf='77_conf_zones_FIN'";
                    last;
                }
            }
        
            @arr0_l=();
            $arr_el0_l=undef;
    
            if ( $return_str_l!~/^OK$/ ) { last; }
        }
        # SOURCE_LIST ops [2] (end)
    
        # IPSET_TMPLT_LIST ops [3] (begin)
        if ( ${$hval0_l}[3]=~/^empty$/ ) { $res_tmp_lv1_l{$zone_type_l}{$inv_host_l}{${$hval0_l}[0]}{'ipset_tmplt_list'}{'empty'}=1; }
        else {
            @arr0_l=split(/\,/,${$hval0_l}[3]);
            foreach $arr_el0_l ( @arr0_l ) {
                #$arr_el0_l=ipset_tmplt_name
                #$ipset_templates_href_l=hash-ref for %h01_conf_ipset_templates_hash_g
                    #$h01_conf_ipset_templates_hash_g{'temporary/permanent'}{ipset_template_name--TMPLT}-> ... #{'ipset_name'}
                if ( !exists(${$ipset_templates_href_l}{'temporary'}{$arr_el0_l}) && !exists(${$ipset_templates_href_l}{'permanent'}{$arr_el0_l}) ) {
                    $return_str_l="fail [$proc_name_l]. IPSET_TMPLT_NAME='$arr_el0_l' (conf='$file_l') is not exists at '01_conf_ipset_templates'";
                    last;
                }
    
                #$h66_conf_ipsets_FIN_hash_g{'temporary/permanent'}{inventory_host}->
                    #{ipset_name_tmplt-0}=1;
                if ( !exists(${$h66_conf_ipsets_FIN_href_l}{'temporary'}{$inv_host_l}{$arr_el0_l}) && !exists(${$h66_conf_ipsets_FIN_href_l}{'permanent'}{$inv_host_l}{$arr_el0_l}) ) {
                    $return_str_l="fail [$proc_name_l]. IPSET_TMPLT_NAME='$arr_el0_l' (conf='$file_l') is not exists at '66_conf_ipsets_FIN' for inv-host='$inv_host_l'";
                    last;
                }
                
                # check for 'ipset-tmplt is already belongs to fw-zone-tmplt'
                if ( exists($ipset_tmplt_uniq_check_l{$inv_host_l}{$arr_el0_l}) ) {
                    $return_str_l="fail [$proc_name_l]. IPSET-tmplt='$arr_el0_l' is already used for fwzone-tmplt='$ipset_tmplt_uniq_check_l{$inv_host_l}{$arr_el0_l}' for inv-host='$inv_host_l' at conf='77_conf_zones_FIN'";
                    last;
                }
                $ipset_tmplt_uniq_check_l{$inv_host_l}{$arr_el0_l}=${$hval0_l}[0];
                ###
    
                if ( !exists($res_tmp_lv1_l{$zone_type_l}{$inv_host_l}{${$hval0_l}[0]}{'ipset_tmplt_list'}{'list'}{$arr_el0_l}) ) {
                    $res_tmp_lv1_l{$zone_type_l}{$inv_host_l}{${$hval0_l}[0]}{'ipset_tmplt_list'}{'list'}{$arr_el0_l}=1;
                    push(@{$res_tmp_lv1_l{$zone_type_l}{$inv_host_l}{${$hval0_l}[0]}{'ipset_tmplt_list'}{'seq'}},$arr_el0_l);
                }
                else { # duplicate ipset_template_name
                    $return_str_l="fail [$proc_name_l]. Duplicated ipset_tmplt_name='$arr_el0_l' (conf='$file_l') for inv-host='$inv_host_l' and fw-zone-tmplt-name='${$hval0_l}[0] at conf='77_conf_zones_FIN'";
                    last;
                }
            }
    
            @arr0_l=();
            $arr_el0_l=undef;
    
            if ( $return_str_l!~/^OK$/ ) { last; }
        }
        # IPSET_TMPLT_LIST ops [3] (end)
    
        # FORWARD_PORTS_SET ops [4] (begin)
        if ( ${$hval0_l}[4]=~/^empty$/ ) { $res_tmp_lv1_l{$zone_type_l}{$inv_host_l}{${$hval0_l}[0]}{'forward_ports_set'}='empty'; }
        else {
            #$fw_ports_set_href_l=hash-ref for %h04_conf_forward_ports_sets_hash_g
                #$h04_conf_forward_ports_sets_hash_g{inv-host}{set_name}-> ...
            if ( !exists(${$fw_ports_set_href_l}{$inv_host_l}{${$hval0_l}[4]}) ) {
                $return_str_l="fail [$proc_name_l]. FORWARD_PORTS_SET='${$hval0_l}[4]' (conf='$file_l) is not exists (or not configured) at '04_conf_forward_ports_sets' (conf='77_conf_zones_FIN') for inv-host='$inv_host_l'";
                last;
            }
            else { $res_tmp_lv1_l{$zone_type_l}{$inv_host_l}{${$hval0_l}[0]}{'forward_ports_set'}=${$hval0_l}[4]; }
        }
        # FORWARD_PORTS_SET ops [4] (end)
    
        # RICH_RULES_SET ops [5] (begin)
        if ( ${$hval0_l}[5]=~/^empty$/ ) { $res_tmp_lv1_l{$zone_type_l}{$inv_host_l}{${$hval0_l}[0]}{'rich_rules_set'}='empty'; }
        else {
            #$rich_rules_set_href_l=hash-ref for %h05_conf_rich_rules_sets_hash_g
                #$h05_conf_rich_rules_sets_hash_g{inv-host}{set_name}-> ...
            if ( !exists(${$rich_rules_set_href_l}{$inv_host_l}{${$hval0_l}[5]}) ) {
                $return_str_l="fail [$proc_name_l]. RICH_RULES_SET='${$hval0_l}[5]' (conf='$file_l) is not exists (or not configured) at '05_conf_rich_rules_sets' (conf='77_conf_zones_FIN') for inv-host='$inv_host_l'";
                last;
            }
            else { $res_tmp_lv1_l{$zone_type_l}{$inv_host_l}{${$hval0_l}[0]}{'rich_rules_set'}=${$hval0_l}[5]; }
        }
        # RICH_RULES_SET ops [5] (end)
	
	# allowed_services_set (begin)
	    #$inv_host_l
	    #$zone_type_l=standard/custom
	    #${$hval0_l}[0]=FIREWALL_ZONE_NAME_TMPLT
	    ###
    	    #$h02_conf_custom_firewall_zones_templates_hash_g{zone_teplate_name--TMPLT}-> ($custom_zone_templates_href_l)
		#... #{'zone_allowed_services'}{'seq'} = (if exists) and seq[0]=set:*
    	    #$h02_conf_standard_firewall_zones_templates_hash_g{zone_teplate_name--TMPLT}-> (#$std_zone_templates_href_l)
		#... #{'zone_allowed_services'}{'seq'} (if exists) and seq[0]=set:*
	    #
	    #$actual_zone_templates_href_l=$custom_zone_templates_href_l or $std_zone_templates_href_l
	    ###
	if ( exists(${$actual_zone_templates_href_l}{${$hval0_l}[0]}{'zone_allowed_services'}{'seq'}) ) {
	    @arr0_l=@{${$actual_zone_templates_href_l}{${$hval0_l}[0]}{'zone_allowed_services'}{'seq'}};
	    
	    if ( $arr0_l[0]=~/^set\:(\S+)$/ ) {
	        $set_name_l=$1;
		
		if ( !exists(${$allowed_services_sets_href_l}{$set_name_l}{$inv_host_l}) ) {
		    $return_str_l="fail [$proc_name_l]. Allowed_services_set='$set_name_l' (conf='02_1_conf_allowed_services_sets') is not configured for inv-host='$inv_host_l' (within a group or tag 'all')";
		    last;
		}
		else {
		    $res_tmp_lv1_l{$zone_type_l}{$inv_host_l}{${$hval0_l}[0]}{'allowed_services_set'}=[@{${$allowed_services_sets_href_l}{$set_name_l}{$inv_host_l}{'seq'}}];
		}
		
		# clear vars
		$set_name_l=undef;
		###
	    }
		
	    # clear vars
	    @arr0_l=();
	    ###
	}
	# allowed_services_set (end)
	
	# allowed_ports_set (begin)
	    #***{'zone_allowed_ports'}***
	# allowed_ports_set (end)
	
	# allowed_source_ports_set (begin)
	    #***{'zone_allowed_source_ports'}***
	# allowed_source_ports_set (end)
	
	# allowed_protocols_set (begin)
	    #***{'zone_allowed_protocols'}***
	# allowed_protocols_set (end)
	
	# icmp_blocks_set + icmp_blocks_inversion (begin)
	    #***{'zone_icmp_block'}***
	# icmp_blocks_set + icmp_blocks_inversion (end)
    }
        
    ($hkey0_l,$hval0_l)=(undef,undef);
    $inv_host_l=undef;
    $fwzone_name_l=undef;
    
    if ( $return_str_l!~/^OK$/ ) { return $return_str_l; }
    ### fill %res_tmp_lv1_l (end)
    
    # fill result hash
    %{$res_href_l}=%res_tmp_lv1_l;
    ###
    
    %res_tmp_lv1_l=();
    
    return $return_str_l;
}

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
