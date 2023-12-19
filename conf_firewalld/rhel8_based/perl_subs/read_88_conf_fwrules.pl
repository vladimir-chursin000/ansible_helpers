###DEPENDENCIES: read_conf_fwrules_common.pl

sub read_88_conf_policies_FIN_v2 {
    my ($file_l,$input_hash4proc_href_l,$res_href_l)=@_;
    #$file_l=$f88_conf_policies_FIN_path_g
    #$input_hash4proc_href_l=hash-ref for %input_hash4proc_g (hash with hash refs for input)
    #$res_href_l=hash ref for %h88_conf_policies_FIN_hash_g
    
    my $inv_hosts_href_l=${$input_hash4proc_href_l}{'inventory_hosts_href'};
    #inv_hosts_href_l=hash-ref for %inventory_hosts_g
    
    my $divisions_for_inv_hosts_href_l=${$input_hash4proc_href_l}{'divisions_for_inv_hosts_href'};
    #$divisions_for_inv_hosts_href_l=hash-ref for %h00_conf_divisions_for_inv_hosts_hash_g
        #$h00_conf_divisions_for_inv_hosts_hash_g{group_name}{inv-host}=1;
    
    my $policy_templates_href_l=${$input_hash4proc_href_l}{'h03_conf_policy_templates_href'};
    #$policy_templates_href_l=hash-ref for %h03_conf_policy_templates_hash_g
        #$h03_conf_policy_templates_hash_g{policy_tmplt_name--TMPLT}-> ... #{'policy_name'}
    
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
        #{'inversion'}=yes/no # not used for policies
    ######
    
    my $custom_zone_templates_href_l=${$input_hash4proc_href_l}{'h02_conf_custom_firewall_zones_templates_href'};
    #$custom_zone_templates_href_l=hash-ref for %h02_conf_custom_firewall_zones_templates_hash_g
    
    my $std_zone_templates_href_l=${$input_hash4proc_href_l}{'h02_conf_standard_firewall_zones_templates_href'};
    #$std_zone_templates_href_l=hash-ref for %h02_conf_standard_firewall_zones_templates_hash_g
    
    my $fw_ports_set_href_l=${$input_hash4proc_href_l}{'h04_conf_forward_ports_sets_href'};
    #$fw_ports_set_href_l=hash-ref for %h04_conf_forward_ports_sets_hash_g
    
    my $rich_rules_set_href_l=${$input_hash4proc_href_l}{'h05_conf_rich_rules_sets_href'};
    #$rich_rules_set_href_l=hash-ref for %h05_conf_rich_rules_sets_hash_g
    
    my $h77_conf_zones_FIN_href_l=${$input_hash4proc_href_l}{'h77_conf_zones_FIN_href'};
    #$h77_conf_zones_FIN_href_l=hash-ref for %h77_conf_zones_FIN_hash_g
        #$h77_conf_zones_FIN_hash_g{'custom/standard'}{inventory_host}{firewall_zone_name_tmplt}->
    
    my $proc_name_l=(caller(0))[3];
    
    #INVENTORY_HOST         #POLICY_NAME_TMPLT              #INGRESS-FIREWALL_ZONE_NAME_TMPLT       #EGRESS-FIREWALL_ZONE_NAME_TMPLT    #FORWARD_PORTS_SET      #RICH_RULES_SET
    #all                    policy_public2home--TMPLT       public--TMPLT                           home--TMPLT     			fw_ports_set1       	rich_rules_set1 (example)
    #10.3.2.2               policy_zoneone2zonetwo--TMPLT   zoneone--TMPLT                          zonetwo--TMPLT     			fw_ports_set2    	rich_rules_set2 (example)
    ###
    #$h88_conf_policies_FIN_hash_g{inventory_host}{policy_name_tmplt}->
    #{'ingress-firewall_zone_name_tmplt'}=value
    #{'egress-firewall_zone_name_tmplt'}=value
    #{'forward_ports_set'}=empty|fw_ports_set (FROM '04_conf_forward_ports_sets')
    #{'rich_rules_set'}=empty|rich_rules_set (FROM '05_conf_rich_rules_sets')
    #
    # ADDING not directly via '88_conf_policies_FIN'
    #{'allowed_services_set'}=[serv1,serv2,etc] (from '02_1_conf_allowed_services_sets')
        #Must exists if set defined for 'policy_name_tmplt'
            #at param 'policy_allowed_services' and set name defined at '02_1_conf_allowed_services_sets'
    #{'allowed_ports_set'}=[port1,port2,etc] (from '02_2_conf_allowed_ports_sets')
        #Must exists if set defined for 'policy_name_tmplt'
            #at param 'policy_allowed_ports' and set name defined at '02_2_conf_allowed_ports_sets'
    #{'allowed_source_ports_set'}=[port1,port2,etc] (from '02_2_conf_allowed_ports_sets')
        #Must exists if set defined for 'policy_name_tmplt'
            #at param 'policy_allowed_source_ports' and set name defined at '02_2_conf_allowed_ports_sets'
    #{'allowed_protocols_set'}=[proto1,proto2,etc] (from '02_3_conf_allowed_protocols_sets')
        #Must exists if set defined for 'policy_name_tmplt'
            #at param 'policy_allowed_protocols' and set name defined at '02_3_conf_allowed_protocols_sets'
    
    #{'icmp_blocks_set'}=[icmp-block1,icmp-block2,etc] (from '02_4_conf_icmp_blocks_sets')
    ###{'icmp_blocks_inversion'}=yes/no (from '02_4_conf_icmp_blocks_sets') = NOT EXISTS FOR policies
        #Must exists if set defined for 'firewall_zone_name_tmplt'
            #at param 'policy_icmp_block' and set name defined at '02_4_conf_icmp_blocks_sets'
    ###
    
    my ($exec_res_l,$inv_host_l)=(undef,undef);
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my $policy_name_l=undef;
    my ($ingress_zone_name_l,$egress_zone_name_l)=(undef,undef); # for ingress_egress_uniq_check_l
    my $set_name_l=undef;
    my $return_str_l='OK';
    
    my %policy_name_uniq_check_l=(); # uniq check for 'inv-host + policy_name (not tmplt)'
        #key0=inv-host, key1=policy_name (not_tmplt), value=policy-tmplt-name
    
    my %ingress_egress_tmplt_uniq_check_l=(); # uniq for 'inv_host + ingress_zone_tmplt + egress_zone_tmplt'
        #key0=inv_host, key1=ingress_zone_tmplt, key2=egress_zone_tmplt, value=policy_tmplt
    
    my %policy_ingress_egress_uniq_check_l=(); # uniq for 'inv_host + policy_name + ingress_zone_name + egress_zone_name'
        #key0=inv_host, key1=policy_name (not tmplt), key2=ingress_zone_name (not tmplt), key3=egress_zone_name (not tmplt), value=policy_tmplt -> policy_name
    
    my %res_tmp_lv0_l=();
        #key=inv-host, value=[array of values]. POLICY_NAME_TMPLT-0, INGRESS-FIREWALL_ZONE_NAME_TMPLT-1, etc
    my %res_tmp_lv1_l=();
        #final hash
    
    $exec_res_l=&read_config_FIN_level0($file_l,$inv_hosts_href_l,$divisions_for_inv_hosts_href_l,6,1,\%res_tmp_lv0_l); #protects fromnot uniq 'inv-host+policy-tmplt'
    #$file_l,$inv_hosts_href_l,$divisions_for_inv_hosts_href_l,$needed_elements_at_line_arr_l,$add_ind4key_l,$res_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }
    
    # fill %res_tmp_lv1_l (begin)
    while ( ($hkey0_l,$hval0_l)=each %res_tmp_lv0_l ) {
        #hval0_l=arr-ref for [#POLICY_NAME_TMPLT-0 #INGRESS-FIREWALL_ZONE_NAME_TMPLT-1 #EGRESS-FIREWALL_ZONE_NAME_TMPLT-2 #FORWARD_PORTS_SET-3 #RICH_RULES_SET-4]
        $inv_host_l=$hkey0_l;
        $inv_host_l=~s/\+\S+$//g;
	
        # POLICY_NAME_TMPLT ops [0] (begin)
            #$policy_templates_href_l=hash-ref for %h03_conf_policy_templates_hash_g
                #$h03_conf_policy_templates_hash_g{policy_tmplt_name--TMPLT}->
        if ( !exists(${$policy_templates_href_l}{${$hval0_l}[0]}) ) {
            $return_str_l="fail [$proc_name_l]. POLICY_NAME_TMPLT='${$hval0_l}[0]' (conf='$file_l') is not exists at '03_conf_policy_templates'";
            last;
        }
        $policy_name_l=${$policy_templates_href_l}{${$hval0_l}[0]}{'policy_name'};
        # POLICY_NAME_TMPLT ops [0] (end)
    	
        # check for uniq policy_name
            #%policy_name_uniq_check_l=(); # uniq check for 'inv-host + policy_name (not tmplt)'
                #key0=inv-host, key1=policy_name (not_tmplt), value=policy-tmplt-name
        if ( exists($policy_name_uniq_check_l{$inv_host_l}{$policy_name_l}) ) {
            $return_str_l="fail [$proc_name_l]. Policy_name='$policy_name_l' (inv-host='$inv_host_l', policy-tmplt='${$hval0_l}[0]') is already assign to policy-tmplt='$policy_name_uniq_check_l{$inv_host_l}{$policy_name_l}' at conf='88_conf_policies_FIN'";
            last;
        }
        $policy_name_uniq_check_l{$inv_host_l}{$policy_name_l}=${$hval0_l}[0];
        ###
    	
        # INGRESS-FIREWALL_ZONE_NAME_TMPLT ops [1] (begin)
        if ( ${$hval0_l}[1]=~/^ANY$|^HOST$/ ) {
            $res_tmp_lv1_l{$inv_host_l}{${$hval0_l}[0]}{'ingress-firewall_zone_name_tmplt'}=${$hval0_l}[1];
            $ingress_zone_name_l=${$hval0_l}[1];
        }
        else { # INGRESS = firewall zone tmplt
            if ( exists(${$custom_zone_templates_href_l}{${$hval0_l}[1]}) ) { $ingress_zone_name_l=${$custom_zone_templates_href_l}{${$hval0_l}[1]}{'zone_name'}; }
            elsif ( exists(${$std_zone_templates_href_l}{${$hval0_l}[1]}) ) { $ingress_zone_name_l=${$std_zone_templates_href_l}{${$hval0_l}[1]}{'zone_name'}; }
            else {
                $return_str_l="fail [$proc_name_l]. Ingress-fw-zone-tmplt='${$hval0_l}[1]' (conf='$file_l') is not exists at '02_conf_custom_firewall_zones_templates/02_conf_standard_firewall_zones_templates'";
                last;
            }
        
            #$h77_conf_zones_FIN_href_l=hash-ref for %h77_conf_zones_FIN_hash_g
                #$h77_conf_zones_FIN_hash_g{'custom/standard'}{inventory_host}{firewall_zone_name_tmplt}->
            if ( !exists(${$h77_conf_zones_FIN_href_l}{'custom'}{$inv_host_l}{${$hval0_l}[1]}) && !exists(${$h77_conf_zones_FIN_href_l}{'standard'}{$inv_host_l}{${$hval0_l}[1]}) ) {
                $return_str_l="fail [$proc_name_l]. Ingress-fw-zone-tmplt='${$hval0_l}[1]' (conf='$file_l') is not exists at '77_conf_zones_FIN' for inv-host='$inv_host_l'";
                last;
            }
    	
            $res_tmp_lv1_l{$inv_host_l}{${$hval0_l}[0]}{'ingress-firewall_zone_name_tmplt'}=${$hval0_l}[1];
        }
        # INGRESS-FIREWALL_ZONE_NAME_TMPLT ops [1] (end)
    	
        # EGRESS-FIREWALL_ZONE_NAME_TMPLT ops [2] (begin)
        if ( ${$hval0_l}[2]=~/^ANY$|^HOST$/ ) {
            $res_tmp_lv1_l{$inv_host_l}{${$hval0_l}[0]}{'egress-firewall_zone_name_tmplt'}=${$hval0_l}[2];
            $egress_zone_name_l=${$hval0_l}[2];
        }
        else { # EGRESS = firewall zone tmplt
            if ( exists(${$custom_zone_templates_href_l}{${$hval0_l}[2]}) ) { $egress_zone_name_l=${$custom_zone_templates_href_l}{${$hval0_l}[2]}{'zone_name'}; }
            elsif ( exists(${$std_zone_templates_href_l}{${$hval0_l}[2]}) ) { $egress_zone_name_l=${$std_zone_templates_href_l}{${$hval0_l}[2]}{'zone_name'}; }
            else {
                $return_str_l="fail [$proc_name_l]. Egress-fw-zone-tmplt='${$hval0_l}[2]' (conf='$file_l') is not exists at '02_conf_custom_firewall_zones_templates/02_conf_standard_firewall_zones_templates'";
                last;
            }
    	
            #$h77_conf_zones_FIN_href_l=hash-ref for %h77_conf_zones_FIN_hash_g
                #$h77_conf_zones_FIN_hash_g{'custom/standard'}{inventory_host}{firewall_zone_name_tmplt}->
            if ( !exists(${$h77_conf_zones_FIN_href_l}{'custom'}{$inv_host_l}{${$hval0_l}[2]}) && !exists(${$h77_conf_zones_FIN_href_l}{'standard'}{$inv_host_l}{${$hval0_l}[2]}) ) {
                $return_str_l="fail [$proc_name_l]. Ingress-fw-zone-tmplt='${$hval0_l}[2]' (conf='$file_l') is not exists at '77_conf_zones_FIN' for inv-host='$inv_host_l'";
                last;
            }
    	
            $res_tmp_lv1_l{$inv_host_l}{${$hval0_l}[0]}{'egress-firewall_zone_name_tmplt'}=${$hval0_l}[2];
        }
        # EGRESS-FIREWALL_ZONE_NAME_TMPLT ops [2] (end)
	
        # CHECK for uniq 'inv-host + ingress-zone-tmplt + egress-zone-tmplt'
            #%ingress_egress_tmplt_uniq_check_l=(); # uniq for 'inv_host + ingress_zone_tmplt + egress_zone_tmplt'
                #key0=inv_host, key1=ingress_zone_tmplt, key2=egress_zone_tmplt, value=policy_tmplt
        if ( exists($ingress_egress_tmplt_uniq_check_l{$inv_host_l}{${$hval0_l}[1]}{${$hval0_l}[2]}) ) {
            $return_str_l="fail [$proc_name_l]. Incorrect policy-tmplt='${$hval0_l}[0]' for inv-host='$inv_host_l'. Pair = '${$hval0_l}[1]' (ingress-zone-tmplt) + '${$hval0_l}[2]' (egress-zone-tmplt) is already used for policy-tmplt='$ingress_egress_tmplt_uniq_check_l{$inv_host_l}{${$hval0_l}[1]}{${$hval0_l}[2]}'";
            last;
        }
        $ingress_egress_tmplt_uniq_check_l{$inv_host_l}{${$hval0_l}[1]}{${$hval0_l}[2]}=${$hval0_l}[0];
        ###
	
        # CHECK for uniq 'inv-host + policy-name + ingress-zone-name + egress-zone-name'
            #%policy_ingress_egress_uniq_check_l=(); # uniq for 'inv_host + policy_name + ingress_zone_name + egress_zone_name'
                #key0=inv_host, key1=policy_name (not tmplt), key2=ingress_zone_name (not tmplt), key3=egress_zone_name (not tmplt), value=policy_tmplt -> policy_name
        if ( exists($policy_ingress_egress_uniq_check_l{$inv_host_l}{$policy_name_l}{$ingress_zone_name_l}{$egress_zone_name_l}) ) {
            $return_str_l="fail [$proc_name_l]. Incorrect policy-tmplt='${$hval0_l}[0]' for inv-host='$inv_host_l'. Complex-key = '$policy_name_l' (policy-name) + '${$hval0_l}[1]' (ingress-zone-name) + '${$hval0_l}[2]' (egress-zone-name) is already used for policy-tmplt='$policy_ingress_egress_uniq_check_l{$inv_host_l}{$policy_name_l}{$ingress_zone_name_l}{$egress_zone_name_l}'";
            last;
        }
        $policy_ingress_egress_uniq_check_l{$inv_host_l}{$policy_name_l}{$ingress_zone_name_l}{$egress_zone_name_l}=${$hval0_l}[0];
        ###
	
        # FORWARD_PORTS_SET ops [3] (begin)
        if ( ${$hval0_l}[3]=~/^empty$/ ) { $res_tmp_lv1_l{$inv_host_l}{${$hval0_l}[0]}{'forward_ports_set'}='empty'; }
        else {
            #$fw_ports_set_href_l=hash-ref for %h04_conf_forward_ports_sets_hash_g
                #$h04_conf_forward_ports_sets_hash_g{inv-host}{set_name}-> ...
            if ( !exists(${$fw_ports_set_href_l}{$inv_host_l}{${$hval0_l}[3]}) ) {
                $return_str_l="fail [$proc_name_l]. FORWARD_PORTS_SET='${$hval0_l}[3]' (conf='$file_l) is not exists (or not configured) at '04_conf_forward_ports_sets' for inv-host='$inv_host_l'";
                last;
            }
            else { $res_tmp_lv1_l{$inv_host_l}{${$hval0_l}[0]}{'forward_ports_set'}=${$hval0_l}[3]; }
        }
        # FORWARD_PORTS_SET ops [3] (end)
	
        # RICH_RULES_SET ops [4] (begin)
        if ( ${$hval0_l}[4]=~/^empty$/ ) { $res_tmp_lv1_l{$inv_host_l}{${$hval0_l}[0]}{'rich_rules_set'}='empty'; }
        else {
            #$rich_rules_set_href_l=hash-ref for %h05_conf_rich_rules_sets_hash_g
                #$h05_conf_rich_rules_sets_hash_g{inv-host}{set_name}-> ...
            if ( !exists(${$rich_rules_set_href_l}{$inv_host_l}{${$hval0_l}[4]}) ) {
                $return_str_l="fail [$proc_name_l]. RICH_RULES_SET='${$hval0_l}[4]' (conf='$file_l) is not exists (or not configured) at '05_conf_rich_rules_sets' for inv-host='$inv_host_l'";
                last;
            }
            else { $res_tmp_lv1_l{$inv_host_l}{${$hval0_l}[0]}{'rich_rules_set'}=${$hval0_l}[4]; }
        }
        # RICH_RULES_SET ops [4] (end)
	
        # allowed_services_set (begin)
	    #$inv_host_l
	    #${$hval0_l}[0]=POLICY_NAME_TMPLT
            #$h03_conf_policy_templates_hash_g{policy_tmplt_name--TMPLT}-> ($policy_templates_href_l)
                #... #{'policy_allowed_services'}{'seq'} = (if exists) and seq[0]=set:*
	    ##$allowed_ports_sets_href_l
        if ( exists(${$policy_templates_href_l}{${$hval0_l}[0]}{'policy_allowed_services'}{'seq'}) ) {
            @arr0_l=@{${$policy_templates_href_l}{${$hval0_l}[0]}{'policy_allowed_services'}{'seq'}};

            if ( $arr0_l[0]=~/^set\:(\S+)$/ ) {
                $set_name_l=$1;

                if ( !exists(${$allowed_services_sets_href_l}{$set_name_l}{$inv_host_l}) ) {
                    $return_str_l="fail [$proc_name_l]. Allowed_services_set='$set_name_l' (conf='02_1_conf_allowed_services_sets') is not configured for inv-host='$inv_host_l' (within a group or tag 'all')";
                    last;
                }
                else {
                    $res_tmp_lv1_l{$inv_host_l}{${$hval0_l}[0]}{'allowed_services_set'}=[@{${$allowed_services_sets_href_l}{$set_name_l}{$inv_host_l}{'seq'}}];
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
	    #***{'policy_allowed_ports'}***
	    #$allowed_ports_sets_href_l
        if ( exists(${$policy_templates_href_l}{${$hval0_l}[0]}{'policy_allowed_ports'}{'seq'}) ) {
            @arr0_l=@{${$policy_templates_href_l}{${$hval0_l}[0]}{'policy_allowed_ports'}{'seq'}};

            if ( $arr0_l[0]=~/^set\:(\S+)$/ ) {
                $set_name_l=$1;

                if ( !exists(${$allowed_ports_sets_href_l}{$set_name_l}{$inv_host_l}) ) {
                    $return_str_l="fail [$proc_name_l]. Allowed_ports_set='$set_name_l' (conf='02_2_conf_allowed_ports_sets') is not configured for inv-host='$inv_host_l' (within a group or tag 'all')";
                    last;
                }
                else {
                    $res_tmp_lv1_l{$inv_host_l}{${$hval0_l}[0]}{'allowed_ports_set'}=[@{${$allowed_ports_sets_href_l}{$set_name_l}{$inv_host_l}{'seq'}}];
                }
                
                # clear vars
                $set_name_l=undef;
                ###
            }
            
            # clear vars
            @arr0_l=();
            ###
        }
        # allowed_ports_set (end)
	
        # allowed_source_ports_set (begin)
	    #***{'policy_allowed_source_ports'}***
	    #$allowed_ports_sets_href_l
        if ( exists(${$policy_templates_href_l}{${$hval0_l}[0]}{'policy_allowed_source_ports'}{'seq'}) ) {
            @arr0_l=@{${$policy_templates_href_l}{${$hval0_l}[0]}{'policy_allowed_source_ports'}{'seq'}};

            if ( $arr0_l[0]=~/^set\:(\S+)$/ ) {
                $set_name_l=$1;

                if ( !exists(${$allowed_ports_sets_href_l}{$set_name_l}{$inv_host_l}) ) {
                    $return_str_l="fail [$proc_name_l]. Allowed_source_ports_set='$set_name_l' (conf='02_2_conf_allowed_ports_sets') is not configured for inv-host='$inv_host_l' (within a group or tag 'all')";
                    last;
                }
                else {
                    $res_tmp_lv1_l{$inv_host_l}{${$hval0_l}[0]}{'allowed_source_ports_set'}=[@{${$allowed_ports_sets_href_l}{$set_name_l}{$inv_host_l}{'seq'}}];
                }
                
                # clear vars
                $set_name_l=undef;
                ###
            }
            
            # clear vars
            @arr0_l=();
            ###
        }
        # allowed_source_ports_set (end)
	
        # allowed_protocols_set (begin)
	    #***{'policy_allowed_protocols'}***
	    #$allowed_protocols_sets_href_l
        # allowed_protocols_set (end)
	
        # icmp_blocks_set (begin)
	    #***{'policy_icmp_block'}***
	    #$icmp_blocks_sets_href_l
        # icmp_blocks_set (end)
    }
    
    ($hkey0_l,$hval0_l)=(undef,undef);
    $inv_host_l=undef;
    $policy_name_l=undef;
    
    if ( $return_str_l!~/^OK$/ ) { return $return_str_l; }
    # fill %res_tmp_lv1_l (end)
    
    # fill result hash
    %{$res_href_l}=%res_tmp_lv1_l;
    ###
    
    %res_tmp_lv1_l=();
    
    return $return_str_l;
}

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
