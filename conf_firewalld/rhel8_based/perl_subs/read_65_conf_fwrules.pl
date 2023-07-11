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
    my ($arr_el0_l)=(undef);
    my ($host_str_l,$ipset_entry_str_l)=(undef,undef);
    my ($host_list_el_l,$ipset_entry_list_el_l)=(undef,undef);
    my $host_type_l=undef;
    my @host_types_l=('all','group','list_of_hosts','single_host');
    my @host_list_arr_l=();
    my @ipset_entry_list_arr_l=();
    my @tmp_arr0_l=();
    
    my $return_str_l='OK';

    my %res_tmp_lv0_l=();
        #key0=ipset_template_name,key1="all/group/list_of_hosts/single_host=ipset_entry_list", value=1
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
    
    # read/search ipset_entries at %res_tmp_lv0_l and write it to %res_tmp_lv1_l
    while ( ($hkey0_l,$hval0_l)=each %res_tmp_lv0_l ) { # while %res_tmp_lv0_l (begin)
    	#$hkey0_l=ipset_template_name
    	@tmp_arr0_l=@{${$hval0_l}{'seq'}};
    	    	
    	foreach $host_type_l ( @host_types_l ) { # foreach -> @host_types_l (begin)
    	    #$host_type_l='all','group','list_of_hosts','single_host' (sequence)
    	    
    	    foreach $arr_el0_l ( @tmp_arr0_l ) { # foreach -> @tmp_arr0_l (begin)
    	    	#$arr_el0_l="all/group/list_of_hosts/single_host=ipset_entry_list"
    	    	$arr_el0_l=~s/ \,/\,/g;
    	    	$arr_el0_l=~s/\, /\,/g;
    	    	
    	    	$arr_el0_l=~s/ \//\//g;
    	    	$arr_el0_l=~s/\/ /\//g;
    	    	
    	    	($host_str_l,$ipset_entry_str_l)=split(/\=/,$arr_el0_l);
		if ( length($host_str_l)<1 ) {
		    $return_str_l="fail [$proc_name_l]. Host for cfg_string='$arr_el0_l' (ipset_tmplt_name='$hkey0_l') is empty at '65_conf_initial_ipsets_content_FIN'";
		    last;
		}
    	    	
    	    	@ipset_entry_list_arr_l=split(/\,/,$ipset_entry_str_l);
		if ( $#ipset_entry_list_arr_l==-1 ) {
		    $return_str_l="fail [$proc_name_l]. IPSET_ENTRIES_LIST for ipset_tmplt_name='$hkey0_l' and host='$host_str_l' is empty at '65_conf_initial_ipsets_content_FIN'";
		    last;
		}
    	    	
    	    	# for 'all'		
    	    	if ( $host_type_l eq 'all' && $host_str_l eq 'all' ) {
    	    	    while ( ($hkey1_l,$hval1_l)=each %{$inv_hosts_href_l} ) {
            	    	#$hkey1_l=inv-host from inv-host-hash
    	    	    	
			foreach $ipset_entry_list_el_l ( @ipset_entry_list_arr_l ) {
			    if ( !exists($res_tmp_lv1_l{$hkey1_l}{$hkey0_l}{$ipset_entry_list_el_l}) ) {
				$res_tmp_lv1_l{$hkey1_l}{$hkey0_l}{$ipset_entry_list_el_l}=1;
				push(@{$res_tmp_lv1_l{$hkey1_l}{$hkey0_l}{'seq'}},$ipset_entry_list_el_l);
			    }
			}
			
			$ipset_entry_list_el_l=undef; # clear vars
    	    	    }
    	    	    
    	    	    # clear vars
    	    	    ($hkey1_l,$hval1_l)=(undef,undef);
    	    	    ###
    	    	}
    	    	###
    	    	    
    	    	# for 'group'
    	    	if ( $host_type_l eq 'group' && $host_str_l=~/^gr\_\S+$/ ) {
    	    	    if ( !exists(${$divisions_for_inv_hosts_href_l}{$host_str_l}) ) {
			$return_str_l="fail [$proc_name_l].Group='$host_str_l' is not configured at '00_conf_divisions_for_inv_hosts' (ipset_tmplt_name='$hkey0_l', linked config='65_conf_initial_ipsets_content_FIN')";
			last;
		    }
		    
		    while ( ($hkey1_l,$hval1_l)=each %{${$divisions_for_inv_hosts_href_l}{$host_str_l}} ) {
			#$hkey1_l=inv-host
			
			foreach $ipset_entry_list_el_l ( @ipset_entry_list_arr_l ) {
			    if ( !exists($res_tmp_lv1_l{$hkey1_l}{$hkey0_l}{$ipset_entry_list_el_l}) ) {
				$res_tmp_lv1_l{$hkey1_l}{$hkey0_l}{$ipset_entry_list_el_l}=1;
				push(@{$res_tmp_lv1_l{$hkey1_l}{$hkey0_l}{'seq'}},$ipset_entry_list_el_l);
			    }
			}
			
			$ipset_entry_list_el_l=undef; # clear vars
		    }
    	    	}
    	    	###
    	    	    
    	    	# for 'list_of_hosts'
    	    	if ( $host_type_l eq 'list_of_hosts' && $host_str_l=~/\,/ && $host_str_l!~/all|gr\_\S+/ ) {
    	    	    
    	    	}
    	    	###
    	    	
    	    	# for 'single_host'
    	    	if ( $host_type_l eq 'single_host' && $host_str_l!~/\,|^gr\_\S+|^all$/ ) {
    	    	    	
    	    	}
    	    	###
    	    	
    	    	# clear vars
    	    	($host_str_l,$ipset_entry_str_l)=(undef,undef);
    	    	@ipset_entry_list_arr_l=();
    	    	###
    	    	
    	    	if ( $return_str_l!~/^OK$/ ) { last; }
    	    } # foreach -> @tmp_arr0_l (end)
    	    
    	    # clear vars
    	    $arr_el0_l=undef;
    	    ###
    	    
    	    if ( $return_str_l!~/^OK$/ ) { last; }    
    	} # foreach -> @host_types_l (end)
    	
    	# clear vars
	$host_type_l=undef;
    	$arr_el0_l=undef;
    	@tmp_arr0_l=();
    	###
    	
    	if ( $return_str_l!~/^OK$/ ) { last; }
    } # while %res_tmp_lv0_l (end)

    ($hkey0_l,$hval0_l)=(undef,undef); # clear vars

    if ( $return_str_l!~/^OK$/ ) { return $return_str_l; }
    ###
    
    # fill result hash aka $h65_conf_initial_ipsets_content_FIN_hash_g
    %{$res_href_l}=%res_tmp_lv1_l;
    ###
    
    %res_tmp_lv1_l=();
    
    return $return_str_l;
}

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
