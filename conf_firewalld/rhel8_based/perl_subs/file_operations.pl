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

sub system_ops_with_local_dyn_fwrules_files_dir {
    my ($dyn_fwrules_files_dir_l)=@_;
    #$dyn_fwrules_files_dir_l=$dyn_fwrules_files_dir_g
    
    system("mkdir -p $dyn_fwrules_files_dir_l");
    system("rm -rf $dyn_fwrules_files_dir_l/*.sh");
    system("rm -rf $dyn_fwrules_files_dir_l/*.conf");
}

sub system_ops_with_local_dyn_ipsets_files_dir { # used at 'apply_IPSET_files_operation.pl -> apply_IPSET_files_operation_main'
    my ($dyn_ipsets_files_dir_l)=@_;
    
    my $proc_name_l=(caller(0))[3];
    
    system("mkdir -p $dyn_ipsets_files_dir_l");
    system("mkdir -p $dyn_ipsets_files_dir_l/remove_queue");
	# for copy content of dir '../remove_queue/inv-host' to remote host to dir '~/ansible_helpers/conf_firewalld/ipset_files/remove_queue'
    system("mkdir -p $dyn_ipsets_files_dir_l/add_queue");
	# for copy content of dir '../add_queue/inv-host' to remote host to dir '~/ansible_helpers/conf_firewalld/ipset_files/add_queue'
    system("rm -rf $dyn_ipsets_files_dir_l/remove_queue/*");
    system("rm -rf $dyn_ipsets_files_dir_l/add_queue/*");
}

sub system_ops_with_local_ipset_input_dir { # used at 'apply_IPSET_files_operation.pl -> apply_IPSET_files_operation_main'
    my ($ipset_input_dir_l)=@_;
    
    my $proc_name_l=(caller(0))[3];
    
    #add
    #del
    #errors
    #history

    system("mkdir -p $ipset_input_dir_l/add");
    system("mkdir -p $ipset_input_dir_l/del");
    system("mkdir -p $ipset_input_dir_l/errors");
    system("mkdir -p $ipset_input_dir_l/history");
}

sub system_ops_with_local_ipset_actual_data_dir { # used at 'apply_IPSET_files_operation.pl -> apply_IPSET_files_operation_main'
    my ($ipset_actual_data_dir_l,$inv_hosts_href_l,$h66_conf_ipsets_FIN_href_l)=@_;
    
    my $proc_name_l=(caller(0))[3];
    
    #Directory structure
    #...ipset_actual_data/inv-host/... (dir)
    	    #permanent/ipset_template_name/... (dir)
		# actual--ipset_name.txt (file)
            	    # First line - description like "###You CAN manually ADD entries to this file!".
            	    # Second line - "datetime of creation" + "ipset_type" in the format "###YYYYMMDDHHMISS;+IPSET_TYPE".
        	#/change_history/ (dir)
	    #temporary/ipset_template_name/.. (dir)
		# actual--ipset_name.txt (file)
            	    # First line - description like "###Manually ADDING entries to this file is DENIED!".
            	    # Second line - "datetime of creation" + "ipset_type" in the format "###YYYYMMDDHHMISS;+IPSET_TYPE".
        	#/change_history/ (dir)
    	    #delete_history/... (dir)
        	#permanent/... (dir)
        	#temporary/... (dir)
    
    #inv_hosts_href_l=hash-ref for %inventory_hosts_g
	#Key=inventory_host, value=1
    
    #$h66_conf_ipsets_FIN_href_l=hash-ref for \%h66_conf_ipsets_FIN_hash_g
        #$h66_conf_ipsets_FIN_hash_g{'temporary/permanent'}{inventory_host}->
            #{ipset_name_tmplt-0}=1;
            #{ipset_name_tmplt-1}=1;
            #etc
    
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my ($hkey1_l,$hval1_l)=(undef,undef);
    
    my $return_str_l='OK';
    
    while ( ($hkey0_l,$hval0_l)=each %{$inv_hosts_href_l} ) {
	#hkey0_l=inv-host
	
	system("mkdir -p $ipset_actual_data_dir_l/$hkey0_l/permanent");
	system("mkdir -p $ipset_actual_data_dir_l/$hkey0_l/temporary");
	
	system("mkdir -p $ipset_actual_data_dir_l/$hkey0_l/delete_history/permanent");
	system("mkdir -p $ipset_actual_data_dir_l/$hkey0_l/delete_history/temporary");
	
	if ( exists(${$h66_conf_ipsets_FIN_href_l}{'permanent'}{$hkey0_l}) ) {
	    while ( ($hkey1_l,$hval1_l)=each %{${$h66_conf_ipsets_FIN_href_l}{'permanent'}{$hkey0_l}} ) {
		#$hkey1_l=ipset_name_tmplt
		system("mkdir -p $ipset_actual_data_dir_l/$hkey0_l/permanent/$hkey1_l/change_history");
	    }
	}
	
	if ( exists(${$h66_conf_ipsets_FIN_href_l}{'temporary'}{$hkey0_l}) ) {
	    while ( ($hkey1_l,$hval1_l)=each %{${$h66_conf_ipsets_FIN_href_l}{'temporary'}{$hkey0_l}} ) {
		#$hkey1_l=ipset_name_tmplt
		system("mkdir -p $ipset_actual_data_dir_l/$hkey0_l/temporary/$hkey1_l/change_history");
	    }
	}
    }
    
    return $return_str_l;
}

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
