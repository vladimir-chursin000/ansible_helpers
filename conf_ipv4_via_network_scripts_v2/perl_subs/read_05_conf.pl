sub read_config_temporary_apply_ifcfg {
    my ($file_l,$res_href_l)=@_;
    #file_l=conf_temp_apply_g
    #res_href_l=hash ref for %inv_hosts_tmp_apply_cfg_g
    my $proc_name_l=(caller(0))[3];
    
    #%inv_hosts_tmp_apply_cfg_g=(); #key=inv_host/common, value=rollback_ifcfg_timeout
    
    my $line_l=undef;
    my $return_str_l='OK';
    
    open(CONF_TMP_APPLY,'<',$file_l);
    while ( <CONF_TMP_APPLY> ) {
        $line_l=$_;
        $line_l=~s/\n$|\r$|\n\r$|\r\n$//g;
        while ($line_l=~/\t/) { $line_l=~s/\t/ /g; }
        $line_l=~s/\s+/ /g;
        $line_l=~s/^ //g;
        if ( length($line_l)>0 && $line_l!~/^\#/ && $line_l=~/^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}|common) (\d+)$/ ) {
            ${$res_href_l}{$1}=$2;
        }
    }
    close(CONF_TMP_APPLY);
    
    $line_l=undef;
    
    return $return_str_l;
}

sub read_05_conf_temp_apply {
    my ($file_l,$inv_hosts_href_l,$divisions_for_inv_hosts_href_l,$res_href_l)=@_;
    #$file_l=$f05_conf_temp_apply_path_g
    #inv_hosts_href_l=hash-ref for %inventory_hosts_g
    #$divisions_for_inv_hosts_href_l=hash-ref for %h00_conf_divisions_for_inv_hosts_hash_g
        #$h00_conf_divisions_for_inv_hosts_hash_g{group-name}{inv-host}=1;
    #$res_href_l=hash ref for %h05_conf_temp_apply_hash_g
        #key=inv_host, value=rollback_timeout
    ###############

}

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
