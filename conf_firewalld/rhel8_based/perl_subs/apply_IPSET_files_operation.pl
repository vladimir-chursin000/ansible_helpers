###DEPENDENCIES: file_operations.pl

sub apply_IPSET_files_operation_main {
    my ($ipset_input_dir_l,$ipset_actual_data_dir_l,$dyn_fwrules_files_dir_l,$input_hash4proc_href_l)=@_;
    #$ipset_input_dir_l=$ipset_input_dir_g
    #$ipset_actual_data_dir_l=$ipset_actual_data_dir_g
    #$dyn_fwrules_files_dir_l=$dyn_fwrules_files_dir_g
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
    #$h65_conf_initial_ipsets_content_FIN_hash_g{inv-host}{ipset_template_name}->
        #{'record-0'}=1 (record=ipset_entry)
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
        #key0=permanent/temporary,key1=inv-host;+ipset_template_name;+ipset_name ->
            #key2=add/del,key3=ipset_entry (according to #ipset_type), value=$expire_datetime_l
    
    my $return_str_l='OK';
    
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
    #print Dumper(\%ipset_input_l);

    ######
        
    $exec_res_l=&update_initial_content_for_local_ipset_actual_data($ipset_actual_data_dir_l,$h65_conf_initial_ipsets_content_FIN_href_l);
    #$ipset_actual_data_dir_l,$h65_conf_initial_ipsets_content_FIN_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }
    $exec_res_l=undef;

    ######

    $exec_res_l=&update_local_ipset_actual_data($ipset_actual_data_dir_l,\%ipset_input_l,$inv_hosts_href_l,$ipset_templates_href_l,$h65_conf_initial_ipsets_content_FIN_href_l,$h66_conf_ipsets_FIN_href_l);
    #$ipset_actual_data_dir_l,$ipset_input_href_l,$inv_hosts_href_l,$ipset_templates_href_l,$h65_conf_initial_ipsets_content_FIN_href_l,$h66_conf_ipsets_FIN_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }
    $exec_res_l=undef;

    ######

    $exec_res_l=&copy_actual_ipset_data_to_scripts_for_remote($ipset_actual_data_dir_l,$dyn_fwrules_files_dir_l,$ipset_templates_href_l,$h66_conf_ipsets_FIN_href_l);
    #$ipset_actual_data_dir_l,$dyn_fwrules_files_dir_l,$ipset_templates_href_l,$h66_conf_ipsets_FIN_href_l
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
            #key0=permanent/temporary,key1=inv-host;+ipset_template_name;+ipset_name ->
                #key2=add/del,key3=ipset_entry (according to #ipset_type), value=$expire_datetime_l

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
	    'input_dir' => $ipset_input_dir_l.'/add', # for read
	    'correct_input_dir' => $ipset_input_dir_l.'/history/correct_input_files/add', # for write
	    'incorrect_input_dir' => $ipset_input_dir_l.'/history/incorrect_input_files/add', # for write
	},
	'del' => {
	    'input_dir' => $ipset_input_dir_l.'/del', # fo read
	    'correct_input_dir' => $ipset_input_dir_l.'/history/correct_input_files/del', # for write
	    'incorrect_input_dir' => $ipset_input_dir_l.'/history/incorrect_input_files/del', # for write
	},
	'history' => $ipset_input_dir_l.'/history', # for write
    );
    my @read_input_seq_l=('del','add');
    my @input_inv_host_arr_l=();
    my @tmp_arr0_l=();
    
    my %input_file_content_hash_l=();
	# key=ipset_entry, value=expire_datetime
    
    my ($input_file_name_l,$input_ipset_template_name_l)=(undef,undef);
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my ($hkey1_l,$hval1_l)=(undef,undef);
    my ($arr_el0_l,$arr_el1_l)=(undef,undef);
    my $dir_line_l=undef;
    my $file_line_l=undef;
    
    my $ipset_type_by_time_l=undef; # temporary/permanent
    my ($ipset_name_l,$ipset_type_l,$ipset_create_option_family_l)=(undef,undef,undef);
    my $last_access_epoch_sec_l=undef;
    
    my ($ipset_entry_l,$expire_datetime_l)=(undef,undef);
    my $ipset_record_is_ok_l=0;
    
    my %log_ops_input_l=();
    
    my %res_tmp_lv0_l=();
    my %res_tmp_lv0_slice_l=();
    #key0=temporary/permanent;+inv-host;+ipset_template_name;+ipset_name;+ipset_entry (according to #ipset_type)
	# key1=add/del, value=[last_access_time_in_sec_epoch,$input_file_name_l,$ipset_type_l,$ipset_create_option_family_l,$expire_datetime_l]
    
    my %res_tmp_lv1_l=(); # like %ipset_input_l
            #key0=permanent/temporary,key1=inv-host;+ipset_template_name;+ipset_name ->
                #key2=add/del,key3=ipset_entry (according to #ipset_type), value=$expire_datetime_l

    my $return_str_l='OK';
    
    ###READ INPUT ADD/DEL
    foreach $arr_el0_l ( @read_input_seq_l ) { # foreach @read_input_seq_l (begin)
    	#$arr_el0_l=del/add
    	opendir(DIR,$read_input_dirs_l{$arr_el0_l}{'input_dir'});
    	while ( readdir(DIR) ) { # readdir(DIR) begin
    	    $dir_line_l=$_;
	    if ( $dir_line_l=~/^\.|^info/ ) { next; }
	    
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
		    
		    &move_file_with_add_to_filename_datetime($input_file_name_l,$read_input_dirs_l{$arr_el0_l}{'input_dir'},$read_input_dirs_l{$arr_el0_l}{'incorrect_input_dir'},'__');
		    #$src_filename_l,$src_dir_l,$dst_dir_l,$dt_separator_l
		    
		    ######
		    %log_ops_input_l=(
        		'INPUT_OP_TYPE'=>$arr_el0_l, 'INPUT_FILE_NAME'=>$input_file_name_l,
        		'INPUT_FILE_CREATE_DATETIME_epoch'=>$last_access_epoch_sec_l,
        		'INV_HOST'=>'no', 'IPSET_TEMPLATE_NAME'=>$input_ipset_template_name_l,
        		'IPSET_NAME'=>'no', 'IPSET_TYPE_BY_TIME'=>'no',
        		'IPSET_TYPE'=>'no', 'RECORD'=>'no',
        		'STATUS'=>'inventory file is empty',
		    );
		    &write_local_ipset_input_log_ops($read_input_dirs_l{'history'},\%log_ops_input_l);
		    #$history_log_dir_l,$input_params_href_l
		    %log_ops_input_l=();
		    ######
		    
		    next; # if error for 'inv_host' at filename
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
	    
	    	    &move_file_with_add_to_filename_datetime($input_file_name_l,$read_input_dirs_l{$arr_el0_l}{'input_dir'},$read_input_dirs_l{$arr_el0_l}{'incorrect_input_dir'},'__');
	    	    #$src_filename_l,$src_dir_l,$dst_dir_l,$dt_separator_l
	    	    
	    	    ######
	    	    %log_ops_input_l=(
    	    		'INPUT_OP_TYPE'=>$arr_el0_l, 'INPUT_FILE_NAME'=>$input_file_name_l,
    	    		'INPUT_FILE_CREATE_DATETIME_epoch'=>$last_access_epoch_sec_l,
    	    		'INV_HOST'=>'no', 'IPSET_TEMPLATE_NAME'=>$input_ipset_template_name_l,
    	    		'IPSET_NAME'=>'no', 'IPSET_TYPE_BY_TIME'=>'no',
    	    		'IPSET_TYPE'=>'no', 'RECORD'=>'no',
    	    		'STATUS'=>"group '$1' is not exists at '00_conf_divisions_for_inv_hosts'",
	    	    );
	    	    &write_local_ipset_input_log_ops($read_input_dirs_l{'history'},\%log_ops_input_l);
	    	    #$history_log_dir_l,$input_params_href_l
	    	    %log_ops_input_l=();
	    	    ######
		    
		    next; # if error for 'inv_host' at filename
    	    	}
    	    }
    	    elsif ( $dir_line_l=~/^(\S+)\_\_(\S+)\.txt$/ ) { # inv-host (VER1)
    	    	$input_file_name_l=$dir_line_l;
    	    	$input_ipset_template_name_l=$2;
    		
    	    	if ( !exists(${$inv_hosts_href_l}{$1}) ) {
    	    	    # inv-host not exists at inv-hosts. Move file to ".../incorrect_input_files/del(add)" and write to log ".../history/DATE-history.log"
		    # ".../incorrect_input_files/del(add)"= $read_input_dirs_l{'del/add'}{'incorrect_input_dir'}

		    &move_file_with_add_to_filename_datetime($input_file_name_l,$read_input_dirs_l{$arr_el0_l}{'input_dir'},$read_input_dirs_l{$arr_el0_l}{'incorrect_input_dir'},'__');
		    #$src_filename_l,$src_dir_l,$dst_dir_l,$dt_separator_l

		    ######
		    %log_ops_input_l=(
        		'INPUT_OP_TYPE'=>$arr_el0_l, 'INPUT_FILE_NAME'=>$input_file_name_l,
        		'INPUT_FILE_CREATE_DATETIME_epoch'=>$last_access_epoch_sec_l,
        		'INV_HOST'=>$1, 'IPSET_TEMPLATE_NAME'=>$input_ipset_template_name_l,
        		'IPSET_NAME'=>'no', 'IPSET_TYPE_BY_TIME'=>'no',
			'IPSET_TYPE'=>'no', 'RECORD'=>'no',
        		'STATUS'=>"host '$1' is not exists at inventory_file",
		    );
		    &write_local_ipset_input_log_ops($read_input_dirs_l{'history'},\%log_ops_input_l);
		    #$history_log_dir_l,$input_params_href_l
		    %log_ops_input_l=();
		    ######
		    
		    next; # if error for 'inv_host' at filename
    	    	}
		
    		push(@input_inv_host_arr_l,$1);
    	    }
    	    else {
		# not match with VER1/VER2/VER3. Move file to ".../incorrect_input_files/del(add)" and write to log ".../history/DATE-history.log"
		# ".../incorrect_input_files/del(add)"= $read_input_dirs_l{'del/add'}{'incorrect_input_dir'}

		&move_file_with_add_to_filename_datetime($dir_line_l,$read_input_dirs_l{$arr_el0_l}{'input_dir'},$read_input_dirs_l{$arr_el0_l}{'incorrect_input_dir'},'__');
		#$src_filename_l,$src_dir_l,$dst_dir_l,$dt_separator_l
		
		######
		%log_ops_input_l=(
        	    'INPUT_OP_TYPE'=>$arr_el0_l, 'INPUT_FILE_NAME'=>$dir_line_l,
        	    'INPUT_FILE_CREATE_DATETIME_epoch'=>$last_access_epoch_sec_l,
        	    'INV_HOST'=>'no', 'IPSET_TEMPLATE_NAME'=>'no',
		    'IPSET_NAME'=>'no', 'IPSET_TYPE_BY_TIME'=>'no',
		    'IPSET_TYPE'=>'no', 'RECORD'=>'no',
        	    'STATUS'=>"input file is not match with VER1/VER2/VER3 templates",
		);
		&write_local_ipset_input_log_ops($read_input_dirs_l{'history'},\%log_ops_input_l);
		#$history_log_dir_l,$input_params_href_l
		%log_ops_input_l=();
		######
		
		next; # if error for 'inv_host' at filename
    	    }
    	    ######
    	    
	    # if no error for 'inv_host' at filename / check ipset_temlate via 01_conf_ipset_templates
    	    if ( exists(${$ipset_templates_href_l}{'temporary'}{$input_ipset_template_name_l}) ) { $ipset_type_by_time_l='temporary'; }
	    elsif ( exists(${$ipset_templates_href_l}{'permanent'}{$input_ipset_template_name_l}) ) { $ipset_type_by_time_l='permanent'; }
	    else {
	    	&move_file_with_add_to_filename_datetime($input_file_name_l,$read_input_dirs_l{$arr_el0_l}{'input_dir'},$read_input_dirs_l{$arr_el0_l}{'incorrect_input_dir'},'__');
	    	#$src_filename_l,$src_dir_l,$dst_dir_l,$dt_separator_l
	    	    
	    	######
	    	%log_ops_input_l=(
    	    	    'INPUT_OP_TYPE'=>$arr_el0_l, 'INPUT_FILE_NAME'=>$input_file_name_l,
		    'INPUT_FILE_CREATE_DATETIME_epoch'=>$last_access_epoch_sec_l,
    	    	    'INV_HOST'=>$1, 'IPSET_TEMPLATE_NAME'=>$input_ipset_template_name_l,
    	    	    'IPSET_NAME'=>'no', 'IPSET_TYPE_BY_TIME'=>'no',
		    'IPSET_TYPE'=>'no', 'RECORD'=>'no',
    	    	    'STATUS'=>"ipset template is not exists at '01_conf_ipset_templates'",
	    	);
	    	&write_local_ipset_input_log_ops($read_input_dirs_l{'history'},\%log_ops_input_l);
	    	#$history_log_dir_l,$input_params_href_l
	    	%log_ops_input_l=();
	    	######
		
		next; # if error for 'ipset template' at filename
	    }
	    ###
	    
	    # no error for 'ipset template' at filename (after this line)
	    $ipset_name_l=${$ipset_templates_href_l}{$ipset_type_by_time_l}{$input_ipset_template_name_l}{'ipset_name'};
	    $ipset_type_l=${$ipset_templates_href_l}{$ipset_type_by_time_l}{$input_ipset_template_name_l}{'ipset_type'};
	    $ipset_create_option_family_l=${$ipset_templates_href_l}{$ipset_type_by_time_l}{$input_ipset_template_name_l}{'ipset_create_option_family'};
    	    
	    # read input file (begin)
	    open(INPUT_FILE,'<',$read_input_dirs_l{$arr_el0_l}{'input_dir'}.'/'.$input_file_name_l);
	    while ( <INPUT_FILE> ) {
		$file_line_l=$_;
		$file_line_l=~s/\n|\r//g;
		$file_line_l=~s/\s+/ /g;
		$file_line_l=~s/ //g;
		if ( $file_line_l!~/^\#/ ) {
		    $input_file_content_hash_l{$file_line_l}=0;
		}
	    }
	    close(INPUT_FILE);
	    
	    #clear vars
	    $file_line_l=undef;
	    ###
	    # read input file (end)
	    
	    # check for empty %input_file_content_hash_l
	    if ( scalar(keys %input_file_content_hash_l)<1 ) {
	    	&move_file_with_add_to_filename_datetime($input_file_name_l,$read_input_dirs_l{$arr_el0_l}{'input_dir'},$read_input_dirs_l{$arr_el0_l}{'incorrect_input_dir'},'__');
	    	#$src_filename_l,$src_dir_l,$dst_dir_l,$dt_separator_l

	    	######
	    	%log_ops_input_l=(
    	    	    'INPUT_OP_TYPE'=>$arr_el0_l, 'INPUT_FILE_NAME'=>$input_file_name_l,
		    'INPUT_FILE_CREATE_DATETIME_epoch'=>$last_access_epoch_sec_l,
    	    	    'INV_HOST'=>'no', 'IPSET_TEMPLATE_NAME'=>$input_ipset_template_name_l,
    	    	    'IPSET_NAME'=>$ipset_name_l, 'IPSET_TYPE_BY_TIME'=>$ipset_type_by_time_l,
		    'IPSET_TYPE'=>$ipset_type_l, 'RECORD'=>'no',
    	    	    'STATUS'=>'no content while read file',
	    	);
	    	&write_local_ipset_input_log_ops($read_input_dirs_l{'history'},\%log_ops_input_l);
	    	#$history_log_dir_l,$input_params_href_l
	    	%log_ops_input_l=();
	    	######

		next; # if no content
	    }
	    ###
	    
	    # fill %res_tmp_lv0_slice_l
	    #my %res_tmp_lv0_l=();
    	    	#key0=temporary/permanent;+inv-host;+ipset_template_name;+ipset_name;+ipset_entry (according to #ipset_type)
    	    	    # key1=add/del, value=[last_access_time_in_sec_epoch,$input_file_name_l,$ipset_type_l,$ipset_create_option_family_l,$expire_datetime_l]
	    foreach $arr_el1_l ( @input_inv_host_arr_l ) { # foreach @input_inv_host_arr_l (begin)
	    	#temporary/permanent=$ipset_type_by_time_l
	    	#inv-host=$arr_el1_l
	    	#$input_ipset_template_name_l
	    	#$ipset_name_l
	    	#del/add=$arr_el0_l
	    	#last_access_time_in_sec_epoch=$last_access_epoch_sec_l
	    	
	    	if ( !exists(${$h66_conf_ipsets_FIN_href_l}{$ipset_type_by_time_l}{$arr_el1_l}{$input_ipset_template_name_l}) ) {
	    	    ######
	    	    %log_ops_input_l=(
    	    		'INPUT_OP_TYPE'=>$arr_el0_l, 'INPUT_FILE_NAME'=>$input_file_name_l,
	    		'INPUT_FILE_CREATE_DATETIME_epoch'=>$last_access_epoch_sec_l,
    	    		'INV_HOST'=>$arr_el1_l, 'IPSET_TEMPLATE_NAME'=>$input_ipset_template_name_l,
    	    		'IPSET_NAME'=>$ipset_name_l, 'IPSET_TYPE_BY_TIME'=>$ipset_type_by_time_l,
	    		'IPSET_TYPE'=>$ipset_type_l, 'RECORD'=>'no',
    	    		'STATUS'=>"ipset_template_name is not configured for inv-host at '66_conf_ipsets_FIN'",
	    	    );
	    	    &write_local_ipset_input_log_ops($read_input_dirs_l{'history'},\%log_ops_input_l);
	    	    #$history_log_dir_l,$input_params_href_l
	    	    %log_ops_input_l=();
	    	    ######
	    	    
	    	    next;
	    	}
	    	
	    	# write records to %res_tmp_lv0_slice_l (begin)
	    	while ( ($hkey0_l,$hval0_l)=each %input_file_content_hash_l ) {
	    	    #$hkey0_l=ipset_record, $hval0_l=expire_datetime
		    
	    	    #FOR USE IN FUTURE
	    	    #&check_ipset_input($hkey0_l,$ipset_type_l,$ipset_create_option_family_l);
	    	    #$ipset_val_l,$ipset_type_l,$ipset_family_l
	    	    
		    if ( $hkey0_l=~/^(\S+)\;\+(\S+)$/ && $arr_el0_l eq 'add' ) { # add-operation. If temporary ipset entry or permanent with external timeout
		    	($ipset_entry_l,$expire_datetime_l)=($1,$2);
			if ( $expire_datetime_l=~/^\d{14}$/ ) { # if date format is correct
			    $input_file_content_hash_l{$ipset_entry_l}=$expire_datetime_l;
			    $ipset_record_is_ok_l=1;
			}
			else {
			    $ipset_record_is_ok_l=0;
			    
			    ######
	    		    %log_ops_input_l=(
    	    			'INPUT_OP_TYPE'=>$arr_el0_l, 'INPUT_FILE_NAME'=>$input_file_name_l,
	    			'INPUT_FILE_CREATE_DATETIME_epoch'=>$last_access_epoch_sec_l,
    	    			'INV_HOST'=>$arr_el1_l, 'IPSET_TEMPLATE_NAME'=>$input_ipset_template_name_l,
    	    			'IPSET_NAME'=>$ipset_name_l, 'IPSET_TYPE_BY_TIME'=>$ipset_type_by_time_l,
	    			'IPSET_TYPE'=>$ipset_type_l, 'RECORD'=>$hkey0_l,
    	    			'STATUS'=>'Expire_datetime is not correct',
	    		    );
	    		    &write_local_ipset_input_log_ops($read_input_dirs_l{'history'},\%log_ops_input_l);
	    		    #$history_log_dir_l,$input_params_href_l
	    		    %log_ops_input_l=();
	    		    ######
			}	
		    }
		    elsif ( $hkey0_l=~/^(\S+)\;\+(\S+)$/ && $arr_el0_l eq 'del' ) { # if exp-timeout is set, but this del-operation
			$ipset_entry_l=$1;
			$expire_datetime_l=0;
			$ipset_record_is_ok_l=1;
		    }
		    else {
		    	# other cases: if permanent ipset entry without external timeout (add/del), 
		    	# permanent with ext timeout, temporary ipsets (add with def timeout), temporary ipsets (del)
			$ipset_entry_l=$hkey0_l;
			$expire_datetime_l=0;
			$ipset_record_is_ok_l=1;
		    }
		    
		    if ( $ipset_record_is_ok_l==1 ) {
	    		######
	    		%log_ops_input_l=(
    	    		    'INPUT_OP_TYPE'=>$arr_el0_l, 'INPUT_FILE_NAME'=>$input_file_name_l,
	    		    'INPUT_FILE_CREATE_DATETIME_epoch'=>$last_access_epoch_sec_l,
    	    		    'INV_HOST'=>$arr_el1_l, 'IPSET_TEMPLATE_NAME'=>$input_ipset_template_name_l,
    	    		    'IPSET_NAME'=>$ipset_name_l, 'IPSET_TYPE_BY_TIME'=>$ipset_type_by_time_l,
	    		    'IPSET_TYPE'=>$ipset_type_l, 'RECORD'=>$hkey0_l,
    	    		    'STATUS'=>'OK',
	    		);
	    		&write_local_ipset_input_log_ops($read_input_dirs_l{'history'},\%log_ops_input_l);
	    		#$history_log_dir_l,$input_params_href_l
	    		%log_ops_input_l=();
	    		######
	    	
	    		$res_tmp_lv0_slice_l{$ipset_type_by_time_l.';+'.$arr_el1_l.';+'.$input_ipset_template_name_l.';+'.$ipset_name_l.';+'.$ipset_entry_l}{$arr_el0_l}=[$last_access_epoch_sec_l,$input_file_name_l,$ipset_type_l,$ipset_create_option_family_l,$expire_datetime_l];
		    }
		    
		    # clear vars
		    ($ipset_entry_l,$expire_datetime_l)=(undef,undef);
		    $ipset_record_is_ok_l=0;
		    ###
	    	}
		
		# clear vars
		($hkey0_l,$hval0_l)=(undef,undef);
		###
		
	    	# write records to %res_tmp_lv0_slice_l (end)
	    } # foreach @input_inv_host_arr_l (end)
	    ###
	    
	    # check if no added content to %res_tmp_lv0_slice_l for list of inv-hosts '@input_inv_host_arr_l'
	    if ( scalar(keys %res_tmp_lv0_slice_l)<1 ) {
	    	######
	    	%log_ops_input_l=(
    	    	    'INPUT_OP_TYPE'=>$arr_el0_l, 'INPUT_FILE_NAME'=>$input_file_name_l,
		    'INPUT_FILE_CREATE_DATETIME_epoch'=>$last_access_epoch_sec_l,
    	    	    'INV_HOST'=>'no', 'IPSET_TEMPLATE_NAME'=>$input_ipset_template_name_l,
    	    	    'IPSET_NAME'=>$ipset_name_l, 'IPSET_TYPE_BY_TIME'=>$ipset_type_by_time_l,
		    'IPSET_TYPE'=>$ipset_type_l, 'RECORD'=>'no',
    	    	    'STATUS'=>"no content after check ipset_template_name is in '66_conf_ipsets_FIN'",
	    	);
	    	&write_local_ipset_input_log_ops($read_input_dirs_l{'history'},\%log_ops_input_l);
	    	#$history_log_dir_l,$input_params_href_l
	    	%log_ops_input_l=();
	    	######
		
		next;
	    }
	    ###
	    
	    # add %res_tmp_lv0_slice_l to %res_tmp_lv0_l and clear %res_tmp_lv0_slice_l
	    %res_tmp_lv0_l=(%res_tmp_lv0_l,%res_tmp_lv0_slice_l);
	    %res_tmp_lv0_slice_l=();
	    ###
	    
	    # Move input file to correct-dir and write log (begin)
	    &move_file_with_add_to_filename_datetime($input_file_name_l,$read_input_dirs_l{$arr_el0_l}{'input_dir'},$read_input_dirs_l{$arr_el0_l}{'correct_input_dir'},'__');
	    #$src_filename_l,$src_dir_l,$dst_dir_l,$dt_separator_l
	    ######
	    %log_ops_input_l=(
    	    	'INPUT_OP_TYPE'=>$arr_el0_l, 'INPUT_FILE_NAME'=>$input_file_name_l,
		'INPUT_FILE_CREATE_DATETIME_epoch'=>$last_access_epoch_sec_l,
    	    	'INV_HOST'=>'no', 'IPSET_TEMPLATE_NAME'=>$input_ipset_template_name_l,
    	    	'IPSET_NAME'=>$ipset_name_l, 'IPSET_TYPE_BY_TIME'=>$ipset_type_by_time_l,
		'IPSET_TYPE'=>$ipset_type_l, 'RECORD'=>'no',
    	    	'STATUS'=>'OK',
	    );
	    &write_local_ipset_input_log_ops($read_input_dirs_l{'history'},\%log_ops_input_l);
	    #$history_log_dir_l,$input_params_href_l
	    %log_ops_input_l=();
	    ######
	    ### (end)
	    	    
    	    ###### clear vars
    	    $ipset_type_by_time_l=undef;
	    ($ipset_name_l,$ipset_type_l,$ipset_create_option_family_l)=(undef,undef,undef);
    	    ($dir_line_l,$input_file_name_l,$input_ipset_template_name_l)=(undef,undef,undef);
    	    @input_inv_host_arr_l=();
	    $last_access_epoch_sec_l=undef;
	    %log_ops_input_l=();
	    %input_file_content_hash_l=();
	    ######
    	} # readdir(DIR) end
    	closedir(DIR);
    } # foreach @read_input_seq_l (end)
    
    $arr_el0_l=undef;
    ###

    # check %res_tmp_lv0_l and fill %res_tmp_lv1_l
    while ( ($hkey0_l,$hval0_l)=each %res_tmp_lv0_l ) { # while %res_tmp_lv0_l (begin)
    	#$hkey0_l=temporary/permanent-0;+inv-host-1;+ipset_template_name-2;+ipset_name-3;+ipset_entry-4
    	#$hval0_l=hash-ref for "add/del=[last_access_time_in_sec_epoch-0,$input_file_name_l-1,$ipset_type_l-2,$ipset_create_option_family_l-3,$expire_datetime_l-4]"
    	@tmp_arr0_l=split(/\;\+/,$hkey0_l);
    	    	
    	if ( exists(${$hval0_l}{'add'}) && exists(${$hval0_l}{'del'}) ) {
    
    	    if ( ${${$hval0_l}{'add'}}[0] > ${${$hval0_l}{'del'}}[0] ) {
    		######
    		%log_ops_input_l=(
    	    	    'INPUT_OP_TYPE'=>'del', 'INPUT_FILE_NAME'=>${${$hval0_l}{'del'}}[1],
    		    'INPUT_FILE_CREATE_DATETIME_epoch'=>${${$hval0_l}{'del'}}[0],
    	    	    'INV_HOST'=>$tmp_arr0_l[1], 'IPSET_TEMPLATE_NAME'=>$tmp_arr0_l[2],
    	    	    'IPSET_NAME'=>$tmp_arr0_l[3], 'IPSET_TYPE_BY_TIME'=>$tmp_arr0_l[0],
    		    'IPSET_TYPE'=>${${$hval0_l}{'del'}}[2], 'RECORD'=>$tmp_arr0_l[4],
    	    	    'STATUS'=>"OK. Del operation is skipped because del:INPUT_FILE_CREATE_DATETIME < add:INPUT_FILE_CREATE_DATETIME",
    		);
    		&write_local_ipset_input_log_ops($read_input_dirs_l{'history'},\%log_ops_input_l);
    		#$history_log_dir_l,$input_params_href_l
    		%log_ops_input_l=();
    		######
    		
    		delete(${$hval0_l}{'del'});
    	    }
    	    elsif ( ${${$hval0_l}{'del'}}[0] > ${${$hval0_l}{'add'}}[0] ) {
    		######
    		%log_ops_input_l=(
    	    	    'INPUT_OP_TYPE'=>'add', 'INPUT_FILE_NAME'=>${${$hval0_l}{'add'}}[1],
    		    'INPUT_FILE_CREATE_DATETIME_epoch'=>${${$hval0_l}{'add'}}[0],
    	    	    'INV_HOST'=>$tmp_arr0_l[1], 'IPSET_TEMPLATE_NAME'=>$tmp_arr0_l[2],
    	    	    'IPSET_NAME'=>$tmp_arr0_l[3], 'IPSET_TYPE_BY_TIME'=>$tmp_arr0_l[0],
    		    'IPSET_TYPE'=>${${$hval0_l}{'add'}}[2], 'RECORD'=>$tmp_arr0_l[4],
    	    	    'STATUS'=>"OK. Add operation is skipped because add:INPUT_FILE_CREATE_DATETIME < del:INPUT_FILE_CREATE_DATETIME",
    		);
    		&write_local_ipset_input_log_ops($read_input_dirs_l{'history'},\%log_ops_input_l);
    		#$history_log_dir_l,$input_params_href_l
    		%log_ops_input_l=();
    		######
    		
    		delete(${$hval0_l}{'add'});
    	    }
    	    elsif ( ${${$hval0_l}{'del'}}[0]==${${$hval0_l}{'add'}}[0] ) {
    		######
    		%log_ops_input_l=(
    	    	    'INPUT_OP_TYPE'=>'add', 'INPUT_FILE_NAME'=>${${$hval0_l}{'add'}}[1],
    		    'INPUT_FILE_CREATE_DATETIME_epoch'=>${${$hval0_l}{'add'}}[0],
    	    	    'INV_HOST'=>$tmp_arr0_l[1], 'IPSET_TEMPLATE_NAME'=>$tmp_arr0_l[2],
    	    	    'IPSET_NAME'=>$tmp_arr0_l[3], 'IPSET_TYPE_BY_TIME'=>$tmp_arr0_l[0],
    		    'IPSET_TYPE'=>${${$hval0_l}{'add'}}[2], 'RECORD'=>$tmp_arr0_l[4],
    	    	    'STATUS'=>"OK. Add operation is skipped because add:INPUT_FILE_CREATE_DATETIME = del:INPUT_FILE_CREATE_DATETIME",
    		);
    		&write_local_ipset_input_log_ops($read_input_dirs_l{'history'},\%log_ops_input_l);
    		#$history_log_dir_l,$input_params_href_l
    		%log_ops_input_l=();
    		######
    
    		delete(${$hval0_l}{'add'});
    	    }
    	}
    	
    	while ( ($hkey1_l,$hval1_l)=each %{$hval0_l} ) { # while %res_tmp_lv0_l -> %{$hval0_l} (begin)
    	    #hkey1_l=add/del, hval1_l=arr-ref for [last_access_time_in_sec_epoch-0,$input_file_name_l-1,$ipset_type_l-2,$ipset_create_option_family_l-3,$expire_datetime_l-4]
    	    
    	    ######
    	    %log_ops_input_l=(
    	    	'INPUT_OP_TYPE'=>$hkey1_l, 'INPUT_FILE_NAME'=>${$hval1_l}[1],
    		'INPUT_FILE_CREATE_DATETIME_epoch'=>${$hval1_l}[0],
    	    	'INV_HOST'=>$tmp_arr0_l[1], 'IPSET_TEMPLATE_NAME'=>$tmp_arr0_l[2],
    	    	'IPSET_NAME'=>$tmp_arr0_l[3], 'IPSET_TYPE_BY_TIME'=>$tmp_arr0_l[0],
    		'IPSET_TYPE'=>${$hval1_l}[2], 'RECORD'=>$tmp_arr0_l[4],
    	    	'STATUS'=>'OK',
    	    );
    	    &write_local_ipset_input_log_ops($read_input_dirs_l{'history'},\%log_ops_input_l);
    	    #$history_log_dir_l,$input_params_href_l
    	    %log_ops_input_l=();
    	    ######
    	    
    	    #my %res_tmp_lv1_l=(); # like %ipset_input_l
            #key0=permanent/temporary,key1=inv-host;+ipset_template_name;+ipset_name ->
                #key2=add/del,key3=ipset_entry (according to #ipset_type), value=$expire_datetime_l (0 or datetime)
    	    $res_tmp_lv1_l{$tmp_arr0_l[0]}{$tmp_arr0_l[1].';+'.$tmp_arr0_l[2].';+'.$tmp_arr0_l[3]}{$hkey1_l}{$tmp_arr0_l[4]}=${$hval1_l}[4];
    	} # while %res_tmp_lv0_l -> %{$hval0_l} (end)
    } # while %res_tmp_lv0_l (end)
    ###

    # fill result hash
    %{$res_href_l}=%res_tmp_lv1_l;
    ###
            
    %res_tmp_lv1_l=();
        
    return $return_str_l;
}

sub update_initial_content_for_local_ipset_actual_data {
    my ($ipset_actual_data_dir_l,$h65_conf_initial_ipsets_content_FIN_href_l)=@_;
    #$ipset_actual_data_dir_l=$ipset_actual_data_dir_g
    #$h65_conf_initial_ipsets_content_FIN_hash_g{inv-host}{ipset_template_name}->
        #{'record-0'}=1 (record=ipset_entry)
        #{'rerord-1'}=1
        #etc
        #{'seq'}=[val-0,val-1] (val=record)
    
    my $proc_name_l=(caller(0))[3];
    
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my ($hkey1_l,$hval1_l)=(undef,undef);
    my ($hkey2_l,$hval2_l)=(undef,undef);
    my ($init_content_file_path_now4add_l,$init_content_file_path_now4del_l,$init_content_file_path_prev4add_l)=(undef,undef,undef);
    my @tmp_arr0_l=();
    my %prev4add_content_l=();
	#key=ipset_entry, value=1
    
    while ( ($hkey0_l,$hval0_l)=each %{$h65_conf_initial_ipsets_content_FIN_href_l} ) { # cycle with key=inv-host (begin)
    	#$hkey0_l=inv-host
    	
    	while ( ($hkey1_l,$hval1_l)=each %{$hval0_l} ) { # cycle with key=ipset_template_name (begin)
    	    #$hkey1_l=ipset_template_name
    	    
    	    $init_content_file_path_now4add_l=$ipset_actual_data_dir_l.'/'.$hkey0_l.'/permanent/'.$hkey1_l.'/initial_content/now4add';
    	    $init_content_file_path_now4del_l=$ipset_actual_data_dir_l.'/'.$hkey0_l.'/permanent/'.$hkey1_l.'/initial_content/now4del';
    	    $init_content_file_path_prev4add_l=$ipset_actual_data_dir_l.'/'.$hkey0_l.'/permanent/'.$hkey1_l.'/initial_content/prev4add';
    	    
    	    if ( -f($init_content_file_path_now4del_l) ) { unlink $init_content_file_path_now4del_l; }
    	    if ( -f($init_content_file_path_prev4add_l) ) { unlink $init_content_file_path_prev4add_l; }
    	    if ( -f($init_content_file_path_now4add_l) ) { rename($init_content_file_path_now4add_l,$init_content_file_path_prev4add_l); }
    	    
    	    &read_lines_without_comments_of_file_to_hash($init_content_file_path_prev4add_l,\%prev4add_content_l);
    	    #$file_l,$href_l
    	    
    	    # form content of $init_content_file_path_now4del_l (if need)
    	    while ( ($hkey2_l,$hval2_l)=each %prev4add_content_l ) {
    		#$hkey2_l=ipset-entry fromn prev4add
    		
    		if ( !exists(${$hval1_l}{$hkey2_l}) ) {
    		    push(@tmp_arr0_l,$hkey2_l); # form content of new $init_content_file_path_now4del_l
    		}
    	    }
    	    
    	    if ( $#tmp_arr0_l!=-1 ) {
    		&rewrite_file_from_array_ref($init_content_file_path_now4del_l,\@tmp_arr0_l);
    		#$file_l,$aref_l
    	    }
    	    ###
    	    
    	    if ( $#{${$hval1_l}{'seq'}}!=-1 ) {
    		&rewrite_file_from_array_ref($init_content_file_path_now4add_l,\@{${$hval1_l}{'seq'}});
    		#$file_l,$aref_l
    	    }
    	    	    
    	    # clear vars
    	    ($init_content_file_path_now4add_l,$init_content_file_path_now4del_l,$init_content_file_path_prev4add_l)=(undef,undef,undef);
    	    @tmp_arr0_l=();
    	    %prev4add_content_l=();
    	    ###
    	} # cycle with key=ipset_template_name (end)
    	
    	($hkey1_l,$hval1_l)=(undef,undef); # clear vars
    	###
    } # cycle with key=inv-host (end)
    
    ($hkey0_l,$hval0_l)=(undef,undef); # clear vars
    ###

    my $return_str_l='OK';
    
    return $return_str_l;
}

sub update_local_ipset_actual_data {
    my ($ipset_actual_data_dir_l,$ipset_input_href_l,$inv_hosts_href_l,$ipset_templates_href_l,$h65_conf_initial_ipsets_content_FIN_href_l,$h66_conf_ipsets_FIN_href_l)=@_;
    #$ipset_actual_data_dir_l=$ipset_actual_data_dir_g
    #$ipset_input_href_l=hash-ref for %ipset_input_l
	#key0=permanent/temporary,key1=inv-host;+ipset_template_name;+ipset_name ->
            #key2=add/del,key3=ipset_entry (according to #ipset_type), value=$expire_datetime_l
    #inv_hosts_href_l=hash-ref for %inventory_hosts_g
    #$ipset_templates_href_l=hash-ref for %h01_conf_ipset_templates_hash_g
	#$h01_conf_ipset_templates_hash_g{'temporary/permanent'}{ipset_template_name--TMPLT}->
        #{'ipset_name'}=value
    #$h65_conf_initial_ipsets_content_FIN_hash_g{inv-host}{ipset_template_name}->
        #{'record-0'}=1 (record=ipset_entry)
        #{'rerord-1'}=1
        #etc
        #{'seq'}=[val-0,val-1] (val=record)
    #$h66_conf_ipsets_FIN_href_l=hash-ref for \%h66_conf_ipsets_FIN_hash_g
	#$h66_conf_ipsets_FIN_hash_g{'temporary/permanent'}{inventory_host}->
            #{ipset_name_tmplt-0}=1;
            #{ipset_name_tmplt-1}=1;
            #etc

    #Directory structure
    #...ipset_actual_data/inv-host/... (dir)
    	    #permanent/ipset_template_name/... (dir)
        	#actual__ipset_name.txt (file)
            	    # First line - description like "###You CAN manually ADD entries to this file!".
            	    # Second line - "datetime of creation" + "ipset_type" in the format "###YYYYMMDDHHMISS;+IPSET_TYPE".
		    # One line - one record with ipset_entry or record in format "ipset_entry;+expire_datetime".
            	    # Ipset_entry must match the ipset type (according to #ipset_type at the conf-file "01_conf_ipset_templates").
            	    # Expire datetime has the format "YYYYMMDDHHMISS".
            	    # The expire_date mechanism is external. That is, WITHOUT using ipset timeouts on the remote side.
            	    # This file can be used to recreate the set if it was deleted (for some reason) on the side of the inventory host.
            	    # You can manually add entries (according to ipset_type) to this file.
        	#/change_history/ (dir)
            	    #CHANGE_DATETIME__ipset_name.txt (file)
                	# For move "actual__ipset_name.txt" here (to this dir) with rename if changed ipset_name or ipset_type.
                	# First line - "datetime of creation;+datetime of change" + "old_ipset_type;+new_ipset_type" + "old_ipset_name;+new_ipset_name"
                    	    # in the format "###YYYYMMDDHHMISS(CREATE_DATE);+YYYYMMDDHHMISS(CHANGE_DATE);+OLD_IPSET_TYPE;+NEW_IPSET_TYPE;+OLD_IPSET_NAME;+NEW_IPSET_NAME".

    	    #temporary/ipset_template_name/.. (dir)
        	#actual__ipset_name.txt (file)
            	    # First line - description like "###Manually ADDING entries to this file is DENIED!".
            	    # Second line - "datetime of creation" + "ipset_type" in the format "###YYYYMMDDHHMISS;+IPSET_TYPE".
		    # One line - one record in format "ipset_entry;+expire_datetime".
            	    # Ipset_entry must match the ipset type (according to #ipset_type at the conf-file "01_conf_ipset_templates").
            	    # Expire datetime has the format "YYYYMMDDHHMISS".
		    # The expire_date mechanism is internal. That is, WITH using ipset timeouts on the remote side.
            	    # Expire date when adding an element to ipset via "ipset_input/add" is calculated as follows - current date + #ipset_create_option_timeout.
		    # You can manually add entries (according to ipset_type) to this file.
        	#/change_history/ (dir)
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
    my $proc_name_l=(caller(0))[3];
    
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my ($hkey1_l,$hval1_l)=(undef,undef);
    my ($hkey2_l,$hval2_l)=(undef,undef);
    my ($inv_host_dir_line_l,$ipset_tmplt_name_dir_line_l)=(undef,undef);
    my $tmp_var_l=undef;
    
    my ($ipset_actual_permanent_dir_l,$ipset_actual_temporary_dir_l)=(undef,undef);
    
    my $ipset_create_date_actual_l=undef; # for date from 'actual__*'-file
    my ($file_ipset_name_actual_l,$ipset_name_actual_l,$ipset_type_actual_l)=(undef,undef,undef);
    my ($file_ipset_name_cfg_l,$ipset_name_cfg_l,$ipset_type_cfg_l)=(undef,undef);
    my $file_ipset_name_ch_hist_l=undef;
    my $change_hist_1line_l=undef;
    
    my ($init_content_file_path_now4add_l,$init_content_file_path_now4del_l)=(undef,undef); # for correct actual-file-data from '65_conf_initial_ipsets_content_FIN' as source
    
    my @tmp_arr0_l=();
    
    my %tmp_hash0_l=();
    
    my $dt_now_l=undef;
    
    my $ipset_actual_file_path_l=undef;

    my $return_str_l='OK';
    
    ###
    # for fill at one iteration, write data to %ipset_actual_files_composition_hash and clear
    my %ipset_actual_file_data_hash_l=(); # for fill content for each inv-host+ipset-tmplt-name+ipset-name and rewrite actual*-file
    # key0=content, key1=entry, value=expire_date (if=0 -> permanent ipset)
    # or key0=info, value=[array of info strings]
    ###
    
    my %ipset_actual_files_composition_hash_l=();
    # key0=$ipset_actual_file_path_l
	#key1A='ipset_file_type': 0-permanent, 1-temporary
	#key1B='subhash' (%ipset_actual_file_data_hash_l)
    
    my $expire_date_actual_l=undef; # for $ipset_actual_file_data_hash_l{'content'}{ipset_entry}=expire_date_actual
    my $expire_date_calculated_l=undef; # for expire_date (for temporary ipset) calculated by adding #ipset_create_option_timeout to current-date
    my ($expire_epoch_sec_actual_l,$expire_epoch_sec_calculated_l)=(undef,undef);
    
    # ipset_actual_data write history operations (BEGIN)
    opendir(DIR,$ipset_actual_data_dir_l);
    
    while ( readdir(DIR) ) { # readdir(DIR) begin
	$inv_host_dir_line_l=$_;
        if ( $inv_host_dir_line_l=~/^\.|^info/ or !-d($ipset_actual_data_dir_l.'/'.$inv_host_dir_line_l) ) { next; }
	
	if ( !exists(${$inv_hosts_href_l}{$inv_host_dir_line_l}) ) {
	    system("echo '$inv_host_dir_line_l is not exists at inventory' > $ipset_actual_data_dir_l/$inv_host_dir_line_l/info");
	    
	    next;
	}
	
	if ( !exists(${$h66_conf_ipsets_FIN_href_l}{'permanent'}{$inv_host_dir_line_l}) && !exists(${$h66_conf_ipsets_FIN_href_l}{'temporary'}{$inv_host_dir_line_l}) ) {
	    system("echo '$inv_host_dir_line_l is not configured at 66_conf_ipsets_FIN' > $ipset_actual_data_dir_l/$inv_host_dir_line_l/info");
	    
	    next;
	}
	
	# read inv-host/permanent dir (BEGIN)
	if ( -d($ipset_actual_data_dir_l.'/'.$inv_host_dir_line_l.'/permanent') ) {
	    $ipset_actual_permanent_dir_l=$ipset_actual_data_dir_l.'/'.$inv_host_dir_line_l.'/permanent';
	    opendir(DIR_P,$ipset_actual_permanent_dir_l);
	    
	    while ( readdir(DIR_P) ) { # while readdir DIR_P (BEGIN)
	    	$ipset_tmplt_name_dir_line_l=$_;
	    	if ( $ipset_tmplt_name_dir_line_l=~/^\.|^info/ or !-d($ipset_actual_permanent_dir_l.'/'.$ipset_tmplt_name_dir_line_l) ) { next; }
	    	
		# if existing dir (with name=permanent template name) is not configured at '01_conf_ipset_templates'
	    	if ( !exists(${$ipset_templates_href_l}{'permanent'}{$ipset_tmplt_name_dir_line_l}) ) {	    
		    # create info-file at $ipset_actual_permanent_dir_l/$ipset_tmplt_name_dir_line_l
	    	    system("echo '$ipset_tmplt_name_dir_line_l is not configured at 01_conf_ipset_templates' > $ipset_actual_permanent_dir_l/$ipset_tmplt_name_dir_line_l/info");
		    # move dir $ipset_actual_permanent_dir_l/$ipset_tmplt_name_dir_line_l to delete_history
	    	    system("mv $ipset_actual_permanent_dir_l/$ipset_tmplt_name_dir_line_l $ipset_actual_data_dir_l/$inv_host_dir_line_l/delete_history/permanent/");
	    	    
	    	    # move to delete_history
	    	    $tmp_var_l=get_dt_yyyymmddhhmmss();
	    	    system("mv $ipset_actual_data_dir_l/$inv_host_dir_line_l/delete_history/permanent/$ipset_tmplt_name_dir_line_l $ipset_actual_data_dir_l/$inv_host_dir_line_l/delete_history/permanent/$tmp_var_l-$ipset_tmplt_name_dir_line_l");
	    	    $tmp_var_l=undef;
	    	    ###
	    	    
	    	    next;
	    	}
		###
	    	
		# if existing dir (with name=permanent template name) is not configured at '66_conf_ipsets_FIN' for inv-host ($inv_host_dir_line_l)
	    	if ( !exists(${$h66_conf_ipsets_FIN_href_l}{'permanent'}{$inv_host_dir_line_l}{$ipset_tmplt_name_dir_line_l}) ) {
	    	    system("echo '$ipset_tmplt_name_dir_line_l for $inv_host_dir_line_l is not configured at 66_conf_ipsets_FIN' > $ipset_actual_permanent_dir_l/$ipset_tmplt_name_dir_line_l/info");
	    	    
	    	    next;
	    	}
		###
	    	
	    	# get ipset_name from 'actual__*'-file
	    	$file_ipset_name_actual_l=`ls $ipset_actual_permanent_dir_l/$ipset_tmplt_name_dir_line_l | grep actual__`;
	    	$file_ipset_name_actual_l=~s/\n$|\r$|\n\r$|\r\n$//g;
	    	$ipset_name_actual_l=$file_ipset_name_actual_l;
	    	$ipset_name_actual_l=~s/^actual__|\.txt$//g;
	    	###
	    	
	    	# get ipset_type from 'actual__*'-file
	    	$tmp_var_l=`sed -n '2p' $ipset_actual_permanent_dir_l/$ipset_tmplt_name_dir_line_l/$file_ipset_name_actual_l`;
	    	$tmp_var_l=~s/\n$|\r$|\n\r$|\r\n$//g;
		($ipset_create_date_actual_l,$ipset_type_actual_l)=$tmp_var_l=~/^\#\#\#(\S+)\;\+(\S+)$/;
	    	$tmp_var_l=undef;
	    	###
	    
	    	# get ipset_name and ipset_type from CFG
	    	$ipset_name_cfg_l=${$ipset_templates_href_l}{'permanent'}{$ipset_tmplt_name_dir_line_l}{'ipset_name'};
	    	$ipset_type_cfg_l=${$ipset_templates_href_l}{'permanent'}{$ipset_tmplt_name_dir_line_l}{'ipset_type'};
	    	###
	    	
	    	# check for changed ipset_name and/or ipset_type (BEGIN)
	    	if ( $ipset_type_actual_l ne $ipset_type_cfg_l ) {
		    # no need to copy ipset_content because different ipset types incompatible with each other
		    
		    $dt_now_l=&get_dt_yyyymmddhhmmss();
		    
		    # move 'actual__*'-file to change_history + modify name of file (from actual to change_history-format) and first lines at moved file
		    $file_ipset_name_ch_hist_l=$dt_now_l.'__'.$ipset_name_actual_l.'.txt';
		    
		    system("mv $ipset_actual_permanent_dir_l/$ipset_tmplt_name_dir_line_l/$file_ipset_name_actual_l $ipset_actual_permanent_dir_l/$ipset_tmplt_name_dir_line_l/change_history/$file_ipset_name_actual_l");
		    
		    system("sed -i 1d $ipset_actual_permanent_dir_l/$ipset_tmplt_name_dir_line_l/change_history/$file_ipset_name_actual_l");
		    system("sed -i 1d $ipset_actual_permanent_dir_l/$ipset_tmplt_name_dir_line_l/change_history/$file_ipset_name_actual_l");
		    
		    $change_hist_1line_l="###$ipset_create_date_actual_l;+$dt_now_l;+$ipset_type_actual_l;+$ipset_type_cfg_l;+$ipset_name_actual_l;+$ipset_name_cfg_l";
		    system("echo ' ' >> $ipset_actual_permanent_dir_l/$ipset_tmplt_name_dir_line_l/change_history/$file_ipset_name_actual_l");
		    system("sed -i '1i $change_hist_1line_l' $ipset_actual_permanent_dir_l/$ipset_tmplt_name_dir_line_l/change_history/$file_ipset_name_actual_l");
		    
	    	    if ( $ipset_name_actual_l ne $ipset_name_cfg_l ) { 
		    	# if need to fix ipset_name changing after move 'actual__*'-file to change_history
			$file_ipset_name_ch_hist_l=$dt_now_l.'__'.$ipset_name_cfg_l.'.txt';
		    }
		    
		    system("mv $ipset_actual_permanent_dir_l/$ipset_tmplt_name_dir_line_l/change_history/$file_ipset_name_actual_l $ipset_actual_permanent_dir_l/$ipset_tmplt_name_dir_line_l/change_history/$file_ipset_name_ch_hist_l");
		    
		    $file_ipset_name_ch_hist_l=undef;
		    $change_hist_1line_l=undef;
                    ###
		    		    		    
		    # create new empty 'actual__*'-file
		    $file_ipset_name_cfg_l='actual__'.$ipset_name_cfg_l.'.txt';
		    @tmp_arr0_l=('###You CAN manually ADD entries to this file!',"###$dt_now_l;+$ipset_type_cfg_l");
                    &rewrite_file_from_array_ref($ipset_actual_permanent_dir_l.'/'.$ipset_tmplt_name_dir_line_l.'/'.$file_ipset_name_cfg_l,\@tmp_arr0_l);
                    #$file_l,$aref_l
		    
                    @tmp_arr0_l=();
		    $file_ipset_name_cfg_l=undef;
		    ###
		    
		    $dt_now_l=undef;
	    	}
		else { # need to copy content from old file to new
		    if ( $ipset_name_actual_l ne $ipset_name_cfg_l ) { # if need to fix ipset_name changing only
			$dt_now_l=&get_dt_yyyymmddhhmmss();
			
			# copy 'actual__*'-file to change_history + modify name of file (from actual to change_history-format) and first lines at copied file
			$file_ipset_name_ch_hist_l=$dt_now_l.'__'.$ipset_name_cfg_l.'.txt';
			
			system("cp $ipset_actual_permanent_dir_l/$ipset_tmplt_name_dir_line_l/$file_ipset_name_actual_l $ipset_actual_permanent_dir_l/$ipset_tmplt_name_dir_line_l/change_history/$file_ipset_name_actual_l");
			
			system("sed -i 1d $ipset_actual_permanent_dir_l/$ipset_tmplt_name_dir_line_l/change_history/$file_ipset_name_actual_l");
			system("sed -i 1d $ipset_actual_permanent_dir_l/$ipset_tmplt_name_dir_line_l/change_history/$file_ipset_name_actual_l");
			
			$change_hist_1line_l="###$ipset_create_date_actual_l;+$dt_now_l;+$ipset_type_actual_l;+$ipset_type_cfg_l;+$ipset_name_actual_l;+$ipset_name_cfg_l";
			system("echo ' ' >> $ipset_actual_permanent_dir_l/$ipset_tmplt_name_dir_line_l/change_history/$file_ipset_name_actual_l");
			system("sed -i '1i $change_hist_1line_l' $ipset_actual_permanent_dir_l/$ipset_tmplt_name_dir_line_l/change_history/$file_ipset_name_actual_l");
			
			system("mv $ipset_actual_permanent_dir_l/$ipset_tmplt_name_dir_line_l/change_history/$file_ipset_name_actual_l $ipset_actual_permanent_dir_l/$ipset_tmplt_name_dir_line_l/change_history/$file_ipset_name_ch_hist_l");
			
			$file_ipset_name_ch_hist_l=undef;
			$change_hist_1line_l=undef;
			###
			
			# rename 'actual__*'-file
			$file_ipset_name_cfg_l='actual__'.$ipset_name_cfg_l.'.txt';
			system("mv $ipset_actual_permanent_dir_l/$ipset_tmplt_name_dir_line_l/$file_ipset_name_actual_l $ipset_actual_permanent_dir_l/$ipset_tmplt_name_dir_line_l/$file_ipset_name_cfg_l");
			
			$file_ipset_name_cfg_l=undef;
			###
			
			$dt_now_l=undef;
		    }
		}
	    	# check for changed ipset_name and/or ipset_type (END)
	    	
	    	# clear vars
	    	$ipset_tmplt_name_dir_line_l=undef;
		$ipset_create_date_actual_l=undef;
	    	($file_ipset_name_actual_l,$ipset_name_actual_l,$ipset_type_actual_l)=(undef,undef,undef);
	    	($ipset_name_cfg_l,$ipset_type_cfg_l)=(undef,undef);
	    	###
	    } # while readdir DIR_P (END)
	    
	    closedir(DIR_P);
	    
	    # clear vars
	    $ipset_actual_permanent_dir_l=undef;
	    ###
	}
	# read inv-host/permanent dir (END)
	
	# read inv-host/temporary dir (BEGIN)
	if ( -d($ipset_actual_data_dir_l.'/'.$inv_host_dir_line_l.'/temporary') ) {
	    $ipset_actual_temporary_dir_l=$ipset_actual_data_dir_l.'/'.$inv_host_dir_line_l.'/temporary';
	    opendir(DIR_T,$ipset_actual_temporary_dir_l);
	    
	    while ( readdir(DIR_T) ) { # while readdir DIR_T (BEGIN)
	    	$ipset_tmplt_name_dir_line_l=$_;
	    	if ( $ipset_tmplt_name_dir_line_l=~/^\.|^info/ or !-d($ipset_actual_temporary_dir_l.'/'.$ipset_tmplt_name_dir_line_l) ) { next; }
	    	
		# if existing dir (with name=temporary template name) is not configured at '01_conf_ipset_templates'
	    	if ( !exists(${$ipset_templates_href_l}{'temporary'}{$ipset_tmplt_name_dir_line_l}) ) {
	    	    # create info-file at $ipset_actual_temporary_dir_l/$ipset_tmplt_name_dir_line_l
	    	    system("echo '$ipset_tmplt_name_dir_line_l is not configured at 01_conf_ipset_templates' > $ipset_actual_temporary_dir_l/$ipset_tmplt_name_dir_line_l/info");
	    	    # move dir $ipset_actual_temporary_dir_l/$ipset_tmplt_name_dir_line_l to delete_history
	    	    system("mv $ipset_actual_temporary_dir_l/$ipset_tmplt_name_dir_line_l $ipset_actual_data_dir_l/$inv_host_dir_line_l/delete_history/temporary/");
	    	    
	    	    # move to delete_history
	    	    $tmp_var_l=get_dt_yyyymmddhhmmss();
	    	    system("mv $ipset_actual_data_dir_l/$inv_host_dir_line_l/delete_history/temporary/$ipset_tmplt_name_dir_line_l $ipset_actual_data_dir_l/$inv_host_dir_line_l/delete_history/temporary/$tmp_var_l-$ipset_tmplt_name_dir_line_l");
	    	    $tmp_var_l=undef;
	    	    ###
	    	    
	    	    next;
	    	}
		###
		
		# if existing dir (with name=temporary template name) is not configured at '66_conf_ipsets_FIN' for inv-host ($inv_host_dir_line_l)
	    	if ( !exists(${$h66_conf_ipsets_FIN_href_l}{'temporary'}{$inv_host_dir_line_l}{$ipset_tmplt_name_dir_line_l}) ) {
	    	    system("echo '$ipset_tmplt_name_dir_line_l for $inv_host_dir_line_l is not configured at 66_conf_ipsets_FIN' > $ipset_actual_temporary_dir_l/$ipset_tmplt_name_dir_line_l/info");
	    	    
	    	    next;
	    	}
		###
	    
	    	# get ipset_name from 'actual__*'-file
	    	$file_ipset_name_actual_l=`ls $ipset_actual_temporary_dir_l/$ipset_tmplt_name_dir_line_l | grep actual__`;
	    	$file_ipset_name_actual_l=~s/\n$|\r$|\n\r$|\r\n$//g;
	    	$ipset_name_actual_l=$file_ipset_name_actual_l;
	    	$ipset_name_actual_l=~s/^actual__|\.txt$//g;
	    	###
	    
	    	# get ipset_type from 'actual__*'-file
	    	$tmp_var_l=`sed -n '2p' $ipset_actual_temporary_dir_l/$ipset_tmplt_name_dir_line_l/$file_ipset_name_actual_l`;
	    	$tmp_var_l=~s/\n$|\r$|\n\r$|\r\n$//g;
	    	($ipset_create_date_actual_l,$ipset_type_actual_l)=$tmp_var_l=~/^\#\#\#(\S+)\;\+(\S+)$/;
	    	$tmp_var_l=undef;
	    	###
	    	
	    	# get ipset_name and ipset_type from CFG
	    	$ipset_name_cfg_l=${$ipset_templates_href_l}{'temporary'}{$ipset_tmplt_name_dir_line_l}{'ipset_name'};
	    	$ipset_type_cfg_l=${$ipset_templates_href_l}{'temporary'}{$ipset_tmplt_name_dir_line_l}{'ipset_type'};
	    	###
	    	
	    	# check for changed ipset_name and/or ipset_type (BEGIN)
	    	if ( $ipset_type_actual_l ne $ipset_type_cfg_l ) {
	    	    # no need to copy ipset_content because different different ipset types incompatible with each other
	    	    
	    	    $dt_now_l=&get_dt_yyyymmddhhmmss();
	    	    
	    	    # move 'actual__*'-file to change_history + modify name of file (from actual to change_history-format) and first lines at moved file
	    	    $file_ipset_name_ch_hist_l=$dt_now_l.'__'.$ipset_name_actual_l.'.txt';
	    	    
	    	    system("mv $ipset_actual_temporary_dir_l/$ipset_tmplt_name_dir_line_l/$file_ipset_name_actual_l $ipset_actual_temporary_dir_l/$ipset_tmplt_name_dir_line_l/change_history/$file_ipset_name_actual_l");
	    	    
	    	    system("sed -i 1d $ipset_actual_temporary_dir_l/$ipset_tmplt_name_dir_line_l/change_history/$file_ipset_name_actual_l");
	    	    system("sed -i 1d $ipset_actual_temporary_dir_l/$ipset_tmplt_name_dir_line_l/change_history/$file_ipset_name_actual_l");
	    	    
	    	    $change_hist_1line_l="###$ipset_create_date_actual_l;+$dt_now_l;+$ipset_type_actual_l;+$ipset_type_cfg_l;+$ipset_name_actual_l;+$ipset_name_cfg_l";
	    	    system("echo ' ' >> $ipset_actual_temporary_dir_l/$ipset_tmplt_name_dir_line_l/change_history/$file_ipset_name_actual_l");
	    	    system("sed -i '1i $change_hist_1line_l' $ipset_actual_temporary_dir_l/$ipset_tmplt_name_dir_line_l/change_history/$file_ipset_name_actual_l");
	    	    
	    	    if ( $ipset_name_actual_l ne $ipset_name_cfg_l ) { 
	    	    	# if need to fix ipset_name changing after move 'actual__*'-file to change_history
	    		$file_ipset_name_ch_hist_l=$dt_now_l.'__'.$ipset_name_cfg_l.'.txt';
	    	    }
	    	    
	    	    system("mv $ipset_actual_temporary_dir_l/$ipset_tmplt_name_dir_line_l/change_history/$file_ipset_name_actual_l $ipset_actual_temporary_dir_l/$ipset_tmplt_name_dir_line_l/change_history/$file_ipset_name_ch_hist_l");
	    	    
	    	    $file_ipset_name_ch_hist_l=undef;
	    	    $change_hist_1line_l=undef;
	    	    ###
	    	    
	    	    # create new empty 'actual__*'-file
	    	    $file_ipset_name_cfg_l='actual__'.$ipset_name_cfg_l.'.txt';
	    	    @tmp_arr0_l=('###Manually ADDING entries to this file is DENIED!',"###$dt_now_l;+$ipset_type_cfg_l");
                    &rewrite_file_from_array_ref($ipset_actual_temporary_dir_l.'/'.$ipset_tmplt_name_dir_line_l.'/'.$file_ipset_name_cfg_l,\@tmp_arr0_l);
                    #$file_l,$aref_l
	    	    
                    @tmp_arr0_l=();
	    	    $file_ipset_name_cfg_l=undef;
	    	    ###
	    	    
	    	    $dt_now_l=undef;
	    	}
	    	else { # need to copy content from old file to new
	    	    if ( $ipset_name_actual_l ne $ipset_name_cfg_l ) { # if need to fix ipset_name changing only
	    	    	$dt_now_l=&get_dt_yyyymmddhhmmss();
	    	    	
		    	# copy 'actual__*'-file to change_history + modify name of file (from actual to change_history-format) and first lines at copied file
		    	$file_ipset_name_ch_hist_l=$dt_now_l.'__'.$ipset_name_cfg_l.'.txt';
		    	
		    	system("cp $ipset_actual_temporary_dir_l/$ipset_tmplt_name_dir_line_l/$file_ipset_name_actual_l $ipset_actual_temporary_dir_l/$ipset_tmplt_name_dir_line_l/change_history/$file_ipset_name_actual_l");
		    	
		    	system("sed -i 1d $ipset_actual_temporary_dir_l/$ipset_tmplt_name_dir_line_l/change_history/$file_ipset_name_actual_l");
		    	system("sed -i 1d $ipset_actual_temporary_dir_l/$ipset_tmplt_name_dir_line_l/change_history/$file_ipset_name_actual_l");
		    	
		    	$change_hist_1line_l="###$ipset_create_date_actual_l;+$dt_now_l;+$ipset_type_actual_l;+$ipset_type_cfg_l;+$ipset_name_actual_l;+$ipset_name_cfg_l";
		    	system("echo ' ' >> $ipset_actual_temporary_dir_l/$ipset_tmplt_name_dir_line_l/change_history/$file_ipset_name_actual_l");
		    	system("sed -i '1i $change_hist_1line_l' $ipset_actual_temporary_dir_l/$ipset_tmplt_name_dir_line_l/change_history/$file_ipset_name_actual_l");
		    	
		    	system("mv $ipset_actual_temporary_dir_l/$ipset_tmplt_name_dir_line_l/change_history/$file_ipset_name_actual_l $ipset_actual_temporary_dir_l/$ipset_tmplt_name_dir_line_l/change_history/$file_ipset_name_ch_hist_l");
		    	
		    	$file_ipset_name_ch_hist_l=undef;
		    	$change_hist_1line_l=undef;
		    	###
		    	
		    	# rename 'actual__*'-file
		    	$file_ipset_name_cfg_l='actual__'.$ipset_name_cfg_l.'.txt';
		    	system("mv $ipset_actual_temporary_dir_l/$ipset_tmplt_name_dir_line_l/$file_ipset_name_actual_l $ipset_actual_temporary_dir_l/$ipset_tmplt_name_dir_line_l/$file_ipset_name_cfg_l");
		    	
		    	$file_ipset_name_cfg_l=undef;
		    	###
			
	    	    	$dt_now_l=undef;
	    	    }
	    	}
	    	# check for changed ipset_name and/or ipset_type (END)
	    	
	    	# clear vars
	    	$ipset_tmplt_name_dir_line_l=undef;
	    	$ipset_create_date_actual_l=undef;
	    	($file_ipset_name_actual_l,$ipset_name_actual_l,$ipset_type_actual_l)=(undef,undef,undef);
	    	($ipset_name_cfg_l,$ipset_type_cfg_l)=(undef,undef);
	    	###
	    } # while readdir DIR_T (END)
	    
	    closedir(DIR_T);
	    
	    # clear vars
	    $ipset_actual_temporary_dir_l=undef;
	    ###
	}
	# read inv-host/temporary dir (END)
	
	# clear vars
	$inv_host_dir_line_l=undef;
	###
    } # readdir(DIR) end
    
    closedir(DIR);
    # ipset_actual_data write history operations (END)
    
    # READ CONTENT of ipsets (permanent and temporary) into %ipset_actual_files_composition_hash_l (BEGIN)
    	#For do not miss manually added data
    while ( ($hkey0_l,$hval0_l)=each %{${$h66_conf_ipsets_FIN_href_l}{'permanent'}} ) { # while h66, permanent, hkey=inv-host (begin)
    	# for permanent (without timeout) ipsets
    	#$hkey0_l=inv-host
    	
    	while ( ($hkey1_l,$hval1_l)=each %{$hval0_l} ) { # while h66, permanent, %{$hval0_l}, hkey=ipset_tmplt_name (begin)
    	    #$hkey1_l=ipset_tmplt_name
    	    if ( exists(${$ipset_templates_href_l}{'permanent'}{$hkey1_l}) ) {
    		$ipset_name_cfg_l=${$ipset_templates_href_l}{'permanent'}{$hkey1_l}{'ipset_name'};
    		$ipset_actual_file_path_l=$ipset_actual_data_dir_l.'/'.$hkey0_l.'/permanent/'.$hkey1_l.'/actual__'.$ipset_name_cfg_l.'.txt';
    	
    		###
    		&read_actual_ipset_file_to_hash($ipset_actual_file_path_l,0,\%ipset_actual_file_data_hash_l);
    		#$file_l,$file_type_l,$href_l
    		# %ipset_actual_file_data_hash_l=();
    		# key0=content, key1=entry, value=expire_date (if=0 -> permanent ipset)
    		# or key0=info, value=[array of info strings]
    		###
    		
    		# check for exists initial file 'now4add' and add ipset values if exists to %ipset_actual_file_data_hash_l (BEGIN)
    		    #now4add formed at sub 'update_initial_content_for_local_ipset_actual_data'
    		$init_content_file_path_now4add_l=$ipset_actual_data_dir_l.'/'.$hkey0_l.'/permanent/'.$hkey1_l.'/initial_content/now4add';
    		&read_lines_without_comments_of_file_to_hash($init_content_file_path_now4add_l,\%tmp_hash0_l);
    		#$file_l,$href_l
    		
    		while ( ($hkey2_l,$hval2_l)=each %tmp_hash0_l ) {
    		    #$hkey2_l = ipset entry for add
    		    if ( !exists($ipset_actual_file_data_hash_l{'content'}{$hkey2_l}) ) {
    			$ipset_actual_file_data_hash_l{'content'}{$hkey2_l}=0;
    		    }
    		}
    		
    		# clear vars
    		($hkey2_l,$hval2_l)=(undef,undef);
    		%tmp_hash0_l=();
    		###
    		# check for exists initial file 'now4add' (END)
    	
    		# check for exists initial file 'now4del' and delete ipset values if exists from %ipset_actual_file_data_hash_l (BEGIN)
    		    #now4del formed at sub 'update_initial_content_for_local_ipset_actual_data'
    		$init_content_file_path_now4del_l=$ipset_actual_data_dir_l.'/'.$hkey0_l.'/permanent/'.$hkey1_l.'/initial_content/now4del';
    		&read_lines_without_comments_of_file_to_hash($init_content_file_path_now4del_l,\%tmp_hash0_l);
    		#$file_l,$href_l
    	
    		while ( ($hkey2_l,$hval2_l)=each %tmp_hash0_l ) {
    		    #$hkey2_l = ipset entry for del
    		    if ( exists($ipset_actual_file_data_hash_l{'content'}{$hkey2_l}) ) {
    			delete($ipset_actual_file_data_hash_l{'content'}{$hkey2_l});
    		    }
    		}
    		
    		# clear vars
    		($hkey2_l,$hval2_l)=(undef,undef);		
    		%tmp_hash0_l=();
    		###
    		# check for exists initial file 'now4del' (END)
    		
    		# WRITE %ipset_actual_file_data_hash_l TO %ipset_actual_files_composition_hash_l
    		# %ipset_actual_files_composition_hash_l
    		# key0=$ipset_actual_file_path_l
    		    #key1A='ipset_file_type': 0-permanent, 1-temporary
    		    #key1B='subhash' (%ipset_actual_file_data_hash_l)
    		$ipset_actual_files_composition_hash_l{$ipset_actual_file_path_l}{'ipset_file_type'}=0;
    		%{$ipset_actual_files_composition_hash_l{$ipset_actual_file_path_l}{'subhash'}}=(%ipset_actual_file_data_hash_l);
    		%ipset_actual_file_data_hash_l=();
    		###
    	
    		# clear vars
    		$ipset_name_cfg_l=undef;
    		$ipset_actual_file_path_l=undef;
    		($init_content_file_path_now4add_l,$init_content_file_path_now4del_l)=(undef,undef);
    		###
    	    }
    	} # while h66, permanent, %{$hval0_l}, hkey=ipset_tmplt_name (end)
    	
    	($hkey1_l,$hval1_l)=(undef,undef);
    } # while h66, permanent, hkey=inv-host (end)
    
    ($hkey0_l,$hval0_l)=(undef,undef);
    
    while ( ($hkey0_l,$hval0_l)=each %{${$h66_conf_ipsets_FIN_href_l}{'temporary'}} ) { # while h66, temporary, hkey=inv-host (begin)
    	# for temporary (with timeout) ipsets
    	#$hkey0_l=inv-host
    	
    	while ( ($hkey1_l,$hval1_l)=each %{$hval0_l} ) { # while h66, temporary, %{$hval0_l}, hkey=ipset_tmplt_name (begin)
    	    #$hkey1_l=ipset_tmplt_name
    	    if ( exists(${$ipset_templates_href_l}{'temporary'}{$hkey1_l}) ) {
    		$ipset_name_cfg_l=${$ipset_templates_href_l}{'temporary'}{$hkey1_l}{'ipset_name'};
    		$ipset_actual_file_path_l=$ipset_actual_data_dir_l.'/'.$hkey0_l.'/temporary/'.$hkey1_l.'/actual__'.$ipset_name_cfg_l.'.txt';
    		
    		###
    		&read_actual_ipset_file_to_hash($ipset_actual_file_path_l,1,\%ipset_actual_file_data_hash_l);
    		#$file_l,$file_type_l,$href_l
    		# %ipset_actual_file_data_hash_l=();
    		# key0=content, key1=entry, value=expire_date (if=0 -> permanent ipset)
    		# or key0=info, value=[array of info strings]
    		###
    		
    		# WRITE %ipset_actual_file_data_hash_l TO %ipset_actual_files_composition_hash_l
    		# %ipset_actual_files_composition_hash_l
    		# key0=$ipset_actual_file_path_l
    		    #key1A='ipset_file_type': 0-permanent, 1-temporary
    		    #key1B='subhash' (%ipset_actual_file_data_hash_l)
    		$ipset_actual_files_composition_hash_l{$ipset_actual_file_path_l}{'ipset_file_type'}=1;
    		%{$ipset_actual_files_composition_hash_l{$ipset_actual_file_path_l}{'subhash'}}=(%ipset_actual_file_data_hash_l);
    		%ipset_actual_file_data_hash_l=();
    		###
    	
    		# clear vars
    		$ipset_name_cfg_l=undef;
    		$ipset_actual_file_path_l=undef;
    		###
    	    }
    	} # while h66, temporary, %{$hval0_l}, hkey=ipset_tmplt_name (end)
    	
    	($hkey1_l,$hval1_l)=(undef,undef);
    } # while h66, temporary, hkey=inv-host (end)
    
    ($hkey0_l,$hval0_l)=(undef,undef);
    # READ CONTENT of ipsets (permanent and temporary) into %ipset_actual_files_composition_hash_l (END)
    
    # operations for permanent ipsets (BEGIN)
	#$ipset_input_href_l=hash-ref for %ipset_input_l
    	    #key0=permanent/temporary,key1=inv-host;+ipset_template_name;+ipset_name ->
        	#key2=add/del,key3=ipset_entry (according to #ipset_type), value=expire_datetime (0 - no expire, datetime - yes expire)
    while ( ($hkey0_l,$hval0_l)=each %{${$ipset_input_href_l}{'permanent'}} ) { # while ipset_input -> permanent (begin)
    	#hkey1_l=inv-host-0;+ipset_template_name-1;+ipset_name-2
    	@tmp_arr0_l=split(/\;\+/,$hkey0_l);
    	
    	$ipset_actual_file_path_l=$ipset_actual_data_dir_l.'/'.$tmp_arr0_l[0].'/permanent/'.$tmp_arr0_l[1].'/actual__'.$tmp_arr0_l[2].'.txt';
    
    	# GET %ipset_actual_file_data_hash_l FROM %ipset_actual_files_composition_hash_l 
    	%ipset_actual_file_data_hash_l=%{$ipset_actual_files_composition_hash_l{$ipset_actual_file_path_l}{'subhash'}};
    	###
    
    	# ops for 'add' (permanent) (begin)
    	while ( ($hkey1_l,$hval1_l)=each %{${$hval0_l}{'add'}} ) {
    	    #$hkey1_l=ipset_entry, $hval1_l=expire_datetime (0 or datetime)
    	    if ( $hval1_l<1 ) { # if permanent WITHOUT external timeout
    		if ( !exists($ipset_actual_file_data_hash_l{'content'}{$hkey1_l}) ) {
    		    $ipset_actual_file_data_hash_l{'content'}{$hkey1_l}=0;
    		}
    	    }
    	    else { # if permanent WITH external timeout
    		
    	    }
    	}
    	
	# clear vars
    	($hkey1_l,$hval1_l)=(undef,undef);
	###
    	# ops for 'add' (permanent) (end)
    
    	# ops for 'del' (permanent)
    	while ( ($hkey1_l,$hval1_l)=each %{${$hval0_l}{'del'}} ) {
    	    #$hkey1_l=ipset_record, $hval1_l=0
    	    if ( exists($ipset_actual_file_data_hash_l{'content'}{$hkey1_l}) ) {
    		delete($ipset_actual_file_data_hash_l{'content'}{$hkey1_l});
    	    }
    	}
    		
    	($hkey1_l,$hval1_l)=(undef,undef); # clear vars
    	###
    
    	# UPDATE 'subhash' FOR ipset_actual_file_path_l AT %ipset_actual_files_composition_hash_l
    	%{$ipset_actual_files_composition_hash_l{$ipset_actual_file_path_l}{'subhash'}}=(%ipset_actual_file_data_hash_l);
    	%ipset_actual_file_data_hash_l=();
    	###
    		
    	# clear vars
    	@tmp_arr0_l=();
    	$ipset_actual_file_path_l=undef;
    	###
    } # while ipset_input -> permanent (end)
    
    # clear vars
    ($hkey0_l,$hval0_l)=(undef,undef);
    ###
    # operations for permanent ipsets (END)

    # operations for temporary ipsets (BEGIN)
    while ( ($hkey0_l,$hval0_l)=each %{${$ipset_input_href_l}{'temporary'}} ) { # while ipset_input -> temporary (begin)
    	#hkey1_l=inv-host-0;+ipset_template_name-1;+ipset_name-2
    	@tmp_arr0_l=split(/\;\+/,$hkey0_l);
    	
    	$ipset_actual_file_path_l=$ipset_actual_data_dir_l.'/'.$tmp_arr0_l[0].'/temporary/'.$tmp_arr0_l[1].'/actual__'.$tmp_arr0_l[2].'.txt';
    	
    	# GET %ipset_actual_file_data_hash_l FROM %ipset_actual_files_composition_hash_l 
    	%ipset_actual_file_data_hash_l=%{$ipset_actual_files_composition_hash_l{$ipset_actual_file_path_l}{'subhash'}};
    	###
    	
    	# ops for 'add' (temporary) (begin)
    	while ( ($hkey1_l,$hval1_l)=each %{${$hval0_l}{'add'}} ) { # while ipset_input -> temporary -> add (begin)
    	    #$hkey1_l=ipset_entry, $hval1_l=expire_datetime ('0 for def' or 'datetime')
    	    
	    if ( $hval1_l<1 ) { # if temporary with DEF expire_datetime (configured at cfg '01_conf_ipset_templates')
    	    	if ( !exists($ipset_actual_file_data_hash_l{'content'}{$hkey1_l}) ) {
    	    	    $expire_epoch_sec_calculated_l=time()+${$ipset_templates_href_l}{$tmp_arr0_l[1]}{'ipset_create_option_timeout'};
    	    	    $expire_date_calculated_l=&conv_epoch_sec_to_yyyymmddhhmiss($expire_epoch_sec_calculated_l);
    	    	    #$for_conv_sec_l
    	    	    
    	    	    $ipset_actual_file_data_hash_l{'content'}{$hkey1_l}=$expire_date_calculated_l;
    	    	    
    	    	    # clear vars
    	    	    $expire_date_calculated_l=undef;
    	    	    $expire_epoch_sec_calculated_l=undef;
    	    	    ###
    	    	}
    	    	else {
    	    	    $expire_date_actual_l=$ipset_actual_file_data_hash_l{'content'}{$hkey1_l};
    	    	    $expire_epoch_sec_actual_l=&conv_yyyymmddhhmiss_to_epoch_sec($expire_date_actual_l);
    	    	    #$for_conv_dt
    	    	
    	    	    $expire_epoch_sec_calculated_l=time() + ${$ipset_templates_href_l}{$tmp_arr0_l[1]}{'ipset_create_option_timeout'};
    	    	    $expire_date_calculated_l=&conv_epoch_sec_to_yyyymmddhhmiss($expire_epoch_sec_calculated_l);
    	    	    #$for_conv_sec_l
    	    	    
    	    	    if ( $expire_epoch_sec_calculated_l>$expire_epoch_sec_actual_l ) { # if ipset_entry is expired
    	    		$ipset_actual_file_data_hash_l{'content'}{$hkey1_l}=$expire_date_calculated_l;
    	    	    }
    	    	    else { $ipset_actual_file_data_hash_l{'content'}{$hkey1_l}=$expire_date_actual_l; }
    	    	    
    	    	    # clear vars
    	    	    $expire_date_actual_l=undef;
    	    	    $expire_date_calculated_l=undef;
    	    	    ($expire_epoch_sec_actual_l,$expire_epoch_sec_calculated_l)=(undef,undef);
    	    	    ###
    	    	}
	    }
	    else { # if temporary with NOT DEF expire_datetime
		
	    }
    	} # while ipset_input -> temporary -> add (end)
    	
	# clear vars
    	($hkey1_l,$hval1_l)=(undef,undef);
	###
    	# ops for 'add' (temporary) (end)
    	
    	# ops for 'del' (temporary)
    	while ( ($hkey1_l,$hval1_l)=each %{${$hval0_l}{'del'}} ) {
    	    #$hkey1_l=ipset_entry, $hval1_l=0
    	    if ( exists($ipset_actual_file_data_hash_l{'content'}{$hkey1_l}) ) {
    		delete($ipset_actual_file_data_hash_l{'content'}{$hkey1_l});
    	    }
    	}
    	
    	($hkey1_l,$hval1_l)=(undef,undef); # clear vars
    	###
    
    	# UPDATE 'subhash' FOR ipset_actual_file_path_l AT %ipset_actual_files_composition_hash_l
    	%{$ipset_actual_files_composition_hash_l{$ipset_actual_file_path_l}{'subhash'}}=(%ipset_actual_file_data_hash_l);
    	%ipset_actual_file_data_hash_l=();
    	###
    
    	# clear vars
    	@tmp_arr0_l=();
    	$ipset_actual_file_path_l=undef;
    	###
    } # while ipset_input -> temporary (end)
    
    # clear vars
    ($hkey0_l,$hval0_l)=(undef,undef);
    ###
    # operations for temporary ipsets (END)

    # FIN write to actual*-files (begin)
    while ( ($hkey0_l,$hval0_l)=each %ipset_actual_files_composition_hash_l ) {
	#$hkey0_l=actual-file-path
	#${$hval0_l}{'ipset_file_type'}=$file_type_l: 0-permanent ipset, 1-temporary_ipset
	#%{${$hval0_l}{'subhash'}}=hash with actual-file-content
	
	# FIN write to one actual*-file
	&rewrite_actual_ipset_file_from_hash($hkey0_l,\%{${$hval0_l}{'subhash'}});
	#$file_l,$href_l
	###
    }
    
    # clear vars
    %ipset_actual_files_composition_hash_l=();
    ($hkey0_l,$hval0_l)=(undef,undef);
    ###
    # FIN write to actual*-files (end)
    
    return $return_str_l;
}

sub copy_actual_ipset_data_to_scripts_for_remote {
    my ($ipset_actual_data_dir_l,$dyn_fwrules_files_dir_l,$ipset_templates_href_l,$h66_conf_ipsets_FIN_href_l)=@_;
    #$ipset_actual_data_dir_l=$ipset_actual_data_dir_g
    #$dyn_fwrules_files_dir_l=$dyn_fwrules_files_dir_g
	#...playbooks/scripts_for_remote/fwrules_files
    #$ipset_templates_href_l=hash-ref for %h01_conf_ipset_templates_hash_g
        #$h01_conf_ipset_templates_hash_g{'temporary/permanent'}{ipset_template_name--TMPLT}->
        #{'ipset_name'}=value
    #$h66_conf_ipsets_FIN_href_l=hash-ref for \%h66_conf_ipsets_FIN_hash_g
        #$h66_conf_ipsets_FIN_hash_g{'temporary/permanent'}{inventory_host}->
            #{ipset_name_tmplt-0}=1;
            #{ipset_name_tmplt-1}=1;
            #etc
    
    my $proc_name_l=(caller(0))[3];
    
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my ($hkey1_l,$hval1_l)=(undef,undef);
    my $arr_el0_l=undef;
    my $ipset_name_l=undef;
    my $dst_dir_l=undef;
    my $apply_run_flag_file_path_l=undef; # file for track changes at ipsets via copy to remote status (for example, like 'recreate_fw_zones.sh')
    my ($src_ipset_file_path_l,$dst_ipset_file_path_l)=(undef,undef);
    my $ipsets_list_file_path_l=undef;
    my @tmp_arr0_l=();
    my @actual_file_cont_l=();
    my @list_of_ipsets_l=();
    my @apply_run_flag_file_content_l=();
    
    # vars only for permanent with external timeout
    my $dst_dir_pwet_l=undef; #pwet = permanent with external timeout
    my $apply_run_flag_file_path_pwet_l=undef; # file for track changes at ipsets (permanent with ext timeout) via copy to remote status (for example, like 'recreate_fw_zones.sh')
    my $ipsets_list_file_path_pwet_l=undef;
    my $dst_ipset_file_path_pwet_l=undef;
    my @actual_file_cont_pwet_l=();
    my @list_of_ipsets_pwet_l=();
    my @apply_run_flag_file_content_pwet_l=();
    # vars only for permanent with external timeout
    
    # operations for permanent ipsets (BEGIN)
    while ( ($hkey0_l,$hval0_l)=each %{${$h66_conf_ipsets_FIN_href_l}{'permanent'}} ) { # cycle for h66, inv-hosts (begin)
    	#$hkey0_l=inv-host
    	
    	$apply_run_flag_file_path_l=$dyn_fwrules_files_dir_l.'/'.$hkey0_l.'/permanent_ipsets_flag_file';
    	$apply_run_flag_file_path_pwet_l=$dyn_fwrules_files_dir_l.'/'.$hkey0_l.'/permanent_ipsets_flag_file_pwet';
    	    
    	$dst_dir_l=$dyn_fwrules_files_dir_l.'/'.$hkey0_l.'/permanent_ipsets';
	$dst_dir_pwet_l=$dyn_fwrules_files_dir_l.'/'.$hkey0_l.'/permanent_ipsets_with_ext_timeout';
	
    	system("mkdir -p $dst_dir_l");
	system("mkdir -p $dst_dir_pwet_l");
    	    
    	$ipsets_list_file_path_l=$dst_dir_l.'/LIST';
	$ipsets_list_file_path_pwet_l=$dst_dir_pwet_l.'/LIST';
    	    
    	while ( ($hkey1_l,$hval1_l)=each %{$hval0_l} ) { # cycle for h66, inv-hosts -> ipset_templates (begin)
    	    #$hkey1_l=ipset_tmplt_name
    	    $ipset_name_l=${$ipset_templates_href_l}{'permanent'}{$hkey1_l}{'ipset_name'};
    	    $src_ipset_file_path_l=$ipset_actual_data_dir_l.'/'.$hkey0_l.'/permanent/'.$hkey1_l.'/actual__'.$ipset_name_l.'.txt';
	    
    	    $dst_ipset_file_path_l=$dst_dir_l.'/'.$ipset_name_l;
	    $dst_ipset_file_path_pwet_l=$dst_dir_pwet_l.'/'.$ipset_name_l; # pwet
	    
    	    &read_lines_without_comments_of_file_to_array($src_ipset_file_path_l,\@tmp_arr0_l);
    	    #$file_l,$aref_l
	    
	    foreach $arr_el0_l ( @tmp_arr0_l ) {
	    	if ( $arr_el0_l=~/\;\+/ ) { # if record WITH external timeout
	    	    push(@actual_file_cont_pwet_l,$arr_el0_l); # pwet
	    	}
	    	else { # if record WITHOUT external timeout
	    	    push(@actual_file_cont_l,$arr_el0_l);
	    	}
	    }
	    
	    # FOR permanent WITHOUT external timeout
	    if ( $#actual_file_cont_l!=-1 ) { # write to dst if ipset entries exists at src-file
    	    	&rewrite_file_from_array_ref($dst_ipset_file_path_l,\@actual_file_cont_l);
    	    	#$file_l,$aref_l
    	    	    
    	    	push(@list_of_ipsets_l,$ipset_name_l);
    	    	###
    	    	@apply_run_flag_file_content_l=(@apply_run_flag_file_content_l,$ipset_name_l,@actual_file_cont_l,' ');
    	    }
    	    else { @apply_run_flag_file_content_l=(@apply_run_flag_file_content_l,$ipset_name_l,'empty',' '); }
	    ###
	    
	    # FOR permanent WITH external timeout
	    if ( $#actual_file_cont_pwet_l!=-1 ) { # write to dst if ipset entries exists at src-file
    	    	&rewrite_file_from_array_ref($dst_ipset_file_path_l,\@actual_file_cont_pwet_l);
    	    	#$file_l,$aref_l
    	    	    
    	    	push(@list_of_ipsets_pwet_l,$ipset_name_l);
    	    	###
    	    	@apply_run_flag_file_content_pwet_l=(@apply_run_flag_file_content_pwet_l,$ipset_name_l,@actual_file_cont_pwet_l,' ');
    	    }
    	    else { @apply_run_flag_file_content_pwet_l=(@apply_run_flag_file_content_pwet_l,$ipset_name_l,'empty',' '); }
	    ###
    	    	
    	    # clear vars
    	    $ipset_name_l=undef;
	    $arr_el0_l=undef;
    	    ($src_ipset_file_path_l,$dst_ipset_file_path_l)=(undef,undef);
	    $dst_ipset_file_path_pwet_l=undef;
    	    @tmp_arr0_l=();
	    @actual_file_cont_l=();
	    @actual_file_cont_pwet_l=();
    	    ###
    	} # cycle for h66, inv-hosts -> ipset_templates (end)
    	
	# FOR permanent WITHOUT external timeout
    	if ( $#list_of_ipsets_l!=-1 ) {
    	    @list_of_ipsets_l=sort(@list_of_ipsets_l);
    	    &rewrite_file_from_array_ref($ipsets_list_file_path_l,\@list_of_ipsets_l);
    	    #$file_l,$aref_l
    	}
    	else { # if no permanent ipsets WITHOUT external timeout
    	    $ipsets_list_file_path_l=$dst_dir_l.'/NO_LIST';
    	    system("touch $ipsets_list_file_path_l");
    	}
    	    
    	if ( $#apply_run_flag_file_content_l!=-1 ) {
    	    &rewrite_file_from_array_ref($apply_run_flag_file_path_l,\@apply_run_flag_file_content_l);
            #$file_l,$aref_l
    	}
	###
	
	# FOR permanent WITH external timeout
    	if ( $#list_of_ipsets_pwet_l!=-1 ) {
    	    @list_of_ipsets_pwet_l=sort(@list_of_ipsets_pwet_l);
    	    &rewrite_file_from_array_ref($ipsets_list_file_path_pwet_l,\@list_of_ipsets_pwet_l);
    	    #$file_l,$aref_l
    	}
    	else { # if no permanent ipsets WITH external timeout
    	    $ipsets_list_file_path_pwet_l=$dst_dir_pwet_l.'/NO_LIST';
    	    system("touch $ipsets_list_file_path_pwet_l");
    	}
    	    
    	if ( $#apply_run_flag_file_content_pwet_l!=-1 ) {
    	    &rewrite_file_from_array_ref($apply_run_flag_file_path_pwet_l,\@apply_run_flag_file_content_pwet_l);
            #$file_l,$aref_l
    	}
	###
    	    
    	#clear vars
    	($hkey1_l,$hval1_l)=(undef,undef);
    	$dst_dir_l=undef;
	$dst_dir_pwet_l=undef;
    	$ipsets_list_file_path_l=undef;
	$ipsets_list_file_path_pwet_l=undef;
	$apply_run_flag_file_path_l=undef;
	$apply_run_flag_file_path_pwet_l=undef;
    	@list_of_ipsets_l=();
    	@list_of_ipsets_pwet_l=();
    	@apply_run_flag_file_content_l=();
	@apply_run_flag_file_content_pwet_l=();
    	###
    } # cycle for h66, inv-hosts (end)
    
    # clear vars
    ($hkey0_l,$hval0_l)=(undef,undef);
    ###
    # operations for permanent ipsets (END)
    
    # operations for temporary ipsets (BEGIN)
    while ( ($hkey0_l,$hval0_l)=each %{${$h66_conf_ipsets_FIN_href_l}{'temporary'}} ) { # cycle for h66, inv-hosts (begin)
    	#$hkey0_l=inv-host
    	
    	$apply_run_flag_file_path_l=$dyn_fwrules_files_dir_l.'/'.$hkey0_l.'/temporary_ipsets_flag_file';
    	    
    	$dst_dir_l=$dyn_fwrules_files_dir_l.'/'.$hkey0_l.'/temporary_ipsets';
    	
    	system("mkdir -p $dst_dir_l");
    	    
    	$ipsets_list_file_path_l=$dst_dir_l.'/LIST';
    	    
    	while ( ($hkey1_l,$hval1_l)=each %{$hval0_l} ) { # cycle for h66, inv-hosts -> ipset_templates (begin)
    	    #$hkey1_l=ipset_tmplt_name
    	    $ipset_name_l=${$ipset_templates_href_l}{'temporary'}{$hkey1_l}{'ipset_name'};
    	    $src_ipset_file_path_l=$ipset_actual_data_dir_l.'/'.$hkey0_l.'/temporary/'.$hkey1_l.'/actual__'.$ipset_name_l.'.txt';
    	    $dst_ipset_file_path_l=$dst_dir_l.'/'.$ipset_name_l;
    	    &read_lines_without_comments_of_file_to_array($src_ipset_file_path_l,\@tmp_arr0_l);
    	    #$file_l,$aref_l
    	    	
    	    if ( $#tmp_arr0_l!=-1 ) { # write to dst if ipset entries exists at src-file
    	    	&rewrite_file_from_array_ref($dst_ipset_file_path_l,\@tmp_arr0_l);
    	    	#$file_l,$aref_l
    	    	    
    	    	push(@list_of_ipsets_l,$ipset_name_l);
    	    	###
    	    	@apply_run_flag_file_content_l=(@apply_run_flag_file_content_l,$ipset_name_l,@tmp_arr0_l,' ');
    	    }
    	    else { @apply_run_flag_file_content_l=(@apply_run_flag_file_content_l,$ipset_name_l,'empty',' '); }
    	    	
    	    # clear vars
    	    $ipset_name_l=undef;
    	    ($src_ipset_file_path_l,$dst_ipset_file_path_l)=(undef,undef);
    	    @tmp_arr0_l=();
    	    ###
    	} # cycle for h66, inv-hosts -> ipset_templates (end)
    	    
    	if ( $#list_of_ipsets_l!=-1 ) {
    	    @list_of_ipsets_l=sort(@list_of_ipsets_l);
    	    &rewrite_file_from_array_ref($ipsets_list_file_path_l,\@list_of_ipsets_l);
    	    #$file_l,$aref_l
    	}
    	else {
    	    $ipsets_list_file_path_l=$dst_dir_l.'/NO_LIST';
    	    system("touch $ipsets_list_file_path_l");
    	}
    	    
    	if ( $#apply_run_flag_file_content_l!=-1 ) {
    	    &rewrite_file_from_array_ref($apply_run_flag_file_path_l,\@apply_run_flag_file_content_l);
            #$file_l,$aref_l
    	}
    	    
    	#clear vars
    	($hkey1_l,$hval1_l)=(undef,undef);
    	$dst_dir_l=undef;
    	$ipsets_list_file_path_l=undef;
	$apply_run_flag_file_path_l=undef;
    	@list_of_ipsets_l=();
    	@apply_run_flag_file_content_l=();
    	###
    } # cycle for h66, inv-hosts (end)
    
    # clear vars
    ($hkey0_l,$hval0_l)=(undef,undef);
    ###
    # operations for temporary ipsets (END)

    my $return_str_l='OK';

    return $return_str_l;
}

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
