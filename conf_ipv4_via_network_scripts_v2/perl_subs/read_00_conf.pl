sub read_00_conf_divisions_for_inv_hosts {
    my ($file_l,$inv_hosts_href_l,$res_href_l)=@_;
    #file_l=$f00_conf_divisions_for_inv_hosts_path_g
    #inv_hosts_href_l=hash-ref for %inventory_hosts_g
    #res_href_l=hash-ref for %h00_conf_divisions_for_inv_hosts_hash_g
    my $proc_name_l=(caller(0))[3];
    
    my ($line_l,$arr_el0_l)=(undef,undef);
    my @arr0_l=();
    my @arr1_l=();
    my %group_uniq_hosts_l=();
        #key0=inv-host, value=group_name
    my $return_str_l='OK';
    
    if ( length($file_l)<1 or ! -e($file_l) ) { return "fail [$proc_name_l]. File='$file_l' is not exists"; }
    
    # read from file (begin)
    open(GROUP_HOSTS,'<',$file_l);
    while ( <GROUP_HOSTS> ) {
        $line_l=$_;
        $line_l=~s/\n$|\r$|\n\r$|\r\n$//g;
        while ($line_l=~/\t/) { $line_l=~s/\t/ /g; }
        $line_l=~s/\s+/ /g;
        $line_l=~s/^ //g;
        $line_l=~s/ $//g;
	
        $line_l=~s/\, /\,/g;
        $line_l=~s/ \,/\,/g;
	
        if ( length($line_l)>0 && $line_l!~/^\#/ ) {
            #DIVISION_NAME/GROUP_NAME       #LIST_OF_HOSTS
            ###
            #$h00_conf_divisions_for_inv_hosts_hash_g{group_name}{inv-host}=1;
            ###
            @arr0_l=split(' ',$line_l);
            if ( $arr0_l[0]!~/^gr_/ ) {
                $return_str_l="fail [$proc_name_l]. Group='$arr0_l[0]'. The group name must start with the substring 'gr_' (at conf '00_conf_divisions_for_inv_hosts')";
                last;
            }
            
            if ( $arr0_l[0]=~/^gr_all$/i ) {
                $return_str_l="fail [$proc_name_l]. Deny using group name like '$arr0_l[0]' at conf '00_conf_divisions_for_inv_hosts'";
                last;
            }
            
            @arr1_l=split(',',$arr0_l[1]);
            foreach $arr_el0_l ( @arr1_l ) {
                #$arr0_l[0]=group-name
                #$arr_el0_l=inv-host
		
                if ( !exists(${$inv_hosts_href_l}{$arr_el0_l}) ) {
                    $return_str_l="fail [$proc_name_l]. Inv-host='$arr_el0_l' is not exists at inventory-file (conf '00_conf_divisions_for_inv_hosts')";
                    last;
                }
		
                if ( exists($group_uniq_hosts_l{$arr_el0_l}) ) {
                    $return_str_l="fail [$proc_name_l]. Inv-host='$arr_el0_l' is already used for host_group='$group_uniq_hosts_l{$arr_el0_l}' at conf '00_conf_divisions_for_inv_hosts'";
                    last;
                }
                
                $group_uniq_hosts_l{$arr_el0_l}=$arr0_l[0];
                ${$res_href_l}{$arr0_l[0]}{$arr_el0_l}=1;
            }
            
            $arr_el0_l=undef;
            @arr0_l=();
            @arr1_l=();
	    
            if ( $return_str_l!~/^OK$/ ) { last; }
        }
    }
    close(GROUP_HOSTS);
    
    # clear vars
    $line_l=undef;
    ###
    # read from file (end)
    
    if ( $return_str_l!~/OK$/ ) { return $return_str_l; }
    
    return $return_str_l;
}

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
