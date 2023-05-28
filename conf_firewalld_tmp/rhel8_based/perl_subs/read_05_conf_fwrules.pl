###DEPENDENCIES: read_conf_fwrules_common.pl

sub read_05_conf_zone_rich_rules_sets {
    my ($file_l,$res_href_l)=@_;
    #file_l=$f05_conf_zone_rich_rules_sets_path_g
    #res_href_l=hash-ref for %h05_conf_zone_rich_rules_sets_hash_g
    my $proc_name_l=(caller(0))[3];

    #[some_rich_rules_set_name:BEGIN]
    #rule family=ipv4 forward-port to-port=8080 protocol=tcp port=80 (example)
    #rule family=ipv4 source address=192.168.55.4/32 destination address=10.10.7.0/24 masquerade (example)
    #[some_rich_rules_set_name:END]
    ###
    #$h05_conf_zone_rich_rules_sets_hash_g{set_name}->
        #{'rule-0'}=1
        #{'rule-1'}=1
        #etc
        #{'seq'}=[val-0,val-1] (val=rule)

    my $exec_res_l=undef;
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my ($hkey1_l,$hval1_l)=(undef,undef);
    my $return_str_l='OK';

    my %res_tmp_lv0_l=();
        #key=rule, value=value filtered by regex

    $exec_res_l=&read_param_only_templates_from_config($file_l,\%res_tmp_lv0_l);
    #$file_l,$res_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }
    
    # check rules with regex (for future functional)
    #while ( ($hkey0_l,$hval0_l)=each %res_tmp_lv0_l ) { # cycle 0
    #   #hkey0_l=tmplt_name, hval0_l=hash ref where key=rule
    #   ###
    #   while ( ($hkey1_l,$hval1_l)=each %{$hval0_l} ) { # cycle 1
    #       #hkey1_l=rule
    #       #rule family=ipv4 forward-port to-port=8080 protocol=tcp port=80 (example)
    #       #rule family=ipv4 source address=192.168.55.4/32 destination address=10.10.7.0/24 masquerade (example)
    #       if ( $hkey1_l!~/^seq$/ ) {
    #       }
    #   } # cycle 1
    #   
    #   if ( $return_str_l!~/^OK$/ ) { last; }
    #} # cycle 0
    #
    #if ( $return_str_l!~/^OK$/ ) { return $return_str_l; }
    ###

    # fill result hash
    %{$res_href_l}=%res_tmp_lv0_l;
    ###

    %res_tmp_lv0_l=();

    return $return_str_l;
}

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
