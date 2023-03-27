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

    my $h66_conf_ipsets_FIN_href_l=${$input_hash4proc_href_l}{'h66_conf_ipsets_FIN_href'};
    #$h66_conf_ipsets_FIN_href_l=hash-ref for \%h66_conf_ipsets_FIN_hash_g
        #$h66_conf_ipsets_FIN_hash_g{'temporary/permanent'}{inventory_host}->
            #{ipset_name_tmplt-0}=1;
            #{ipset_name_tmplt-1}=1;
            #etc
    
    my ($exec_res_l)=(undef);
    my %ipset_input_l=();
	#key0=temporary/permanent,key1=inv-host,key2=ipset_template_name,key3=ipset_name ->
	    #key4=add -> ipset_record (according to #ipset_type)
	    #key4=del -> ipset_record (according to #ipset_type)
    
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

    $exec_res_l=&update_local_ipset_actual_data($ipset_actual_data_dir_l,\%ipset_input_l,$inv_hosts_href_l,$ipset_templates_href_l,$h66_conf_ipsets_FIN_href_l);
    #$ipset_actual_data_dir_l,$ipset_input_href_l,$inv_hosts_href_l,$ipset_templates_href_l,$h66_conf_ipsets_FIN_href_l
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
    #$ipset_templates_href_l=hash-ref for %h01_conf_ipset_templates_hash_g
    #$h66_conf_ipsets_FIN_href_l=hash-ref for \%h66_conf_ipsets_FIN_hash_g
    #$res_href_l=hash-ref for %ipset_input_l
	#my %ipset_input_l=();
        #key0=temporary/permanent,key1=inv-host,key2=ipset_template_name,key3=ipset_name ->
            #key4=add -> ipset_record (according to #ipset_type)
            #key4=del -> ipset_record (according to #ipset_type)


    #The directory ("ipset_input") is intended for preprocessing incoming data for ipset.
    #"ipset_input/add" - dir for add entries to some_ipset (for permanent and temporary sets).
	# Add-file name format VER1 - "inventory_host--ipset_template_name.txt". For add entry to ipset at one inv-host.
	# Add-file name format VER2 - "all--ipset_template_name.txt". For add entry to ipset at all inventory hosts.
	# Add-file name format VER3 - "gr_some_group--ipset_template_name.txt". For add entry to ipset at hosts of the group (configured at "00_conf_divisions_for_inv_hosts").
    	    # One line - one record according to #ipset_type (conf-file "01_conf_ipset_templates").

    #"ipset_input/del" - dir for delete entries from some_ipset. Only for permanent sets (when #ipset_create_option_timeout=0).
	# Delete-file name format VER1 - "inventory_host--ipset_template_name.txt". For remove entry from ipset at one inv-host.
	# Delete-file name format VER2 - "all--ipset_template_name.txt". For remove entry from ipset at all inventory hosts.
	# Delete-file name format VER3 - "gr_some_group--ipset_template_name.txt". For remove entry from ipset at hosts of the group (configured at "00_conf_divisions_for_inv_hosts").
    	    # One line - one record according to #ipset_type (conf-file "01_conf_ipset_templates").

    #"ipset_input/history" - dir for save add/del history.
	# File name format - "DATE-history.log"
    	    # Record format - "datetime;+temporary/permanent;+inventory-host;+ipset_template_name;+ipset_name;+add/del;+ipset_type-record;+status"
            # Datetime format - YYYYMMDDHHMISS.
            # Status = OK / error (incorrect ip-address, etc).
	#/incorrect_input_files/... (dir)
    	    # Move here only if:
        	# 1) incorrect add/del-file format (no VER1/VER2/VER3).
        	# 2) not configured "ipset_template_name" for all inventory-hosts (VER1/VER2/VER3).
    	#    /add/... (dir)
    	#    /del/... (dir)
	#/correct_input_files/... (dir)
    	#    /add/... (dir)
    	#    /del/... (dir)

    my $return_str_l='OK';

    return $return_str_l;
}

sub update_local_ipset_actual_data {
    my ($ipset_actual_data_dir_l,$ipset_input_href_l,$inv_hosts_href_l,$ipset_templates_href_l,$h66_conf_ipsets_FIN_href_l)=@_;
    #$ipset_actual_data_dir_l=$ipset_actual_data_dir_g
    #$ipset_input_href_l=hash-ref for %ipset_input_l
    #inv_hosts_href_l=hash-ref for %inventory_hosts_g
    #$ipset_templates_href_l=hash-ref for %h01_conf_ipset_templates_hash_g
    #$h66_conf_ipsets_FIN_href_l=hash-ref for \%h66_conf_ipsets_FIN_hash_g
    
    #Directory structure
    #...ipset_actual_data/inv-host/... (dir)
    	    #permanent/ipset_template_name/... (dir)
        	#actual--ipset_name.txt (file)
            	    # First line - description like "###You CAN manually ADD entries to this file!".
            	    # Second line - "datetime of creation" + "ipset_type" in the format "###YYYYMMDDHHMISS;+IPSET_TYPE".
            	    # One line - one record according to #ipset_type (conf-file "01_conf_ipset_templates").
            	    # This file can be used to recreate the set if it was deleted (for some reason) on the side of the inventory host.
            	    # You can manually add entries (according to ipset_type) to this file.
        	#/change_history/ (dir)
            	    #CHANGE_DATETIME--ipset_name.txt (file)
                	# For move "actual--ipset_name.txt" here (to this dir) with rename if changed ipset_name or ipset_type.

    	    #temporary/ipset_template_name/.. (dir)
        	#actual--ipset_name.txt (file)
            	    # First line - description like "###Manually ADDING entries to this file is DENIED!".
            	    # Second line - "datetime of creation" + "ipset_type" in the format "###YYYYMMDDHHMISS;+IPSET_TYPE".
            	    # One line - one record according to #ipset_type (conf-file "01_conf_ipset_templates"), but the record format is "expire datetime;+record associated with ipset_type".
            	    # Expire datetime has the format "YYYYMMDDHHMISS".
            	    # Expire date when adding an element to ipset via "ipset_input/add" is calculated as follows - current date + #ipset_create_option_timeout.
            	    # This file is for informational purposes only and cannot be used to recreate temporary sets.
        	#/change_history/ (dir)
            	    #CHANGE_DATETIME--ipset_name.txt (file)
                	# For move "actual--ipset_name.txt" here (to this dir) with rename if changed ipset_name or ipset_type.
                	# First line - "datetime of creation->datetime of change" + "old_ipset_type->new_ipset_type" + "old_ipset_name->new_ipset_name"
                    	    # in the format "###YYYYMMDDHHMISS->YYYYMMDDHHMISS;+OLD_IPSET_TYPE->NEW_IPSET_TYPE;+OLD_IPSET_NAME->NEW_IPSET_NAME".

    	    #delete_history/... (dir)
        	# If the ownership of "ipset template_name" is changed (via config "66_conf_ipsets_FIN"), then the ipset data and change history
            	# are moved to this directory.
        	#permanent/DEL_DATETIME-ipset_template_name/... (dir)
            	    #actual--ipset_name.txt (file)
            	    #/change_history/ (dir)
        	#temporary/DEL_DATETIME-ipset_template_name/... (dir)
            	    #actual--ipset_name.txt (file)
            	    #/change_history/ (dir)

    my $return_str_l='OK';

    return $return_str_l;
}

sub form_local_dyn_ipsets_files_for_copy_to_remote {
    my ($remote_ipset_dir_for_absible_helper_l,$dyn_ipsets_files_dir_l)=@_;
    #$remote_ipset_dir_for_absible_helper_l=$remote_ipset_dir_for_absible_helper_g
    #$dyn_ipsets_files_dir_l=$dyn_ipsets_files_dir_g -> #for copy to REMOTE_HOST:'$HOME/ansible_helpers/conf_firewalld/ipset_files'
	#...scripts_for_remote/fwrules_files/ipset_files/add_queue/inv-host
	#...scripts_for_remote/fwrules_files/ipset_files/remove_queue/inv-host
    
}
#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
