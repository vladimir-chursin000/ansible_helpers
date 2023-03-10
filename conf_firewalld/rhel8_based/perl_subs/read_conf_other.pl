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
        while ($line_l=~/\t/) { $line_l=~s/\t/ /g; }
        $line_l=~s/\s+/ /g;
        $line_l=~s/^ //g;
        $line_l=~s/ $//g;
        if ( length($line_l)>0 && $line_l!~/^\#/ ) {
            if ( $line_l=~/^\[rhel8_firewall_hosts\]/ && $start_read_hosts_flag_l==0 ) { $start_read_hosts_flag_l=1; }
            elsif ( $start_read_hosts_flag_l==1 && $line_l=~/^\[rhel8_firewall_hosts\:vars\]/ ) {
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
    my @arr0_l=();

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
            #INV_HOST-0       #INT_NAME-1       #IPADDR-2
            #$inv_hosts_network_data_g{inv_host}{int_name}=ipaddr
            ###
            @arr0_l=split(' ',$line_l);
            ${$res_href_l}{$arr0_l[0]}{$arr0_l[1]}=$arr0_l[2];
            $value_cnt_l++;
        }
    }
    close(NDATA);

    $line_l=undef;

    if ( $value_cnt_l<1 ) { return "fail [$proc_name_l]. No needed data at file='$file_l'"; }

    return 'OK';
}

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
