###DEPENDENCIES: file_operations.pl

sub generate_shell_script_for_recreate_firewall_zones_v2 {
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
    
    my $std_zone_templates_href_l=${$input_hash4proc_href_l}{'h02_conf_standard_firewall_zones_templates_href'};
    #$std_zone_templates_href_l=hash-ref for %h02_conf_standard_firewall_zones_templates_hash_g
    
    my $custom_zone_templates_href_l=${$input_hash4proc_href_l}{'h02_conf_custom_firewall_zones_templates_href'};
    #$custom_zone_templates_href_l=hash-ref for %h02_conf_custom_firewall_zones_templates_hash_g
    
    my $fw_ports_set_href_l=${$input_hash4proc_href_l}{'h04_conf_forward_ports_sets_href'};
    #$fw_ports_set_href_l=hash-ref for %h04_conf_forward_ports_sets_hash_g
    	#$h04_conf_forward_ports_sets_hash_g{inv-host}{set_name}->
    
    my $rich_rules_set_href_l=${$input_hash4proc_href_l}{'h05_conf_rich_rules_sets_href'};
    #$rich_rules_set_href_l=hash-ref for %h05_conf_rich_rules_sets_hash_g
    	#$h05_conf_rich_rules_sets_hash_g{inv-host}{set_name}->
    
    my $h77_conf_zones_FIN_href_l=${$input_hash4proc_href_l}{'h77_conf_zones_FIN_href'};
    #$h77_conf_zones_FIN_href_l=hash-ref for %h77_conf_zones_FIN_hash_g
    	#$h77_conf_zones_FIN_hash_g{'custom/standard'}{inventory_host}{firewall_zone_name_tmplt}->
    
    my $proc_name_l=(caller(0))[3];
    
    #$h00_conf_firewalld_hash_g{inventory_host}->
    #{'unconfigured_custom_firewall_zones_action'}=no_action|remove
    #{'temporary_apply_fwrules_timeout'}=NUM
    #{'if_no_ipsets_conf_action'}=remove|no_action
    #{'if_no_zones_conf_action'}=restore_defaults|no_action
    #{'if_no_policies_conf_action'}=remove|no_action
    #{'DefaultZone'}=name_of_default_zone
    #{'CleanupOnExit'}=yes|no
    #{'CleanupModulesOnExit'}=yes|no
    #{'Lockdown'}=yes|no
    #{'IPv6_rpfilter'}=yes|no
    #{'IndividualCalls'}=yes|no
    #{'LogDenied'}=all|unicast|broadcast|multicast|off
    #{'enable_logging_of_dropped_packets'}=yes|no
    #{'FirewallBackend'}=nftables|iptables
    #{'FlushAllOnReload'}=yes|no
    #{'RFC3964_IPv4'}=yes|no
    #{'AllowZoneDrifting'}=yes|no
    ######
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
    
    # ADDING not directly via '77_conf_zones_FIN' (see 'read_77_conf_fwrules.pl')
    #{'allowed_services_set'}=[serv1,serv2,etc] (from '02_1_conf_allowed_services_sets')
    #{'allowed_sericess_set_empty'}=1 (if set configured, but set is empty for current inv-host)
    
    #{'allowed_ports_set'}=[port1,port2,etc] (from '02_2_conf_allowed_ports_sets')
    #{'allowed_ports_set_empty'}=1 (if set configured, but set is empty for current inv-host)
    
    #{'allowed_source_ports_set'}=[port1,port2,etc] (from '02_2_conf_allowed_ports_sets')
    #{'allowed_source_ports_set_empty'}=1 (if set configured, but set is empty for current inv-host)
    
    #{'allowed_protocols_set'}=[proto1,proto2,etc] (from '02_3_conf_allowed_protocols_sets')
    #{'allowed_protocols_set_empty'}=1 (if set configured, but set is empty for current inv-host)
    
    #{'icmp_blocks_set'}=[icmp-block1,icmp-block2,etc] (from '02_4_conf_icmp_blocks_sets')
    #{'icmp_blocks_set_empty'}=1 (if set configured, but set is empty for current inv-host)
    #{'icmp_blocks_inversion'}=yes/no (from '02_4_conf_icmp_blocks_sets')
    ######
    
    my $exec_res_l=undef;
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my ($hkey1_l,$hval1_l)=(undef,undef);
    my ($arr_el0_l,$arr_el1_l)=(undef,undef);
    my @tmp_arr_l=();
    
    my $wr_str_l=undef;
    my $wr_file_l=undef;
    my $unconf_custom_fw_zones_act_l=undef;
    my @wr_arr_l=();
    
    my @std_fwzones_l=('block','dmz','drop','external','internal','public','trusted','work','home');
    my %std_fwzones_defs_services_l=();
    
    # init fw-zone-params (begin)
    my ($zone_name_l,$zone_target_l)=(undef,undef,undef,undef); # std, custom
    my ($zone_description_l,$zone_short_description_l)=(undef,undef); # custom only
    my @zone_allowed_services_arr_l=(); # std, custom
    my @zone_services_for_remove_arr_l=(); # std
    my @zone_allowed_ports_arr_l=(); # std, custom
    my @zone_allowed_protocols_arr_l=(); # std, custom
    my ($zone_forward_l,$zone_masquerade_general_l)=(undef,undef); # std, custom
    my @zone_allowed_source_ports_arr_l=(); # std, custom
    my ($zone_icmp_block_inversion_l)=(undef); # std, custom
    my @zone_icmp_block_arr_l=(); # std, custom
    my @interface_list_arr_l=(); # std, custom
    my @source_list_arr_l=(); # std, custom
    
    my @ipset_tmplt_list_arr_l=(); # std, custom
    my $ipset_name_l=undef;
    
    my $forward_ports_set_l=undef; # std, custom
    my @forward_ports_arr_l=(); 
    
    my $rich_rules_set_l=undef; # std, custom
    my @rich_rules_arr_l=();
    # init fw-zone-params (end)
    
    # fill %std_fwzones_defs_services_l (begin)
    $std_fwzones_defs_services_l{'internal'}{'cockpit'}=1;
    $std_fwzones_defs_services_l{'internal'}{'dhcpv6-client'}=1;
    $std_fwzones_defs_services_l{'internal'}{'mdns'}=1;
    $std_fwzones_defs_services_l{'internal'}{'samba-client'}=1;
    $std_fwzones_defs_services_l{'internal'}{'ssh'}=1;
    
    $std_fwzones_defs_services_l{'home'}{'cockpit'}=1;
    $std_fwzones_defs_services_l{'home'}{'dhcpv6-client'}=1;
    $std_fwzones_defs_services_l{'home'}{'mdns'}=1;
    $std_fwzones_defs_services_l{'home'}{'samba-client'}=1;
    $std_fwzones_defs_services_l{'home'}{'ssh'}=1;
    
    $std_fwzones_defs_services_l{'public'}{'cockpit'}=1;
    $std_fwzones_defs_services_l{'public'}{'dhcpv6-client'}=1;
    $std_fwzones_defs_services_l{'public'}{'ssh'}=1;
    
    $std_fwzones_defs_services_l{'work'}{'cockpit'}=1;
    $std_fwzones_defs_services_l{'work'}{'dhcpv6-client'}=1;
    $std_fwzones_defs_services_l{'work'}{'ssh'}=1;
    # fill %std_fwzones_defs_services_l (end)
    		
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
    
    # fill array (for each host) with commands for recreate standard fw-zones (begin)
    while ( ($hkey0_l,$hval0_l)=each %{${$h77_conf_zones_FIN_href_l}{'standard'}} ) {
    	#$hkey0_l=inv-host
    	
    	#%wr_hash_l=();
    	    #key0=inv-host, key1=wr_type (standard, custom, etc), value=array of strings
    	
    	# commands for remove and recreate std fw-zones (begin)
    	foreach $arr_el0_l ( @std_fwzones_l ) {
    	    #$arr_el0_l=std zone name
    	    $wr_str_l='\cp '."/usr/lib/firewalld/zones/$arr_el0_l.xml /etc/firewalld/zones/$arr_el0_l.xml;";
    	    push(@{$wr_hash_l{$hkey0_l}{'std_recreate'}},$wr_str_l);
    	    
    	    $wr_str_l=undef;
    	}
    	
    	$arr_el0_l=undef;
    	# commands for remove and recreate std fw-zones (end)
    	
    	# commands for configure and correcting std fw-zones (begin)
    	@tmp_arr_l=sort(keys %{$hval0_l});
    	foreach $arr_el0_l ( @tmp_arr_l ) {
    	    #$arr_el0_l=fw-zone-tmplt-name
    	    $zone_name_l=${$std_zone_templates_href_l}{$arr_el0_l}{'zone_name'};
    	    
    	    # target (begin)
    	    $zone_target_l=${$std_zone_templates_href_l}{$arr_el0_l}{'zone_target'};
    	    # Set zone target = "firewall-cmd --permanent --zone=some_std_zone_name --set-target=some_target"
    	    $wr_str_l="firewall-cmd --permanent --zone=$zone_name_l --set-target=$zone_target_l;";
    	    push(@{$wr_hash_l{$hkey0_l}{'standard'}},$wr_str_l);
    	    
    	    $wr_str_l=undef;
    	    $zone_target_l=undef;
    	    # target (end)
    	    
    	    # services or services_sets (SETS) (begin)
    	    if ( exists(${$std_zone_templates_href_l}{$arr_el0_l}{'zone_allowed_services'}{'seq'}) or exists(${$hval0_l}{$arr_el0_l}{'allowed_services_set'}) ) {
    	    	#internal=cockpit,dhcpv6-client,mdns,samba-client,ssh (services)
    	    	#home=cockpit,dhcpv6-client,mdns,samba-client,ssh
    	    	#public=cockpit,dhcpv6-client,ssh (services)
    	    	#work=cockpit,dhcpv6-client,ssh
    	    	#$std_fwzones_defs_services_l{zone-name}{service-name}=1
    	    	# Allow service = "firewall-cmd --permanent --zone=some_std_zone_name --add-service=http"
		
		if ( !exists(${$hval0_l}{$arr_el0_l}{'allowed_services_set'}) ) {
    	    	    @zone_allowed_services_arr_l=sort(@{${$std_zone_templates_href_l}{$arr_el0_l}{'zone_allowed_services'}{'seq'}});
    	    		#$arr_el0_l=fw-zone-tmplt-name
		    if ( $zone_allowed_services_arr_l[0]=~/^set\:/ ) { @zone_allowed_services_arr_l=(); } # clear arr if set is empty
		}
		else { @zone_allowed_services_arr_l=sort(@{${$hval0_l}{$arr_el0_l}{'allowed_services_set'}}); }
    	    	if ( exists($std_fwzones_defs_services_l{$zone_name_l}) ) {
    	    	    while ( ($hkey1_l,$hval1_l)=each %{$std_fwzones_defs_services_l{$zone_name_l}} ) {
    	    		#$hkey1_l=def service for zone=$zone_name_l
    	    		if ( !exists(${$std_zone_templates_href_l}{$arr_el0_l}{'zone_allowed_services'}{'list'}{$hkey1_l}) ) {
    	    		    push(@zone_services_for_remove_arr_l,$hkey1_l);
    	    		}
    	    	    }
    	    	    
    	    	    if ( $#zone_services_for_remove_arr_l!=-1 ) {
    	    		@zone_services_for_remove_arr_l=sort(@zone_services_for_remove_arr_l);
    	    		foreach $arr_el1_l ( @zone_services_for_remove_arr_l ) { # need to remove-service if it default at zone, but not in 'zone_allowed_services'
    	    		    #$arr_el1_l=service name for remove
    	    		    $wr_str_l="firewall-cmd --permanent --zone=$zone_name_l --remove-service=$arr_el1_l;";
    	    		    push(@{$wr_hash_l{$hkey0_l}{'standard'}},$wr_str_l);
    	    		    
    	    		    $wr_str_l=undef;
    	    		}
    	    		
    	    		$arr_el1_l=undef;
    	    		@zone_services_for_remove_arr_l=();
    	    	    }
    	    	}
    	    	
    	    	foreach $arr_el1_l ( @zone_allowed_services_arr_l ) {
    	    	    #$arr_el1_l=service name for add
    	    	    if ( !exists($std_fwzones_defs_services_l{$zone_name_l}{$arr_el1_l}) ) { # need to add-service if service is not default
    	    		$wr_str_l="firewall-cmd --permanent --zone=$zone_name_l --add-service=$arr_el1_l;";
    	    		push(@{$wr_hash_l{$hkey0_l}{'standard'}},$wr_str_l);
    	    	    	    
    	    		$wr_str_l=undef;
    	    	    }
    	    	}
    	    	
    	    	$arr_el1_l=undef;
    	    	@zone_allowed_services_arr_l=();
    	    }
    	    # services or services_sets (end)
    	    
    	    # ports or ports_sets (SETS) (begin)
    	    if ( exists(${$std_zone_templates_href_l}{$arr_el0_l}{'zone_allowed_ports'}{'seq'}) or exists(${$hval0_l}{$arr_el0_l}{'allowed_ports_set'}) ) {
    		# Allow port = "firewall-cmd --permanent --zone=some_std_zone_name --add-port=1234/tcp"
    		
    		if ( !exists(${$hval0_l}{$arr_el0_l}{'allowed_ports_set'}) ) {
    		    @zone_allowed_ports_arr_l=sort(@{${$std_zone_templates_href_l}{$arr_el0_l}{'zone_allowed_ports'}{'seq'}});
    			#$arr_el0_l=fw-zone-tmplt-name
    		    if ( $zone_allowed_ports_arr_l[0]=~/^set\:/ ) { @zone_allowed_ports_arr_l=(); } # clear arr if set is empty
    		}
    		else { @zone_allowed_ports_arr_l=sort(@{${$hval0_l}{$arr_el0_l}{'allowed_ports_set'}}); }
    		
    		foreach $arr_el1_l ( @zone_allowed_ports_arr_l ) {
    		    #$arr_el1_l=port for allow
    		    $wr_str_l="firewall-cmd --permanent --zone=$zone_name_l --add-port=$arr_el1_l;";
    		    push(@{$wr_hash_l{$hkey0_l}{'standard'}},$wr_str_l);
    		        
    		    $wr_str_l=undef;
    		}
    		
    		$arr_el1_l=undef;
    		@zone_allowed_ports_arr_l=();
    	    }
    	    # ports or ports_sets (end)
    	    
    	    # protocols or protocols_sets (SETS) (begin)
    	    if ( exists(${$std_zone_templates_href_l}{$arr_el0_l}{'zone_allowed_protocols'}{'seq'}) or exists(${$hval0_l}{$arr_el0_l}{'allowed_protocols_set'}) ) {
    		# Allow protocol="firewall-cmd --permanent --zone=some_std_zone_name --add-protocol=gre"
    		
    		if ( !exists(${$hval0_l}{$arr_el0_l}{'allowed_protocols_set'}) ) {
    		    @zone_allowed_protocols_arr_l=sort(@{${$std_zone_templates_href_l}{$arr_el0_l}{'zone_allowed_protocols'}{'seq'}});
    			#$arr_el0_l=fw-zone-tmplt-name
    		    if ( $zone_allowed_protocols_arr_l[0]=~/^set\:/ ) { @zone_allowed_protocols_arr_l=(); } # clear arr if set is empty
    		}
    		else { @zone_allowed_protocols_arr_l=sort(@{${$hval0_l}{$arr_el0_l}{'allowed_protocols_set'}}); }
    		
    		foreach $arr_el1_l ( @zone_allowed_protocols_arr_l ) {
    		    #$arr_el1_l=proto for allow
    		    $wr_str_l="firewall-cmd --permanent --zone=$zone_name_l --add-protocol=$arr_el1_l;";
    		    push(@{$wr_hash_l{$hkey0_l}{'standard'}},$wr_str_l);
    		        
    		    $wr_str_l=undef;
    		}
    		
    		$arr_el1_l=undef;
    		@zone_allowed_protocols_arr_l=();
    	    }
    	    # protocols or protocols_sets (end)
    	    
    	    # forward (begin)
    	    $zone_forward_l=${$std_zone_templates_href_l}{$arr_el0_l}{'zone_forward'};
    	    # Allow intra zone forwarding = "firewall-cmd --permanent --zone=some_std_zone_name --add-forward"
    	    if ( $zone_forward_l eq 'yes' ) {
    	    	$wr_str_l="firewall-cmd --permanent --zone=$zone_name_l --add-forward;";
    	    	push(@{$wr_hash_l{$hkey0_l}{'standard'}},$wr_str_l);
    	    	                
    	    	$wr_str_l=undef;
    	    }
    	    # forward (end)
    	    
    	    # masquerade (begin)
    	    $zone_masquerade_general_l=${$std_zone_templates_href_l}{$arr_el0_l}{'zone_masquerade_general'};
    	    	#$arr_el0_l=fw-zone-tmplt-name
    	    # Allow masquerade general = "firewall-cmd --permanent --zone=some_std_zone_name --add-masquerade"
    	    if ( $zone_masquerade_general_l eq 'yes' ) {
    	    	$wr_str_l="firewall-cmd --permanent --zone=$zone_name_l --add-masquerade;";
    	    	push(@{$wr_hash_l{$hkey0_l}{'standard'}},$wr_str_l);
    	    	                
    	    	$wr_str_l=undef;
    	    }
    	    # masquerade (end)
    	    
    	    # source ports or source_ports_sets (SETS) (begin)
    	    if ( exists(${$std_zone_templates_href_l}{$arr_el0_l}{'zone_allowed_source_ports'}{'seq'}) or exists(${$hval0_l}{$arr_el0_l}{'allowed_source_ports_set'}) ) {
    	    	# Allow source port="firewall-cmd --permanent --zone=some_std_zone_name --add-source-port=8080/tcp"
    		
    		if ( !exists(${$hval0_l}{$arr_el0_l}{'allowed_source_ports_set'}) ) {
    	    	    @zone_allowed_source_ports_arr_l=sort(@{${$std_zone_templates_href_l}{$arr_el0_l}{'zone_allowed_source_ports'}{'seq'}});
    	    		#$arr_el0_l=fw-zone-tmplt-name
    		    if ( $zone_allowed_source_ports_arr_l[0]=~/^set\:/ ) { @zone_allowed_source_ports_arr_l=(); } # clear arr if set is empty
    		}
    		else { @zone_allowed_source_ports_arr_l=sort(@{${$hval0_l}{$arr_el0_l}{'allowed_source_ports_set'}}); }
    		
    	    	foreach $arr_el1_l ( @zone_allowed_source_ports_arr_l ) {
                    #$arr_el1_l=source-port for allow
                    $wr_str_l="firewall-cmd --permanent --zone=$zone_name_l --add-source-port=$arr_el1_l;";
                    push(@{$wr_hash_l{$hkey0_l}{'standard'}},$wr_str_l);
    	    
                    $wr_str_l=undef;
                }
    	    
                $arr_el1_l=undef;
                @zone_allowed_source_ports_arr_l=();
    	    }
    	    # source ports or source_ports_sets (end)
    	    
    	    # icmp block inversion or inversion from icmp_blocks_sets (SETS) (begin)
    	    if ( !exists(${$hval0_l}{$arr_el0_l}{'icmp_blocks_inversion'}) ) {
    		$zone_icmp_block_inversion_l=${$std_zone_templates_href_l}{$arr_el0_l}{'zone_icmp_block_inversion'};
    	    	    #$arr_el0_l=fw-zone-tmplt-name
    	    }
    	    else { $zone_icmp_block_inversion_l=${$hval0_l}{$arr_el0_l}{'icmp_blocks_inversion'}; }
    	    
    	    # Set icmp-block-inversion = "firewall-cmd --permanent --zone=some_std_zone_name --add-icmp-block-inversion"
    	    if ( $zone_icmp_block_inversion_l eq 'yes' ) {
    	    	$wr_str_l="firewall-cmd --permanent --zone=$zone_name_l --add-icmp-block-inversion;";
    	    	push(@{$wr_hash_l{$hkey0_l}{'standard'}},$wr_str_l);
    	    	                
    	    	$wr_str_l=undef;
    	    }
    	    # icmp block inversion or inversion from icmp_blocks_sets (end)
    	    
    	    # icmp block or icmp_blocks_sets (SETS) (begin)
    	    if ( exists(${$std_zone_templates_href_l}{$arr_el0_l}{'zone_icmp_block'}{'seq'}) or exists(${$hval0_l}{$arr_el0_l}{'icmp_blocks_set'}) ) {
    	    	# Add icmptype to icmp-block section = "firewall-cmd --permanent --zone=some_std_zone_name --add-icmp-block=some_icmp_type"
    		
    		if ( !exists(${$hval0_l}{$arr_el0_l}{'icmp_blocks_set'}) ) {
    	    	    @zone_icmp_block_arr_l=sort(@{${$std_zone_templates_href_l}{$arr_el0_l}{'zone_icmp_block'}{'seq'}});
    	    		#$arr_el0_l=fw-zone-tmplt-name
    		    if ( $zone_icmp_block_arr_l[0]=~/^set\:/ ) { @zone_icmp_block_arr_l=(); } # clear arr if set is empty
    		}
    		else { @zone_icmp_block_arr_l=sort(@{${$hval0_l}{$arr_el0_l}{'icmp_blocks_set'}}); }
    		
                foreach $arr_el1_l ( @zone_icmp_block_arr_l ) {
                    #$arr_el1_l=icmp-block
                    $wr_str_l="firewall-cmd --permanent --zone=$zone_name_l --add-icmp-block=$arr_el1_l;";
                    push(@{$wr_hash_l{$hkey0_l}{'standard'}},$wr_str_l);
            
                    $wr_str_l=undef;
                }
            
                $arr_el1_l=undef;
                @zone_icmp_block_arr_l=();
    	    }
    	    # icmp block or icmp_blocks_sets (end)
    	    
    	    # interface_list (begin)
    	    if ( exists(${$hval0_l}{$arr_el0_l}{'interface_list'}{'seq'}) ) {
    	    	# Change interface affiliation to zone = "firewall-cmd --permanent --zone=some_zone_name --change-interface=some_interface_name"
    	    	@interface_list_arr_l=sort(@{${$hval0_l}{$arr_el0_l}{'interface_list'}{'seq'}});
    	    	foreach $arr_el1_l ( @interface_list_arr_l ) {
                    #$arr_el1_l=interface
                    $wr_str_l="firewall-cmd --permanent --zone=$zone_name_l --change-interface=$arr_el1_l;";
                    push(@{$wr_hash_l{$hkey0_l}{'standard'}},$wr_str_l);
            
                    $wr_str_l=undef;
                }
            
                $arr_el1_l=undef;
                @interface_list_arr_l=();
    	    }
    	    # interface_list (end)
    	    
    	    # source_list (begin)
    	    if ( exists(${$hval0_l}{$arr_el0_l}{'source_list'}{'seq'}) ) {
    	    	# Change source affiliation to zone = "firewall-cmd --permanent --zone=some_zone_name --change-source=some_source"
    	    	@source_list_arr_l=sort(@{${$hval0_l}{$arr_el0_l}{'source_list'}{'seq'}});
    	    	    #$arr_el0_l=fw-zone-tmplt-name
    	    	foreach $arr_el1_l ( @source_list_arr_l ) {
                    #$arr_el1_l=source
                    $wr_str_l="firewall-cmd --permanent --zone=$zone_name_l --change-source=$arr_el1_l;";
                    push(@{$wr_hash_l{$hkey0_l}{'standard'}},$wr_str_l);
            
                    $wr_str_l=undef;
                }
            
                $arr_el1_l=undef;
                @source_list_arr_l=();
    	    }
    	    # source_list (end)
    	    
    	    # ipset_tmplt_list (begin)
    	    if ( exists(${$hval0_l}{$arr_el0_l}{'ipset_tmplt_list'}{'seq'}) ) {
    	    	# Change source affiliation to zone = "firewall-cmd --permanent --zone=some_zone_name --change-source=ipset:some_ipset"
    	    	@ipset_tmplt_list_arr_l=sort(@{${$hval0_l}{$arr_el0_l}{'ipset_tmplt_list'}{'seq'}});
    	    	    #$arr_el0_l=fw-zone-tmplt-name
    	    	foreach $arr_el1_l ( @ipset_tmplt_list_arr_l ) {
                    #$arr_el1_l=ipset-tmplt-name
    	    		#$ipset_templates_href_l=hash-ref for %h01_conf_ipset_templates_hash_g
    	    		#$h01_conf_ipset_templates_hash_g{'temporary/permanent'}{ipset_template_name--TMPLT}->
    	    		    #{'ipset_name'}=value
    	    	    if ( exists(${$ipset_templates_href_l}{'temporary'}{$arr_el1_l}) ) {
    	    		$ipset_name_l=${$ipset_templates_href_l}{'temporary'}{$arr_el1_l}{'ipset_name'};
    	    	    }
    	    	    elsif ( exists(${$ipset_templates_href_l}{'permanent'}{$arr_el1_l}) ) {
    	    		$ipset_name_l=${$ipset_templates_href_l}{'permanent'}{$arr_el1_l}{'ipset_name'};
    	    	    }
    	    	    $wr_str_l="firewall-cmd --permanent --zone=$zone_name_l --change-source=ipset:$ipset_name_l;";
                    push(@{$wr_hash_l{$hkey0_l}{'standard'}},$wr_str_l);
            
                    $wr_str_l=undef;
                }
            
                $arr_el1_l=undef;
                @ipset_tmplt_list_arr_l=();
    	    }
    	    # ipset_tmplt_list (end)
    	    
    	    # forward_ports_set (begin)
    	    	#$fw_ports_set_href_l
    	        #$h04_conf_forward_ports_sets_hash_g{inv-host}{set_name}->
    	    	    #{'rule-0'}=1
    	    	    #{'rule-1'}=1
    	    	    #etc
    	    	    #{'seq'}=[val-0,val-1] (val=rule)
    	    # Add forward-port = "firewall-cmd --permanent --zone=some_zone_name --add-forward-port='some-fw-port-string'" (for information only).
    	    $forward_ports_set_l=${$hval0_l}{$arr_el0_l}{'forward_ports_set'};
    	    	#$arr_el0_l=fw-zone-tmplt-name
    	    if ( $forward_ports_set_l ne 'empty' ) {
    	    	@forward_ports_arr_l=sort(@{${$fw_ports_set_href_l}{$hkey0_l}{$forward_ports_set_l}{'seq'}});
    	    	foreach $arr_el1_l ( @forward_ports_arr_l ) {
                    #$arr_el1_l=forward-port rule
                    $wr_str_l="firewall-cmd --permanent --zone=$zone_name_l --add-forward-port='$arr_el1_l';";
                    push(@{$wr_hash_l{$hkey0_l}{'standard'}},$wr_str_l);
            
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
    	    # Add rich-rule = "firewall-cmd --permanent --zone=some_zone_name --add-rich-rule='some-rich-rule-string'" (for information only).
    	    $rich_rules_set_l=${$hval0_l}{$arr_el0_l}{'rich_rules_set'};
    	    	#$arr_el0_l=fw-zone-tmplt-name
    	    if ( $rich_rules_set_l ne 'empty' ) {
    	    	@rich_rules_arr_l=sort(@{${$rich_rules_set_href_l}{$hkey0_l}{$rich_rules_set_l}{'seq'}});
    	    	foreach $arr_el1_l ( @rich_rules_arr_l ) {
                    #$arr_el1_l=rich-rule
                    $wr_str_l="firewall-cmd --permanent --zone=$zone_name_l --add-rich-rule='$arr_el1_l';";
                    push(@{$wr_hash_l{$hkey0_l}{'standard'}},$wr_str_l);
            
                    $wr_str_l=undef;
                }
            
                $arr_el1_l=undef;
                @rich_rules_arr_l=();
    	    }
    	    # rich_rules_set (end)
    	    
    	    push(@{$wr_hash_l{$hkey0_l}{'standard'}},' ');
    	}
    	
    	$arr_el0_l=undef;
    	$zone_name_l=undef;
    	@tmp_arr_l=();
    	# commands for configure and correcting std fw-zones (end)
    }
    
    ($hkey0_l,$hval0_l)=(undef,undef);
    
    if ( $return_str_l!~/^OK$/ ) { return $return_str_l; }
    ### fill array (for each host) with commands for recreate standard fw-zones (end)
    
    # fill array (for each host) with commands for recreate custom fw-zones (begin)
    while ( ($hkey0_l,$hval0_l)=each %{${$h77_conf_zones_FIN_href_l}{'custom'}} ) {
    	#$hkey0_l=inv-host
    	
    	#%wr_hash_l=();
    	    #key0=inv-host, key1=wr_type (standard, custom, etc), value=array of strings
    	
    	# commands for remove custom fw-zones (begin)
    	# $wr_str_l="rm -rf /etc/firewalld/zones/*--custom.xml;";
    	$wr_str_l='#REMOVE_CUSTOM_ZONES'; # NEW 20231102
        push(@{$wr_hash_l{$hkey0_l}{'custom_remove'}},$wr_str_l);
        
        $wr_str_l=undef;
    	
    	$unconf_custom_fw_zones_act_l=${$conf_firewalld_href_l}{$hkey0_l}{'unconfigured_custom_firewall_zones_action'};
    	if ( $unconf_custom_fw_zones_act_l eq 'remove' ) {
    	    # If "remove" -> all custom firewall zones not configured at conf files
        	# "02_conf_custom_firewall_zones_templates" and "77_conf_zones_FIN" will be deleted.
    	    ###
    	    # 'block','dmz','drop','external','internal','public','trusted','work','home'
    	    # $wr_str_l='find /etc/firewalld/zones -type f | grep -v "\/block.xml$\|\/dmz.xml$\|\/drop.xml$\|\/external.xml$\|\/internal.xml$\|\/public.xml$\|\/trusted.xml$\|\/work.xml$\|\/home.xml$\|--custom.xml$" | xargs rm -f;';
    	    $wr_str_l='#REMOVE_UNCONFIGURED_CUSTOM_ZONES'; # NEW 20231102
    	    push(@{$wr_hash_l{$hkey0_l}{'custom_remove'}},$wr_str_l);
    	    
    	    $wr_str_l=undef;
    	}
    	# commands for remove custom fw-zones (end)
    	
    	# commands for configure custom fw-zones (begin)
    	@tmp_arr_l=sort(keys %{$hval0_l});
    	foreach $arr_el0_l ( @tmp_arr_l ) {
    	    #$arr_el0_l=fw-zone-tmplt-name
    	    $zone_name_l=${$custom_zone_templates_href_l}{$arr_el0_l}{'zone_name'};
    	    # Create custom zone = "firewall-cmd --permanent --new-zone=some_zone_name"
    	    $wr_str_l="firewall-cmd --permanent --new-zone='$zone_name_l';";
    	    push(@{$wr_hash_l{$hkey0_l}{'custom'}},$wr_str_l);
    	    
    	    $wr_str_l=undef;
    	    ###
    	    
    	    # description (begin)
    	    $zone_description_l=${$custom_zone_templates_href_l}{$arr_el0_l}{'zone_description'};
    		#$arr_el0_l=fw-zone-tmplt-name
    	    if ( $zone_description_l ne 'empty' ) {
    		# Set zone description = "firewall-cmd --permanent --zone=some_zone_name --set-description='some_description'"	
    		$wr_str_l="firewall-cmd --permanent --zone='$zone_name_l' --set-description='$zone_description_l';";
    		push(@{$wr_hash_l{$hkey0_l}{'custom'}},$wr_str_l);
    	    
    		$wr_str_l=undef;
    	    }
    	    
    	    $zone_description_l=undef;
    	    # description (end)
    	    
    	    # short description (begin)
    	    $zone_short_description_l=${$custom_zone_templates_href_l}{$arr_el0_l}{'zone_short_description'};
    		#$arr_el0_l=fw-zone-tmplt-name
    	    if ( $zone_short_description_l ne 'empty' ) {
    		# Set zone short description = "firewall-cmd --permanent --zone=some_zone_name --set-short='some_short_description'"
    		$wr_str_l="firewall-cmd --permanent --zone='$zone_name_l' --set-short='$zone_short_description_l';";
    		push(@{$wr_hash_l{$hkey0_l}{'custom'}},$wr_str_l);
    	    
    		$wr_str_l=undef;
    	    }
    	    
    	    $zone_short_description_l=undef;
    	    # short description (end)
    	    
    	    # target (begin)
    	    $zone_target_l=${$custom_zone_templates_href_l}{$arr_el0_l}{'zone_target'};
    		#$arr_el0_l=fw-zone-tmplt-name
    	    # Set zone target = "firewall-cmd --permanent --zone=some_custom_zone_name --set-target=some_target"
    	    $wr_str_l="firewall-cmd --permanent --zone='$zone_name_l' --set-target=$zone_target_l;";
    	    push(@{$wr_hash_l{$hkey0_l}{'custom'}},$wr_str_l);
    	    
    	    $wr_str_l=undef;
    	    $zone_target_l=undef;
    	    # target (end)
    	    
    	    # services or services_sets (SETS) (begin)
    	    if ( exists(${$custom_zone_templates_href_l}{$arr_el0_l}{'zone_allowed_services'}{'seq'}) or exists(${$hval0_l}{$arr_el0_l}{'allowed_services_set'}) ) {
    		# Allow service = "firewall-cmd --permanent --zone=some_custom_zone_name --add-service=http"
		
		if ( !exists(${$hval0_l}{$arr_el0_l}{'allowed_services_set'}) ) {
    		    @zone_allowed_services_arr_l=sort(@{${$custom_zone_templates_href_l}{$arr_el0_l}{'zone_allowed_services'}{'seq'}});
    			#$arr_el0_l=fw-zone-tmplt-name
    		    if ( $zone_allowed_services_arr_l[0]=~/^set\:/ ) { @zone_allowed_services_arr_l=(); } # clear arr if set is empty
    		}
    		else { @zone_allowed_services_arr_l=sort(@{${$hval0_l}{$arr_el0_l}{'allowed_services_set'}}); }
    		
    		foreach $arr_el1_l ( @zone_allowed_services_arr_l ) {
    		    #$arr_el1_l=service name for add
    		    $wr_str_l="firewall-cmd --permanent --zone='$zone_name_l' --add-service=$arr_el1_l;";
    		    push(@{$wr_hash_l{$hkey0_l}{'custom'}},$wr_str_l);
    		    	    
    		    $wr_str_l=undef;
    		}
    		
    		$arr_el1_l=undef;
    		@zone_allowed_services_arr_l=();
    	    }
    	    # services or services_sets (end)
    	    
    	    # ports or ports_sets (SETS) (begin)
    	    if ( exists(${$custom_zone_templates_href_l}{$arr_el0_l}{'zone_allowed_ports'}{'seq'}) or exists(${$hval0_l}{$arr_el0_l}{'allowed_ports_set'}) ) {
    		# Allow port = "firewall-cmd --permanent --zone=some_custom_zone_name --add-port=1234/tcp"
    		
    		if ( !exists(${$hval0_l}{$arr_el0_l}{'allowed_ports_set'}) ) {
    		    @zone_allowed_ports_arr_l=sort(@{${$custom_zone_templates_href_l}{$arr_el0_l}{'zone_allowed_ports'}{'seq'}});
    			#$arr_el0_l=fw-zone-tmplt-name
    		    if ( $zone_allowed_ports_arr_l[0]=~/^set\:/ ) { @zone_allowed_ports_arr_l=(); } # clear arr if set is empty
    		}
    		else { @zone_allowed_ports_arr_l=sort(@{${$hval0_l}{$arr_el0_l}{'allowed_ports_set'}}); }
    		
    		foreach $arr_el1_l ( @zone_allowed_ports_arr_l ) {
    		    #$arr_el1_l=port for allow
    		    $wr_str_l="firewall-cmd --permanent --zone='$zone_name_l' --add-port=$arr_el1_l;";
    		    push(@{$wr_hash_l{$hkey0_l}{'custom'}},$wr_str_l);
    		        
    		    $wr_str_l=undef;
    		}
    		
    		$arr_el1_l=undef;
    		@zone_allowed_ports_arr_l=();
    	    }
    	    # ports or ports_sets (end)
    	    
    	    # protocols or protocols_sets (SETS) (begin)
    	    if ( exists(${$custom_zone_templates_href_l}{$arr_el0_l}{'zone_allowed_protocols'}{'seq'}) or exists(${$hval0_l}{$arr_el0_l}{'allowed_protocols_set'}) ) {
    		# Allow protocol="firewall-cmd --permanent --zone=some_custom_zone_name --add-protocol=gre"
    		
    		if ( !exists(${$hval0_l}{$arr_el0_l}{'allowed_protocols_set'}) ) {
    		    @zone_allowed_protocols_arr_l=sort(@{${$custom_zone_templates_href_l}{$arr_el0_l}{'zone_allowed_protocols'}{'seq'}});
    			#$arr_el0_l=fw-zone-tmplt-name
    		    if ( $zone_allowed_protocols_arr_l[0]=~/^set\:/ ) { @zone_allowed_protocols_arr_l=(); } # clear arr if set is empty
    		}
    		else { @zone_allowed_protocols_arr_l=sort(@{${$hval0_l}{$arr_el0_l}{'allowed_protocols_set'}}); }
    		
    		foreach $arr_el1_l ( @zone_allowed_protocols_arr_l ) {
    		    #$arr_el1_l=proto for allow
    		    $wr_str_l="firewall-cmd --permanent --zone='$zone_name_l' --add-protocol=$arr_el1_l;";
    		    push(@{$wr_hash_l{$hkey0_l}{'custom'}},$wr_str_l);
    		        
    		    $wr_str_l=undef;
    		}
    		
    		$arr_el1_l=undef;
    		@zone_allowed_protocols_arr_l=();
    	    }
    	    # protocols or protocols_sets (end)
    	    
    	    # forward (begin)
    	    $zone_forward_l=${$custom_zone_templates_href_l}{$arr_el0_l}{'zone_forward'};
    		#$arr_el0_l=fw-zone-tmplt-name
    	    # Allow intra zone forwarding = "firewall-cmd --permanent --zone=some_cunstom_zone_name --add-forward"
    	    if ( $zone_forward_l eq 'yes' ) {
    		$wr_str_l="firewall-cmd --permanent --zone='$zone_name_l' --add-forward;";
        	push(@{$wr_hash_l{$hkey0_l}{'custom'}},$wr_str_l);
        	                
        	$wr_str_l=undef;
    	    }
    	    # forward (end)
    	
    	    # masquerade (begin)
    	    $zone_masquerade_general_l=${$custom_zone_templates_href_l}{$arr_el0_l}{'zone_masquerade_general'};
    		#$arr_el0_l=fw-zone-tmplt-name
    	    # Allow masquerade general = "firewall-cmd --permanent --zone=some_custom_zone_name --add-masquerade"
    	    if ( $zone_masquerade_general_l eq 'yes' ) {
    		$wr_str_l="firewall-cmd --permanent --zone='$zone_name_l' --add-masquerade;";
        	push(@{$wr_hash_l{$hkey0_l}{'custom'}},$wr_str_l);
        	                
        	$wr_str_l=undef;
    	    }
    	    # masquerade (end)
    	    
    	    # source ports or source_ports_sets (SETS) (begin)
    	    if ( exists(${$custom_zone_templates_href_l}{$arr_el0_l}{'zone_allowed_source_ports'}{'seq'}) or exists(${$hval0_l}{$arr_el0_l}{'allowed_source_ports_set'}) ) {
    	    	# Allow source port="firewall-cmd --permanent --zone=some_custom_zone_name --add-source-port=8080/tcp"
    		
    		if ( !exists(${$hval0_l}{$arr_el0_l}{'allowed_source_ports_set'}) ) {
    	    	    @zone_allowed_source_ports_arr_l=sort(@{${$custom_zone_templates_href_l}{$arr_el0_l}{'zone_allowed_source_ports'}{'seq'}});
    			#$arr_el0_l=fw-zone-tmplt-name
    		    if ( $zone_allowed_source_ports_arr_l[0]=~/^set\:/ ) { @zone_allowed_source_ports_arr_l=(); } # clear arr if set is empty
    		}
    		else { @zone_allowed_source_ports_arr_l=sort(@{${$hval0_l}{$arr_el0_l}{'allowed_source_ports_set'}}); }
    		
    	    	foreach $arr_el1_l ( @zone_allowed_source_ports_arr_l ) {
                    #$arr_el1_l=source-port for allow
                    $wr_str_l="firewall-cmd --permanent --zone='$zone_name_l' --add-source-port=$arr_el1_l;";
                    push(@{$wr_hash_l{$hkey0_l}{'custom'}},$wr_str_l);
    		
                    $wr_str_l=undef;
                }
    		
                $arr_el1_l=undef;
                @zone_allowed_source_ports_arr_l=();
    	    }
    	    # source ports or source_ports_sets (end)
    	
    	    # icmp block inversion or inversion from icmp_blocks_sets (SETS) (begin)
    	    if ( !exists(${$hval0_l}{$arr_el0_l}{'icmp_blocks_inversion'}) ) {
    		$zone_icmp_block_inversion_l=${$custom_zone_templates_href_l}{$arr_el0_l}{'zone_icmp_block_inversion'};
    		    #$arr_el0_l=fw-zone-tmplt-name
    	    }
    	    else { $zone_icmp_block_inversion_l=${$hval0_l}{$arr_el0_l}{'icmp_blocks_inversion'}; }
    	    
    	    # Set icmp-block-inversion = "firewall-cmd --permanent --zone=some_custom_zone_name --add-icmp-block-inversion"
    	    if ( $zone_icmp_block_inversion_l eq 'yes' ) {
    	    	$wr_str_l="firewall-cmd --permanent --zone='$zone_name_l' --add-icmp-block-inversion;";
    	    	push(@{$wr_hash_l{$hkey0_l}{'custom'}},$wr_str_l);
    	    	                
    	    	$wr_str_l=undef;
    	    }
    	    # icmp block inversion or inversion from icmp_blocks_sets (end)
    	    
    	    # icmp block or icmp_blocks_sets (SETS) (begin)
    	    if ( exists(${$custom_zone_templates_href_l}{$arr_el0_l}{'zone_icmp_block'}{'seq'}) or exists(${$hval0_l}{$arr_el0_l}{'icmp_blocks_set'}) ) {
    	    	# Add icmptype to icmp-block section = "firewall-cmd --permanent --zone=some_custom_zone_name --add-icmp-block=some_icmp_type"
    		
    		if ( !exists(${$hval0_l}{$arr_el0_l}{'icmp_blocks_set'}) ) {
    	    	    @zone_icmp_block_arr_l=sort(@{${$custom_zone_templates_href_l}{$arr_el0_l}{'zone_icmp_block'}{'seq'}});
    			#$arr_el0_l=fw-zone-tmplt-name
    		    if ( $zone_icmp_block_arr_l[0]=~/^set\:/ ) { @zone_icmp_block_arr_l=(); } # clear arr if set is empty
    		}
    		else { @zone_icmp_block_arr_l=sort(@{${$hval0_l}{$arr_el0_l}{'icmp_blocks_set'}}); }
    		
    	    	foreach $arr_el1_l ( @zone_icmp_block_arr_l ) {
                    #$arr_el1_l=icmp-block
                    $wr_str_l="firewall-cmd --permanent --zone='$zone_name_l' --add-icmp-block=$arr_el1_l;";
                    push(@{$wr_hash_l{$hkey0_l}{'custom'}},$wr_str_l);
        	
                    $wr_str_l=undef;
                }
        	
                $arr_el1_l=undef;
                @zone_icmp_block_arr_l=();
    	    }
    	    # icmp block or icmp_blocks_sets (end)
    	
    	    # interface_list (begin)
    	    if ( exists(${$hval0_l}{$arr_el0_l}{'interface_list'}{'seq'}) ) {
    		# Change interface affiliation to zone = "firewall-cmd --permanent --zone=some_zone_name --change-interface=some_interface_name"
    		@interface_list_arr_l=sort(@{${$hval0_l}{$arr_el0_l}{'interface_list'}{'seq'}});
    		    #$arr_el0_l=fw-zone-tmplt-name
    		foreach $arr_el1_l ( @interface_list_arr_l ) {
                    #$arr_el1_l=interface
                    $wr_str_l="firewall-cmd --permanent --zone='$zone_name_l' --change-interface=$arr_el1_l;";
                    push(@{$wr_hash_l{$hkey0_l}{'custom'}},$wr_str_l);
            
                    $wr_str_l=undef;
                }
            
                $arr_el1_l=undef;
                @interface_list_arr_l=();
    	    }
    	    # interface_list (end)
    	    
    	    # source_list (begin)
    	    if ( exists(${$hval0_l}{$arr_el0_l}{'source_list'}{'seq'}) ) {
    		# Change source affiliation to zone = "firewall-cmd --permanent --zone=some_zone_name --change-source=some_source"
    		@source_list_arr_l=sort(@{${$hval0_l}{$arr_el0_l}{'source_list'}{'seq'}});
    		    #$arr_el0_l=fw-zone-tmplt-name
    		foreach $arr_el1_l ( @source_list_arr_l ) {
                    #$arr_el1_l=source
                    $wr_str_l="firewall-cmd --permanent --zone='$zone_name_l' --change-source=$arr_el1_l;";
                    push(@{$wr_hash_l{$hkey0_l}{'custom'}},$wr_str_l);
            
                    $wr_str_l=undef;
                }
            
                $arr_el1_l=undef;
                @source_list_arr_l=();
    	    }
    	    # source_list (end)
    	    
    	    # ipset_tmplt_list (begin)
    	    if ( exists(${$hval0_l}{$arr_el0_l}{'ipset_tmplt_list'}{'seq'}) ) {
    	    	# Change source affiliation to zone = "firewall-cmd --permanent --zone=some_zone_name --change-source=ipset:some_ipset"
    	    	@ipset_tmplt_list_arr_l=sort(@{${$hval0_l}{$arr_el0_l}{'ipset_tmplt_list'}{'seq'}});
    	    	    #$arr_el0_l=fw-zone-tmplt-name
    	    	foreach $arr_el1_l ( @ipset_tmplt_list_arr_l ) {
                    #$arr_el1_l=ipset-tmplt-name
    	    		#$ipset_templates_href_l=hash-ref for %h01_conf_ipset_templates_hash_g
    	    		#$h01_conf_ipset_templates_hash_g{'temporary/permanent'}{ipset_template_name--TMPLT}->
    	    		    #{'ipset_name'}=value
    	    	    if ( exists(${$ipset_templates_href_l}{'temporary'}{$arr_el1_l}) ) {
    	    		$ipset_name_l=${$ipset_templates_href_l}{'temporary'}{$arr_el1_l}{'ipset_name'};
    	    	    }
    	    	    elsif ( exists(${$ipset_templates_href_l}{'permanent'}{$arr_el1_l}) ) {
    	    		$ipset_name_l=${$ipset_templates_href_l}{'permanent'}{$arr_el1_l}{'ipset_name'};
    	    	    }
                    $wr_str_l="firewall-cmd --permanent --zone='$zone_name_l' --change-source=ipset:$ipset_name_l;";
                    push(@{$wr_hash_l{$hkey0_l}{'custom'}},$wr_str_l);
            
                    $wr_str_l=undef;
                }
            
                $arr_el1_l=undef;
                @ipset_tmplt_list_arr_l=();
    	    }
    	    # ipset_tmplt_list (end)
    	    
    	    # forward_ports_set (begin)
    	    	#$fw_ports_set_href_l
    	        #$h04_conf_forward_ports_sets_hash_g{inv-host}{set_name}->
    	    	    #{'rule-0'}=1
    	    	    #{'rule-1'}=1
    	    	    #etc
    	    	    #{'seq'}=[val-0,val-1] (val=rule)
    	    # Add forward-port = "firewall-cmd --permanent --zone=some_zone_name --add-forward-port='some-fw-port-string'" (for information only).
    	    $forward_ports_set_l=${$hval0_l}{$arr_el0_l}{'forward_ports_set'};
    	    	#$arr_el0_l=fw-zone-tmplt-name
    	    if ( $forward_ports_set_l ne 'empty' ) {
    	    	@forward_ports_arr_l=sort(@{${$fw_ports_set_href_l}{$hkey0_l}{$forward_ports_set_l}{'seq'}});
    	    	foreach $arr_el1_l ( @forward_ports_arr_l ) {
                    #$arr_el1_l=forward-port rule
                    $wr_str_l="firewall-cmd --permanent --zone='$zone_name_l' --add-forward-port='$arr_el1_l';";
                    push(@{$wr_hash_l{$hkey0_l}{'custom'}},$wr_str_l);
            
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
    	    # Add rich-rule = "firewall-cmd --permanent --zone=some_zone_name --add-rich-rule='some-rich-rule-string'" (for information only).
    	    $rich_rules_set_l=${$hval0_l}{$arr_el0_l}{'rich_rules_set'};
    	    	#$arr_el0_l=fw-zone-tmplt-name
    	    if ( $rich_rules_set_l ne 'empty' ) {
    	    	@rich_rules_arr_l=sort(@{${$rich_rules_set_href_l}{$hkey0_l}{$rich_rules_set_l}{'seq'}});
    	    	foreach $arr_el1_l ( @rich_rules_arr_l ) {
                    #$arr_el1_l=rich-rule
                    $wr_str_l="firewall-cmd --permanent --zone='$zone_name_l' --add-rich-rule='$arr_el1_l';";
                    push(@{$wr_hash_l{$hkey0_l}{'custom'}},$wr_str_l);
            
                    $wr_str_l=undef;
                }
            
                $arr_el1_l=undef;
                @rich_rules_arr_l=();
    	    }
    	    # rich_rules_set (end)
    	    
    	    push(@{$wr_hash_l{$hkey0_l}{'custom'}},' ');    
    	}
    	
    	$arr_el0_l=undef;
    	$zone_name_l=undef;
    	@tmp_arr_l=();
    	### commands for configure custom fw-zones (end)
    }
    
    ($hkey0_l,$hval0_l)=(undef,undef);
    
    if ( $return_str_l!~/^OK$/ ) { return $return_str_l; }
    ### fill array (for each host) with commands for recreate custom fw-zones (end)
    
    #print Dumper(\%wr_hash_l);
    
    # create scripts for each host (begin)
    	#@begin_script_arr_l
    while ( ($hkey0_l,$hval0_l)=each %{$inv_hosts_href_l} ) {
    	#$hkey0_l=inv-host
    	    #subkeys: custom, standard, custom_remove, std_recreate
    	if ( ! -d "$dyn_fwrules_files_dir_l/$hkey0_l" ) { system("mkdir -p $dyn_fwrules_files_dir_l/$hkey0_l"); }
    	$wr_file_l=$dyn_fwrules_files_dir_l.'/'.$hkey0_l.'/recreate_fw_zones.sh';
    	
    	if ( exists($wr_hash_l{$hkey0_l}) ) {    
    	    @wr_arr_l=(@begin_script_arr_l);
    	    if ( exists($wr_hash_l{$hkey0_l}{'std_recreate'}) ) { @wr_arr_l=(@wr_arr_l,@{$wr_hash_l{$hkey0_l}{'std_recreate'}}); }
    	    else {
    		@wr_arr_l=(@wr_arr_l,'#RESTORE_DEFAULT_ZONES'); # NEW 20240110
    	    }
    	    if ( exists($wr_hash_l{$hkey0_l}{'custom_remove'}) ) { @wr_arr_l=(@wr_arr_l,' ',@{$wr_hash_l{$hkey0_l}{'custom_remove'}}); }
    	    if ( exists($wr_hash_l{$hkey0_l}{'standard'}) ) { @wr_arr_l=(@wr_arr_l,' ',@{$wr_hash_l{$hkey0_l}{'standard'}}); }
    	    if ( exists($wr_hash_l{$hkey0_l}{'custom'}) ) { @wr_arr_l=(@wr_arr_l,@{$wr_hash_l{$hkey0_l}{'custom'}}); }
    	}
    	elsif ( !exists($wr_hash_l{$hkey0_l}) && ${$conf_firewalld_href_l}{$hkey0_l}{'if_no_zones_conf_action'}=~/^restore_defaults$/ ) {
	    # Just restore default zones if no zones conf for current inv-host and 'restore_deaults' is active
    	    @wr_arr_l=(@begin_script_arr_l);
    	    # @wr_arr_l=(@wr_arr_l,'rm -rf /etc/firewalld/zones/*;','cp -r /usr/lib/firewalld/zones/* /etc/firewalld/zones;',' ');
    	    @wr_arr_l=(@wr_arr_l,'#RESTORE_DEFAULT_ZONES',' '); # NEW 20231102
    	}
    	else { @wr_arr_l=(@begin_script_arr_l,'#NO NEED TO RECREATE FIREWALL ZONES'); }
    
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
