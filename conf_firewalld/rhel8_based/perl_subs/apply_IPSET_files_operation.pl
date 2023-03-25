###DEPENDENCIES: file_operations.pl

sub apply_IPSET_files_operation_main {
    my ($dyn_ipsets_files_dir_l,$ipset_input_dir_l,$ipset_actual_data_dir_l,$input_hash4proc_href_l)=@_;
    #$dyn_ipsets_files_dir_l=$dyn_ipsets_files_dir_g
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

    $exec_res_l=&read_ipset_input($ipset_input_dir_l,$inv_hosts_href_l,$divisions_for_inv_hosts_href_l,$ipset_templates_href_l,$h66_conf_ipsets_FIN_href_l,\%ipset_input_l);
    #$ipset_input_dir_l,$inv_hosts_href_l,$divisions_for_inv_hosts_href_l,$ipset_templates_href_l,$h66_conf_ipsets_FIN_href_l,$res_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }
    $exec_res_l=undef;

    ######
    
    return $return_str_l;
}

sub read_ipset_input {
    my ($ipset_input_dir_l,$inv_hosts_href_l,$divisions_for_inv_hosts_href_l,$ipset_templates_href_l,$h66_conf_ipsets_FIN_href_l,$res_href_l)=@_;
    #$ipset_input_dir_l=$ipset_input_dir_g
    #inv_hosts_href_l=hash-ref for %inventory_hosts_g
    #$divisions_for_inv_hosts_href_l=hash-ref for %h00_conf_divisions_for_inv_hosts_hash_g
    #$ipset_templates_href_l=hash-ref for %h01_conf_ipset_templates_hash_g
    #$h66_conf_ipsets_FIN_href_l=hash-ref for \%h66_conf_ipsets_FIN_hash_g
    #$res_href_l=hash-ref for %ipset_input_l

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

    my $return_str_l='OK';

    return $return_str_l;
}

sub update_ipset_actual_data {
    
}
#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
