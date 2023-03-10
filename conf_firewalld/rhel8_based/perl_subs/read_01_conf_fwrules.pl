###DEPENDENCIES: read_conf_fwrules_common.pl

sub read_01_conf_ipset_templates {
    my ($file_l,$res_href_l)=@_;
    #file_l=$f01_conf_ipset_templates_path_g
    #res_href_l=hash-ref for %h01_conf_ipset_templates_hash_g
    my $proc_name_l=(caller(0))[3];

    #[some_ipset_template_name--TMPLT:BEGIN]
    #ipset_name=some_ipset_name
    #ipset_description=empty
    #ipset_short_description=empty
    #ipset_create_option_timeout=0
    #ipset_create_option_hashsize=1024
    #ipset_create_option_maxelem=65536
    #ipset_create_option_family=inet
    #ipset_type=some_ipset_type
    #[some_ipset_template_name--TMPLT:END]
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

    my $exec_res_l=undef;
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my $return_str_l='OK';

    my %res_tmp_lv0_l=();
        #key0=ipset_tmplt_name, key1=param, value=value filtered by regex
    my %res_tmp_lv1_l=();

    my %cfg_params_and_regex_l=(
        'ipset_name'=>'^\S+$',
        'ipset_description'=>'^empty$|^.{1,100}',
        'ipset_short_description'=>'^empty$|^.{1,20}',
        'ipset_create_option_timeout'=>'^\d+$',
        'ipset_create_option_hashsize'=>'^\d+$',
        'ipset_create_option_maxelem'=>'^\d+$',
        'ipset_create_option_family'=>'^inet$|^inet6$',
        'ipset_type'=>'^hash\:ip$|^hash\:ip\,port$|^hash\:ip\,mark$|^hash\:net$|^hash\:net\,port$|^hash\:net\,iface$|^hash\:mac$|^hash\:ip\,port\,ip$|^hash\:ip\,port\,net$|^hash\:net\,net$|^hash\:net\,port\,net$',
    );

    $exec_res_l=&read_param_value_templates_from_config($file_l,\%cfg_params_and_regex_l,\%res_tmp_lv0_l);
    #$file_l,$regex_href_l,$res_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }

    # fill %res_tmp_lv1_l
    while ( ($hkey0_l,$hval0_l)=each %res_tmp_lv0_l ) {
        #$hkey0_l=tmplt_name, $hval0_l=href for hash slice with params and values
        if ( ${$hval0_l}{'ipset_create_option_timeout'}>0 ) { %{$res_tmp_lv1_l{'temporary'}{$hkey0_l}}=%{$hval0_l}; }
        else { %{$res_tmp_lv1_l{'permanent'}{$hkey0_l}}=%{$hval0_l}; }
    }

    ($hkey0_l,$hval0_l)=(undef,undef);
    %res_tmp_lv0_l=();
    ###

    # fill result hash
    %{$res_href_l}=%res_tmp_lv1_l;
    ###

    %res_tmp_lv1_l=();

    return $return_str_l;
}

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
