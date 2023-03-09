sub read_00_conf_divisions_for_inv_hosts {
    my ($file_l,$inv_hosts_href_l,$res_href_l)=@_;
    #file_l=$f00_conf_firewalld_path_g
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

    $line_l=undef;

    if ( $return_str_l!~/OK$/ ) { return $return_str_l; }

    return $return_str_l;
}

sub read_00_conf_firewalld {
    my ($file_l,$inv_hosts_href_l,$divisions_for_inv_hosts_href_l,$res_href_l)=@_;
    #file_l=$f00_conf_firewalld_path_g
    #inv_hosts_href_l=hash-ref for %inventory_hosts_g
    #$divisions_for_inv_hosts_href_l=hash-ref for %h00_conf_divisions_for_inv_hosts_hash_g
    #res_href_l=hash-ref for %h00_conf_firewalld_hash_g
    my $proc_name_l=(caller(0))[3];

    #[firewall_conf_for_all--TMPLT:BEGIN]
    #host_list_for_apply=all
    #unconfigured_custom_firewall_zones_action=no_action
    #temporary_apply_fwrules_timeout=10
    #if_no_ipsets_conf_action=no_action
    #if_no_zones_conf_action=no_action
    #if_no_policies_conf_action=no_action
    #DefaultZone=public
    #CleanupOnExit=yes
    #CleanupModulesOnExit=yes
    #Lockdown=no
    #IPv6_rpfilter=yes
    #IndividualCalls=no
    #LogDenied=off
    #enable_logging_of_dropped_packets=no
    #FirewallBackend=nftables
    #FlushAllOnReload=yes
    #RFC3964_IPv4=yes
    #AllowZoneDrifting=no
    #[firewall_conf_for_all--TMPLT:END]
    ###
    #$h00_conf_firewalld_hash_g{inventory_host}->
    #{'unconfigured_custom_firewall_zones_action'}=no_action|remove
    #{'temporary_apply_fwrules_timeout'}=NUM
    #{'if_no_ipsets_conf_action'}=remove|no_action
    #{'if_no_zones_conf_action'}=restore_defaults|no_action
    #{'if_no_policies_conf_action'}=remove|no_action
    #{'DefaultZone'}=name_of_default_zone
    #{'CleanupOnExit'}=yes|no
    #{'CleanupModulesOnExit'}=yes|no
    #{'Lockdown'}=yes|no
    #{'IPv6_rpfilter'}=yes|no
    #{'IndividualCalls'}=yes|no
    #{'LogDenied'}=all|unicast|broadcast|multicast|off
    #{'enable_logging_of_dropped_packets'}=yes|no
    #{'FirewallBackend'}=nftables|iptables
    #{'FlushAllOnReload'}=yes|no
    #{'RFC3964_IPv4'}=yes|no
    #{'AllowZoneDrifting'}=yes|no

    #DIVISION_NAME/GROUP_NAME       #LIST_OF_HOSTS
    ###
    #$h00_conf_divisions_for_inv_hosts_hash_g{group_name}{inv-host}=1;
    ###

    my $arr_el0_l=undef;
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my ($hkey1_l,$hval1_l)=(undef,undef);
    my $exec_res_l=undef;
    my $return_str_l='OK';
    
    my @inv_hosts_arr_l=();

    my %res_tmp_lv0_l=();
        #key0=tmplt_name, key1=param, value=value filtered by regex
    my %res_tmp_lv1_l=();
        #key0=inv-host, key1=param (except = host_list_for_apply), value=hash ref for %res_tmp_lv0_l
    my %cfg_params_and_regex_l=(
        'host_list_for_apply'=>'^all$|\S+',
        'unconfigured_custom_firewall_zones_action'=>'^no_action$|^remove$',
        'temporary_apply_fwrules_timeout'=>'^\d+$',
        'if_no_ipsets_conf_action'=>'^no_action$|^remove$',
        'if_no_zones_conf_action'=>'^no_action$|^restore_defaults$',
        'if_no_policies_conf_action'=>'^no_action$|^remove$',
        'DefaultZone'=>'^\S+$',
        'CleanupOnExit'=>'^yes$|^no$',
        'CleanupModulesOnExit'=>'^yes$|^no$',
        'Lockdown'=>'^yes$|^no$',
        'IPv6_rpfilter'=>'^yes$|^no$',
        'IndividualCalls'=>'^yes$|^no$',
        'LogDenied'=>'^all$|^unicast$|^broadcast$|^multicast$|^off$',
        'enable_logging_of_dropped_packets'=>'^yes$|^no$',
        'FirewallBackend'=>'^nftables$|^iptables$',
        'FlushAllOnReload'=>'^yes$|^no$',
        'RFC3964_IPv4'=>'^yes$|^no$',
        'AllowZoneDrifting'=>'^yes$|^no$'
    );
    
    $exec_res_l=&read_param_value_templates_from_config($file_l,\%cfg_params_and_regex_l,\%res_tmp_lv0_l);
    #$file_l,$regex_href_l,$res_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }

    # fill res_tmp_lv1_l
    while ( ($hkey0_l,$hval0_l)=each %res_tmp_lv0_l ) { # read only host_list_for_apply=all
        #hkey0_l=tmplt_name, hval0_l=hash of params
        if ( ${$hval0_l}{'host_list_for_apply'} eq 'all' ) {
            while ( ($hkey1_l,$hval1_l)=each %{$inv_hosts_href_l} ) {
                #$hkey1_l=inv-host from inv-host-hash
                push(@inv_hosts_arr_l,$hkey1_l);
            }

            ($hkey1_l,$hval1_l)=(undef,undef);

            foreach $arr_el0_l ( @inv_hosts_arr_l ) {
                #arr_el0_l=inv-host
                %{$res_tmp_lv1_l{$arr_el0_l}}=%{$hval0_l};
            }
            
            $arr_el0_l=undef;
            @inv_hosts_arr_l=();

            delete($res_tmp_lv0_l{$hkey0_l});
        }
    }
    
    ($hkey0_l,$hval0_l)=(undef,undef);
    
    while ( ($hkey0_l,$hval0_l)=each %res_tmp_lv0_l ) { # read only host_list_for_apply=host groups
        #hkey0_l=tmplt_name, hval0_l=hash of params
    
        if ( ${$hval0_l}{'host_list_for_apply'}=~/^gr_/ && exists(${$divisions_for_inv_hosts_href_l}{${$hval0_l}{'host_list_for_apply'}}) ) {
            while ( ($hkey1_l,$hval1_l)=each %{${$divisions_for_inv_hosts_href_l}{${$hval0_l}{'host_list_for_apply'}}} ) {
                #hkey1_l=inv-host
                %{$res_tmp_lv1_l{$hkey1_l}}=%{$hval0_l};
            }
                
            ($hkey1_l,$hval1_l)=(undef,undef);
            
            delete($res_tmp_lv0_l{$hkey0_l});
        }
        elsif ( ${$hval0_l}{'host_list_for_apply'}=~/^gr_/ && !exists(${$divisions_for_inv_hosts_href_l}{${$hval0_l}{'host_list_for_apply'}}) ) {
            $return_str_l="fail [$proc_name_l]. Group='${$hval0_l}{'host_list_for_apply'}' is not configured at '00_conf_divisions_for_inv_hosts'";
            last;
        }
    }
    
    while ( ($hkey0_l,$hval0_l)=each %res_tmp_lv0_l ) { # read only host_list_for_apply=some host or list of hosts (separated by ',')
        #hkey0_l=tmplt_name, hval0_l=hash of params
        @inv_hosts_arr_l=split(/\,/,${$hval0_l}{'host_list_for_apply'});

        foreach $arr_el0_l ( @inv_hosts_arr_l ) {
            #arr_el0_l=inv-host
            if ( !exists(${$inv_hosts_href_l}{$arr_el0_l}) ) {
                $return_str_l="fail [$proc_name_l]. Host='$arr_el0_l' is not exists at inventory file";
                last;
            }

            %{$res_tmp_lv1_l{$arr_el0_l}}=%{$hval0_l};
        }
        
        $arr_el0_l=undef;
        @inv_hosts_arr_l=();
        
        delete($res_tmp_lv0_l{$hkey0_l});
    }
    
    ($hkey0_l,$hval0_l)=(undef,undef);
    @inv_hosts_arr_l=();
    %res_tmp_lv0_l=();
    ###

    # check for not existing configs for inv-hosts
    while ( ($hkey0_l,$hval0_l)=each %{$inv_hosts_href_l} ) {
        # hkey0_l = inv-host-name
        if ( !exists($res_tmp_lv1_l{$hkey0_l}) ) {
            $return_str_l="fail [$proc_name_l]. Host='$hkey0_l' have not configuration";
            last;
        }
    }

    ($hkey0_l,$hval0_l)=(undef,undef);

    if ( $return_str_l!~/OK$/ ) { return $return_str_l; }

    ###

    # fill result hash
    %{$res_href_l}=%res_tmp_lv1_l;
    ###

    %res_tmp_lv1_l=();

    return $return_str_l;
}
