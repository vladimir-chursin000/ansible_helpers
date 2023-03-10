sub read_03_conf_policy_templates {
    my ($file_l,$res_href_l)=@_;
    #file_l=$f03_conf_policy_templates_path_g
    #res_href_l=hash-ref for %h03_conf_policy_templates_hash_g
    my $proc_name_l=(caller(0))[3];

    #[some_policy--TMPLT:BEGIN]
    #policy_name=some_policy_name
    #policy_description=empty
    #policy_short_description=empty
    #policy_target=CONTINUE
    #policy_priority=-1
    #policy_allowed_services=empty
    #policy_allowed_ports=empty
    #policy_allowed_protocols=empty
    #policy_masquerade_general=no
    #policy_allowed_source_ports=empty
    #policy_icmp_block=empty
    #[some_policy--TMPLT:END]
    ###
    #$h03_conf_policy_templates_hash_g{policy_tmplt_name--TMPLT}->
    #{'policy_name'}=value
    #{'policy_description'}=empty|value
    #{'policy_short_description'}=empty|value
    #{'policy_target'}=ACCEPT|REJECT|DROP|CONTINUE
    #{'policy_priority'}=num (+/-)
    #{'policy_allowed_services'}->
        #{'empty'}=1 or
        #{'list'}->
            #{'service-0'}=1
            #{'service-1'}=1
            #etc
        #{'seq'}=[val-0,val-1] (val=service)
    #{'policy_allowed_ports'}->
        #{'empty'}=1 or
        #{'list'}->
            #{'port-0'}=1
            #{'port-1'}=1
            #etc
        #{'seq'}=[val-0,val-1] (val=port)
    #{'policy_allowed_protocols'}->
        #{'empty'}=1 or
        #{'list'}->
            #{'proto-0'}=1
            #{'proto-1'}=1
            #etc
        #{'seq'}=[val-0,val-1] (val=proto)
    #{'policy_masquerade_general'}=yes|no
    #{'policy_allowed_source_ports'}->
        #{'empty'}=1 or
        #{'list'}->
            #{'port-0'}=1
            #{'port-1'}=1
            #etc
        #{'seq'}=[val-0,val-1] (val=port)
    #{'policy_icmp_block'}->
        #{'empty'}=1 or
        #{'list'}->
            #{'icmptype-0'}=1
            #{'icmptype-1'}=1
            #etc
        #{'seq'}=[val-0,val-1] (val=icmptype)

    my $exec_res_l=undef;
    my $arr_el0_l=undef;
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my ($hkey1_l,$hval1_l)=(undef,undef);
    my @split_arr0_l=();
    my $return_str_l='OK';
    my $param_list_regex_l='^policy_allowed_services$|^policy_allowed_protocols$|^policy_icmp_block$|^policy_allowed_ports$|^policy_allowed_source_ports$';

    my %res_tmp_lv0_l=();
        #key0=tmplt_name,key1=param, value=value filtered by regex
    my %res_tmp_lv1_l=();

    my %cfg_params_and_regex_l=(
        'policy_name'=>'^\S+$',
        'policy_description'=>'^empty$|^.{1,100}',
        'policy_short_description'=>'^empty$|^.{1,20}',
        'policy_target'=>'^ACCEPT$|^REJECT$|^DROP$|^CONTINUE$',
        'policy_priority'=>'^\d+$|^\-\d+$',
        'policy_allowed_services'=>'^empty$|^.*$',
        'policy_allowed_ports'=>'^empty$|^.*$',
        'policy_allowed_protocols'=>'^empty$|^.*$',
        'policy_masquerade_general'=>'^yes$|^no$',
        'policy_allowed_source_ports'=>'^empty$|^.*$',
        'policy_icmp_block'=>'^empty$|^.*$',
    );
            
    $exec_res_l=&read_param_value_templates_from_config($file_l,\%cfg_params_and_regex_l,\%res_tmp_lv0_l);
    #$file_l,$regex_href_l,$res_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }
    
    # fill %res_tmp_lv1_l (postprocessing_v1_after_read_param_value_templates_from_config)
    $exec_res_l=&postprocessing_v1_after_read_param_value_templates_from_config($file_l,$param_list_regex_l,\%res_tmp_lv0_l,\%res_tmp_lv1_l);
    #$file_l,$param_list_regex_for_postproc_l,$src_href_l,$res_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }
    ###
        
    # fill result hash
    %{$res_href_l}=%res_tmp_lv1_l;
    ###
        
    %res_tmp_lv1_l=();
        
    return $return_str_l;
}

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
