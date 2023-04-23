###DEPENDENCIES: file_operations.pl

sub apply_IPSET_files_operation_main {
    my ($remote_ipset_dir_for_absible_helper_l,$dyn_ipsets_files_dir_l,$ipset_input_dir_l,$ipset_actual_data_dir_l,$input_hash4proc_href_l)=@_;
    #$remote_ipset_dir_for_absible_helper_l=$remote_ipset_dir_for_absible_helper_g
    #$dyn_ipsets_files_dir_l=$dyn_ipsets_files_dir_g -> #for copy to REMOTE_HOST:'$HOME/ansible_helpers/conf_firewalld/ipset_files'
	#...scripts_for_remote/fwrules_files/ipset_files/add_queue/inv-host
	#...scripts_for_remote/fwrules_files/ipset_files/remove_queue/inv-host
    #$ipset_input_dir_l=$ipset_input_dir_g
    #$ipset_actual_data_dir_l=$ipset_actual_data_dir_g
    #$input_hash4proc_href_l=hash-ref for %input_hash4proc_g (hash with hash refs for input)
    
    my $proc_name_l=(caller(0))[3];
    
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
    
    my $h65_conf_initial_ipsets_content_FIN_href_l=${$input_hash4proc_href_l}{'h65_conf_initial_ipsets_content_FIN_href'};
    #$h65_conf_initial_ipsets_content_FIN_hash_g{ipset_template_name}->
        #{'record-0'}=1
        #{'rerord-1'}=1
        #etc
        #{'seq'}=[val-0,val-1] (val=record)
    
    my $h66_conf_ipsets_FIN_href_l=${$input_hash4proc_href_l}{'h66_conf_ipsets_FIN_href'};
    #$h66_conf_ipsets_FIN_href_l=hash-ref for \%h66_conf_ipsets_FIN_hash_g
        #$h66_conf_ipsets_FIN_hash_g{'temporary/permanent'}{inventory_host}->
            #{ipset_name_tmplt-0}=1;
            #{ipset_name_tmplt-1}=1;
            #etc
    
    my ($exec_res_l)=(undef);
    my %ipset_input_l=();
	#key0=temporary/permanent,key1=inv-host,key2=ipset_template_name,key3=ipset_name ->
	    #key4=last_access_time_in_sec_epoch
        	#key5=add -> ipset_record (according to #ipset_type), value=1
        	#key5=del -> ipset_record (according to #ipset_type), value=1
    
    my $return_str_l='OK';
    
    ######

    &init_files_ops_with_local_dyn_ipsets_files_dir($dyn_ipsets_files_dir_l);
    #$dyn_ipsets_files_dir_l
    #$dyn_ipsets_files_dir_l/remove_queue
        # for copy content of dir '../remove_queue/inv-host' to remote host to dir '~/ansible_helpers/conf_firewalld/ipset_files/remove
    #$dyn_ipsets_files_dir_l/add_queue
        # for copy content of dir '../add_queue/inv-host' to remote host to dir '~/ansible_helpers/conf_firewalld/ipset_files/add_queue
    ###
    
    ######
    
    &init_create_dirs_at_local_ipset_input_dir($ipset_input_dir_l);
    #$ipset_input_dir_l
    #
    #$ipset_input_dir_l/add
    #$ipset_input_dir_l/del
    #$ipset_input_dir_l/errors
    #$ipset_input_dir_l/history
    ###
    
    ######
    
    $exec_res_l=&init_create_dirs_and_files_at_local_ipset_actual_data_dir($ipset_actual_data_dir_l,$inv_hosts_href_l,$ipset_templates_href_l,$h66_conf_ipsets_FIN_href_l);
    #$ipset_actual_data_dir_l,$inv_hosts_href_l,$ipset_templates_href_l,$h66_conf_ipsets_FIN_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }
    $exec_res_l=undef;
    
    ######

    $exec_res_l=&read_local_ipset_input($ipset_input_dir_l,$inv_hosts_href_l,$divisions_for_inv_hosts_href_l,$ipset_templates_href_l,$h66_conf_ipsets_FIN_href_l,\%ipset_input_l);
    #$ipset_input_dir_l,$inv_hosts_href_l,$divisions_for_inv_hosts_href_l,$ipset_templates_href_l,$h66_conf_ipsets_FIN_href_l,$res_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }
    $exec_res_l=undef;

    ######

    $exec_res_l=&update_local_ipset_actual_data($ipset_actual_data_dir_l,\%ipset_input_l,$inv_hosts_href_l,$ipset_templates_href_l,$h65_conf_initial_ipsets_content_FIN_href_l,$h66_conf_ipsets_FIN_href_l);
    #$ipset_actual_data_dir_l,$ipset_input_href_l,$inv_hosts_href_l,$ipset_templates_href_l,$h65_conf_initial_ipsets_content_FIN_href_l,$h66_conf_ipsets_FIN_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }
    $exec_res_l=undef;

    ######

    $exec_res_l=&form_local_dyn_ipsets_files_for_copy_to_remote($remote_ipset_dir_for_absible_helper_l,$dyn_ipsets_files_dir_l);
    #$remote_ipset_dir_for_absible_helper_l,$dyn_ipsets_files_dir_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }
    $exec_res_l=undef;
    
    ######
        
    return $return_str_l;
}

sub read_local_ipset_input {
    my ($ipset_input_dir_l,$inv_hosts_href_l,$divisions_for_inv_hosts_href_l,$ipset_templates_href_l,$h66_conf_ipsets_FIN_href_l,$res_href_l)=@_;
    #$ipset_input_dir_l=$ipset_input_dir_g
    #inv_hosts_href_l=hash-ref for %inventory_hosts_g
    #$divisions_for_inv_hosts_href_l=hash-ref for %h00_conf_divisions_for_inv_hosts_hash_g
	#$h00_conf_divisions_for_inv_hosts_hash_g{group_name}{inv-host}=1;
    #$ipset_templates_href_l=hash-ref for %h01_conf_ipset_templates_hash_g
	#$h01_conf_ipset_templates_hash_g{'temporary/permanent'}{ipset_template_name--TMPLT}->
    #$h66_conf_ipsets_FIN_href_l=hash-ref for \%h66_conf_ipsets_FIN_hash_g
	#$h66_conf_ipsets_FIN_hash_g{'temporary/permanent'}{inventory_host}->
            #{ipset_name_tmplt-0}=1;
            #{ipset_name_tmplt-1}=1;
            #etc
    #$res_href_l=hash-ref for %ipset_input_l
	#my %ipset_input_l=();
        #key0=temporary/permanent,key1=inv-host,key2=ipset_template_name,key3=ipset_name ->
	    #key4=last_access_time_in_sec_epoch
        	#key5=add -> ipset_record (according to #ipset_type), value=1
        	#key5=del -> ipset_record (according to #ipset_type), value=1

    #The directory ("ipset_input") is intended for preprocessing incoming data for ipset.
    #"ipset_input/add" - dir for add entries to some_ipset (for permanent and temporary sets).
	# Add-file name format VER1 - "inventory_host__ipset_template_name.txt". For add entry to ipset at one inv-host.
	# Add-file name format VER2 - "all__ipset_template_name.txt". For add entry to ipset at all inventory hosts.
	# Add-file name format VER3 - "gr_some_group__ipset_template_name.txt". For add entry to ipset at hosts of the group (configured at "00_conf_divisions_for_inv_hosts").
    	    # One line - one record according to #ipset_type (conf-file "01_conf_ipset_templates").

    #"ipset_input/del" - dir for delete entries from some_ipset. Only for permanent sets (when #ipset_create_option_timeout=0).
	# Delete-file name format VER1 - "inventory_host__ipset_template_name.txt". For remove entry from ipset at one inv-host.
	# Delete-file name format VER2 - "all__ipset_template_name.txt". For remove entry from ipset at all inventory hosts.
	# Delete-file name format VER3 - "gr_some_group__ipset_template_name.txt". For remove entry from ipset at hosts of the group (configured at "00_conf_divisions_for_inv_hosts").
    	    # One line - one record according to #ipset_type (conf-file "01_conf_ipset_templates").

    #"ipset_input/history" - dir for save add/del history.
	# File name format - "DATE-history.log"
        # Record format - "WRITE_LOG_DATETIME;+INPUT_OP_TYPE;+INPUT_FILE_NAME;+INPUT_FILE_CREATE_DATETIME;+INV_HOST;+IPSET_TEMPLATE_NAME;+IPSET_NAME;+IPSET_TYPE_BY_TIME;+IPSET_TYPE;+RECORD;+STATUS"
            # WRITE_LOG_DATETIME - format "YYYYMMDDHHMISS".
            # INPUT_OP_TYPE - add/del.
            # INPUT_FILE_NAME.
            # INPUT_FILE_CREATE_DATETIME - format "YYYYMMDDHHMISS".
            # INV_HOST = inventory-host/no.
            # IPSET_TEMPLATE_NAME = ipset_template_name/no.
            # IPSET_NAME = ipset_name/no.
            # IPSET_TYPE_BY_TIME = temporary/permanent/no.
            # IPSET_TYPE = ipset_type/no.
            # RECORD = ipset-record.
            # STATUS = OK / error (incorrect ip-address, etc).

	#/incorrect_input_files/... (dir)
	    # Moved files name format - "DATETIME__orig_file_name.txt".
    	    # Move here only if:
        	# 1) incorrect add/del-file format (no VER1/VER2/VER3).
        	# 2) not configured "ipset_template_name" for all inventory-hosts (VER1/VER2/VER3).
    	#    /add/... (dir)
    	#    /del/... (dir)
	#/correct_input_files/... (dir)
	    # Moved files name format - "DATETIME__orig_file_name.txt".
    	#    /add/... (dir)
    	#    /del/... (dir)
    my $proc_name_l=(caller(0))[3];
    
    my %read_input_dirs_l=(
	'add' => {
	    'input_dir' => $ipset_input_dir_l.'/add',
	    'correct_input_dir' => $ipset_input_dir_l.'/history/correct_input_files/add',
	    'incorrect_input_dir' => $ipset_input_dir_l.'/history/incorrect_input_files/add',
	},
	'del' => {
	    'input_dir' => $ipset_input_dir_l.'/del',
	    'correct_input_dir' => $ipset_input_dir_l.'/history/correct_input_files/del',
	    'incorrect_input_dir' => $ipset_input_dir_l.'/history/incorrect_input_files/del',
	},
	'history' => $ipset_input_dir_l.'/history',
    );
    my @read_input_seq_l=('del','add');
    my $dir_line_l=undef;
    my @input_inv_host_arr_l=();
    
    my ($input_file_name_l,$input_ipset_template_name_l)=(undef,undef);
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my ($arr_el0_l,$arr_el1_l)=(undef,undef);
    
    my $ipset_type_by_time_l=undef; # temporary/permanent
    my ($ipset_name_l,$ipset_type_l)=(undef,undef);
    my $last_access_epoch_sec_l=undef;
    
    my %log_ops_input_l=();
    
    my $is_inv_host_err_at_filename_l=0;
    my $no_err_at_filename_l=1;

    my %res_tmp_lv0_l=();
    #$res_href_l=hash-ref for %ipset_input_l
	#my %ipset_input_l=(); ()
        #key0=temporary/permanent,key1=inv-host,key2=ipset_template_name,key3=ipset_name ->
	    #key4=last_access_time_in_sec_epoch
        	#key5=add -> ipset_record (according to #ipset_type), value=1
        	#key5=del -> ipset_record (according to #ipset_type), value=1
    
    my $return_str_l='OK';
    
    ###READ INPUT ADD/DEL
    foreach $arr_el0_l ( @read_input_seq_l ) { # foreach @read_input_seq_l (begin)
    	#$arr_el0_l=del/add
    	opendir(DIR,$read_input_dirs_l{$arr_el0_l}{'input_dir'});
    	while ( readdir(DIR) ) { # readdir(DIR) begin
    	    $dir_line_l=$_;
	    if ( $dir_line_l=~/^\.|^info/ ) { next; }
    	    $is_inv_host_err_at_filename_l=0;
	    $no_err_at_filename_l=1;
	    
	    $last_access_epoch_sec_l=&get_last_access_time_in_epoch_sec_for_file($read_input_dirs_l{$arr_el0_l}{'input_dir'}.'/'.$dir_line_l);
	    #$file_l
	    
    	    if ( $dir_line_l=~/^(all)\_\_(\S+)\.txt$/ ) { # all (VER2)
    		$input_file_name_l=$dir_line_l;
    		$input_ipset_template_name_l=$2;
    		
    		if ( scalar(keys %{$inv_hosts_href_l})>0 ) {
    		    while ( ($hkey0_l,$hval0_l)=each %{$inv_hosts_href_l} ) {
    		        #$hkey0_l=inv-host
    			push(@input_inv_host_arr_l,$hkey0_l);
    		    }
    		    ($hkey0_l,$hval0_l)=(undef,undef);
    		}
    		else { # inventory file is empty
		    # move file to ".../incorrect_input_files/del(add)" and write to log ".../history/DATE-history.log"
		    # ".../incorrect_input_files/del(add)"= $read_input_dirs_l{'del/add'}{'incorrect_input_dir'}
    		    $is_inv_host_err_at_filename_l=1;
		    
		    &move_file_with_add_to_filename_datetime($input_file_name_l,$read_input_dirs_l{$arr_el0_l}{'input_dir'},$read_input_dirs_l{$arr_el0_l}{'incorrect_input_dir'},'__');
		    #$src_filename_l,$src_dir_l,$dst_dir_l,$dt_separator_l
		    
		    ######
		    %log_ops_input_l=(
        		'INPUT_OP_TYPE'=>$arr_el0_l,
        		'INPUT_FILE_NAME'=>$input_file_name_l,
        		'INPUT_FILE_CREATE_DATETIME_epoch'=>$last_access_epoch_sec_l,
        		'INV_HOST'=>'no',
        		'IPSET_TEMPLATE_NAME'=>$input_ipset_template_name_l,
        		'IPSET_NAME'=>'no',
        		'IPSET_TYPE_BY_TIME'=>'no',
        		'IPSET_TYPE'=>'no',
        		'RECORD'=>'no',
        		'STATUS'=>'inventory file is empty',
		    );
		    &read_local_ipset_input_log_ops($read_input_dirs_l{'history'},\%log_ops_input_l);
		    #$history_log_dir_l,$input_params_href_l
		    %log_ops_input_l=();
		    ######
    		}
    	    }
    	    elsif ( $dir_line_l=~/^(gr_\S+)\_\_(\S+)\.txt$/ ) { # groups (VER3)
    	    	$input_file_name_l=$dir_line_l;
    	    	$input_ipset_template_name_l=$2;
    	    	
    	    	if ( exists(${$divisions_for_inv_hosts_href_l}{$1}) && scalar(keys %{${$divisions_for_inv_hosts_href_l}{$1}})>0 ) {
    	    	    while ( ($hkey0_l,$hval0_l)=each %{${$divisions_for_inv_hosts_href_l}{$1}} ) {
    	    		#$hkey0_l=inv-host
    	    		push(@input_inv_host_arr_l,$hkey0_l);
    	    	    }
    	    	}
    	    	else { # "group '$1' is not exists at '00_conf_divisions_for_inv_hosts'"
	    	    # move file to ".../incorrect_input_files/del(add)" and write to log ".../history/DATE-history.log"
	    	    # ".../incorrect_input_files/del(add)"= $read_input_dirs_l{'del/add'}{'incorrect_input_dir'}
    	    	    $is_inv_host_err_at_filename_l=1;
	    
	    	    &move_file_with_add_to_filename_datetime($input_file_name_l,$read_input_dirs_l{$arr_el0_l}{'input_dir'},$read_input_dirs_l{$arr_el0_l}{'incorrect_input_dir'},'__');
	    	    #$src_filename_l,$src_dir_l,$dst_dir_l,$dt_separator_l
	    	    
	    	    ######
	    	    %log_ops_input_l=(
    	    		'INPUT_OP_TYPE'=>$arr_el0_l,
    	    		'INPUT_FILE_NAME'=>$input_file_name_l,
    	    		'INPUT_FILE_CREATE_DATETIME_epoch'=>$last_access_epoch_sec_l,
    	    		'INV_HOST'=>'no',
    	    		'IPSET_TEMPLATE_NAME'=>$input_ipset_template_name_l,
    	    		'IPSET_NAME'=>'no',
    	    		'IPSET_TYPE_BY_TIME'=>'no',
    	    		'IPSET_TYPE'=>'no',
    	    		'RECORD'=>'no',
    	    		'STATUS'=>"group '$1' is not exists at '00_conf_divisions_for_inv_hosts'",
	    	    );
	    	    &read_local_ipset_input_log_ops($read_input_dirs_l{'history'},\%log_ops_input_l);
	    	    #$history_log_dir_l,$input_params_href_l
	    	    %log_ops_input_l=();
	    	    ######
    	    	}
    	    }
    	    elsif ( $dir_line_l=~/^(\S+)\_\_(\S+)\.txt$/ ) { # inv-host (VER1)
    	    	$input_file_name_l=$dir_line_l;
    	    	$input_ipset_template_name_l=$2;
    		
    	    	if ( !exists(${$inv_hosts_href_l}{$1}) ) {
    	    	    # inv-host not exists at inv-hosts. Move file to ".../incorrect_input_files/del(add)" and write to log ".../history/DATE-history.log"
		    # ".../incorrect_input_files/del(add)"= $read_input_dirs_l{'del/add'}{'incorrect_input_dir'}
    	    	    $is_inv_host_err_at_filename_l=1;

		    &move_file_with_add_to_filename_datetime($input_file_name_l,$read_input_dirs_l{$arr_el0_l}{'input_dir'},$read_input_dirs_l{$arr_el0_l}{'incorrect_input_dir'},'__');
		    #$src_filename_l,$src_dir_l,$dst_dir_l,$dt_separator_l

		    ######
		    %log_ops_input_l=(
        		'INPUT_OP_TYPE'=>$arr_el0_l,
        		'INPUT_FILE_NAME'=>$input_file_name_l,
        		'INPUT_FILE_CREATE_DATETIME_epoch'=>$last_access_epoch_sec_l,
        		'INV_HOST'=>$1,
        		'IPSET_TEMPLATE_NAME'=>$input_ipset_template_name_l,
        		'IPSET_NAME'=>'no',
        		'IPSET_TYPE_BY_TIME'=>'no',
        		'IPSET_TYPE'=>'no',
        		'RECORD'=>'no',
        		'STATUS'=>"host '$1' is not exists at inventory_file",
		    );
		    &read_local_ipset_input_log_ops($read_input_dirs_l{'history'},\%log_ops_input_l);
		    #$history_log_dir_l,$input_params_href_l
		    %log_ops_input_l=();
		    ######
    	    	}
    		else { push(@input_inv_host_arr_l,$1); }
    	    }
    	    else {
		# not match with VER1/VER2/VER3. Move file to ".../incorrect_input_files/del(add)" and write to log ".../history/DATE-history.log"
		# ".../incorrect_input_files/del(add)"= $read_input_dirs_l{'del/add'}{'incorrect_input_dir'}
    		$is_inv_host_err_at_filename_l=1;

		&move_file_with_add_to_filename_datetime($dir_line_l,$read_input_dirs_l{$arr_el0_l}{'input_dir'},$read_input_dirs_l{$arr_el0_l}{'incorrect_input_dir'},'__');
		#$src_filename_l,$src_dir_l,$dst_dir_l,$dt_separator_l
		
		######
		%log_ops_input_l=(
        	    'INPUT_OP_TYPE'=>$arr_el0_l,
        	    'INPUT_FILE_NAME'=>$dir_line_l,
        	    'INPUT_FILE_CREATE_DATETIME_epoch'=>$last_access_epoch_sec_l,
        	    'INV_HOST'=>'no',
        	    'IPSET_TEMPLATE_NAME'=>'no',
        	    'IPSET_NAME'=>'no',
        	    'IPSET_TYPE_BY_TIME'=>'no',
        	    'IPSET_TYPE'=>'no',
        	    'RECORD'=>'no',
        	    'STATUS'=>"input file is not match with VER1/VER2/VER3 templates",
		);
		&read_local_ipset_input_log_ops($read_input_dirs_l{'history'},\%log_ops_input_l);
		#$history_log_dir_l,$input_params_href_l
		%log_ops_input_l=();
		######
    	    }
    	    ######
    	    
    	    if ( $is_inv_host_err_at_filename_l!=1 ) { # no error for 'inv_host' at filename
    		if ( exists(${$ipset_templates_href_l}{'temporary'}{$input_ipset_template_name_l}) ) { $ipset_type_by_time_l='temporary'; }
		elsif ( exists(${$ipset_templates_href_l}{'permanent'}{$input_ipset_template_name_l}) ) { $ipset_type_by_time_l='permanent'; }
		else { $no_err_at_filename_l=0; }
	
		if ( $no_err_at_filename_l==1 ) {
		    $ipset_name_l=${$ipset_templates_href_l}{$ipset_type_by_time_l}{$input_ipset_template_name_l}{'ipset_name'};
		    $ipset_type_l=${$ipset_templates_href_l}{$ipset_type_by_time_l}{$input_ipset_template_name_l}{'ipset_type'};
    		
		    #my %res_tmp_lv0_l=();
			#$res_href_l=hash-ref for %ipset_input_l
			    #my %ipset_input_l=();
    			    #key0=temporary/permanent,key1=inv-host,key2=ipset_template_name,key3=ipset_name ->
				#key4=last_access_time_in_sec_epoch
        			    #key5=add -> ipset_record (according to #ipset_type), value=1
        			    #key5=del -> ipset_record (according to #ipset_type), value=1
		    foreach $arr_el1_l ( @input_inv_host_arr_l ) {
			#$arr_el1_l=inv-host
			#$res_tmp_lv0_l{$ipset_type_by_time_l}{$arr_el1_l}
		    }
		    
    		    ###### clear vars
    		    $ipset_type_by_time_l=undef;
		    ($ipset_name_l,$ipset_type_l)=(undef,undef);
		}
    	    }
	    
    	    ###### clear vars
    	    $dir_line_l=undef;
    	    ($input_file_name_l,$input_ipset_template_name_l)=(undef,undef);
    	    @input_inv_host_arr_l=();
	    $last_access_epoch_sec_l=undef;
	    %log_ops_input_l=();
    	} # readdir(DIR) end
    	closedir(DIR);
    } # foreach @read_input_seq_l (end)
    
    $arr_el0_l=undef;
    ###
    
    return $return_str_l;
}

sub update_local_ipset_actual_data {
    my ($ipset_actual_data_dir_l,$ipset_input_href_l,$inv_hosts_href_l,$ipset_templates_href_l,$h65_conf_initial_ipsets_content_FIN_href_l,$h66_conf_ipsets_FIN_href_l)=@_;
    #$ipset_actual_data_dir_l=$ipset_actual_data_dir_g
    #$ipset_input_href_l=hash-ref for %ipset_input_l
    #inv_hosts_href_l=hash-ref for %inventory_hosts_g
    #$ipset_templates_href_l=hash-ref for %h01_conf_ipset_templates_hash_g
    #$h65_conf_initial_ipsets_content_FIN_href_l=hash-ref for %h65_conf_initial_ipsets_content_FIN_hash_g
    #$h66_conf_ipsets_FIN_href_l=hash-ref for \%h66_conf_ipsets_FIN_hash_g
	#$h65_conf_initial_ipsets_content_FIN_hash_g{ipset_template_name}->
    	    #{'record-0'}=1
    	    #{'rerord-1'}=1
    	    #etc
    	    #{'seq'}=[val-0,val-1] (val=record)

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

    	    #temporary/ipset_template_name/.. (dir)
        	#actual__ipset_name.txt (file)
            	    # First line - description like "###Manually ADDING entries to this file is DENIED!".
            	    # Second line - "datetime of creation" + "ipset_type" in the format "###YYYYMMDDHHMISS;+IPSET_TYPE".
            	    # One line - one record according to #ipset_type (conf-file "01_conf_ipset_templates"), but the record format is "expire datetime;+record associated with ipset_type".
            	    # Expire datetime has the format "YYYYMMDDHHMISS".
            	    # Expire date when adding an element to ipset via "ipset_input/add" is calculated as follows - current date + #ipset_create_option_timeout.
            	    # This file is for informational purposes only and cannot be used to recreate temporary sets.
        	#/change_history/ (dir)
            	    #CHANGE_DATETIME__ipset_name.txt (file)
                	# For move "actual__ipset_name.txt" here (to this dir) with rename if changed ipset_name or ipset_type.
                	# First line - "datetime of creation->datetime of change" + "old_ipset_type->new_ipset_type" + "old_ipset_name->new_ipset_name"
                    	    # in the format "###YYYYMMDDHHMISS->YYYYMMDDHHMISS;+OLD_IPSET_TYPE->NEW_IPSET_TYPE;+OLD_IPSET_NAME->NEW_IPSET_NAME".

    	    #delete_history/... (dir)
        	# If the ownership of "ipset template_name" is changed (via config "66_conf_ipsets_FIN"), then the ipset data and change history
            	# are moved to this directory.
        	#permanent/DEL_DATETIME-ipset_template_name/... (dir)
            	    #actual__ipset_name.txt (file)
            	    #/change_history/ (dir)
        	#temporary/DEL_DATETIME-ipset_template_name/... (dir)
            	    #actual__ipset_name.txt (file)
            	    #/change_history/ (dir)
    my $proc_name_l=(caller(0))[3];
    
    my $return_str_l='OK';

    return $return_str_l;
}

sub form_local_dyn_ipsets_files_for_copy_to_remote {
    my ($remote_ipset_dir_for_absible_helper_l,$dyn_ipsets_files_dir_l)=@_;
    #$remote_ipset_dir_for_absible_helper_l=$remote_ipset_dir_for_absible_helper_g
    #$dyn_ipsets_files_dir_l=$dyn_ipsets_files_dir_g -> #for copy to REMOTE_HOST:'$HOME/ansible_helpers/conf_firewalld/ipset_files'
	#...scripts_for_remote/fwrules_files/ipset_files/add_queue/inv-host
	#...scripts_for_remote/fwrules_files/ipset_files/remove_queue/inv-host
    my $proc_name_l=(caller(0))[3];
    
    my $return_str_l='OK';
    
    return $return_str_l;
}

sub check_input_ipset_template_name_via_66_conf {
    my ($input_ipset_template_name_l,$h66_conf_ipsets_FIN_href_l)=@_;
    
    #$h66_conf_ipsets_FIN_href_l=hash-ref for \%h66_conf_ipsets_FIN_hash_g
        #$h66_conf_ipsets_FIN_hash_g{'temporary/permanent'}{inventory_host}->
            #{ipset_name_tmplt-0}=1;
            #{ipset_name_tmplt-1}=1;
            #etc

    my $proc_name_l=(caller(0))[3];
    
    my $return_str_l='OK';
    
    return $return_str_l;
}

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
