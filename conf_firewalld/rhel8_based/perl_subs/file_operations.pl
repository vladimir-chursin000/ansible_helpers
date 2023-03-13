###NO DEPENDENCIES

sub rewrite_file_from_array_ref {
    my ($file_l,$aref_l)=@_;
    my $proc_name_l=(caller(0))[3];
    
    my $arr_el0_l=undef;
    my $return_str_l='OK';
    
    open(FILE,'>',$file_l);
    while ( $arr_el0_l=splice(@{$aref_l},0,1) ) {
    	print FILE $arr_el0_l."\n";
    	
    	$arr_el0_l=undef;
    }
    close(FILE);
    
    return $return_str_l;
}   

sub ops_with_local_dyn_fwrules_files_dir {
    my ($dyn_fwrules_files_dir_l)=@_;
    #$dyn_fwrules_files_dir_l=$dyn_fwrules_files_dir_g
    
    system("mkdir -p $dyn_fwrules_files_dir_l");
    system("rm -rf $dyn_fwrules_files_dir_l/*.sh");
    system("rm -rf $dyn_fwrules_files_dir_l/*.conf");
}

sub ops_with_local_dyn_ipsets_files_dir {
    my ($dyn_ipsets_files_dir_l)=@_;
    #$dyn_ipsets_files_dir_l=$dyn_ipsets_files_dir_g
    
    system("mkdir -p $dyn_ipsets_files_dir_l");
    system("mkdir -p $dyn_ipsets_files_dir_l/remove_queue");
	# for copy content of dir '../remove_queue/inv-host' to remote host to dir '~/ansible_helpers/conf_firewalld/ipset_files/remove_queue'
    system("mkdir -p $dyn_ipsets_files_dir_l/add_queue");
	# for copy content of dir '../add_queue/inv-host' to remote host to dir '~/ansible_helpers/conf_firewalld/ipset_files/add_queue'
    system("rm -rf $dyn_ipsets_files_dir_l/remove_queue/*");
    system("rm -rf $dyn_ipsets_files_dir_l/add_queue/*");
}

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
