###DEPENDENCIES: read_conf_fwrules_common.pl, value_check.pl

sub read_04_conf_zone_forward_ports_sets {
    my ($file_l,$res_href_l)=@_;
    #file_l=$f04_conf_zone_forward_ports_sets_path_g
    #res_href_l=hash-ref for %h04_conf_zone_forward_ports_sets_hash_g
    my $proc_name_l=(caller(0))[3];

    #[some_forward_ports_set_name:BEGIN]
    #port=80:proto=tcp:toport=8080:toaddr=192.168.1.60 (example)
    #port=80:proto=tcp:toport=8080 (example)
    #[some_forward_ports_set_name:END]
    ###
    #$h04_conf_zone_forward_ports_sets_hash_g{set_name}->
        #{'rule-0'}=1
        #{'rule-1'}=1
        #etc
        #{'seq'}=[val-0,val-1] (val=rule)

    my $exec_res_l=undef;
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my ($hkey1_l,$hval1_l)=(undef,undef);
    my ($from_port_l,$to_port_l,$proto_l,$to_addr_l)=(undef,undef,undef,'localhost');
    my ($port_str4check0_l,$port_str4check1_l)=(undef,undef);
    my $return_str_l='OK';

    my %res_tmp_lv0_l=();
        #key=rule, value=value filtered by regex

    $exec_res_l=&read_param_only_templates_from_config($file_l,\%res_tmp_lv0_l);
    #$file_l,$res_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }

    # check rules with regex
    while ( ($hkey0_l,$hval0_l)=each %res_tmp_lv0_l ) { # cycle 0
        #hkey0_l=tmplt_name, hval0_l=hash ref where key=rule
        ###
        while ( ($hkey1_l,$hval1_l)=each %{$hval0_l} ) { # cycle 1
            #hkey1_l=rule
            #port=80:proto=tcp:toport=8080:toaddr=192.168.1.60 (example)
            #port=80:proto=tcp:toport=8080 (example)
            if ( $hkey1_l!~/^seq$/ ) {
                if ( $hkey1_l=~/^port\=(\d+)\:proto\=(\S+)\:toport\=(\d+)$/ ) {
                    $from_port_l=$1; $proto_l=$2; $to_port_l=$3;
                    $port_str4check0_l=$from_port_l.'/'.$proto_l;
                    $port_str4check1_l=$to_port_l.'/'.$proto_l;
                    $to_addr_l='localhost';
                }
                elsif ( $hkey1_l=~/^port\=(\d+)\:proto\=(\S+)\:toport\=(\d+)\:toaddr\=(\S+)$/ ) {
                    $from_port_l=$1; $proto_l=$2; $to_port_l=$3; $to_addr_l=$4;
                    $port_str4check0_l=$from_port_l.'/'.$proto_l;
                    $port_str4check1_l=$to_port_l.'/'.$proto_l;
                }
                else {
                    $return_str_l="fail [$proc_name_l]. Rule for port forwarding must be like 'port=80:proto=tcp:toport=8080:toaddr=192.168.1.60' or 'port=80:proto=tcp:toport=8080' (for example)";
                    last;
                }

                if ( $proto_l!~/^tcp$|^udp$|^sctp$|^dccp$/ ) {
                    $return_str_l="fail [$proc_name_l]. Proto must be like 'tcp/udp/sctp/dccp'";
                    last;
                }
                
                $exec_res_l=&check_port_for_apply_to_fw_conf($port_str4check0_l);
                #$port_str_l
                if ( $exec_res_l=~/^fail/ ) {
                    $return_str_l="fail [$proc_name_l] -> ".$exec_res_l;
                    last;
                }
                
                $exec_res_l=&check_port_for_apply_to_fw_conf($port_str4check1_l);
                #$port_str_l
                if ( $exec_res_l=~/^fail/ ) {
                    $return_str_l="fail [$proc_name_l] -> ".$exec_res_l;
                    last;
                }
                
                if ( $to_addr_l!~/^localhost$/ && $to_addr_l=~/^\d{1,3}\./ && $to_addr_l!~/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/ ) { #check ipv4
                    $return_str_l="fail [$proc_name_l]. The IPv4 addr must be like 'xxx.yyy.zzz.qqq'";
                    last;
                }
            }
            
            ($from_port_l,$to_port_l,$proto_l,$to_addr_l)=(undef,undef,undef,undef);

        } # cycle 1

        $exec_res_l=undef;
        ($hkey1_l,$hval1_l)=(undef,undef);
        ($from_port_l,$to_port_l,$proto_l,$to_addr_l)=(undef,undef,undef,undef);

        if ( $return_str_l!~/^OK$/ ) { last; }
    } # cycle 0

    $exec_res_l=undef;
    ($hkey0_l,$hval0_l)=(undef,undef);
    ($hkey1_l,$hval1_l)=(undef,undef);
    ($from_port_l,$to_port_l,$proto_l,$to_addr_l)=(undef,undef,undef,undef);

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
