sub apply_IPSET_files_operation_main {
    my ($dyn_ipsets_files_dir_l)=@_;
    #$dyn_ipsets_files_dir_l=$dyn_ipsets_files_dir_g
    
    my $return_str_l='OK';
    
    &ops_with_local_dyn_ipsets_files_dir($dyn_ipsets_files_dir_l);
    #$dyn_ipsets_files_dir_l
    #$dyn_ipsets_files_dir_l/remove_queue
        # for copy content of dir '../remove_queue/inv-host' to remote host to dir '~/ansible_helpers/conf_firewalld/ipset_files/remove
    #$dyn_ipsets_files_dir_l/add_queue
        # for copy content of dir '../add_queue/inv-host' to remote host to dir '~/ansible_helpers/conf_firewalld/ipset_files/add_queue
    ###

    return $return_str_l;
}

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
