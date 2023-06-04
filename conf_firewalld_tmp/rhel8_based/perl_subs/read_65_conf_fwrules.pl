###DEPENDENCIES: read_conf_fwrules_common.pl

sub read_65_conf_initial_ipsets_content_FIN {
    my ($file_l,$ipset_templates_href_l,$res_href_l)=@_;
    #file_l=$f65_conf_initial_ipsets_content_FIN_path_g
    #$ipset_templates_href_l=hash-ref for %h01_conf_ipset_templates_hash_g
    #res_href_l=hash-ref for %h66_conf_ipsets_FIN_hash_g
    my $proc_name_l=(caller(0))[3];

    # This CFG only for permanent ipset templates (if "#ipset_create_option_timeout=0").
    #[IPSET_TEMPLATE_NAME:BEGIN]
    #one row = one record with ipset accoring to "#ipset_type" of conf file "01_conf_ipset_templates"
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
    #$h65_conf_initial_ipsets_content_FIN_hash_g{ipset_template_name}->
	#{'record-0'}=1
	#{'rerord-1'}=1
	#etc
	#{'seq'}=[val-0,val-1] (val=record)
    ######

    my $exec_res_l=undef;
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my ($hkey1_l,$hval1_l)=(undef,undef);
    my $return_str_l='OK';

    my %res_tmp_lv0_l=();
        #key=rule, value=value filtered by regex

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
    
    # fill result hash
    %{$res_href_l}=%res_tmp_lv0_l;
    ###

    %res_tmp_lv0_l=();

    return $return_str_l;
}

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )