sub read_inventory_file {
    my ($file_l,$res_href_l)=@_;
    #file_l=$inventory_conf_path_g, res_href_l=hash-ref for %inventory_hosts_g
    my $proc_name_l=(caller(0))[3];
    
    my ($line_l,$start_read_hosts_flag_l,$value_cnt_l)=(undef,0,0);
    
    if ( length($file_l)<1 or ! -e($file_l) ) { return "fail [$proc_name_l]. File='$file_l' is not exists"; }
    
    open(INVDATA,'<',$file_l);
    while ( <INVDATA> ) {
        $line_l=$_;
        $line_l=~s/\n$|\r$|\n\r$|\r\n$//g;
        $line_l=~s/\#.*$//g;
        while ($line_l=~/\t/) { $line_l=~s/\t/ /g; }
        $line_l=~s/\s+/ /g;
        $line_l=~s/^ //g;
        $line_l=~s/ $//g;
        if ( length($line_l)>0 && $line_l!~/^\#/ ) {
            if ( $line_l=~/^\[network_scripts_conf_dedic_app_v1\]/ && $start_read_hosts_flag_l==0 ) { $start_read_hosts_flag_l=1; }
            elsif ( $start_read_hosts_flag_l==1 && $line_l=~/^\[network_scripts_conf_dedic_app_v1\:vars\]/ ) {
                $start_read_hosts_flag_l=0;
                last;
            }
            elsif ( $start_read_hosts_flag_l==1 ) {
                ${$res_href_l}{$line_l}=1;
                $value_cnt_l++;
            }
        }
    }
    close(INVDATA);

    ($line_l,$start_read_hosts_flag_l)=(undef,undef);

    if ( $value_cnt_l<1 ) { return "fail [$proc_name_l]. No needed data at file='$file_l'"; }

    return 'OK';
}

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
	    $arr0_l[2]=lc($arr0_l[2]);
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

sub modify_inv_hosts_hash1 {
    my ($dyn_ifcfg_common_dir_l,$ifcfg_backup_from_remote_dir_l,$ifcfg_backup_from_remote_nd_file_l,$inv_hosts_ifcfg_del_not_configured_href_l,$res_href_l)=@_;
    #$dyn_ifcfg_common_dir_l=$dyn_ifcfg_common_dir_g
    #$ifcfg_backup_from_remote_dir_l=$ifcfg_backup_from_remote_dir_g
    #$ifcfg_backup_from_remote_nd_file_l=$ifcfg_backup_from_remote_nd_file_g
    #$inv_hosts_ifcfg_del_not_configured_href_l=hash ref for %inv_hosts_ifcfg_del_not_configured_g
    #$res_href_l=hash ref for %inv_hosts_hash1_g
    my $proc_name_l=(caller(0))[3];

    my ($hkey0_l,$hval0_l)=(undef,undef);
    my ($hkey1_l,$hval1_l)=(undef,undef);
    my ($tmp_var_l,$exec_res_l)=(undef,undef);
    my $return_str_l='OK';

    #%inv_hosts_hash1_g=(); #key0=inv_host, key1=now/fin (generated by this script)/for_upd/for_del, key2=ifcfg_name
    while ( ($hkey0_l,$hval0_l)=each %{$res_href_l} ) {
        #hkey0_l=inv_host, hval0_l=hash
        while ( ($hkey1_l,$hval1_l)=each %{${$hval0_l}{'fin'}} ) { #just only configure interfaces from '00_config'
            #hkey1_l=ifcfg_name
            if ( !exists(${$hval0_l}{'now'}{$hkey1_l}) ) { #new interface -> for_upd
                ${$res_href_l}{$hkey0_l}{'for_upd'}{$hkey1_l}=1;
            }
            else {
                $exec_res_l=&ifcfg_diff_with_zone_param_save("$dyn_ifcfg_common_dir_l/$hkey0_l/fin/$hkey1_l","$ifcfg_backup_from_remote_dir_l/$hkey0_l/$hkey1_l");
                #$ifcfg_generated_file_l,$ifcfg_from_remote_file_l

                if ( $exec_res_l>0 ) { #if generated ifcfg (fin) not eq actual (now) -> for_upd
                    ${$res_href_l}{$hkey0_l}{'for_upd'}{$hkey1_l}=1;
                }
            }
        }
        ($hkey1_l,$hval1_l)=(undef,undef);

        if ( exists(${$inv_hosts_ifcfg_del_not_configured_href_l}{$hkey0_l}) ) { #if need to configure AND to delete not configured at '00_config' interfaces
            while ( ($hkey1_l,$hval1_l)=each %{${$hval0_l}{'now'}} ) {
                #hkey1_l=ifcfg_name

                #$ifcfg_backup_from_remote_nd_file_l = file for grep-check. If ifcfg-int at this file for cur inv_host -> no 'ip link delete'
                if ( !exists(${$hval0_l}{'fin'}{$hkey1_l}) ) { #interface for delete -> for_del
                    $tmp_var_l=$hkey1_l;
                    $tmp_var_l=~s/^ifcfg\-//g; # now-ifcfg-name without 'ifcfg-'
                    $exec_res_l=`grep -a $hkey0_l $ifcfg_backup_from_remote_nd_file_l | grep $tmp_var_l | wc -l`;
		    #hkey0_l=inv-host
		    #ifcfg_backup_from_remote_nd_file_l=path to 'inv_hosts_interfaces_info.txt'
                    $exec_res_l=~s/\n|\r|\n\r|\r\n//g;
                    $exec_res_l=int($exec_res_l);

                    ${$res_href_l}{$hkey0_l}{'for_del'}{$hkey1_l}=1; # just shutdown and delete ifcfg-file

                    if ( $exec_res_l!=1 ) { # not exists at 'fin' (generated) and interface-name not exists at remote host
                        ${$res_href_l}{$hkey0_l}{'for_del_ip_link'}{$tmp_var_l}=1; # if included (means not interface-ifcfg) -> 'ip link delete'
                    }

                    ($tmp_var_l,$exec_res_l)=(undef,undef);
                }
            }
            ($hkey1_l,$hval1_l)=(undef,undef);
            ($tmp_var_l,$exec_res_l)=(undef,undef);
        }
    }
    ($hkey0_l,$hval0_l)=(undef,undef);
    ($hkey1_l,$hval1_l)=(undef,undef);

    return $return_str_l;
}

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
