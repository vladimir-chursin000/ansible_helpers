sub hwaddr_check {
    my ($inv_host_l,$interface_name_l,$hwaddr_l,$inv_hosts_network_data_href_l)=@_;
    #inv_hosts_network_data_href_l=hash ref for %inv_hosts_network_data_g
        #v1) key0='hwaddr_all', key1=hwaddr, value=inv_host
        #v2) key0='inv_host', key1=inv_host, key2=interface_name, key3=hwaddr
    my $proc_name_l=(caller(0))[3];
    
    my $return_str_l='OK';

    if ( $hwaddr_l!~/^\S{2}\:\S{2}\:\S{2}\:\S{2}\:\S{2}\:\S{2}$/ ) {
        $return_str_l="fail [$proc_name_l]. Incorrect value='$hwaddr_l' (inv-host='$inv_host_l', interface='$interface_name_l'). HWADDR must be like 'XX:XX:XX:XX:XX:XX'. Please, check and correct config-file ('01a_conf_int_hwaddr_inf')";
        return $return_str_l;
    }
    
    if ( exists(${$inv_hosts_network_data_href_l}{'hwaddr_all'}{$hwaddr_l}) && $inv_host_l ne ${$inv_hosts_network_data_href_l}{'hwaddr_all'}{$hwaddr_l} ) {
        $return_str_l="fail [$proc_name_l]. NETWORK DATA check. HWADDR='$hwaddr_l' configured for inv_host='$inv_host_l' is already used by host='${$inv_hosts_network_data_href_l}{'hwaddr_all'}{$hwaddr_l}'. Please, check and correct config-file ('01a_conf_int_hwaddr_inf') or solve problem with duplicated mac-address";
    	return $return_str_l;
    }
                    
    if ( !exists(${$inv_hosts_network_data_href_l}{'inv_host'}{$inv_host_l}{$interface_name_l}{$hwaddr_l}) ) {
    	$return_str_l="fail [$proc_name_l]. NETWORK DATA check. At inv_host='$inv_host_l' interface='interface_name_l' not linked with hwaddr='$hwaddr_l. Please, check and correct config-file ('01a_conf_int_hwaddr_inf')";
    	return $return_str_l;
    }
    
    return $return_str_l;
}

sub inv_host_check {
    my ($inv_host_l,$inv_hosts_href_l,$conf_file_l)=@_;
    #inv_hosts_href_l=hash-ref for %inventory_hosts_g
    my $proc_name_l=(caller(0))[3];
    
    my $return_str_l='OK';
    
    if ( !exists(${$inv_hosts_href_l}{$inv_host_l}) ) {
	return "fail [$proc_name_l]. Inv-host='$inv_host_l' (conf-file='$conf_file_l') is not exists at inventory";
    }
    
    return $return_str_l;
}

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
