###DEPENDENCIES: file_operations.pl

sub generate_shell_script_for_recreate_policies_v2 {
    my ($dyn_fwrules_files_dir_l,$input_hash4proc_href_l)=@_;
    #$dyn_fwrules_files_dir_l=$dyn_fwrules_files_dir_g
    #$input_hash4proc_href_l=hash-ref for %input_hash4proc_g (hash with hash refs for input)
    
    my $inv_hosts_href_l=${$input_hash4proc_href_l}{'inventory_hosts_href'};
    #$inv_hosts_href_l=hash-ref for %invetory_hosts_g
    
    my $conf_firewalld_href_l=${$input_hash4proc_href_l}{'h00_conf_firewalld_href'};
    #$conf_firewalld_href_l=hash-ref for %h00_conf_firewalld_hash_g
    	#$h00_conf_firewalld_hash_g{inventory_host}->
    
    my $ipset_templates_href_l=${$input_hash4proc_href_l}{'h01_conf_ipset_templates_href'};
    #$ipset_templates_href_l=hash-ref for %h01_conf_ipset_templates_hash_g
    	#$h01_conf_ipset_templates_hash_g{'temporary/permanent'}{ipset_template_name--TMPLT}->
    
    my $custom_zone_templates_href_l=${$input_hash4proc_href_l}{'h02_conf_custom_firewall_zones_templates_href'};
    #$custom_zone_templates_href_l=hash-ref for %h02_conf_custom_firewall_zones_templates_hash_g
    
    my $std_zone_templates_href_l=${$input_hash4proc_href_l}{'h02_conf_standard_firewall_zones_templates_href'};
    #$std_zone_templates_href_l=hash-ref for %h02_conf_standard_firewall_zones_templates_hash_g
    
    my $conf_policy_templates_href_l=${$input_hash4proc_href_l}{'h03_conf_policy_templates_href'};
    #$conf_policy_templates_href_l=hash-ref for %h03_conf_policy_templates_hash_g
        
    my $fw_ports_set_href_l=${$input_hash4proc_href_l}{'h04_conf_forward_ports_sets_href'};
    #$fw_ports_set_href_l=hash-ref for %h04_conf_forward_ports_sets_hash_g
    	#$h04_conf_forward_ports_sets_hash_g{inv-host}{set_name}->
    
    my $rich_rules_set_href_l=${$input_hash4proc_href_l}{'h05_conf_rich_rules_sets_href'};
    #$rich_rules_set_href_l=hash-ref for %h05_conf_rich_rules_sets_hash_g
    	#$h05_conf_rich_rules_sets_hash_g{inv-host}{set_name}->
    
    my $h88_conf_policies_FIN_href_l=${$input_hash4proc_href_l}{'h88_conf_policies_FIN_href'};
    #$h88_conf_policies_FIN_href_l=hash-ref for %h88_conf_policies_FIN_hash_g
    	#$h88_conf_policies_FIN_hash_g{inventory_host}{policy_name_tmplt}->
    
    my $proc_name_l=(caller(0))[3];
    
    #$h01_conf_ipset_templates_hash_g{'temporary/permanent'}{ipset_template_name--TMPLT}->
    #{'ipset_name'}=value
    #{'ipset_description'}=empty|value
    #{'ipset_short_description'}=empty|value
    #{'ipset_create_option_timeout'}=num
    #{'ipset_create_option_hashsize'}=num
    #{'ipset_create_option_maxelem'}=num
    #{'ipset_create_option_family'}=inet|inet6
    #{'ipset_type'}=hash:ip|hash:ip,port|hash:ip,mark|hash:net|hash:net,port|hash:net,iface|hash:mac|hash:ip,port,ip|hash:ip,port,net|hash:net,net|hash:net,port,net
    ######
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
    ######
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
    
    ######
    #$h03_conf_policy_templates_hash_g{policy_tmplt_name--TMPLT}->
    #{'policy_name'}=value
    #{'policy_description'}=empty|value
    #{'policy_short_description'}=empty|value
    #{'policy_target'}=ACCEPT|REJECT|DROP|CONTINUE
    #{'policy_priority'}=num (+/-)
    #{'policy_allowed_services'}->
    	#{'empty'}=1 or
    	#{'list'}->
    	    #{'service-0'}=1
    	    #{'service-1'}=1
    	    #etc
    	#{'seq'}=[val-0,val-1] (val=service)
    #{'policy_allowed_ports'}->
    	#{'empty'}=1 or
    	#{'list'}->
    	    #{'port-0'}=1
    	    #{'port-1'}=1
    	    #etc
    	#{'seq'}=[val-0,val-1] (val=port)
    #{'policy_allowed_protocols'}->
    	#{'empty'}=1 or
    	#{'list'}->
    	    #{'proto-0'}=1
    	    #{'proto-1'}=1
    	    #etc
    	#{'seq'}=[val-0,val-1] (val=proto)
    #{'policy_masquerade_general'}=yes|no
    #{'policy_allowed_source_ports'}->
    	#{'empty'}=1 or
    	#{'list'}->
    	    #{'port-0'}=1
    	    #{'port-1'}=1
    	    #etc
    	#{'seq'}=[val-0,val-1] (val=port)
    #{'policy_icmp_block'}->
    	#{'empty'}=1 or
    	#{'list'}->
    	    #{'icmptype-0'}=1
    	    #{'icmptype-1'}=1
    	    #etc
        #{'seq'}=[val-0,val-1] (val=icmptype)
    ######
    #$h04_conf_forward_ports_sets_hash_g{inv-host}{set_name}->
        #{'rule-0'}=1
        #{'rule-1'}=1
        #etc
        #{'seq'}=[val-0,val-1] (val=rule)
    ######
    #$h05_conf_rich_rules_sets_hash_g{inv-host}{set_name}->
        #{'rule-0'}=1
        #{'rule-1'}=1
        #etc
        #{'seq'}=[val-0,val-1] (val=rule)
    ######
    #$h88_conf_policies_FIN_hash_g{inventory_host}{policy_name_tmplt}->
    #{'ingress-firewall_zone_name_tmplt'}=value
    #{'egress-firewall_zone_name_tmplt'}=value
    #{'forward_ports_set'}=empty|fw_ports_set (FROM '04_conf_forward_ports_sets')
    #{'rich_rules_set'}=empty|rich_rules_set (FROM '05_conf_rich_rules_sets')
    
    # ADDING not directly via '88_conf_policies_FIN' (see 'read_88_conf_fwrules.pl')
    #{'allowed_services_set'}=[serv1,serv2,etc] (from '02_1_conf_allowed_services_sets')
    #{'allowed_services_set_empty'}=1 (if set configured, but set is empty for current inv-host)
    
    #{'allowed_ports_set'}=[port1,port2,etc] (from '02_2_conf_allowed_ports_sets')
    #{'allowed_ports_set_empty'}=1 (if set configured, but set is empty for current inv-host)
    
    #{'allowed_source_ports_set'}=[port1,port2,etc] (from '02_2_conf_allowed_ports_sets')
    #{'allowed_source_ports_set_empty'}=1 (if set configured, but set is empty for current inv-host)
    
    #{'allowed_protocols_set'}=[proto1,proto2,etc] (from '02_3_conf_allowed_protocols_sets')
    #{'allowed_protocols_set_empty'}=1 (if set configured, but set is empty for current inv-host)
    
    #{'icmp_blocks_set'}=[icmp-block1,icmp-block2,etc] (from '02_4_conf_icmp_blocks_sets')
    #{'icmp_blocks_set_empty'}=1 (if set configured, but set is empty for current inv-host)
    ######
    
    my $exec_res_l=undef;
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my ($hkey1_l,$hval1_l)=(undef,undef);
    my ($arr_el0_l,$arr_el1_l)=(undef,undef);
    my @tmp_arr_l=();
    
    my $wr_str_l=undef;
    my $wr_file_l=undef;
    my @wr_arr_l=();
    
    # init fw-zone-params (begin)
    my ($policy_name_l,$policy_target_l)=(undef,undef,undef,undef);
    my ($policy_description_l,$policy_short_description_l,$policy_priority_l)=(undef,undef,undef);
    my @policy_allowed_services_arr_l=();
    my @policy_allowed_ports_arr_l=();
    my @policy_allowed_protocols_arr_l=();
    my $policy_masquerade_general_l=undef;
    my @policy_allowed_source_ports_arr_l=();
    my @policy_icmp_block_arr_l=();
    
    my $ingress_firewall_zone_name_tmplt_l=undef;
    my $ingress_firewall_zone_name_l=undef;
    
    my $egress_firewall_zone_name_tmplt_l=undef;
    my $egress_firewall_zone_name_l=undef;
    
    my $forward_ports_set_l=undef;
    my @forward_ports_arr_l=(); 
    
    my $rich_rules_set_l=undef;
    my @rich_rules_arr_l=();
    # init fw-zone-params (end)
    
    my @begin_script_arr_l=();
    my %wr_hash_l=();
        #key0=inv-host, key1=wr_type (standard, custom, etc), value=array of strings
    my $return_str_l='OK';
    
    # fill array with strings for scripts at all hosts (begin)
    @begin_script_arr_l=(
    	'#!/usr/bin/bash',
    	' ',
    	'###GENERATED BY ansible_helpers/conf_firewalld (https://github.com/vladimir-chursin000/ansible_helpers)',
    	'###DO NOT CHANGE!',
    	' '
    );
    # fill array with strings for scripts at all hosts (end)
    
    # fill array (for each host) with commands for recreate policies (begin)
    while ( ($hkey0_l,$hval0_l)=each %{$h88_conf_policies_FIN_href_l} ) {
    	#$hkey0_l=inv-host
    
    	#%wr_hash_l=();
    	    #key0=inv-host, key1=wr_type (standard, custom, etc), value=array of strings
    	
    	# commands for remove policies (begin)
    	# $wr_str_l="rm -rf /etc/firewalld/policies/*;";
    	$wr_str_l='#REMOVE_POLICIES'; # NEW 20231102
        push(@{$wr_hash_l{$hkey0_l}{'policies_remove'}},$wr_str_l);
    	
        $wr_str_l=undef;
    	# commands for remove policies (end)
    	
    	# commands for configure policies (begin)
    	@tmp_arr_l=sort(keys %{$hval0_l});
    	foreach $arr_el0_l ( @tmp_arr_l ) {
    	    #$arr_el0_l=policy-tmplt-name
    	    $policy_name_l=${$conf_policy_templates_href_l}{$arr_el0_l}{'policy_name'};
    	    # Create policy = "firewall-cmd --permanent --new-policy=some_policy_name"
    	    $wr_str_l="firewall-cmd --permanent --new-policy='$policy_name_l';";
    	    push(@{$wr_hash_l{$hkey0_l}{'policies_recreate'}},$wr_str_l);
    	    
    	    $wr_str_l=undef;
    	    ###
    	    
    	    # description (begin)
    	    $policy_description_l=${$conf_policy_templates_href_l}{$arr_el0_l}{'policy_description'};
    	    	#$arr_el0_l=policy-tmplt-name
    	    if ( $policy_description_l ne 'empty' ) {
    	    	# Set policy description = "firewall-cmd --permanent --policy=some_policy_name --set-description='some_description'"	
    	    	$wr_str_l="firewall-cmd --permanent --policy='$policy_name_l' --set-description='$policy_description_l';";
    	    	push(@{$wr_hash_l{$hkey0_l}{'policies_recreate'}},$wr_str_l);
    	    
    	    	$wr_str_l=undef;
    	    }
    	    
    	    $policy_description_l=undef;
    	    # description (end)
    	    
    	    # short description (begin)
    	    $policy_short_description_l=${$conf_policy_templates_href_l}{$arr_el0_l}{'policy_short_description'};
    	    	#$arr_el0_l=policy-tmplt-name
    	    if ( $policy_short_description_l ne 'empty' ) {
    	    	# Set policy short description = "firewall-cmd --permanent --policy=some_policy_name --set-short='some_short_description'"
    	    	$wr_str_l="firewall-cmd --permanent --policy='$policy_name_l' --set-short='$policy_short_description_l';";
    	    	push(@{$wr_hash_l{$hkey0_l}{'policies_recreate'}},$wr_str_l);
    	    
    	    	$wr_str_l=undef;
    	    }
    	    
    	    $policy_short_description_l=undef;
    	    # short description (end)
    	    
    	    # policy_target (begin)
    	    $policy_target_l=${$conf_policy_templates_href_l}{$arr_el0_l}{'policy_target'};
    	    	#$arr_el0_l=policy-tmplt-name
    	    # Set policy target = "firewall-cmd --permanent --policy=some_policy_name --set-target=some_target"
    	    $wr_str_l="firewall-cmd --permanent --policy='$policy_name_l' --set-target=$policy_target_l;";
    	    push(@{$wr_hash_l{$hkey0_l}{'policies_recreate'}},$wr_str_l);
    	    
    	    $wr_str_l=undef;
    	    $policy_priority_l=undef;
    	    # policy_target (end)
    	    
    	    # policy_priority (begin)
    	    $policy_priority_l=${$conf_policy_templates_href_l}{$arr_el0_l}{'policy_priority'};
    	    	#$arr_el0_l=policy-tmplt-name
    	    # Set policy priority = "firewall-cmd --permanent --policy=some_policy_name --set-priority=-1"
    	    $wr_str_l="firewall-cmd --permanent --policy='$policy_name_l' --set-priority=$policy_priority_l;";
    	    push(@{$wr_hash_l{$hkey0_l}{'policies_recreate'}},$wr_str_l);
    	    
    	    $wr_str_l=undef;
    	    $policy_priority_l=undef;
    	    # policy_priority (end)
    	    
    	    # services or services_sets (SETS) (begin)
    	    if ( exists(${$conf_policy_templates_href_l}{$arr_el0_l}{'policy_allowed_services'}{'seq'}) ) {
    	    	# Allow service = "firewall-cmd --permanent --policy=some_policy_name --add-service=http"
		
		if ( !exists(${$hval0_l}{$arr_el0_l}{'allowed_services_set'}) ) {
    	    	    @policy_allowed_services_arr_l=sort(@{${$conf_policy_templates_href_l}{$arr_el0_l}{'policy_allowed_services'}{'seq'}});
    	    		#$arr_el0_l=policy-tmplt-name
		}
		else { @policy_allowed_services_arr_l=sort(@{${$hval0_l}{$arr_el0_l}{'allowed_services_set'}}); }
		
    	    	foreach $arr_el1_l ( @policy_allowed_services_arr_l ) {
    	    	    #$arr_el1_l=service name for add
    	    	    $wr_str_l="firewall-cmd --permanent --policy='$policy_name_l' --add-service=$arr_el1_l;";
    	    	    push(@{$wr_hash_l{$hkey0_l}{'policies_recreate'}},$wr_str_l);
    	    	    	    
    	    	    $wr_str_l=undef;
    	    	}
    	    	
    	    	$arr_el1_l=undef;
    	    	@policy_allowed_services_arr_l=();
    	    }
    	    # services or services_sets (end)
    	    
    	    # ports or ports_sets (SETS) (begin)
    	    if ( exists(${$conf_policy_templates_href_l}{$arr_el0_l}{'policy_allowed_ports'}{'seq'}) ) {
    	    	# Allow port = "firewall-cmd --permanent --policy=some_policy_name --add-port=1234/tcp"
		
		if ( !exists(${$hval0_l}{$arr_el0_l}{'allowed_ports_set'}) ) {
    	    	    @policy_allowed_ports_arr_l=sort(@{${$conf_policy_templates_href_l}{$arr_el0_l}{'policy_allowed_ports'}{'seq'}});
    	    		#$arr_el0_l=policy-tmplt-name
		}
		else { @policy_allowed_ports_arr_l=sort(@{${$hval0_l}{$arr_el0_l}{'allowed_ports_set'}}); }
		
    	    	foreach $arr_el1_l ( @policy_allowed_ports_arr_l ) {
    	    	    #$arr_el1_l=port for allow
    	    	    $wr_str_l="firewall-cmd --permanent --policy='$policy_name_l' --add-port=$arr_el1_l;";
    	    	    push(@{$wr_hash_l{$hkey0_l}{'policies_recreate'}},$wr_str_l);
    	    	        
    	    	    $wr_str_l=undef;
    	    	}
    	    	
    	    	$arr_el1_l=undef;
    	    	@policy_allowed_ports_arr_l=();
    	    }
    	    # ports or ports_sets (end)
    	    
    	    # protocols or protocols_sets (SETS) (begin)
    	    if ( exists(${$conf_policy_templates_href_l}{$arr_el0_l}{'policy_allowed_protocols'}{'seq'}) ) {
    	    	# Allow protocol="firewall-cmd --permanent --policy=some_policy_name --add-protocol=gre"
		
		if ( !exists(${$hval0_l}{$arr_el0_l}{'allowed_protocols_set'}) ) {
    	    	    @policy_allowed_protocols_arr_l=sort(@{${$conf_policy_templates_href_l}{$arr_el0_l}{'policy_allowed_protocols'}{'seq'}});
    	    		#$arr_el0_l=policy-tmplt-name
		}
		else { @policy_allowed_protocols_arr_l=sort(@{${$hval0_l}{$arr_el0_l}{'allowed_protocols_set'}}); }
		
    	    	foreach $arr_el1_l ( @policy_allowed_protocols_arr_l ) {
    	    	    #$arr_el1_l=proto for allow
    	    	    $wr_str_l="firewall-cmd --permanent --policy='$policy_name_l' --add-protocol=$arr_el1_l;";
    	    	    push(@{$wr_hash_l{$hkey0_l}{'policies_recreate'}},$wr_str_l);
    	    	        
    	    	    $wr_str_l=undef;
    	    	}
    	    	
    	    	$arr_el1_l=undef;
    	    	@policy_allowed_protocols_arr_l=();
    	    }
    	    # protocols or protocols_sets (end)
    	    
    	    # masquerade (begin)
    	    $policy_masquerade_general_l=${$conf_policy_templates_href_l}{$arr_el0_l}{'policy_masquerade_general'};
    	    	#$arr_el0_l=policy-tmplt-name
    	    # Allow masquerade general = "firewall-cmd --permanent --policy=some_policy_name --add-masquerade"
    	    if ( $policy_masquerade_general_l eq 'yes' ) {
    	    	$wr_str_l="firewall-cmd --permanent --policy='$policy_name_l' --add-masquerade;";
    	    	push(@{$wr_hash_l{$hkey0_l}{'policies_recreate'}},$wr_str_l);
    	    	                
    	    	$wr_str_l=undef;
    	    }
    	    # masquerade (end)
    	    
    	    # source ports or source_ports_sets (SETS) (begin)
    	    if ( exists(${$conf_policy_templates_href_l}{$arr_el0_l}{'policy_allowed_source_ports'}{'seq'}) ) {
    	    	# Allow source port="firewall-cmd --permanent --policy=some_policy_name --add-source-port=8080/tcp"
		
		if ( !exists(${$hval0_l}{$arr_el0_l}{'allowed_source_ports_set'}) ) {
    	    	    @policy_allowed_source_ports_arr_l=sort(@{${$conf_policy_templates_href_l}{$arr_el0_l}{'policy_allowed_source_ports'}{'seq'}});
    	    		#$arr_el0_l=policy-tmplt-name
		}
		else { @policy_allowed_source_ports_arr_l=sort(@{${$hval0_l}{$arr_el0_l}{'allowed_source_ports_set'}}); }
		
    	    	foreach $arr_el1_l ( @policy_allowed_source_ports_arr_l ) {
    	    	    #$arr_el1_l=port for allow
    	    	    $wr_str_l="firewall-cmd --permanent --policy='$policy_name_l' --add-source-port=$arr_el1_l;";
    	    	    push(@{$wr_hash_l{$hkey0_l}{'policies_recreate'}},$wr_str_l);
    	    	        
    	    	    $wr_str_l=undef;
    	    	}
    	    	
    	    	$arr_el1_l=undef;
    	    	@policy_allowed_source_ports_arr_l=();
    	    }
    	    # source ports or source_ports_sets (end)
    	    
    	    # icmp block or icmp_blocks_sets (SETS) (begin)
    	    if ( exists(${$conf_policy_templates_href_l}{$arr_el0_l}{'policy_icmp_block'}{'seq'}) ) {
    	    	# Add icmptype to icmp-block section = "firewall-cmd --permanent --policy=some_policy_name --add-icmp-block=some_icmp_type"
		
		if ( !exists(${$hval0_l}{$arr_el0_l}{'icmp_blocks_set'}) ) {
    	    	    @policy_icmp_block_arr_l=sort(@{${$conf_policy_templates_href_l}{$arr_el0_l}{'policy_icmp_block'}{'seq'}});
    	    		#$arr_el0_l=policy-tmplt-name
		}
		else { @policy_icmp_block_arr_l=sort(@{${$hval0_l}{$arr_el0_l}{'icmp_blocks_set'}}); }
		
        	foreach $arr_el1_l ( @policy_icmp_block_arr_l ) {
                    #$arr_el1_l=icmp-block
                    $wr_str_l="firewall-cmd --permanent --policy='$policy_name_l' --add-icmp-block=$arr_el1_l;";
                    push(@{$wr_hash_l{$hkey0_l}{'policies_recreate'}},$wr_str_l);
        	
                    $wr_str_l=undef;
                }
        	
                $arr_el1_l=undef;
                @policy_icmp_block_arr_l=();
    	    }
    	    # icmp block or icmp_blocks_sets (end)
    	    
    	    # ingress (begin)
    	    $ingress_firewall_zone_name_tmplt_l=${$hval0_l}{$arr_el0_l}{'ingress-firewall_zone_name_tmplt'};
    	    	#$arr_el0_l=policy-tmplt-name
    	    if ( $ingress_firewall_zone_name_tmplt_l!~/^ANY$|^HOST$/ ) {
    	    	if ( exists(${$custom_zone_templates_href_l}{$ingress_firewall_zone_name_tmplt_l}) ) {
    	    	    $ingress_firewall_zone_name_l=${$custom_zone_templates_href_l}{$ingress_firewall_zone_name_tmplt_l}{'zone_name'};
    	    	}
    	    	elsif ( exists(${$std_zone_templates_href_l}{$ingress_firewall_zone_name_tmplt_l}) ) {
    	    	    $ingress_firewall_zone_name_l=${$std_zone_templates_href_l}{$ingress_firewall_zone_name_tmplt_l}{'zone_name'};
    	    	}
    	    }
    	    else { $ingress_firewall_zone_name_l=$ingress_firewall_zone_name_tmplt_l; }
    	    # Add ingress zone to policy = "firewall-cmd --permanent --policy=some_policy --add-ingress-zone=some_firewall_zone"
    	    $wr_str_l="firewall-cmd --permanent --policy='$policy_name_l' --add-ingress='$ingress_firewall_zone_name_l';";
    	    push(@{$wr_hash_l{$hkey0_l}{'policies_recreate'}},$wr_str_l);
    	    	                
    	    $wr_str_l=undef;
    	    $ingress_firewall_zone_name_l=undef;
    	    $ingress_firewall_zone_name_tmplt_l=undef;
    	    # ingress (end)
    	    
    	    # egress (begin)
    	    $egress_firewall_zone_name_tmplt_l=${$hval0_l}{$arr_el0_l}{'egress-firewall_zone_name_tmplt'};
    	    	#$arr_el0_l=policy-tmplt-name
    	    if ( $egress_firewall_zone_name_tmplt_l!~/^ANY$|^HOST$/ ) {
    	    	if ( exists(${$custom_zone_templates_href_l}{$egress_firewall_zone_name_tmplt_l}) ) {
    	    	    $egress_firewall_zone_name_l=${$custom_zone_templates_href_l}{$egress_firewall_zone_name_tmplt_l}{'zone_name'};
    	    	}
    	    	elsif ( exists(${$std_zone_templates_href_l}{$egress_firewall_zone_name_tmplt_l}) ) {
    	    	    $egress_firewall_zone_name_l=${$std_zone_templates_href_l}{$egress_firewall_zone_name_tmplt_l}{'zone_name'};
    	    	}
    	    }
    	    else { $egress_firewall_zone_name_l=$egress_firewall_zone_name_tmplt_l; }
    	    # Add ingress zone to policy = "firewall-cmd --permanent --policy=some_policy --add-egress-zone=some_firewall_zone"
    	    $wr_str_l="firewall-cmd --permanent --policy='$policy_name_l' --add-egress='$egress_firewall_zone_name_l';";
    	    push(@{$wr_hash_l{$hkey0_l}{'policies_recreate'}},$wr_str_l);
    	    	                
    	    $wr_str_l=undef;
    	    $egress_firewall_zone_name_l=undef;
    	    $egress_firewall_zone_name_tmplt_l=undef;
    	    # egress (end)
    	    
    	    # forward_ports_set (begin)
    	    	#$fw_ports_set_href_l
    	        #$h04_conf_forward_ports_sets_hash_g{inv-host}{set_name}->
    	    	    #{'rule-0'}=1
    	    	    #{'rule-1'}=1
    	    	    #etc
    	    	    #{'seq'}=[val-0,val-1] (val=rule)
    	    # Add forward-port = "firewall-cmd --permanent --policy=some_zone_name --add-forward-port='some-fw-port-string'" (for information only).
    	    $forward_ports_set_l=${$hval0_l}{$arr_el0_l}{'forward_ports_set'};
    	    	#$arr_el0_l=policy-tmplt-name
    	    if ( $forward_ports_set_l ne 'empty' ) {
    	    	@forward_ports_arr_l=sort(@{${$fw_ports_set_href_l}{$hkey0_l}{$forward_ports_set_l}{'seq'}});
    	    	foreach $arr_el1_l ( @forward_ports_arr_l ) {
                    #$arr_el1_l=forward-port rule
                    $wr_str_l="firewall-cmd --permanent --policy='$policy_name_l' --add-forward-port='$arr_el1_l';";
                    push(@{$wr_hash_l{$hkey0_l}{'policies_recreate'}},$wr_str_l);
            
                    $wr_str_l=undef;
                }
            
                $arr_el1_l=undef;
                @forward_ports_arr_l=();
    	    }
    	    # forward_ports_set (end)
    	    
    	    # rich_rules_set (begin)
    	    	#$rich_rules_set_href_l
    	    	#$h05_conf_rich_rules_sets_hash_g{inv-host}{set_name}->
    	    	    #{'rule-0'}=1
    	    	    #{'rule-1'}=1
    	    	    #etc
    	    	    #{'seq'}=[val-0,val-1] (val=rule)
    	    # Add rich-rule = "firewall-cmd --permanent --policy=some_policy_name --add-rich-rule='some-rich-rule-string'" (for information only).
    	    $rich_rules_set_l=${$hval0_l}{$arr_el0_l}{'rich_rules_set'};
    	    	#$arr_el0_l=policy-tmplt-name
    	    if ( $rich_rules_set_l ne 'empty' ) {
    	    	@rich_rules_arr_l=sort(@{${$rich_rules_set_href_l}{$hkey0_l}{$rich_rules_set_l}{'seq'}});
    	    	foreach $arr_el1_l ( @rich_rules_arr_l ) {
                    #$arr_el1_l=rich-rule
                    $wr_str_l="firewall-cmd --permanent --policy='$policy_name_l' --add-rich-rule='$arr_el1_l';";
                    push(@{$wr_hash_l{$hkey0_l}{'policies_recreate'}},$wr_str_l);
            
                    $wr_str_l=undef;
                }
            
                $arr_el1_l=undef;
                @rich_rules_arr_l=();
    	    }
    	    # rich_rules_set (end)
    	    
    	    push(@{$wr_hash_l{$hkey0_l}{'policies_recreate'}},' ');
    	}
    	
    	$arr_el0_l=undef;
    	$policy_name_l=undef;
    	@tmp_arr_l=();
    	# commands for configure policies (end)
    }
    
    ($hkey0_l,$hval0_l)=(undef,undef);
    
    if ( $return_str_l!~/^OK$/ ) { return $return_str_l; }
    # fill array (for each host) with commands for recreate policies (end)
    
    # create scripts for each host (begin)
    	#@begin_script_arr_l
    while ( ($hkey0_l,$hval0_l)=each %{$inv_hosts_href_l} ) {
    	#$hkey0_l=inv-host
    	    #subkeys: policies_remove, policies_recreate
    	if ( ! -d "$dyn_fwrules_files_dir_l/$hkey0_l" ) { system("mkdir -p $dyn_fwrules_files_dir_l/$hkey0_l"); }
    	$wr_file_l=$dyn_fwrules_files_dir_l.'/'.$hkey0_l.'/recreate_policies.sh';
    	
    	if ( exists($wr_hash_l{$hkey0_l}) ) {    
    	    @wr_arr_l=(@begin_script_arr_l);
    	    if ( exists($wr_hash_l{$hkey0_l}{'policies_remove'}) ) { @wr_arr_l=(@wr_arr_l,@{$wr_hash_l{$hkey0_l}{'policies_remove'}}); }
    	    if ( exists($wr_hash_l{$hkey0_l}{'policies_recreate'}) ) { @wr_arr_l=(@wr_arr_l,' ',@{$wr_hash_l{$hkey0_l}{'policies_recreate'}}); }
    	}
    	elsif ( !exists($wr_hash_l{$hkey0_l}) && ${$conf_firewalld_href_l}{$hkey0_l}{'if_no_policies_conf_action'}=~/^remove$/ ) {
    	    @wr_arr_l=(@begin_script_arr_l);
    	    # @wr_arr_l=(@wr_arr_l,'rm -rf /etc/firewalld/policies/*;',' ');
    	    @wr_arr_l=(@wr_arr_l,'#REMOVE_POLICIES',' '); # NEW 20231102
    	}
    	else { @wr_arr_l=(@begin_script_arr_l,'#NO NEED TO RECREATE POLICIES'); }
    	
    	$exec_res_l=&rewrite_file_from_array_ref($wr_file_l,\@wr_arr_l);
    	#$file_l,$aref_l
    	if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }
    	    
    	$wr_file_l=undef;
    	@wr_arr_l=();
    }
    
    ($hkey0_l,$hval0_l)=(undef,undef);
    # create scripts for each host (end)
    
    return $return_str_l;
}

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
