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
        #key0=permanent/temporary,key1=inv-host;+ipset_template_name;+ipset_name ->
            #key2=add/del,key3=ipset_record (according to #ipset_type), value=1
    
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
            #key0=permanent/temporary,key1=inv-host;+ipset_template_name;+ipset_name ->
                #key2=add/del,key3=ipset_record (according to #ipset_type), value=1

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
    my @input_inv_host_arr_l=();
    my @tmp_arr0_l=();
    
    my %input_file_content_hash_l=();
    
    my ($input_file_name_l,$input_ipset_template_name_l)=(undef,undef);
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my ($hkey1_l,$hval1_l)=(undef,undef);
    my ($arr_el0_l,$arr_el1_l)=(undef,undef);
    my $dir_line_l=undef;
    my $file_line_l=undef;
    
    my $ipset_type_by_time_l=undef; # temporary/permanent
    my ($ipset_name_l,$ipset_type_l,$ipset_create_option_family_l)=(undef,undef,undef);
    my $last_access_epoch_sec_l=undef;
    
    my %log_ops_input_l=();
    
    my %res_tmp_lv0_l=();
    my %res_tmp_lv0_slice_l=();
    #key0=temporary/permanent;+inv-host;+ipset_template_name;+ipset_name;+ipset_record (according to #ipset_type)
	# key1=add/del, value=[last_access_time_in_sec_epoch,$input_file_name_l,$ipset_type_l,$ipset_create_option_family_l]
    my %res_tmp_lv1_l=(); # like %ipset_input_l
            #key0=permanent/temporary,key1=inv-host;+ipset_template_name;+ipset_name ->
                #key2=add/del,key3=ipset_record (according to #ipset_type), value=1

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
		    &read_local_ipset_input_log_ops($read_input_dirs_l{'history'},\%log_ops_input_l);
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
	    	    &read_local_ipset_input_log_ops($read_input_dirs_l{'history'},\%log_ops_input_l);
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
		    &read_local_ipset_input_log_ops($read_input_dirs_l{'history'},\%log_ops_input_l);
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
		&read_local_ipset_input_log_ops($read_input_dirs_l{'history'},\%log_ops_input_l);
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
	    	&read_local_ipset_input_log_ops($read_input_dirs_l{'history'},\%log_ops_input_l);
	    	#$history_log_dir_l,$input_params_href_l
	    	%log_ops_input_l=();
	    	######
		
		next; # if error for 'ipset template' at filename
	    }
	    ###
	    
	    # no error for 'ipset template' at filename
	    $ipset_name_l=${$ipset_templates_href_l}{$ipset_type_by_time_l}{$input_ipset_template_name_l}{'ipset_name'};
	    $ipset_type_l=${$ipset_templates_href_l}{$ipset_type_by_time_l}{$input_ipset_template_name_l}{'ipset_type'};
	    $ipset_create_option_family_l=${$ipset_templates_href_l}{$ipset_type_by_time_l}{$input_ipset_template_name_l}{'ipset_create_option_family'};
    	    
	    # read input file    
	    open(INPUT_FILE,'<',$read_input_dirs_l{$arr_el0_l}{'input_dir'}.'/'.$input_file_name_l);
	    while ( <INPUT_FILE> ) {
		$file_line_l=$_;
		$file_line_l=~s/\n|\r//g;
		$file_line_l=~s/\s+/ /g;
		$file_line_l=~s/ //g;
		if ( $file_line_l!~/^\#/ ) {
		    $input_file_content_hash_l{$file_line_l}=1;
		}
	    }
	    close(INPUT_FILE);
	    ###
	    
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
	    	&read_local_ipset_input_log_ops($read_input_dirs_l{'history'},\%log_ops_input_l);
	    	#$history_log_dir_l,$input_params_href_l
	    	%log_ops_input_l=();
	    	######

		next; # if no content
	    }
	    ###
	    
	    # fill %res_tmp_lv0_slice_l
	    #my %res_tmp_lv0_l=();
    	    	#key0=temporary/permanent;+inv-host;+ipset_template_name;+ipset_name;+ipset_record (according to #ipset_type)
        	    # key1=add/del, value=[last_access_time_in_sec_epoch,$input_file_name_l,$ipset_type_l,$ipset_create_option_family_l]
	    foreach $arr_el1_l ( @input_inv_host_arr_l ) {
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
    	    		'STATUS'=>"ipset_template_name is not configured for ivn-host at '66_conf_ipsets_FIN'",
	    	    );
	    	    &read_local_ipset_input_log_ops($read_input_dirs_l{'history'},\%log_ops_input_l);
	    	    #$history_log_dir_l,$input_params_href_l
	    	    %log_ops_input_l=();
	    	    ######
		    
		    next;
		}
		
		# write records to %res_tmp_lv0_slice_l
		while ( ($hkey0_l,$hval0_l)=each %input_file_content_hash_l ) {
		    #$hkey0_l=ipset_record
		    
		    #FOR USE IN FUTURE
		    #&check_ipset_input($hkey0_l,$ipset_type_l,$ipset_create_option_family_l);
		    #$ipset_val_l,$ipset_type_l,$ipset_family_l
		    
		    ######
	    	    %log_ops_input_l=(
    	    		'INPUT_OP_TYPE'=>$arr_el0_l, 'INPUT_FILE_NAME'=>$input_file_name_l,
			'INPUT_FILE_CREATE_DATETIME_epoch'=>$last_access_epoch_sec_l,
    	    		'INV_HOST'=>$arr_el1_l, 'IPSET_TEMPLATE_NAME'=>$input_ipset_template_name_l,
    	    		'IPSET_NAME'=>$ipset_name_l, 'IPSET_TYPE_BY_TIME'=>$ipset_type_by_time_l,
			'IPSET_TYPE'=>$ipset_type_l, 'RECORD'=>$hkey0_l,
    	    		'STATUS'=>'OK',
	    	    );
	    	    &read_local_ipset_input_log_ops($read_input_dirs_l{'history'},\%log_ops_input_l);
	    	    #$history_log_dir_l,$input_params_href_l
	    	    %log_ops_input_l=();
	    	    ######

		    $res_tmp_lv0_slice_l{$ipset_type_by_time_l.';+'.$arr_el1_l.';+'.$input_ipset_template_name_l.';+'.$ipset_name_l}{$arr_el0_l}=[$last_access_epoch_sec_l,$input_file_name_l,$ipset_type_l,$ipset_create_option_family_l];
		}
		###
	    }
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
	    	&read_local_ipset_input_log_ops($read_input_dirs_l{'history'},\%log_ops_input_l);
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
	    &read_local_ipset_input_log_ops($read_input_dirs_l{'history'},\%log_ops_input_l);
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
    	} # readdir(DIR) end
    	closedir(DIR);
    } # foreach @read_input_seq_l (end)
    
    $arr_el0_l=undef;
    ###

    # check %res_tmp_lv0_l and fill %res_tmp_lv1_l
    while ( ($hkey0_l,$hval0_l)=each %res_tmp_lv0_l ) {
    	#$hkey0_l=temporary/permanent-0;+inv-host-1;+ipset_template_name-2;+ipset_name-3;+ipset_record-4
    	#$hval0_l=hash-ref for "add/del=[last_access_time_in_sec_epoch-0,$input_file_name_l-1,$ipset_type_l-2,$ipset_create_option_family_l-3]"
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
    		&read_local_ipset_input_log_ops($read_input_dirs_l{'history'},\%log_ops_input_l);
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
    		&read_local_ipset_input_log_ops($read_input_dirs_l{'history'},\%log_ops_input_l);
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
    		&read_local_ipset_input_log_ops($read_input_dirs_l{'history'},\%log_ops_input_l);
    		#$history_log_dir_l,$input_params_href_l
    		%log_ops_input_l=();
    		######
    
    		delete(${$hval0_l}{'add'});
    	    }
    	}
    	
    	while ( ($hkey1_l,$hval1_l)=each %{$hval0_l} ) {
    	    #hkey1_l=add/del, hval1_l=arr-ref for [last_access_time_in_sec_epoch-0,$input_file_name_l-1,$ipset_type_l-2,$ipset_create_option_family_l-3]
    	    
    	    ######
    	    %log_ops_input_l=(
    	    	'INPUT_OP_TYPE'=>$hkey1_l, 'INPUT_FILE_NAME'=>${$hval1_l}[1],
    		'INPUT_FILE_CREATE_DATETIME_epoch'=>${$hval1_l}[0],
    	    	'INV_HOST'=>$tmp_arr0_l[1], 'IPSET_TEMPLATE_NAME'=>$tmp_arr0_l[2],
    	    	'IPSET_NAME'=>$tmp_arr0_l[3], 'IPSET_TYPE_BY_TIME'=>$tmp_arr0_l[0],
    		'IPSET_TYPE'=>${$hval1_l}[2], 'RECORD'=>$tmp_arr0_l[4],
    	    	'STATUS'=>'OK',
    	    );
    	    &read_local_ipset_input_log_ops($read_input_dirs_l{'history'},\%log_ops_input_l);
    	    #$history_log_dir_l,$input_params_href_l
    	    %log_ops_input_l=();
    	    ######
	    
	    #my %res_tmp_lv1_l=(); # like %ipset_input_l
            #key0=permanent/temporary,key1=inv-host;+ipset_template_name;+ipset_name ->
                #key2=add/del,key3=ipset_record (according to #ipset_type), value=1
	    $res_tmp_lv1_l{$tmp_arr0_l[0]}{$tmp_arr0_l[1].';+'.$tmp_arr0_l[2].';+'.$tmp_arr0_l[3]}{$hkey1_l}{$tmp_arr0_l[4]}=1;
    	}
    }
    ###

    # fill result hash
    %{$res_href_l}=%res_tmp_lv1_l;
    ###
            
    %res_tmp_lv1_l=();
        
    return $return_str_l;
}

sub update_local_ipset_actual_data {
    my ($ipset_actual_data_dir_l,$ipset_input_href_l,$inv_hosts_href_l,$ipset_templates_href_l,$h65_conf_initial_ipsets_content_FIN_href_l,$h66_conf_ipsets_FIN_href_l)=@_;
    #$ipset_actual_data_dir_l=$ipset_actual_data_dir_g
    #$ipset_input_href_l=hash-ref for %ipset_input_l
	#key0=permanent/temporary,key1=inv-host;+ipset_template_name;+ipset_name ->
            #key2=add/del,key3=ipset_record (according to #ipset_type), value=1
    #inv_hosts_href_l=hash-ref for %inventory_hosts_g
    #$ipset_templates_href_l=hash-ref for %h01_conf_ipset_templates_hash_g
	#$h01_conf_ipset_templates_hash_g{'temporary/permanent'}{ipset_template_name--TMPLT}->
        #{'ipset_name'}=value
    #$h65_conf_initial_ipsets_content_FIN_href_l=hash-ref for %h65_conf_initial_ipsets_content_FIN_hash_g
	#$h65_conf_initial_ipsets_content_FIN_hash_g{ipset_template_name}->
    	    #{'record-0'}=1
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
            	    # One line - one record according to #ipset_type (conf-file "01_conf_ipset_templates").
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
            	    # One line - one record according to #ipset_type (conf-file "01_conf_ipset_templates"), but the record format is "expire datetime;+record associated with ipset_type".
            	    # Expire datetime has the format "YYYYMMDDHHMISS".
            	    # Expire date when adding an element to ipset via "ipset_input/add" is calculated as follows - current date + #ipset_create_option_timeout.
            	    # This file is for informational purposes only and cannot be used to recreate temporary sets.
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
    my ($inv_host_dir_line_l,$ipset_tmplt_name_dir_line_l)=(undef,undef);
    my $tmp_var_l=undef;
    
    my ($ipset_actual_permanent_dir_l,$ipset_actual_temporary_dir_l)=(undef,undef);
    
    my $ipset_create_date_actual_l=undef; # for date from 'actual__*'-file
    my ($file_ipset_name_actual_l,$ipset_name_actual_l,$ipset_type_actual_l)=(undef,undef,undef);
    my ($file_ipset_name_cfg_l,$ipset_name_cfg_l,$ipset_type_cfg_l)=(undef,undef);
    my $file_ipset_name_ch_hist_l=undef;
    my $change_hist_1line_l=undef;
    
    my @tmp_arr0_l=();
    
    my $dt_now_l=undef;
    
    my $ipset_actual_file_path_l=undef;
    
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
    
    # operations for permanent ipsets (BEGIN)
	#$ipset_input_href_l=hash-ref for %ipset_input_l
    	    #key0=permanent/temporary,key1=inv-host;+ipset_template_name;+ipset_name ->
        	#key2=add/del,key3=ipset_record (according to #ipset_type), value=1
    while ( ($hkey0_l,$hval0_l)=each %{${$ipset_input_href_l}{'permanent'}} ) {
	#hkey1_l=inv-host-0;+ipset_template_name-1;+ipset_name-2
	@tmp_arr0_l=split(/\;\+/,$hkey0_l);
	
	$ipset_actual_file_path_l=$ipset_actual_data_dir_l.'/'.$tmp_arr0_l[0].'/permanent/'.$tmp_arr0_l[1].'/actual__'.$tmp_arr0_l[2].'.txt';

	###
	read_actual_ipset_file_to_hash($ipset_actual_file_path_l,\%ipset_actual_file_data_hash_l);
	#$file_l,$href_l
	# %ipset_actual_file_data_hash_l=();
	# key0=content, key1=entry, value=expire_date (if=0 -> permanent ipset)
	# or key0=info, value=[array of info strings]
	###
	
	# ops for 'add' (permanent)
	while ( ($hkey1_l,$hval1_l)=each %{${$hval0_l}{'add'}} ) {
	    #$hkey1_l=ipset_record
	    #One row="ipset_entry" at actual*-file
	    if ( !exists($ipset_actual_file_data_hash_l{'content'}{$hkey1_l}) ) {
		$ipset_actual_file_data_hash_l{'content'}{$hkey1_l}=0;
	    }
	}
	
	($hkey1_l,$hval1_l)=(undef,undef);
	###

	# ops for 'del' (permanent)
	while ( ($hkey1_l,$hval1_l)=each %{${$hval0_l}{'del'}} ) {
	    #$hkey1_l=ipset_record
	    if ( exists($ipset_actual_file_data_hash_l{'content'}{$hkey1_l}) ) {
		delete($ipset_actual_file_data_hash_l{'content'}{$hkey1_l});
	    }
	}
		
	($hkey1_l,$hval1_l)=(undef,undef);
	###
	
	$ipset_actual_files_composition_hash_l{$ipset_actual_file_path_l}{'ipset_file_type'}=0;
	%{$ipset_actual_files_composition_hash_l{$ipset_actual_file_path_l}{'subhash'}}=(%ipset_actual_file_data_hash_l);
	%ipset_actual_file_data_hash_l=();
    }

    ($hkey0_l,$hval0_l)=(undef,undef);
    # operations for permanent ipsets (END)

    # operations for temporary ipsets (BEGIN)
    while ( ($hkey0_l,$hval0_l)=each %{${$ipset_input_href_l}{'temporary'}} ) {
	#hkey1_l=inv-host-0;+ipset_template_name-1;+ipset_name-2
	@tmp_arr0_l=split(/\;\+/,$hkey0_l);

	$ipset_actual_file_path_l=$ipset_actual_data_dir_l.'/'.$tmp_arr0_l[0].'/temporary/'.$tmp_arr0_l[1].'/actual__'.$tmp_arr0_l[2].'.txt';

	###
	&read_actual_ipset_file_to_hash($ipset_actual_file_path_l,\%ipset_actual_file_data_hash_l);
	#$file_l,$href_l
	# %ipset_actual_file_data_hash_l=();
	# key0=content, key1=entry, value=expire_date (if=0 -> permanent ipset)
	# or key0=info, value=[array of info strings]
	###
	
	# ops for 'add' (temporary)
	while ( ($hkey1_l,$hval1_l)=each %{${$hval0_l}{'add'}} ) {
	    #$hkey1_l=ipset_record
	    #One row="ipset_entry;+expire_date (format=YYYYMMDDHHMISS)" at actual*-file
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
		$expire_epoch_sec_actual_l=&dtot_conv_yyyymmddhhmiss_to_epoch_sec($expire_date_actual_l);
		#$for_conv_dt
		
		$expire_epoch_sec_calculated_l=time() + ${$ipset_templates_href_l}{$tmp_arr0_l[1]}{'ipset_create_option_timeout'};
		$expire_date_calculated_l=&conv_epoch_sec_to_yyyymmddhhmiss($expire_epoch_sec_calculated_l);
		#$for_conv_sec_l
		
		if ( $expire_epoch_sec_calculated_l>$expire_epoch_sec_actual_l ) {
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
	
	($hkey1_l,$hval1_l)=(undef,undef);
	###
	
	# ops for 'del' (temporary)
	while ( ($hkey1_l,$hval1_l)=each %{${$hval0_l}{'del'}} ) {
	    #$hkey1_l=ipset_record
	    if ( exists($ipset_actual_file_data_hash_l{'content'}{$hkey1_l}) ) {
		delete($ipset_actual_file_data_hash_l{'content'}{$hkey1_l});
	    }
	}
	
	($hkey1_l,$hval1_l)=(undef,undef);
	###

	$ipset_actual_files_composition_hash_l{$ipset_actual_file_path_l}{'ipset_file_type'}=1;
	%{$ipset_actual_files_composition_hash_l{$ipset_actual_file_path_l}{'subhash'}}=(%ipset_actual_file_data_hash_l);
	%ipset_actual_file_data_hash_l=();
    }
    
    ($hkey0_l,$hval0_l)=(undef,undef);
    # operations for temporary ipsets (END)

    ## FIN write to one actual*-file
    #&rewrite_actual_ipset_file_from_hash($ipset_actual_file_path_l,1,\%ipset_actual_file_data_hash_l);
    ##$file_l,$file_type_l,$href_l)=@_;
    ##$file_type_l: 0-permanent ipset, 1-temporary_ipset
    ####
    
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

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
