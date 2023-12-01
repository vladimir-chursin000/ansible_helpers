###DEPENDENCIES: read_conf_fwrules_common.pl

sub read_02_2_conf_allowed_ports_sets {
    my ($file_l,$inv_hosts_href_l,$divisions_for_inv_hosts_href_l,$res_href_l)=@_;
    #file_l=$f02_2_conf_allowed_ports_sets_path_g
    #inv_hosts_href_l=hash-ref for %inventory_hosts_g
    #$divisions_for_inv_hosts_href_l=hash-ref for %h00_conf_divisions_for_inv_hosts_hash_g
        #$h00_conf_divisions_for_inv_hosts_hash_g{group_name}{inv-host}=1;
    #res_href_l=hash-ref for %h02_2_conf_allowed_ports_sets_hash_g
    my $proc_name_l=(caller(0))[3];
    #[ports_set1:BEGIN]
    #all=1122/tcp,1133/udp
    #gr_some_example_group=1122/tcp,1133/tcp,1133/udp
    #192.168.144.12,192.168.100.14,192.110.144.16=11221/tcp,11331/udp
    #192.168.144.12=11222-11333/tcp
    #[ports_set1:END]
    ###
    #$h02_2_conf_allowed_ports_sets_hash_g{inv-host}{set_name}->
    	#{'port-0'}=1
    	#{'port-1'}=1
    	#etc
    	#{'seq'}=[val-0,val-1] (val=port)
    
    my $exec_res_l=undef;
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my ($hkey1_l,$hval1_l)=(undef,undef);
    my $return_str_l='OK';
    
    my %res_tmp_lv0_l=();
        #key=set_tmplt_name, value=
            #{'string with rule params-1'}
            #{'string with rule params-2'}
            #etc
            #{'seq'}=['string with rule params-1', 'string with rule params-2', etc]
    my %res_tmp_lv1_l=(); # like '%h02_2_conf_allowed_ports_sets_hash_g'
    
    $exec_res_l=&read_param_only_templates_from_config($file_l,\%res_tmp_lv0_l);
    #$file_l,$res_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }
    
    # check rules and save res to '%res_tmp_lv1_l' (begin)
    while ( ($hkey0_l,$hval0_l)=each %res_tmp_lv0_l ) { # cycle 0
        #hkey0_l=tmplt_name, hval0_l=hash ref where key=string with rule params
    
        delete($res_tmp_lv0_l{$hkey0_l}{'seq'}); # seq-array don't need here
    
    } # cycle 0
    
    # clear vars
    $exec_res_l=undef;
    ($hkey0_l,$hval0_l)=(undef,undef);
    ($hkey1_l,$hval1_l)=(undef,undef);
    ###
    
    if ( $return_str_l!~/^OK$/ ) { return $return_str_l; }
    # check rules and save res to '%res_tmp_lv1_l' (end)
    
    return $return_str_l;
}

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
