###DEPENDENCIES: read_conf_fwrules_common.pl

sub read_02_2_conf_allowed_ports_sets {
    my ($file_l,$inv_hosts_href_l,$divisions_for_inv_hosts_href_l,$res_href_l)=@_;
    #file_l=$f02_2_conf_allowed_ports_sets_path_g
    #inv_hosts_href_l=hash-ref for %inventory_hosts_g
    #$divisions_for_inv_hosts_href_l=hash-ref for %h00_conf_divisions_for_inv_hosts_hash_g
        #$h00_conf_divisions_for_inv_hosts_hash_g{group_name}{inv-host}=1;
    #res_href_l=hash-ref for %h02_2_conf_allowed_ports_sets_hash_g
    my $proc_name_l=(caller(0))[3];

}

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
