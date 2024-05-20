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

sub conf_type_check {
    my ($conf_type_l,$conf_file_l)=@_;
    my $proc_name_l=(caller(0))[3];
    
    my $return_str_l='OK';
    
    if ( $conf_type_l!~/^just_interface$|^virt_bridge$|^just_bridge$|^just_bond$|^bond\-bridge$|^interface\-vlan$|^bridge\-vlan$|^bond\-vlan$|^bond\-bridge\-vlan$/ ) {
        return "fail [$proc_name_l]. Wrong conf_type='$conf_type_l'. Conf_type must be 'just_interface/virt_bridge/just_bridge/just_bond/bond-bridge/interface-vlan/bridge-vlan/bond-vlan/bond-bridge-vlan'. Please, check and correct config-file ('$conf_file_l')";
    }

    return $return_str_l;
}

sub conf_id_check {
    my ($conf_id_l,$conf_file_l)=@_;
    my $proc_name_l=(caller(0))[3];
    
    my $return_str_l='OK';
    
    if ( $conf_id_l!~/^\w+$/ ) {
        return "fail [$proc_name_l]. Wrong conf_id='$conf_id_l'. Conf_id must be a string with numbers, latin chars and symbol '_'. Please, check and correct config-file ('$conf_file_l')";
    }

    return $return_str_l;
}

sub vlan_id_check {
    my ($vlan_id_l,$conf_file_l)=@_;
    my $proc_name_l=(caller(0))[3];
    
    my $return_str_l='OK';
    
    if ( $vlan_id_l!~/^no$|^\d+$/ ) {
        return "fail [$proc_name_l]. Wrong vlan_id='$vlan_id_l'. Vlan_id must be a number or 'no'. Please, check and correct config-file ('$conf_file_l')";
    }

    return $return_str_l;
}

sub int_list_check {
    my ($inv_host_l,$int_list_aref_l,$inv_hosts_network_data_href_l,$conf_file_l)=@_;
    #inv_hosts_network_data_href_l=hash ref for %inv_hosts_network_data_g
        #v1) key0='hwaddr_all', key1=hwaddr, value=inv_host
        #v2) key0='inv_host', key1=inv_host, key2=interface_name, key3=hwaddr
    my $proc_name_l=(caller(0))[3];
    
    my $int_l=undef;
    my $return_str_l='OK';
    
    foreach $int_l ( @{$int_list_aref_l} ) {
	if ( !exists(${$inv_hosts_network_data_href_l}{'inv_host'}{$inv_host_l}{$int_l}) ) {
	    $return_str_l="fail [$proc_name_l]. Interface='$int_l' is not exists at host='$inv_host_l' (conf-file='$conf_file_l')";
	    last;
	}
    }
    
    # clear vars
    $int_l=undef;
    ###
    
    return $return_str_l;
}

sub bond_name_check {
    my ($bond_name_l,$conf_file_l)=@_;
    my $proc_name_l=(caller(0))[3];
    
    my $return_str_l='OK';
    
    if ( $bond_name_l!~/^no$|^\w+$|^bnd/ ) {
        return "fail [$proc_name_l]. Wrong bond_name='$bond_name_l'. Bond_name must be a string with numbers, latin chars and symbol '_' and start with 'bnd'. Please, check and correct config-file ('$conf_file_l')";
    }

    return $return_str_l;
}

sub bridge_name_check {
    my ($bridge_name_l,$conf_file_l)=@_;
    my $proc_name_l=(caller(0))[3];
    
    my $return_str_l='OK';
    
    if ( $bridge_name_l!~/^no$|^\w+$|^br/ ) {
        return "fail [$proc_name_l]. Wrong bridge_name='$bridge_name_l'. Bridge_name must be a string with numbers, latin chars and symbol '_' and start with 'br'. Please, check and correct config-file ('$conf_file_l')";
    }

    return $return_str_l;
}

sub defroute_check {
    my ($defroute_l,$conf_file_l)=@_;
    my $proc_name_l=(caller(0))[3];
    
    my $return_str_l='OK';
    
    if ( $defroute_l!~/^no$|^\w+$|^br/ ) {
        return "fail [$proc_name_l]. Wrong defroute='$defroute_l'. Defroute must be 'yes' or 'no'. Please, check and correct config-file ('$conf_file_l')";
    }

    return $return_str_l;
}

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )