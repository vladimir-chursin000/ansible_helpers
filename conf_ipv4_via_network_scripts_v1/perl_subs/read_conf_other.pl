sub read_network_data_for_checks {
    my ($file_l,$res_href_l)=@_;
    #file_l=$ifcfg_backup_from_remote_nd_file_g
    #res_href_l=hash-ref for %inv_hosts_network_data_g
    my $proc_name_l=(caller(0))[3];

    my ($line_l,$value_cnt_l)=(undef,0);
    my @arr0_l=undef;
    
    if ( length($file_l)<1 or ! -e($file_l) ) { return "fail [$proc_name_l]. File='$file_l' is not exists"; }
    
    open(NDATA,'<',$file_l);
    while ( <NDATA> ) {
        $line_l=$_;
        $line_l=~s/\n$|\r$|\n\r$|\r\n$//g;
        while ($line_l=~/\t/) { $line_l=~s/\t/ /g; }
        $line_l=~s/\s+/ /g;
        $line_l=~s/^ //g;
        $line_l=~s/ $//g;
        if ( length($line_l)>0 && $line_l!~/^\#/ ) {
            #INV_HOST-0       #INT_NAME-1       #HWADDR-2
            @arr0_l=split(' ',$line_l);
            ${$res_href_l}{'hwaddr_all'}{$arr0_l[2]}=$arr0_l[0];
            ${$res_href_l}{'inv_host'}{$arr0_l[0]}{$arr0_l[1]}{$arr0_l[2]}=1;
            $value_cnt_l++;
        }
    }
    close(NDATA);

    $line_l=undef;

    if ( $value_cnt_l<1 ) { return "fail [$proc_name_l]. No needed data at file='$file_l'"; }

    return 'OK';
}

sub fill_inv_hosts_hash1_with_fin_n_now_dirs {
    my ($dyn_ifcfg_common_dir_l,$ifcfg_backup_from_remote_dir_l,$inv_hosts_hash0_href_l,$res_href_l)=@_;
    #$dyn_ifcfg_common_dir_l=$dyn_ifcfg_common_dir_g
    #$ifcfg_backup_from_remote_dir_l=$ifcfg_backup_from_remote_dir_g
    #$inv_hosts_hash0_href_l=hash ref for %inv_hosts_hash0_g
    #$res_href_l=hash ref for %inv_hosts_hash1_g
    my $proc_name_l=(caller(0))[3];

    my $line_l=undef;
    my $is_wireless_interface_l=0; # if == 1 (is wireless interface) -> ignore (no add to res_href_l)
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my $return_str_l='OK';

    while ( ($hkey0_l,$hval0_l)=each %{$inv_hosts_hash0_href_l} ) {
        #hkey0_g=inv_host
        opendir(DIR_FIN,$dyn_ifcfg_common_dir_l.'/'.$hkey0_l.'/fin');
        while ( readdir DIR_FIN ) {
            $line_l=$_;
            if ( $line_l!~/^\./ ) {
                ${$res_href_l}{$hkey0_l}{'fin'}{$line_l}=1;
            }
        }
        closedir(DIR_FIN);
    
        opendir(DIR_NOW,$ifcfg_backup_from_remote_dir_l.'/'.$hkey0_l);
        while ( readdir DIR_NOW ) {
            $line_l=$_;
            if ( $line_l=~/^\./ ) { next; }

            $is_wireless_interface_l=`grep -i 'TYPE=Wireless' "$ifcfg_backup_from_remote_dir_l/$hkey0_l/$line_l" | wc -l`;

            if ( $line_l!~/^\.|^ifcfg\-lo$/ && $is_wireless_interface_l!=1 ) {
                ${$res_href_l}{$hkey0_l}{'now'}{$line_l}=1;
            }
           
            # clear vars
            $line_l=undef;
            $is_wireless_interface_l=0;
            ###
        }
        closedir(DIR_NOW);

        delete(${$inv_hosts_hash0_href_l}{$hkey0_l});
    }
    
    $line_l=undef;
    ($hkey0_l,$hval0_l)=(undef,undef);
    
    return $return_str_l;
}

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
