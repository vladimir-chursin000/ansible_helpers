###NO DEPENDENCIES

sub generate_rollback_fwrules_changes_sh {
    my ($with_rollback_l,$scripts_for_remote_dir_l,$dyn_fwrules_files_dir_l,$inv_hosts_href_l,$conf_firewalld_href_l)=@_;
    #$with_rollback_l=$with_rollback_g
    #$scripts_for_remote_dir_l=$scripts_for_remote_dir_g
    #$dyn_fwrules_files_dir_l=$dyn_fwrules_files_dir_g
    #$inv_hosts_href_l=hash-ref for %inventory_hosts_g
	#Key=inventory_host, value=1
    
    #$h00_conf_firewalld_hash_g{inventory_host}->
    #{'unconfigured_custom_firewall_zones_action'}=no_action|remove
    #{'temporary_apply_fwrules_timeout'}=NUM
    #{'if_no_ipsets_conf_action'}=remove|no_action
    #{'if_no_zones_conf_action'}=restore_deaults|no_action
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
	
    my $proc_name_l=(caller(0))[3];

    my ($hkey0_l,$hval0_l)=(undef,undef);
    my $rollback_timeout_l=undef;
    my ($rollback_fwrules_changes_tmplt_file_l,$rollback_fwrules_changes_file_l)=(undef,undef);
    my $return_str_l='OK';
    
    ###
    if ( $with_rollback_l==1 ) {
    	while ( ($hkey0_l,$hval0_l)=each %{$inv_hosts_href_l} ) {
    	    #hkey0_l=inv-host
	    $rollback_timeout_l=${$conf_firewalld_href_l}{$hkey0_l}{'temporary_apply_fwrules_timeout'};
	    $rollback_fwrules_changes_tmplt_file_l=$scripts_for_remote_dir_l.'/rollback_fwrules_changes_tmplt.sh';
	    $rollback_fwrules_changes_file_l=$dyn_fwrules_files_dir_l.'/'.$hkey0_l.'_rollback_fwrules_changes.sh';
	    system("\\cp $rollback_fwrules_changes_tmplt_file_l $rollback_fwrules_changes_file_l");
	    system("sed -i 's/!_TIMEOUT_NUM_!/$rollback_timeout_l/g' $rollback_fwrules_changes_file_l");
	    
	    ($rollback_fwrules_changes_tmplt_file_l,$rollback_fwrules_changes_file_l)=(undef,undef);
    	}
	
	if ( $return_str_l=~/^fail/ ) { return $return_str_l; }
    
	($hkey0_l,$hval0_l)=(undef,undef);
    }
    ###
    
    return $return_str_l;
}

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
