sub read_config_del_not_configured_ifcfg {
    my ($file_l,$res_href_l)=@_;
    #$file_l=$conf_file_del_not_configured_g
    #$res_href_l=hash ref for %inv_hosts_ifcfg_del_not_configured_g
    my $proc_name_l=(caller(0))[3];
    
    #%inv_hosts_ifcfg_del_not_configured_g=(); #for config '02_config_del_not_configured_ifcfg'. Key=inv_host
    
    my $line_l=undef;
    my $return_str_l='OK';
    
    open(CONF_DEL,'<',$file_l);
    while ( <CONF_DEL> ) {
        $line_l=$_;
        $line_l=~s/\n$|\r$|\n\r$|\r\n$//g;
        while ($line_l=~/\t/) { $line_l=~s/\t/ /g; }
        $line_l=~s/\s+/ /g;
        $line_l=~s/^ //g;
        if ( length($line_l)>0 && $line_l!~/^\#/ && $line_l=~/^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})$/ ) {
            ${$res_href_l}{$1}=1;
        }
    }
    close(CONF_DEL);
    
    $line_l=undef;
    
    return $return_str_l;
}

sub read_05_not_configured_interfaces {
    my ($file_l,$inv_hosts_href_l,$divisions_for_inv_hosts_href_l,$res_href_l)=@_;
    #$file_l=$f05_not_configured_interfaces_path_g
    #inv_hosts_href_l=hash-ref for %inventory_hosts_g
    #$divisions_for_inv_hosts_href_l=hash-ref for %h00_conf_divisions_for_inv_hosts_hash_g
        #$h00_conf_divisions_for_inv_hosts_hash_g{group-name}{inv-host}=1;
    #$res_href_l=hash ref for %h05_not_configured_interfaces_hash_g
        #Key=inv_host, value=do-not-touch/reconfigure
    ###############
    # INVENTORY_HOST = all / list of inventory hosts separated by "," / group name from conf '00_conf_divisions_for_inv_hosts'.
	# If "all" -> the configuration will be applied to all inventory hosts.
	# Priority (from lower to higher): all (0), group name from conf '00_conf_divisions_for_inv_hosts' (1),
	# list of inventory hosts separated by "," or individual hosts (2).
    ###
    # ACTION. Possible values: do-not-touch (for new hosts), reconfigure (for hosts with already configured interfaces).
	# "reconfigure"
    	    # Configured Wi-Fi interfaces (with line 'TYPE=Wireless' at ifcfg-file) will ignored.
    	    # Delete ifcfg-files and shutdown interfaces that not configured at conf files.
    	    # This setting is recommended to be used, for example, if you plan to rename interfaces
        	#(for example, ifcfg-br0 -> ifcfg-br00).
    ###
    #INVENTORY_HOST                         #ACTION
    ###############

}

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )