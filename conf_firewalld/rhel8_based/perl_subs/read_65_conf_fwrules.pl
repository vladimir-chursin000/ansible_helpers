###DEPENDENCIES: read_conf_fwrules_common.pl

sub read_65_conf_initial_ipsets_content_FIN {
    my ($file_l,$inv_hosts_href_l,$divisions_for_inv_hosts_href_l,$ipset_templates_href_l,$res_href_l)=@_;
    #file_l=$f65_conf_initial_ipsets_content_FIN_path_g
    #inv_hosts_href_l=hash-ref for %inventory_hosts_g
    #$divisions_for_inv_hosts_href_l=hash-ref for %h00_conf_divisions_for_inv_hosts_hash_g
        #$h00_conf_divisions_for_inv_hosts_hash_g{group_name}{inv-host}=1;
    #$ipset_templates_href_l=hash-ref for %h01_conf_ipset_templates_hash_g
    #res_href_l=hash-ref for %h66_conf_ipsets_FIN_hash_g
    my $proc_name_l=(caller(0))[3];

    # This CFG only for permanent ipset templates (if "#ipset_create_option_timeout=0").
    #[IPSET_TEMPLATE_NAME:BEGIN]
    # one row = "all/group_name/list_of_hosts/host=ipset_entry0,ipset_entry1,ipset_entry2,ipset_entryN"
	# If "all" -> the configuration will be applied to all inventory hosts.
	# Priority (from lower to higher): all (0), group name from conf '00_conf_divisions_for_inv_hosts' (1), list of inventory hosts separated by "," or individual hosts (2).
	# ipset_entries -> accoring to "#ipset_type" of conf file "01_conf_ipset_templates"
    #[IPSET_TEMPLATE_NAME:END]
    ###
    #$h01_conf_ipset_templates_hash_g{'temporary/permanent'}{ipset_template_name--TMPLT}->
    #{'ipset_name'}=value
    #{'ipset_description'}=empty|value
    #{'ipset_short_description'}=empty|value
    #{'ipset_create_option_timeout'}=num
    #{'ipset_create_option_hashsize'}=num
    #{'ipset_create_option_maxelem'}=num
    #{'ipset_create_option_family'}=inet|inet6
    #{'ipset_type'}=hash:ip|hash:ip,port|hash:ip,mark|hash:net|hash:net,port|hash:net,iface|hash:mac|hash:ip,port,ip|hash:ip,port,net|hash:net,net|hash:net,port,net
    ###
    #$h65_conf_initial_ipsets_content_FIN_hash_g{inv-host}{ipset_template_name}->
	#{'record-0'}=1 (record=ipset_entry)
	#{'rerord-1'}=1
	#etc
	#{'seq'}=[val-0,val-1] (val=record)
    ######

    my $exec_res_l=undef;
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my ($hkey1_l,$hval1_l)=(undef,undef);
    my ($arr_el0_l,$arr_el1_l)=(undef,undef);
    my ($host_str_l,$ipset_entry_str_l)=(undef,undef);
    my @tmp_arr0_l=();
    my @tmp_arr1_l=();
    
    my $return_str_l='OK';

    my %res_tmp_lv0_l=();
        #key0=ipset_template_name,key1="all/group/list_of_hosts/host=ipset_entry_list", value=1
    	#...+ key1=seq, value=[array of vals]
    
    my %res_tmp_lv1_l=();
    
    $exec_res_l=&read_param_only_templates_from_config($file_l,\%res_tmp_lv0_l);
    #$file_l,$res_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }
    
    # check for temporary ipset templates (DENY)
    while ( ($hkey0_l,$hval0_l)=each %res_tmp_lv0_l ) {
    	#$hkey0_l=ipset_template_name
    	if ( !exists(${$ipset_templates_href_l}{$hkey0_l}) ) {
    	    $return_str_l="fail [$proc_name_l]. IPSET_TMPLT='$hkey0_l' configured at '65_conf_initial_ipsets_content_FIN' is not exists at '01_conf_ipset_templates'";
    	    last;
    	}
    	if ( ${$ipset_templates_href_l}{$hkey0_l}{'ipset_create_option_timeout'}>0 ) {
    	    $return_str_l="fail [$proc_name_l]. IPSET_TMPLT='$hkey0_l' is not permanent";
    	    last;
    	}
    }
    
    ($hkey0_l,$hval0_l)=(undef,undef);
    
    if ( $return_str_l!~/^OK$/ ) { return $return_str_l; }
    ###
    
    # read/search ipset_entries at %res_tmp_lv0_l for 'all' and write it to %res_tmp_lv1_l
    while ( ($hkey0_l,$hval0_l)=each %res_tmp_lv0_l ) {
    	#$hkey0_l=ipset_template_name
    	@tmp_arr0_l=@{${$hval0_l}{'seq'}};
    	
    	foreach $arr_el0_l ( @tmp_arr0_l ) {
    	    #$arr_el0_l="all/group/list_of_hosts/host=ipset_entry_list"
	    $arr_el0_l=~s/ \,/\,/g;
    	    $arr_el0_l=~s/\, /\,/g;

	    $arr_el0_l=~s/ \//\//g;
    	    $arr_el0_l=~s/\/ /\//g;
	
    	    ($host_str_l,$ipset_entry_str_l)=split(/\=/,$arr_el0_l);
	    
	    if ( $host_str_l eq 'all' ) {
		
	    }
    	    
    	    # clear vars
    	    ($host_str_l,$ipset_entry_str_l)=(undef,undef);
    	    ###
    	}
    	
    	# clear vars
    	$arr_el0_l=undef;
    	@tmp_arr0_l=();
    	###
    }
    
    ($hkey0_l,$hval0_l)=(undef,undef);
    ###
    
    # read/search ipset_entries at %res_tmp_lv0_l for 'groups' and write it to %res_tmp_lv1_l
    while ( ($hkey0_l,$hval0_l)=each %res_tmp_lv0_l ) {
    	#$hkey0_l=ipset_template_name
    	@tmp_arr0_l=@{${$hval0_l}{'seq'}};
    
    	foreach $arr_el0_l ( @tmp_arr0_l ) {
    	    #$arr_el0_l="all/group/list_of_hosts/host=ipset_entry_list"
    	    ($host_str_l,$ipset_entry_str_l)=split(/\=/,$arr_el0_l);
    
    	    # clear vars
    	    ($host_str_l,$ipset_entry_str_l)=(undef,undef);
    	    ###
    	}
    
    	# clear vars
    	$arr_el0_l=undef;
    	@tmp_arr0_l=();
    	###
    }
    
    ($hkey0_l,$hval0_l)=(undef,undef);
    ###
    
    # read/search ipset_entries at %res_tmp_lv0_l for 'list_of_hosts' and write it to %res_tmp_lv1_l
    while ( ($hkey0_l,$hval0_l)=each %res_tmp_lv0_l ) {
    	#$hkey0_l=ipset_template_name
    	@tmp_arr0_l=@{${$hval0_l}{'seq'}};
    	
    	foreach $arr_el0_l ( @tmp_arr0_l ) {
    	    #$arr_el0_l="all/group/list_of_hosts/host=ipset_entry_list"
    	    ($host_str_l,$ipset_entry_str_l)=split(/\=/,$arr_el0_l);
    	    
    	    # clear vars
    	    ($host_str_l,$ipset_entry_str_l)=(undef,undef);
    	    ###
    	}
    
    	# clear vars
    	$arr_el0_l=undef;
    	@tmp_arr0_l=();
    	###
    }
    
    ($hkey0_l,$hval0_l)=(undef,undef);
    ###
    
    # read/search ipset_entries at %res_tmp_lv0_l for 'one-host' and write it to %res_tmp_lv1_l
    while ( ($hkey0_l,$hval0_l)=each %res_tmp_lv0_l ) {
    	#$hkey0_l=ipset_template_name
    	@tmp_arr_l=@{${$hval0_l}{'seq'}};
    
    	foreach $arr_el0_l ( @tmp_arr0_l ) {
    	    #$arr_el0_l="all/group/list_of_hosts/host=ipset_entry_list"
    	    ($host_str_l,$ipset_entry_str_l)=split(/\=/,$arr_el0_l);
    	    
    	    # clear vars
    	    ($host_str_l,$ipset_entry_str_l)=(undef,undef);
    	    ###
    	}
    
    	# clear vars
    	$arr_el0_l=undef;
    	@tmp_arr_l=();
    	###
    }

    ($hkey0_l,$hval0_l)=(undef,undef);
    ###
    
    # fill result hash aka $h65_conf_initial_ipsets_content_FIN_hash_g
    %{$res_href_l}=%res_tmp_lv1_l;
    ###
    
    %res_tmp_lv1_l=();
    
    return $return_str_l;
}

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
