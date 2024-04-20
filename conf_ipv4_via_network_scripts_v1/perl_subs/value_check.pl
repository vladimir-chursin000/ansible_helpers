sub hwaddr_check {
    my ($hwaddr_l,$inv_hosts_network_data_href_l)=@_;
    #inv_hosts_network_data_href_l=hash ref for %inv_hosts_network_data_g
        #v1) key0='hwaddr_all', key1=hwaddr, value=inv_host
        #v2) key0='inv_host', key1=inv_host, key2=interface_name, key3=hwaddr
    my $proc_name_l=(caller(0))[3];
    
    my $return_str_l='OK';

    if ( $hwaddr_l!~/^\S{2}\:\S{2}\:\S{2}\:\S{2}\:\S{2}\:\S{2}$/ ) {
        $return_str_l="fail [$proc_name_l]. HWADDR must be like 'XX:XX:XX:XX:XX:XX' (incorrect value='$hwaddr_l'). Please, check and correct config-file ('01a_conf_int_hwaddr_inf')";
        return $return_str_l;
    }

    return $return_str_l;
}

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
