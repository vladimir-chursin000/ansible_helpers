sub read_uniq_lines_with_params_from_config {
    my ($file_l,$prms_per_line_l,$res_href_l)=@_;
    #file_l=simple config where one line=string with params
    #res_href_l=hash-ref for result-hash
    my $proc_name_l=(caller(0))[3];
        
    my ($line_l)=(undef);
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my ($hkey1_l,$hval1_l)=(undef,undef);
    my @str_arr_l=();
    my $return_str_l='OK';
    
    $prms_per_line_l=$prms_per_line_l-1;

    my %res_tmp_lv0_l=();
        #key=string with params, value=1

    if ( length($file_l)<1 or ! -e($file_l) ) { return "fail [$proc_name_l]. File='$file_l' is not exists"; }
    
    # read file
    open(CONF_LINES,'<',$file_l);
    while ( <CONF_LINES> ) {
        $line_l=$_;
        $line_l=~s/\n$|\r$|\n\r$|\r\n$//g;
        $line_l=~s/\#.*$//g;
        while ( $line_l=~/\t/ ) { $line_l=~s/\t/ /g; }
        $line_l=~s/\s+/ /g;
        $line_l=~s/^ //g;
        $line_l=~s/ $//g;

        $line_l=~s/ \./\./g;
        $line_l=~s/\. /\./g;

        $line_l=~s/ \,/\,/g;
        $line_l=~s/\, /\,/g;

        $line_l=~s/ \:/\:/g;
        $line_l=~s/\: /\:/g;

        $line_l=~s/ \=/\=/g;
        $line_l=~s/\= /\=/g;

        $line_l=~s/ \//\//g;
        $line_l=~s/\/ /\//g;

        if ( length($line_l)>0 && $line_l!~/^\#/ ) {
            if ( exists($res_tmp_lv0_l{$line_l}) ) { # duplicated value
                $return_str_l="fail [$proc_name_l]. Duplicated value ('$line_l') at file='$file_l'. Fix it!";
                last;
            }

	    (@str_arr_l)=$line_l=~/\S+/g;
	    
	    if ( $#str_arr_l!=$prms_per_line_l ) {
		$return_str_l="fail [$proc_name_l]. Conf-line='$line_l' must contain $prms_per_line_l params. Please, check and correct config-file ('$file_l')";
		last;
	    }
	    
            push(@{$res_tmp_lv0_l{'seq'}},$line_l);
            $res_tmp_lv0_l{$line_l}=[@str_arr_l];
	    
	    # clear vars
	    @str_arr_l=();
	    ###
        }
    }
    close(CONF_LINES);

    $line_l=undef;

    if ( $return_str_l!~/^OK$/ ) { return $return_str_l; } # check for return_str err after lv1-read
    ###

    # fill result hash
    %{$res_href_l}=%res_tmp_lv0_l;
    ###

    %res_tmp_lv0_l=();

    return $return_str_l;
}

sub read_conf_lines_with_priority_by_first_param {
    my ($file_l,$inv_hosts_href_l,$divisions_for_inv_hosts_href_l,$needed_elements_at_line_arr_l,$add_ind4key_l,$res_href_l)=@_;
    #$file_l=conf file
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
    open(CONF_LINES_WITH_PRIO,'<',$file_l);
    while ( <CONF_LINES_WITH_PRIO> ) {
    	$line_l=$_;
        $line_l=~s/\n$|\r$|\n\r$|\r\n$//g;
    	$line_l=~s/\#.*$//g;
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
    close(CONF_LINES_WITH_PRIO);
    
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
    
    # third read %res_tmp_lv0_l (for inv-host='list of inv hosts')
    while ( ($hkey0_l,$hval0_l)=each %res_tmp_lv0_l ) {
    	#%res_tmp_lv0_l
    	#key=inventory-host (arr-0 + arr with index=$add_ind4key_l), value=[arr-0,arr-1,arr-2,etc]
    	if ( ${$hval0_l}[0]=~/\,/ ) {
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
	    
	    delete($res_tmp_lv0_l{$hkey0_l});
	        
	    if ( $return_str_l!~/^OK$/ ) { last; }
	}
    }
    
    ($hkey0_l,$hval0_l)=(undef,undef);
    
    if ( $return_str_l!~/^OK$/ ) { return $return_str_l; }
    ###

    # third read %res_tmp_lv0_l (for inv-host='single hosts')
    while ( ($hkey0_l,$hval0_l)=each %res_tmp_lv0_l ) {
	#%res_tmp_lv0_l
	#key=inventory-host (arr-0 + arr with index=$add_ind4key_l), value=[arr-0,arr-1,arr-2,etc]
	    
	# check if exists at inventory-file
	if ( !exists(${$inv_hosts_href_l}{${$hval0_l}[0]}) ) {
	    $return_str_l="fail [$proc_name_l]. Err at conf_file='$file_l'. Inv-host='${$hval0_l}[0]' is not exists at inventory-file";
	    last;
	}
	###
		
	$key_ind_l=${$hval0_l}[0];
	if ( $add_ind4key_l>0 ) { $key_ind_l.='+'.${$hval0_l}[$add_ind4key_l]; }
	    	    
	$res_tmp_lv1_l{$key_ind_l}=[@{$hval0_l}[1..$#{$hval0_l}]];
	    	
	$key_ind_l=undef;
	
	delete($res_tmp_lv0_l{$hkey0_l});
	
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
