###DEPENDENCIES: file_operations.pl

sub apply_IPSET_files_operation_main {
    my ($dyn_ipsets_files_dir_l,$ipset_input_dir_l,$ipset_actual_data_dir_l)=@_;
    #$dyn_ipsets_files_dir_l=$dyn_ipsets_files_dir_g
    #$ipset_input_dir_l=$ipset_input_dir_g
    #$ipset_actual_data_dir_l=$ipset_actual_data_dir_g
    
    my $return_str_l='OK';
    
    &ops_with_local_dyn_ipsets_files_dir($dyn_ipsets_files_dir_l);
    #$dyn_ipsets_files_dir_l
    #$dyn_ipsets_files_dir_l/remove_queue
        # for copy content of dir '../remove_queue/inv-host' to remote host to dir '~/ansible_helpers/conf_firewalld/ipset_files/remove
    #$dyn_ipsets_files_dir_l/add_queue
        # for copy content of dir '../add_queue/inv-host' to remote host to dir '~/ansible_helpers/conf_firewalld/ipset_files/add_queue
    ###
    
    &ops_with_local_ipset_input_dir($ipset_input_dir_l);
    #$ipset_input_dir_l
    #
    #$ipset_input_dir_l/add
    #$ipset_input_dir_l/del
    #$ipset_input_dir_l/errors
    #$ipset_input_dir_l/history
    ###
    
    return $return_str_l;
}

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
