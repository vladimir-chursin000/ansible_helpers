###NO DEPENDENCIES

sub read_param_value_templates_from_config {
    my ($file_l,$regex_href_l,$res_href_l)=@_;
    #file_l=config with templates
    #regex_href_l=hash-ref for %cfg_params_and_regex_l
    #res_href_l=hash-ref for result-hash
    my $proc_name_l=(caller(0))[3];

    my ($line_l)=(undef);
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my ($hkey1_l,$hval1_l)=(undef,undef);
    my ($read_tmplt_flag_l)=(0);
    my ($tmplt_name_begin_l,$tmplt_name_end_l)=(undef,undef);
    my $return_str_l='OK';

    my @split_arr0_l=();

    my %res_tmp_lv0_l=();
	#key0=tmplt_name, key1=param, value=value filtered by regex
    my %uniq_tmplt_name_check_l=();
	#key=tmplt_name, value=1
    
    if ( length($file_l)<1 or ! -e($file_l) ) { return "fail [$proc_name_l]. File='$file_l' is not exists"; }

    # read file
    open(CONF_TMPLT,'<',$file_l);
    while ( <CONF_TMPLT> ) {
        $line_l=$_;
        $line_l=~s/\n$|\r$|\n\r$|\r\n$//g;
        while ($line_l=~/\t/) { $line_l=~s/\t/ /g; }
        $line_l=~s/\s+/ /g;
        $line_l=~s/^ //g;
	$line_l=~s/ $//g;
	
	$line_l=~s/ \,/\,/g;
	$line_l=~s/\, /\,/g;

	$line_l=~s/ \=/\=/g;
	$line_l=~s/\= /\=/g;

        if ( length($line_l)>0 && $line_l!~/^\#/ ) {
	    if ( $line_l=~/^\[(\S+\-\-TMPLT)\:BEGIN\]$/ ) { # if cfg block begin
		$tmplt_name_begin_l=$1;
		$read_tmplt_flag_l=1;
		if ( exists($uniq_tmplt_name_check_l{$tmplt_name_begin_l}) ) {
		    $return_str_l="fail [$proc_name_l]. Duplicated template='$tmplt_name_begin_l'. Check and correct config='$file_l'";
		    last;
		}
		$uniq_tmplt_name_check_l{$tmplt_name_begin_l}=1;
	    }
	    elsif ( $read_tmplt_flag_l==1 && $line_l=~/^\[(\S+\-\-TMPLT)\:END\]$/ ) { # if cfg block ends
		$tmplt_name_end_l=$1;
		if ( $tmplt_name_begin_l eq $tmplt_name_end_l ) { # if correct begin and end of template
		    $read_tmplt_flag_l=0;
		    $tmplt_name_begin_l='notmplt';
		}
		else { # if incorrect begin and end of template
		    $return_str_l="fail [$proc_name_l]. Tmplt_name_begin ('$tmplt_name_begin_l') != tmplt_name_end ('$tmplt_name_end_l'). Check and correct config='$file_l'";
		    last;
		}
	    }
	    elsif ( $read_tmplt_flag_l==1 && $tmplt_name_begin_l ne 'notmplt' ) { # if cfg param + value
		@split_arr0_l=split(/\=/,$line_l);
		
		if ( exists(${$regex_href_l}{$split_arr0_l[0]}) && $split_arr0_l[1]=~/${$regex_href_l}{$split_arr0_l[0]}/ ) {
		    ($res_tmp_lv0_l{$tmplt_name_begin_l}{$split_arr0_l[0]})=$split_arr0_l[1]=~/(${$regex_href_l}{$split_arr0_l[0]})/;
		}
		elsif ( exists(${$regex_href_l}{$split_arr0_l[0]}) && $split_arr0_l[1]!~/${$regex_href_l}{$split_arr0_l[0]}/ ) {
		    $return_str_l="fail [$proc_name_l]. For param='$split_arr0_l[0]' value ('$split_arr0_l[1]') is incorrect (tmplt_name='$tmplt_name_begin_l')";
		    last;
		}
		elsif ( !exists(${$regex_href_l}{$split_arr0_l[0]}) ) {
		    $return_str_l="fail [$proc_name_l]. Param='$split_arr0_l[0]' is not allowed (tmplt_name='$tmplt_name_begin_l')";
		    last;
		}
		@split_arr0_l=();
	    }
	}
    }
    close(CONF_TMPLT);
        
    $line_l=undef;
    ($tmplt_name_begin_l,$tmplt_name_end_l)=(undef,undef);
    @split_arr0_l=();

    if ( $return_str_l!~/^OK$/ ) { return $return_str_l; } # check for return_str err after lv1-read
    ###

    # check for not existsing params
    while ( ($hkey0_l,$hval0_l)=each %res_tmp_lv0_l ) {
	# hkey0_l = tmplt_name
	# hval0_l = hash with params
	while ( ($hkey1_l,$hval1_l)=each %{$regex_href_l} ) {
	    #hkey1_l = param
	    if ( !exists(${$hval0_l}{$hkey1_l}) ) {
		$return_str_l="fail [$proc_name_l]. Param '$hkey1_l' is not exists at cfg for tmplt_name='$hkey0_l'";
		last;
	    }
	}
	if ( $return_str_l!~/^OK$/ ) { last; }
    }
    
    ($hkey0_l,$hval0_l)=(undef,undef);
    ($hkey1_l,$hval1_l)=(undef,undef);
    
    if ( $return_str_l!~/^OK$/ ) { return $return_str_l; } # check for return_str err after 'check for not existsing params'
    ###

    # fill result hash
    %{$res_href_l}=%res_tmp_lv0_l;
    ###
    
    %res_tmp_lv0_l=();
    
    return $return_str_l;
}

sub read_param_only_templates_from_config {
    my ($file_l,$res_href_l)=@_;
    #file_l=config with templates
    #res_href_l=hash-ref for result-hash
    my $proc_name_l=(caller(0))[3];

    my ($line_l)=(undef);
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my ($hkey1_l,$hval1_l)=(undef,undef);
    my ($read_tmplt_flag_l)=(0);
    my ($tmplt_name_begin_l,$tmplt_name_end_l)=(undef,undef);
    my $return_str_l='OK';

    my @split_arr0_l=();

    my %res_tmp_lv0_l=();
	#key=param, value=1
    my %uniq_tmplt_name_check_l=();
	#key=tmplt_name, value=1
    
    if ( length($file_l)<1 or ! -e($file_l) ) { return "fail [$proc_name_l]. File='$file_l' is not exists"; }

    # read file
    open(CONF_TMPLT,'<',$file_l);
    while ( <CONF_TMPLT> ) {
        $line_l=$_;
        $line_l=~s/\n$|\r$|\n\r$|\r\n$//g;
        while ($line_l=~/\t/) { $line_l=~s/\t/ /g; }
        $line_l=~s/\s+/ /g;
        $line_l=~s/^ //g;
	$line_l=~s/ $//g;
	
	$line_l=~s/ \./\./g;
	$line_l=~s/\. /\./g;

	$line_l=~s/ \:/\:/g;
	$line_l=~s/\: /\:/g;

	$line_l=~s/ \=/\=/g;
	$line_l=~s/\= /\=/g;

        if ( length($line_l)>0 && $line_l!~/^\#/ ) {
	    if ( $line_l=~/^\[(\S+)\:BEGIN\]$/ ) { # if cfg block begin
		$tmplt_name_begin_l=$1;
		$read_tmplt_flag_l=1;
		if ( exists($uniq_tmplt_name_check_l{$tmplt_name_begin_l}) ) {
		    $return_str_l="fail [$proc_name_l]. Duplicated template='$tmplt_name_begin_l'. Check and correct config='$file_l'";
		    last;
		}
		$uniq_tmplt_name_check_l{$tmplt_name_begin_l}=1;
	    }
	    elsif ( $read_tmplt_flag_l==1 && $line_l=~/^\[(\S+)\:END\]$/ ) { # if cfg block ends
		$tmplt_name_end_l=$1;
		if ( $tmplt_name_begin_l eq $tmplt_name_end_l ) { # if correct begin and end of template
		    $read_tmplt_flag_l=0;
		    $tmplt_name_begin_l='notmplt';
		}
		else { # if incorrect begin and end of template
		    $return_str_l="fail [$proc_name_l]. Tmplt_name_begin ('$tmplt_name_begin_l') != tmplt_name_end ('$tmplt_name_end_l'). Check and correct config='$file_l'";
		    last;
		}
	    }
	    elsif ( $read_tmplt_flag_l==1 && $tmplt_name_begin_l ne 'notmplt' ) { # if param str
		if ( !exists($res_tmp_lv0_l{$tmplt_name_begin_l}{$line_l}) ) {
		    push(@{$res_tmp_lv0_l{$tmplt_name_begin_l}{'seq'}},$line_l);
		    $res_tmp_lv0_l{$tmplt_name_begin_l}{$line_l}=1;
		}
		else { # duplicated value
		    $return_str_l="fail [$proc_name_l]. Duplicated value ('$line_l') at file='$file_l' for tmplt='$tmplt_name_begin_l'. Fix it!";
		    last;
		}
	    }
	}
    }
    close(CONF_TMPLT);
        
    $line_l=undef;
    ($tmplt_name_begin_l,$tmplt_name_end_l)=(undef,undef);

    if ( $return_str_l!~/^OK$/ ) { return $return_str_l; } # check for return_str err after lv1-read
    ###

    # fill result hash
    %{$res_href_l}=%res_tmp_lv0_l;
    ###
    
    %res_tmp_lv0_l=();
    
    return $return_str_l;    
}

sub postprocessing_v1_after_read_param_value_templates_from_config {
    my ($file_l,$param_list_regex_for_postproc_l,$src_href_l,$res_href_l)=@_;
    #$param_list_regex_for_postproc_l = string like '^zone_allowed_services$|^zone_allowed_protocols$|^zone_icmp_block$|^zone_allowed_ports$|^zone_allowed_source_ports$'
    #$src_href_l=hash ref for result hash of '&read_templates_from_config'
    #$res_href_lhash ref for result hash
    my $proc_name_l=(caller(0))[3];
    
    my $arr_el0_l=undef;
    my $exec_res_l=undef;
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my ($hkey1_l,$hval1_l)=(undef,undef);
    my @split_arr0_l=();
    my $return_str_l='OK';
    
    while ( ($hkey0_l,$hval0_l)=each %{$src_href_l} ) { # cycle 0
	#hkey0_l=zone_tmpltname, hval0_l=hash ref with params and values
	while ( ($hkey1_l,$hval1_l)=each %{$hval0_l} ) { # cycle 1
	    #hkey1_l=param_name, hval1_l=param_value
	    if ( $hkey1_l=~/$param_list_regex_for_postproc_l/ ) { #if regex list params
		if ( $hval1_l!~/^empty$/ ) { # if regex list params and value is not empty
		    @split_arr0_l=split(/\,/,$hval1_l);
		    foreach $arr_el0_l ( @split_arr0_l ) { # cycle 2
			#$arr_el0_l=port/port_type or port_begin-port_end/port_type
			if ( $hkey1_l=~/_ports$/ ) { # if need to check values with ports (udp/tcp)
			    $arr_el0_l=~s/\/ /\//g;
			    $arr_el0_l=~s/ \//\//g;
			    $exec_res_l=&check_port_for_apply_to_fw_conf($arr_el0_l);
			    #$port_str_l
			    if ( $exec_res_l=~/^fail/ ) { # exit from cycle 2 if error
				$return_str_l="fail [$proc_name_l] -> ".$exec_res_l;
				last;
			    }
			}
			
			if ( !exists(${$res_href_l}{$hkey0_l}{$hkey1_l}{'list'}{$arr_el0_l}) ) {
			    push(@{${$res_href_l}{$hkey0_l}{$hkey1_l}{'seq'}},$arr_el0_l);
			    ${$res_href_l}{$hkey0_l}{$hkey1_l}{'list'}{$arr_el0_l}=1;
			}
			else { # duplicate list-value
			    $return_str_l="fail [$proc_name_l]. Duplicated list-value ('$arr_el0_l') at file='$file_l' for tmlt='$hkey0_l'. Fix it!";
			    last;
			}
		    } # cycle 2
		    
		    $arr_el0_l=undef;
		    @split_arr0_l=();
		    
		    if ( $return_str_l!~/^OK$/ ) { last; } # exit from cycle 1 if at cycle 2 catched error
		}
		else { ${$res_href_l}{$hkey0_l}{$hkey1_l}{'empty'}=1; } # regex params and value = empty
	    }
	    else { ${$res_href_l}{$hkey0_l}{$hkey1_l}=$hval1_l; } # just param=value
	} # cycle 1
	
	($hkey1_l,$hval1_l)=(undef,undef);
	
	if ( $return_str_l!~/^OK$/ ) { last; } # exit from cycle 0 if at cycle 1/2 catched error
    } # cycle 0
    
    ($hkey0_l,$hval0_l)=(undef,undef);
    ($hkey1_l,$hval1_l)=(undef,undef);
    %{$src_href_l}=();
    
    return $return_str_l;
}

sub read_config_FIN_level0 {
    my ($file_l,$inv_hosts_href_l,$divisions_for_inv_hosts_href_l,$needed_elements_at_line_arr_l,$add_ind4key_l,$res_href_l)=@_;
    #$file_l=fin conf file '66_conf_ipsets_FIN/77_conf_zones_FIN/88_conf_policies_FIN'
    #inv_hosts_href_l=hash-ref for %inventory_hosts_g
    #$divisions_for_inv_hosts_href_l=hash-ref for %h00_conf_divisions_for_inv_hosts_hash_g
	#$h00_conf_divisions_for_inv_hosts_hash_g{group-name}{inv-host}=1;
    #$needed_elements_at_line_arr_l=needed count of elements at array formed from line
    #$add_ind4key_l (addditional index of array for hash-key)=by default at result hash key=first element of array (with 0 index), but if set add_ind_l -> key="0+add_ind_l"
    #res_href_l=hash ref for result-hash
	#key=inventory-host (arr-0), value=[arr-1,arr-2,etc]
    ###
    
    my $proc_name_l=(caller(0))[3];
    
    my ($line_l)=(undef);
    my ($arr_el0_l)=(undef);
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my ($hkey1_l,$hval1_l)=(undef,undef);
    my ($arr_cnt_l,$key_ind_l)=(undef,undef);
    my $inv_hosts_group_name_l=undef;
    my %key_ind_cnt_l=();
	#key=$key_ind_l, value=1
    my @arr0_l=();
    my @arr1_l=();
    my %res_tmp_lv0_l=();
	#key=inventory-host (arr-0 + arr with index=$add_ind4key_l), value=[arr-0,arr-1,arr-2,etc]
    my %res_tmp_lv1_l=();
	#key=inventory-host (arr-0 + arr with index=$add_ind4key_l), value=[arr-1,arr-2,etc] (AFTER prereturnPROCESSING)
    my $return_str_l='OK';
    
    if ( length($file_l)<1 or ! -e($file_l) ) { return "fail [$proc_name_l]. File='$file_l' is not exists"; }

    # read conf file
    open(CONF_FIN,'<',$file_l);
    while ( <CONF_FIN> ) {
	$line_l=$_;
        $line_l=~s/\n$|\r$|\n\r$|\r\n$//g;
        while ($line_l=~/\t/) { $line_l=~s/\t/ /g; }
        $line_l=~s/\s+/ /g;
        $line_l=~s/^ //g;
	$line_l=~s/ $//g;

	if ( length($line_l)>0 && $line_l!~/^\#/ ) {
	    $line_l=~s/ \,/\,/g;
	    $line_l=~s/\, /\,/g;

	    @arr0_l=$line_l=~/(\S+)/g;
	    
	    # arr0_l element count check
	    $arr_cnt_l=$#arr0_l+1;
	    if ( $arr_cnt_l!=$needed_elements_at_line_arr_l ) {
		$return_str_l="fail [$proc_name_l]. Count of params at string of cfg-file='$file_l' must be = $needed_elements_at_line_arr_l";
		last;
	    }
	    ###

	    # key-ind uniq check
	    $key_ind_l=$arr0_l[0];
	    if ( $add_ind4key_l>0 ) { $key_ind_l.='+'.$arr0_l[$add_ind4key_l]; }
	    if ( !exists($key_ind_cnt_l{$key_ind_l}) ) { $key_ind_cnt_l{$key_ind_l}=1; }
	    else {
		$return_str_l="fail [$proc_name_l]. At conf='$file_l' can be only one param 'inventory-host' with value like '$key_ind_l'. Check config and run again";
		last;
	    }
	    ###
	    
	    $res_tmp_lv0_l{$key_ind_l}=[@arr0_l];
	    
	    $key_ind_l=undef;
	    @arr0_l=();
	}
    }
    close(CONF_FIN);
    
    $line_l=undef;
    $key_ind_l=undef;
    @arr0_l=();
    
    if ( $return_str_l!~/^OK$/ ) { return $return_str_l; }
    ###
    
    # first read %res_tmp_lv0_l (for inv-host='all')
    while ( ($hkey0_l,$hval0_l)=each %res_tmp_lv0_l ) {
	#%res_tmp_lv0_l
	#key=inventory-host (arr-0 + arr with index=$add_ind4key_l), value=[arr-0,arr-1,arr-2,etc]
	
	if ( ${$hval0_l}[0] eq 'all' ) {
	    while ( ($hkey1_l,$hval1_l)=each %{$inv_hosts_href_l} ) {
            	#$hkey1_l=inv-host from inv-host-hash
	    	$key_ind_l=$hkey1_l;
	    	if ( $add_ind4key_l>0 ) { $key_ind_l.='+'.${$hval0_l}[$add_ind4key_l]; }
	    	
	    	$res_tmp_lv1_l{$key_ind_l}=[@{$hval0_l}[1..$#{$hval0_l}]];
		
		$key_ind_l=undef;
    	    }
	    
	    ($hkey1_l,$hval1_l)=(undef,undef);
	    ###
	    delete($res_tmp_lv0_l{$hkey0_l});
	}
    }
    
    ($hkey0_l,$hval0_l)=(undef,undef);
    ###

    # second read %res_tmp_lv0_l (for inv-host='some_group')
    while ( ($hkey0_l,$hval0_l)=each %res_tmp_lv0_l ) {
	#%res_tmp_lv0_l
	#key=inventory-host (arr-0 + arr with index=$add_ind4key_l), value=[arr-0,arr-1,arr-2,etc]
	
	# check for group-name inside the list (via ",")
	if ( ${$hval0_l}[0]=~/gr_\S+/ && ${$hval0_l}[0]=~/\,/ ) {
	    $return_str_l="fail [$proc_name_l]. Err at conf_file='$file_l'. Deny to include group-name ('${$hval0_l}[0]') to the list separated by ','.";
	    last;
	}
	###
	
	if ( ${$hval0_l}[0]=~/^(gr_\S+)$/ ) {
	    #$divisions_for_inv_hosts_href_l=hash-ref for %h00_conf_divisions_for_inv_hosts_hash_g
    		#$h00_conf_divisions_for_inv_hosts_hash_g{group-name}{inv-host}=1;
	    $inv_hosts_group_name_l=$1;
	    
	    # check for exists at '00_conf_divisions_for_inv_hosts'
	    if ( !exists(${$divisions_for_inv_hosts_href_l}{$inv_hosts_group_name_l}) ) {
		$return_str_l="fail [$proc_name_l]. Err at conf_file='$file_l'. Inv-group='$inv_hosts_group_name_l' is not configured at '00_conf_divisions_for_inv_hosts'";
		last;
	    }
	    ###
	    
	    while ( ($hkey1_l,$hval1_l)=each %{${$divisions_for_inv_hosts_href_l}{$inv_hosts_group_name_l}} ) {
		#$hkey1_l=inv-host
		$key_ind_l=$hkey1_l;
	    	if ( $add_ind4key_l>0 ) { $key_ind_l.='+'.${$hval0_l}[$add_ind4key_l]; }
	    	
	    	$res_tmp_lv1_l{$key_ind_l}=[@{$hval0_l}[1..$#{$hval0_l}]];
		
		$key_ind_l=undef;
	    }
	    
	    ($hkey1_l,$hval1_l)=(undef,undef);
	    $inv_hosts_group_name_l=undef;
	    ###
	    delete($res_tmp_lv0_l{$hkey0_l});
	}
    }
    
    ($hkey0_l,$hval0_l)=(undef,undef);
    
    if ( $return_str_l!~/^OK$/ ) { return $return_str_l; }
    ###

    # third (last) read %res_tmp_lv0_l (for inv-host='some inv-host' or inv-host='list of inv hosts')
    while ( ($hkey0_l,$hval0_l)=each %res_tmp_lv0_l ) {
	#%res_tmp_lv0_l
	#key=inventory-host (arr-0 + arr with index=$add_ind4key_l), value=[arr-0,arr-1,arr-2,etc]
	@arr0_l=split(/\,/,${$hval0_l}[0]);
	foreach $arr_el0_l ( @arr0_l ) {
	    #$arr_el0_l=inv-host
	    
	    # check if exists at inventory-file
	    if ( !exists(${$inv_hosts_href_l}{$arr_el0_l}) ) {
		$return_str_l="fail [$proc_name_l]. Err at conf_file='$file_l'. Inv-host='$arr_el0_l' is not exists at inventory-file";
		last;
	    }
	    ###
	    
	    $key_ind_l=$arr_el0_l;
	    if ( $add_ind4key_l>0 ) { $key_ind_l.='+'.${$hval0_l}[$add_ind4key_l]; }
	    	
	    $res_tmp_lv1_l{$key_ind_l}=[@{$hval0_l}[1..$#{$hval0_l}]];
	    	
	    $key_ind_l=undef;
	}
	
	$arr_el0_l=undef;
	@arr0_l=();
	
	if ( $return_str_l!~/^OK$/ ) { last; }
    }
    
    ($hkey0_l,$hval0_l)=(undef,undef);
    
    if ( $return_str_l!~/^OK$/ ) { return $return_str_l; }
    ###

    # fill result hash
    %{$res_href_l}=%res_tmp_lv1_l;
    ###
    
    %res_tmp_lv1_l=();
    
    return $return_str_l;
}

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
