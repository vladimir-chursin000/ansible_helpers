###DEPENDENCIES: read_conf_fwrules_common.pl

sub read_02_1_conf_allowed_services_sets {
    my ($file_l,$inv_hosts_href_l,$divisions_for_inv_hosts_href_l,$res_href_l)=@_;
    #file_l=$f02_1_conf_allowed_services_sets_path_g
    #inv_hosts_href_l=hash-ref for %inventory_hosts_g
    #$divisions_for_inv_hosts_href_l=hash-ref for %h00_conf_divisions_for_inv_hosts_hash_g
        #$h00_conf_divisions_for_inv_hosts_hash_g{group_name}{inv-host}=1;
    #res_href_l=hash-ref for %h02_1_conf_allowed_services_sets_hash_g
    my $proc_name_l=(caller(0))[3];
    
    my $exec_res_l=undef;
    my $return_str_l='OK';
    
    my %res_tmp_lv0_l=();
        #key=set_tmplt_name, value=
            #{'string with rule params-1'}
            #{'string with rule params-2'}
            #etc
            #{'seq'}=['string with rule params-1', 'string with rule params-2', etc]
    my %res_tmp_lv1_l=(); # like '%h02_1_conf_allowed_services_sets_hash_g'
            
    $exec_res_l=&read_param_only_templates_from_config($file_l,\%res_tmp_lv0_l);
    #$file_l,$res_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }
    
    return $return_str_l;
}

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
