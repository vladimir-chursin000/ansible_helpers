###DEPENDENCIES: datetime.pl

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

sub init_files_ops_with_local_dyn_fwrules_files_dir {
    my ($dyn_fwrules_files_dir_l)=@_;
    #$dyn_fwrules_files_dir_l=$dyn_fwrules_files_dir_g
    
    system("mkdir -p $dyn_fwrules_files_dir_l");
    system("rm -rf $dyn_fwrules_files_dir_l/*.sh");
    system("rm -rf $dyn_fwrules_files_dir_l/*.conf");
}

sub init_files_ops_with_local_dyn_ipsets_files_dir { # used at 'apply_IPSET_files_operation.pl -> apply_IPSET_files_operation_main'
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

sub init_create_dirs_at_local_ipset_input_dir { # used at 'apply_IPSET_files_operation.pl -> apply_IPSET_files_operation_main'
    my ($ipset_input_dir_l)=@_;
    
    my $proc_name_l=(caller(0))[3];
    
    #add
    #del
    #errors
    #history

    system("mkdir -p $ipset_input_dir_l/add");
    system("mkdir -p $ipset_input_dir_l/del");
    system("mkdir -p $ipset_input_dir_l/history");
    system("mkdir -p $ipset_input_dir_l/history/incorrect_input_files");
    system("mkdir -p $ipset_input_dir_l/history/correct_input_files");
    system("mkdir -p $ipset_input_dir_l/history/incorrect_input_files/add");
    system("mkdir -p $ipset_input_dir_l/history/correct_input_files/add");
    system("mkdir -p $ipset_input_dir_l/history/incorrect_input_files/del");
    system("mkdir -p $ipset_input_dir_l/history/correct_input_files/del");
}

sub init_create_dirs_and_files_at_local_ipset_actual_data_dir { # used at 'apply_IPSET_files_operation.pl -> apply_IPSET_files_operation_main'
    my ($ipset_actual_data_dir_l,$inv_hosts_href_l,$ipset_templates_href_l,$h66_conf_ipsets_FIN_href_l)=@_;
    
    my $proc_name_l=(caller(0))[3];
    
    #Directory structure
    #...ipset_actual_data/inv-host/... (dir)
    	    #permanent/ipset_template_name/... (dir)
		# actual__ipset_name.txt (file)
            	    # First line - description like "###You CAN manually ADD entries to this file!".
            	    # Second line - "datetime of creation" + "ipset_type" in the format "###YYYYMMDDHHMISS;+IPSET_TYPE".
        	#/change_history/ (dir)
	    #temporary/ipset_template_name/.. (dir)
		# actual__ipset_name.txt (file)
            	    # First line - description like "###Manually ADDING entries to this file is DENIED!".
            	    # Second line - "datetime of creation" + "ipset_type" in the format "###YYYYMMDDHHMISS;+IPSET_TYPE".
        	#/change_history/ (dir)
    	    #delete_history/... (dir)
        	#permanent/... (dir)
        	#temporary/... (dir)
    
    #inv_hosts_href_l=hash-ref for %inventory_hosts_g
	#Key=inventory_host, value=1
    
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


    #$h66_conf_ipsets_FIN_href_l=hash-ref for \%h66_conf_ipsets_FIN_hash_g
        #$h66_conf_ipsets_FIN_hash_g{'temporary/permanent'}{inventory_host}->
            #{ipset_name_tmplt-0}=1;
            #{ipset_name_tmplt-1}=1;
            #etc
    
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my ($hkey1_l,$hval1_l)=(undef,undef);
    my $dt_now_l=undef;
    my ($ipset_name_l,$ipset_type_l)=(undef,undef);
    my $init_file_l=undef;
    
    my $return_str_l='OK';
    my @init_lines_arr_l=();
    
    $dt_now_l=&get_dt_yyyymmddhhmmss();
    
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

		#permanent/ipset_template_name/... (dir)
            	    # actual__ipset_name.txt (file)
                	# First line - description like "###You CAN manually ADD entries to this file!".
                	# Second line - "datetime of creation" + "ipset_type" in the format "###YYYYMMDDHHMISS;+IPSET_TYPE".
            	    #/change_history/ (dir)
		$ipset_name_l=${$ipset_templates_href_l}{'permanent'}{$hkey1_l}{'ipset_name'};
		$ipset_type_l=${$ipset_templates_href_l}{'permanent'}{$hkey1_l}{'ipset_type'};
		$init_file_l="$ipset_actual_data_dir_l/$hkey0_l/permanent/$hkey1_l/actual__".$ipset_name_l.".txt";
		
		if ( !-e($init_file_l) ) {
		    @init_lines_arr_l=('###You CAN manually ADD entries to this file!',"###$dt_now_l;+$ipset_type_l");
		    
		    &rewrite_file_from_array_ref($init_file_l,\@init_lines_arr_l);
		    #$file_l,$aref_l
		    
		    @init_lines_arr_l=();
		}
		
		($ipset_name_l,$ipset_type_l)=(undef,undef);
		$init_file_l=undef;
		##############
	    }
	    
	    ($hkey1_l,$hval1_l)=(undef,undef);
	}
	
	if ( exists(${$h66_conf_ipsets_FIN_href_l}{'temporary'}{$hkey0_l}) ) {
	    while ( ($hkey1_l,$hval1_l)=each %{${$h66_conf_ipsets_FIN_href_l}{'temporary'}{$hkey0_l}} ) {
		#$hkey1_l=ipset_name_tmplt
		system("mkdir -p $ipset_actual_data_dir_l/$hkey0_l/temporary/$hkey1_l/change_history");

        	#temporary/ipset_template_name/.. (dir)
            	    # actual__ipset_name.txt (file)
                	# First line - description like "###Manually ADDING entries to this file is DENIED!".
                	# Second line - "datetime of creation" + "ipset_type" in the format "###YYYYMMDDHHMISS;+IPSET_TYPE".
            	    #/change_history/ (dir)
		$ipset_name_l=${$ipset_templates_href_l}{'temporary'}{$hkey1_l}{'ipset_name'};
		$ipset_type_l=${$ipset_templates_href_l}{'temporary'}{$hkey1_l}{'ipset_type'};
		$init_file_l="$ipset_actual_data_dir_l/$hkey0_l/temporary/$hkey1_l/actual__".$ipset_name_l.".txt";
		
		if ( !-e($init_file_l) ) {
		    @init_lines_arr_l=('###Manually ADDING entries to this file is DENIED!',"###$dt_now_l;+$ipset_type_l");

		    &rewrite_file_from_array_ref($init_file_l,\@init_lines_arr_l);
		    #$file_l,$aref_l
		    
		    @init_lines_arr_l=();
		}

		($ipset_name_l,$ipset_type_l)=(undef,undef);
		$init_file_l=undef;
		##############
	    }

	    ($hkey1_l,$hval1_l)=(undef,undef);
	}
    }
    
    ($hkey0_l,$hval0_l)=(undef,undef);
    
    return $return_str_l;
}

sub get_last_access_time_in_epoch_sec_for_file {
    my ($file_l)=@_;    
    my @stat_l=stat($file_l);
    return $stat_l[8];
}

sub move_file_with_add_to_filename_datetime {
    my ($src_filename_l,$src_dir_l,$dst_dir_l,$dt_separator_l)=@_;
    my $dt_now_l=&get_dt_yyyymmddhhmmss();
    my $src_file_path_l=$src_dir_l.'/'.$src_filename_l;
    my $dst_file_path=$dst_dir_l.'/'.$dt_now_l.$dt_separator_l.$src_filename_l;
    system("cp $src_file_path_l $dst_file_path");
}

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
