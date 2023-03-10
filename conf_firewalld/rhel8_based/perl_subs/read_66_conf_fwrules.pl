sub read_66_conf_ipsets_FIN {
    my ($file_l,$inv_hosts_href_l,$divisions_for_inv_hosts_href_l,$ipset_templates_href_l,$res_href_l)=@_;
    #$file_l=$f66_conf_ipsets_FIN_path_g
    #inv_hosts_href_l=hash-ref for %inventory_hosts_g
    #$divisions_for_inv_hosts_href_l=hash-ref for %h00_conf_divisions_for_inv_hosts_hash_g
        #$h00_conf_divisions_for_inv_hosts_hash_g{group_name}{inv-host}=1;
    #$ipset_templates_href_l=hash-ref for %h01_conf_ipset_templates_hash_g
    #$res_href_l=hash ref for %h66_conf_ipsets_FIN_hash_g


    my $proc_name_l=(caller(0))[3];

    #INVENTORY_HOST         #IPSET_NAME_TMPLT_LIST
    #all                    ipset1--TMPLT,ipset4all_public--TMPLT (example)
    #10.3.2.2               ipset4public--TMPLT (example)
    ###
    #$h66_conf_ipsets_FIN_hash_g{'temporary/permanent'}{inventory_host}->
        #{ipset_name_tmplt-0}=1;
        #{ipset_name_tmplt-1}=1;
        #etc
    ###

    my $exec_res_l=undef;
    my $arr_el0_l=undef;
    my $ipset_type_l=undef; # temporary / permanent
    my $ipset_name_l=undef;
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my @arr0_l=();
    my $return_str_l='OK';

    my %ipset_uniq_check_l=();
        #key0=inv-host, key1=ipset_name (not tmplt-name), value=1

    my %res_tmp_lv0_l=();
        #key=inv-host, value=[array of values]. IPSET_NAME_TMPLT_LIST-0
    my %res_tmp_lv1_l=();
        #final hash

    $exec_res_l=&read_config_FIN_level0($file_l,$inv_hosts_href_l,$divisions_for_inv_hosts_href_l,2,0,\%res_tmp_lv0_l);
    #$file_l,$inv_hosts_href_l,$divisions_for_inv_hosts_href_l,$needed_elements_at_line_arr_l,$add_ind4key_l,$res_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }

    # fill %res_tmp_lv1_l
    while ( ($hkey0_l,$hval0_l)=each %res_tmp_lv0_l ) {
        #hkey0_l=inv-host
        @arr0_l=split(/\,/,${$hval0_l}[0]);
        foreach $arr_el0_l ( @arr0_l ) {
            #$arr_el0_l=ipset_template_name
            #$h01_conf_ipset_templates_hash_g{'temporary/permanent'}{ipset_template_name--TMPLT}->
                #{'ipset_name'}=value
                #{'ipset_description'}=empty|value
                #{'ipset_short_description'}=empty|value
                #{'ipset_create_option_timeout'}=num
                #{'ipset_create_option_hashsize'}=num
                #{'ipset_create_option_maxelem'}=num
                #{'ipset_create_option_family'}=inet|inet6
                #{'ipset_type'}=hash:ip|hash:ip,port|hash:ip,mark|hash:net|hash:net,port|hash:net,iface|hash:mac|hash:ip,port,ip|hash:ip,port,net|hash:net,net|hash:net,port,net

            # check ipset-tmpl for exists at 'h01_conf_ipset_templates_hash_g'
            if ( exists(${$ipset_templates_href_l}{'temporary'}{$arr_el0_l}) ) {
                $ipset_type_l='temporary';
                $ipset_name_l=${$ipset_templates_href_l}{'temporary'}{$arr_el0_l}{'ipset_name'};
            }
            elsif ( exists(${$ipset_templates_href_l}{'permanent'}{$arr_el0_l}) ) {
                $ipset_type_l='permanent';
                $ipset_name_l=${$ipset_templates_href_l}{'permanent'}{$arr_el0_l}{'ipset_name'};
            }
            else {
                $return_str_l="fail [$proc_name_l]. Template '$arr_el0_l' (used at '$file_l') is not exists at '01_conf_ipset_templates'";
                last;
            }
            ###

            # check for uniq inv-host+ipset_name
            if ( exists($ipset_uniq_check_l{$hkey0_l}{$ipset_name_l}) ) {
                $return_str_l="fail [$proc_name_l]. Duplicate ipset_name='$ipset_name_l' (tmplt_name='$arr_el0_l') for inv-host='$hkey0_l' at conf '66_conf_ipsets_FIN'. Check '01_conf_ipset_templates' and '66_conf_ipsets_FIN'";
                last;
            }
            $ipset_uniq_check_l{$hkey0_l}{$ipset_name_l}=1;
            ###
                
            if ( !exists($res_tmp_lv1_l{$ipset_type_l}{$hkey0_l}{$arr_el0_l}) ) {
                $res_tmp_lv1_l{$ipset_type_l}{$hkey0_l}{$arr_el0_l}=1;
            }
            else { # duplicated value
                $return_str_l="fail [$proc_name_l]. Duplicated template name value ('$arr_el0_l') at file='$file_l' at substring='${$hval0_l}[0]'. Fix it!";
                last;
            }
        }
        
        $arr_el0_l=undef;
        $ipset_type_l=undef;
        @arr0_l=();

        if ( $return_str_l!~/^OK$/ ) { last; }
    }
    
    ($hkey0_l,$hval0_l)=(undef,undef);
    $arr_el0_l=undef;
    @arr0_l=();

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
