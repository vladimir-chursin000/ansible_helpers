###DEPENDENCIES: file_operations.pl

sub apply_IPSET_files_operation_main {
    my ($dyn_ipsets_files_dir_l,$ipset_input_dir_l,$ipset_actual_data_dir_l,$input_hash4proc_href_l)=@_;
    #$dyn_ipsets_files_dir_l=$dyn_ipsets_files_dir_g
    #$ipset_input_dir_l=$ipset_input_dir_g
    #$ipset_actual_data_dir_l=$ipset_actual_data_dir_g
    #$input_hash4proc_href_l=hash-ref for %input_hash4proc_g (hash with hash refs for input)
    
    my $inv_hosts_href_l=${$input_hash4proc_href_l}{'inventory_hosts_href'};
    #inv_hosts_href_l=hash-ref for %inventory_hosts_g

    my $divisions_for_inv_hosts_href_l=${$input_hash4proc_href_l}{'divisions_for_inv_hosts_href'};
    #$divisions_for_inv_hosts_href_l=hash-ref for %h00_conf_divisions_for_inv_hosts_hash_g
        #$h00_conf_divisions_for_inv_hosts_hash_g{group_name}{inv-host}=1;

    my $ipset_templates_href_l=${$input_hash4proc_href_l}{'h01_conf_ipset_templates_href'};
    #$ipset_templates_href_l=hash-ref for %h01_conf_ipset_templates_hash_g
	#$h01_conf_ipset_templates_hash_g{'temporary/permanent'}{ipset_template_name--TMPLT}->
	#{'ipset_name'}=value
	#{'ipset_description'}=empty|value
	#{'ipset_short_description'}=empty|value
	#{'ipset_create_option_timeout'}=num
	#{'ipset_create_option_hashsize'}=num
	#{'ipset_create_option_maxelem'}=num
	#{'ipset_create_option_family'}=inet|inet6
	#{'ipset_type'}=hash:ip|hash:ip,port|hash:ip,mark|hash:net|hash:net,port|hash:net,iface|hash:mac|hash:ip,port,ip|hash:ip,port,net|hash:net,net|hash:net,port,net

    my $h66_conf_ipsets_FIN_href_l=${$input_hash4proc_href_l}{'h66_conf_ipsets_FIN_href'};
    #$h66_conf_ipsets_FIN_href_l=hash-ref for \%h66_conf_ipsets_FIN_hash_g
        #$h66_conf_ipsets_FIN_hash_g{'temporary/permanent'}{inventory_host}->
            #{ipset_name_tmplt-0}=1;
            #{ipset_name_tmplt-1}=1;
            #etc

    my $return_str_l='OK';
    
    ######

    &ops_with_local_dyn_ipsets_files_dir($dyn_ipsets_files_dir_l);
    #$dyn_ipsets_files_dir_l
    #$dyn_ipsets_files_dir_l/remove_queue
        # for copy content of dir '../remove_queue/inv-host' to remote host to dir '~/ansible_helpers/conf_firewalld/ipset_files/remove
    #$dyn_ipsets_files_dir_l/add_queue
        # for copy content of dir '../add_queue/inv-host' to remote host to dir '~/ansible_helpers/conf_firewalld/ipset_files/add_queue
    ###
    
    ######
    
    &ops_with_local_ipset_input_dir($ipset_input_dir_l);
    #$ipset_input_dir_l
    #
    #$ipset_input_dir_l/add
    #$ipset_input_dir_l/del
    #$ipset_input_dir_l/errors
    #$ipset_input_dir_l/history
    ###
    
    ######
    
    return $return_str_l;
}

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
