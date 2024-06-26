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

sub read_02_dns_settings {
    my ($file_l,$res_href_l)=@_;
    #$file_l=$f02_dns_settings_path_g
    #$res_href_l=hash ref for %h02_dns_settings_hash_g
    	#key=inv_host, value=[array of nameservers]
    my $proc_name_l=(caller(0))[3];
    
    my ($exec_res_l)=(undef);    
    my $return_str_l='OK';
    
    my %res_tmp_lv0_l=();
        #key=string with params from cfg, value=1
    my %res_tmp_lv1_l=(); # result hash
    
    $exec_res_l=&read_uniq_lines_with_params_from_config($file_l,3,\%res_tmp_lv0_l);
    #$file_l,$file_l,$prms_per_line_l,$res_href_l,$res_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }
    $exec_res_l=undef;
    
    return $return_str_l;
}

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )