###DEPENDENCIES: datetime.pl
sub rewrite_actual_ipset_file_from_hash {
    my ($file_l,$file_type_l,$href_l)=@_;
    #$file_type_l: 0-permanent ipset, 1-temporary_ipset
    
    my $proc_name_l=(caller(0))[3];
    
    #href = key0=content, key1=entry, value=expire_date (if=0 -> permanent ipset)
    # or key0=info, value=[array of info strings]
    
    my $arr_el0_l=undef;
    my $expire_date_l=undef;
    my @wr_arr_l=();
    my @tmp_arr_l=();
    
    my $return_str_l='OK';
    
    if ( exists(${$href_l}{'info'}) ) { @wr_arr_l=@{${$href_l}{'info'}}; }
    
    if ( exists(${$href_l}{'content'}) ) {
	if ( $file_type_l<1 ) { # for permanent ipset file
	    @tmp_arr_l=sort(keys %{${$href_l}{'content'}});
	    @wr_arr_l=(@wr_arr_l,@tmp_arr_l);
	    
	    # clear vars
	    @tmp_arr_l=();
	    ###
	}
	else { # for temporary ipset file
	    @tmp_arr_l=sort(keys %{${$href_l}{'content'}});
	    
	    foreach $arr_el0_l ( @tmp_arr_l ) {
		#$arr_el0_l=ipset entry
		
		$expire_date_l=${${$href_l}{'content'}}{$arr_el0_l};
		push(@wr_arr_l,"$arr_el0_l;+$expire_date_l");
	    }
	    
	    # clear vars
	    $arr_el0_l=undef;
	    $expire_date_l=undef;
	    @tmp_arr_l=();
	    ###
	}
    }
    
    &rewrite_file_from_array_ref($file_l,\@wr_arr_l);
    #$file_l,$aref_l
    
    @wr_arr_l=();
    
    return $return_str_l;
}

sub read_actual_ipset_file_to_hash {
    my ($file_l,$href_l)=@_;
    my $proc_name_l=(caller(0))[3];
    
    #href = key0=content, key1=entry, value=expire_date (if=0 -> permanent ipset)
    # or key0=info, value=[array of info strings]

    my $line_l=undef;
    my ($expire_epoch_sec_l,$now_epoch_sec_l)=(0,undef);
    my @tmp_arr_l=();
    my $return_str_l='OK';
    
    open(FILE,'<',$file_l);
    while ( <FILE> ) {
	$line_l=$_;
	
	$line_l=~s/^\s+//g;
	$line_l=~s/\n|\r|\r\n|\n\r//g;
	
	if ( $line_l!~/^\#/ ) { # if line not comment
	    $line_l=~s/\s+//g;

	    if ( $line_l!~/\;\+/ ) { ${$href_l}{'content'}{$line_l}=0; } # for permanent ipsets
	    else { # for temporary ipsets
		@tmp_arr_l=split(/\;\+/,$line_l);
		
		#YYYYMMDDHHMISS
		if ( $tmp_arr_l[1]=~/^\d{14}$/ ) { # if date format is correct
		    if ( $now_epoch_sec_l<1 ) { $now_epoch_sec_l=time(); }
		    $expire_epoch_sec_l=&dtot_conv_yyyymmddhhmiss_to_epoch_sec($tmp_arr_l[1]);
		    #$for_conv_dt
		
		    if ( $expire_epoch_sec_l>$now_epoch_sec_l ) { # if temporary ipset entry is expired
			${$href_l}{'content'}{$tmp_arr_l[0]}=$tmp_arr_l[1];
		    }
		}
	    }
	}
	else { # if line is comment from file begin
	    push(@{${$href_l}{'info'}},$line_l);
	}
    }
    close(FILE);
    
    return $return_str_l;
}

sub simple_read_lines_of_file_to_hash {
    my ($file_l,$href_l)=@_;
    my $proc_name_l=(caller(0))[3];
    
    my $line_l=undef;
    my $return_str_l='OK';
    
    open(FILE,'<',$file_l);
    while ( <FILE> ) {
	$line_l=$_;
	
	$line_l=~s/^\s+//g;
	$line_l=~s/\n|\r|\r\n|\n\r//g;
	
	if ( $line_l!~/^\#/ ) { # if line not comment
	    $line_l=~s/\s+//g;
	    ${$href_l}{$line_l}=1;
	}
    }
    close(FILE);
    
    return $return_str_l;
}

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
    system("rm -rf $dyn_fwrules_files_dir_l/*");
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
        	#actual__ipset_name.txt (file)
            	    # First line - description like "###You CAN manually ADD entries to this file!".
            	    # Second line - "datetime of creation" + "ipset_type" in the format "###YYYYMMDDHHMISS;+IPSET_TYPE".
            	    # One line - one record according to #ipset_type (conf-file "01_conf_ipset_templates").
            	    # This file can be used to recreate the set if it was deleted (for some reason) on the side of the inventory host.
            	    # You can manually add entries (according to ipset_type) to this file.
        	#/change_history/ (dir)
            	    #CHANGE_DATETIME__ipset_name.txt (file)
                	# For move "actual__ipset_name.txt" here (to this dir) with rename if changed ipset_name or ipset_type.
                	# First line - "datetime of creation;+datetime of change" + "old_ipset_type;+new_ipset_type" + "old_ipset_name;+new_ipset_name"
                    	    # in the format "###YYYYMMDDHHMISS(CREATE_DATE);+YYYYMMDDHHMISS(CHANGE_DATE);+OLD_IPSET_TYPE;+NEW_IPSET_TYPE;+OLD_IPSET_NAME;+NEW_IPSET_NAME".
    
    	    #temporary/ipset_template_name/... (dir)
        	#actual__ipset_name.txt (file)
            	    # First line - description like "###Manually ADDING entries to this file is DENIED!".
            	    # Second line - "datetime of creation" + "ipset_type" in the format "###YYYYMMDDHHMISS;+IPSET_TYPE".
            	    # One line - one record according to #ipset_type (conf-file "01_conf_ipset_templates"), but the record format is "expire datetime;+record associated with ipset_type".
            	    # Expire datetime has the format "YYYYMMDDHHMISS".
            	    # Expire date when adding an element to ipset via "ipset_input/add" is calculated as follows - current date + #ipset_create_option_timeout.
            	    # This file is for informational purposes only and cannot be used to recreate temporary sets.
        	#/change_history/... (dir)
            	    #CHANGE_DATETIME__ipset_name.txt (file)
                	# For move "actual__ipset_name.txt" here (to this dir) with rename if changed ipset_name or ipset_type.
                	# First line - "datetime of creation;+datetime of change" + "old_ipset_type;+new_ipset_type" + "old_ipset_name;+new_ipset_name"
                    	    # in the format "###YYYYMMDDHHMISS(CREATE_DATE);+YYYYMMDDHHMISS(CHANGE_DATE);+OLD_IPSET_TYPE;+NEW_IPSET_TYPE;+OLD_IPSET_NAME;+NEW_IPSET_NAME".
	
    	    #delete_history/... (dir)
		    # If "ipset template_name" is deleted from "01_conf_ipset_templates", then the ipset data and change history
            	    # are moved to this directory.
        	#permanent/DEL_DATETIME-ipset_template_name/... (dir)
            	    #actual__ipset_name.txt (file)
            	    #/change_history/ (dir)
        	#temporary/DEL_DATETIME-ipset_template_name/... (dir)
            	    #actual__ipset_name.txt (file)
            	    #/change_history/ (dir)
    
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
    
    # create dirs and create init-files if need (BEGIN)
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
		
		system("mkdir -p $ipset_actual_data_dir_l/$hkey0_l/permanent/$hkey1_l/initial_content");
		
		if ( !-e($ipset_actual_data_dir_l.'/'.$hkey0_l.'/permanent/'.$hkey1_l.'/initial_content/info') ) {
		    system("echo 'DO NOT CHANGE ANY FILES AT THIS DIR' > $ipset_actual_data_dir_l/$hkey0_l/permanent/$hkey1_l/initial_content/info");
		}

		#permanent/ipset_template_name/... (dir)
            	    # actual__ipset_name.txt (file)
                	# First line - description like "###You CAN manually ADD entries to this file!".
                	# Second line - "datetime of creation" + "ipset_type" in the format "###YYYYMMDDHHMISS;+IPSET_TYPE".
            	    #/change_history/ (dir)
		$ipset_name_l=${$ipset_templates_href_l}{'permanent'}{$hkey1_l}{'ipset_name'};
		$ipset_type_l=${$ipset_templates_href_l}{'permanent'}{$hkey1_l}{'ipset_type'};
		$init_file_l="$ipset_actual_data_dir_l/$hkey0_l/permanent/$hkey1_l/actual__".$ipset_name_l.".txt";
		
		if ( !-e($init_file_l) ) {
		    @init_lines_arr_l=('###You CAN manually ADD entries to this file! One row="ipset_entry"',"###$dt_now_l;+$ipset_type_l");
		    
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
                	# First line - description like "###You CAN manually ADD entries to this file!".
                	# Second line - "datetime of creation" + "ipset_type" in the format "###YYYYMMDDHHMISS;+IPSET_TYPE".
            	    #/change_history/ (dir)
		$ipset_name_l=${$ipset_templates_href_l}{'temporary'}{$hkey1_l}{'ipset_name'};
		$ipset_type_l=${$ipset_templates_href_l}{'temporary'}{$hkey1_l}{'ipset_type'};
		$init_file_l="$ipset_actual_data_dir_l/$hkey0_l/temporary/$hkey1_l/actual__".$ipset_name_l.".txt";
		
		if ( !-e($init_file_l) ) {
		    @init_lines_arr_l=('###You CAN manually ADD entries to this file! One row="ipset_entry;+expire_date" (date format=YYYYMMDDHHMISS)',"###$dt_now_l;+$ipset_type_l");

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
    # create dirs and create init-files if need (END)
    
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
    system("mv $src_file_path_l $dst_file_path");
}

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
