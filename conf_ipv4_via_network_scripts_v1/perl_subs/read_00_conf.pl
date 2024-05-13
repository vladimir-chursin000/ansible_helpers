sub read_00_conf_divisions_for_inv_hosts {
    my ($file_l,$inv_hosts_href_l,$res_href_l)=@_;
    #file_l=$f00_conf_divisions_for_inv_hosts_path_g
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

    # read from file (begin)
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

    # clear vars
    $line_l=undef;
    ###
    # read from file (end)

    if ( $return_str_l!~/OK$/ ) { return $return_str_l; }

    return $return_str_l;
}

sub read_main_config {
    my ($file_l,$inv_hosts_network_data_href_l,$res_href_l)=@_;
    #file_l='01_configs/00_config',$res_href_l=hash rer for %cfg0_hash_g
    #inv_hosts_network_data_href_l=hash ref for %inv_hosts_network_data_g
    my $proc_name_l=(caller(0))[3];
    
    my ($line_l,$arr_el0_l,$arr_i0_l)=(undef,undef,undef);
    my $return_str_l='OK';
    
    my @arr0_l=();
    my @int_list_arr_l=();
    my @hwaddr_list_arr_l=();
    my @ipaddr_opts_arr_l=();

    my $bond_opts_str_def_l='mode=4 xmit_hash_policy=2 lacp_rate=1 miimon=100';
    my $bond_opts_str_l=$bond_opts_str_def_l;

    my %cfg0_uniq_check_l=();
    #Checks (uniq) for novlan interfaces at current inv_host.
    #$cfg0_uniq_check{inv_host}{'common'}{interface_name}=conf_id; #if interface_name ne 'no' and vlan_id eq 'no'.
    #$cfg0_uniq_check{inv_host}{'common'}{hwaddr}=conf_id; if vlan_id eq 'no'.
    #$cfg0_uniq_check{inv_host}{'common'}{bond_name}=conf_id; #if bond_name ne 'no' and vlan_id eq 'no'.
    #$cfg0_uniq_check{inv_host}{'common'}{bridge_name}=conf_id; #if bridge_name ne 'no' and vlan_id eq 'no'.
    #$cfg0_uniq_check{inv_host}{'common'}{ipaddr}=conf_id; #if ipaddr_opts ne 'dhcp'. ###1
    ###
    #Checks (uniq) for vlan interfaces at current inv_host.
    #$cfg0_uniq_check{inv_host}{'vlan'}{vlan_id}=conf_id; #if vlan_id ne 'no'.
    #$cfg0_uniq_check{inv_host}{'vlan'}{interface_name-vlan_id}=conf_id; #if vlan_id ne 'no'.
    #$cfg0_uniq_check{inv_host}{'vlan'}{hwaddr-vlan_id}=conf_id; #if vlan_id ne 'no'.
    #$cfg0_uniq_check{inv_host}{'vlan'}{bond_name-vlan_id}=conf_id; #if vlan_id ne 'no' and bond_name ne 'no'.
    #$cfg0_uniq_check{inv_host}{'vlan'}{bridge_name-vlan_id}=conf_id; #if vlan_id ne 'no' and bridge_name ne 'no'.
    ###
    #Checks (uniq) for interfaces at '00_config' (for all inv_hosts)
    #$cfg0_uniq_check{'all_hosts'}{hwaddr}=inv_host;
    #$cfg0_uniq_check{'all_hosts'}{ipaddr}=inv_host; #if ipaddr ne 'dhcp'.
    ######
    my %defroute_check_l=();
    #$defroute_check_l{inv_host}=conf_id; ###2

    my ($inv_host_l,$conf_id_l,$conf_type_l,$int_list_str_l,$hwaddr_list_str_l,$vlan_id_l,$bond_name_l,$bridge_name_l,$ipaddr_opts_l,$bond_opts_l,$defroute_l)=(undef,undef,undef,undef,undef,undef,undef,undef,undef,undef,undef);
        
    open(CONF,'<',$file_l);
    while ( <CONF> ) {
	$line_l=$_;
	$line_l=~s/\n$|\r$|\n\r$|\r\n$//g;
	while ($line_l=~/\t/) { $line_l=~s/\t/ /g; }
	$line_l=~s/\s+/ /g;
	$line_l=~s/^ //g;
	if ( length($line_l)>0 && $line_l!~/^\#/ ) {
    	    $line_l=~s/ \,/\,/g;
    	    $line_l=~s/\, /\,/g;
    	    $line_l=~s/ \, /\,/g;
    	    
    	    $line_l=~s/ \./\./g;
    	    $line_l=~s/\. /\./g;
    	    $line_l=~s/ \. /\./g;
    	    
    	    @arr0_l=split(' ',$line_l);
    	    if ( $#arr0_l!=10 ) {
    		$return_str_l="fail [$proc_name_l]. Conf-line='$line_l' must contain 11 params. Please, check and correct config-file ('00_config')";
    		last;
    	    }
    	
    	    ($inv_host_l,$conf_id_l,$conf_type_l,$int_list_str_l,$hwaddr_list_str_l,$vlan_id_l,$bond_name_l,$bridge_name_l,$ipaddr_opts_l,$bond_opts_l,$defroute_l)=@arr0_l;

	    $hwaddr_list_str_l=lc($hwaddr_list_str_l);
    	    
    	    #######check conf_type
    	    if ( $conf_type_l!~/^just_interface$|^virt_bridge$|^just_bridge$|^just_bond$|^bond\-bridge$|^interface\-vlan$|^bridge\-vlan$|^bond\-vlan$|^bond\-bridge\-vlan$/ ) {
    		$return_str_l="fail [$proc_name_l]. Wrong conf_type='$conf_type_l'. Conf_type must be 'just_interface/virt_bridge/just_bridge/just_bond/bond-bridge/interface-vlan/bridge-vlan/bond-vlan/bond-bridge-vlan'. Please, check and correct config-file ('00_config')";
		last;
    	    }
	    if ( $conf_type_l=~/\-vlan$/ && $vlan_id_l eq 'no' ) {
		$return_str_l="fail [$proc_name_l]. For vlan-config-type param vlan_id must be a NUMBER. Please, check and correct config-file ('00_config')";
		last;
	    }
    	    #######check conf_type
    	    
    	    #######defroute check
    		#$defroute_check_l{inv_host}=conf_id;
    	    if ( !exists($defroute_check_l{$inv_host_l}) && $defroute_l eq 'yes' ) {
    		$defroute_check_l{$inv_host_l}=$conf_id_l;
    	    }
    	    elsif ( exists($defroute_check_l{$inv_host_l}) && $defroute_l eq 'yes' ) {
    		$return_str_l="fail [$proc_name_l]. Defroute for inv_host='$inv_host_l' (conf_id='$conf_id_l') is already defined by conf_id='$defroute_check_l{$inv_host_l}'. Please, check and correct config-file ('00_config')";
		last;
    	    }
    	    #######defroute check
    	    
    	    #######bond_name/bridge_name simple checks
    	    if ( $conf_type_l=~/^just_interface$|^interface\-vlan$/ ) {
    		if ( $bond_name_l ne 'no' ) {
    		    $return_str_l="fail [$proc_name_l]. For conf_types='just_interface/interface-vlan' bond_name must be 'no' (conf_id='$conf_id_l'). Please, check and correct config-file ('00_config')";
		    last;
    		}
    		if ( $bridge_name_l ne 'no' ) {
    		    $return_str_l="fail [$proc_name_l]. For conf_types='just_interface/interface-vlan' bridge_name must be 'no' (conf_id='$conf_id_l'). Please, check and correct config-file ('00_config')";
		    last;
    		}
    	    }
    	    
    	    if ( $conf_type_l=~/^virt_bridge$|^just_bridge$|^bridge\-vlan$/ ) {
    		if ( $bond_name_l ne 'no' ) {
    		    $return_str_l="fail [$proc_name_l]. For conf_types='virt_bridge/just_bridge/bridge-vlan' bond_name must be 'no' (conf_id='$conf_id_l'). Please, check and correct config-file ('00_config')";
		    last;
    		}
    		if ( $bridge_name_l eq 'no' ) {
    		    $return_str_l="fail [$proc_name_l]. For conf_types='virt_bridge/just_bridge/bridge-vlan' bridge_name must be NOT 'no'. Please, check and correct config-file ('00_config')";
		    last;
    		}
    	    }
    	    
    	    if ( $conf_type_l=~/^just_bond$|^bond\-vlan$/ ) {
    		if ( $bridge_name_l ne 'no' ) {
    		    $return_str_l="fail [$proc_name_l]. For conf_types='just_bond/bond-vlan' bridge_name must be 'no' (conf_id='$conf_id_l'). Please, check and correct config-file ('00_config')";
		    last;
    		}
    		if ( $bond_name_l eq 'no' ) {
    		    $return_str_l="fail [$proc_name_l]. For conf_types='just_bond/bond-vlan' bond_name must be NOT 'no'. Please, check and correct config-file ('00_config')";
		    last;
    		}
    	    }
    	    
    	    if ( $conf_type_l=~/^bond\-bridge$|^bond\-bridge\-vlan$/ ) {
    		if ( $bridge_name_l eq 'no' ) {
    		    $return_str_l="fail [$proc_name_l]. For conf_types='bond-bridge/bond-bridge-vlan' bridge_name must be NOT 'no'. Please, check and correct config-file ('00_config')";
		    last;
    		}
    		if ( $bond_name_l eq 'no' ) {
    		    $return_str_l="fail [$proc_name_l]. For conf_types='bond-bridge/bond-bridge-vlan' bond_name must be NOT 'no'. Please, check and correct config-file ('00_config')";
		    last;
    		}
    	    }
    	    #######bond_name/bridge_name simple checks
	    
    	    #######IPADDRv4 PREcheck via regexp
    	    if ( $conf_type_l!~/^virt_bridge$/ && $ipaddr_opts_l!~/^dhcp$|^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\,\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\,\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/ ) {
    		$return_str_l="fail [$proc_name_l]. IPv4_ADDR_OPTS must be 'dhcp' or 'ipv4,gw,netmask' (conf_id='$conf_id_l'). Please, check and correct config-file ('00_config')";
		last;
    	    }
    	    elsif ( $conf_type_l=~/^virt_bridge$/ && $ipaddr_opts_l!~/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\,nogw\,\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/ ) {
    		$return_str_l="fail [$proc_name_l]. IPv4_ADDR_OPTS for conf_type='virt-bridge' (conf_id='$conf_id_l') must be 'ipv4,nogw,netmask' (for example '10.1.1.1,nogw,255.255.255.0'). Please, check and correct config-file ('00_config')";
		last;
    	    }
    	    #######IPADDRv4 PREcheck via regexp
	    
    	    #######extract complex vars
    	    @int_list_arr_l=split(/\,/,$int_list_str_l);
    	    @hwaddr_list_arr_l=split(/\,/,$hwaddr_list_str_l);
    	    @ipaddr_opts_arr_l=split(/\,/,$ipaddr_opts_l);
	    $bond_opts_str_l=$bond_opts_str_def_l;
    	    if ( $conf_type_l=~/^just_bond$|^bond\-vlan$|^bond\-bridge$|^bond\-bridge\-vlan$/ && $bond_opts_l!~/^def$/ ) {
    		$bond_opts_str_l=$bond_opts_l;
    		$bond_opts_str_l=~s/\,/ /g;
    	    }
    	    #######extract complex vars
	    
	    #######CHECK if ip=gw
	    if ( $ipaddr_opts_arr_l[0] eq $ipaddr_opts_arr_l[1] ) {
		$return_str_l="fail [$proc_name_l]. It is deny to set ip=gw (conf_id='$conf_id_l'). Please, check and correct config-file ('00_config')";
		last;
	    }
	    #######CHECK if ip=gw
    	    
    	    #######interfaces + hwaddr count checks for each conf_type
    	    if ( $conf_type_l=~/^virt_bridge$/ ) { #for conf_type=virt_bridge. No interfaces
    		if ( $#hwaddr_list_arr_l!=0 ) {
    		    $return_str_l="fail [$proc_name_l]. For conf_type='$conf_type_l' must be configured only one HWADDR (conf_id='$conf_id_l'). Please, check and correct config-file ('00_config')";
		    last;
    		}
    		if ( $#int_list_arr_l>0 or $int_list_arr_l[0] ne 'no' ) {
    		    $return_str_l="fail [$proc_name_l]. For conf_type='$conf_type_l' int_list must contain only 'no' (conf_id='$conf_id_l'). Please, check and correct config-file ('00_config')";
		    last;
    		}
    	    }
    	    
    	    if ( $conf_type_l=~/^just_interface$|^interface\-vlan$|^bridge\-vlan$/ ) { #for conf_types where possible using only one interface
		# prev = $conf_type_l=~/^just_interface$|^just_bridge$|^interface\-vlan$|^bridge\-vlan$/
    		if ( ($#int_list_arr_l==$#hwaddr_list_arr_l && $#int_list_arr_l!=0) or $#int_list_arr_l!=$#hwaddr_list_arr_l ) {
    		    $return_str_l="fail [$proc_name_l]. For conf_type='$conf_type_l' must be configured only one HWADDR (conf_id='$conf_id_l'). Please, check and correct config-file ('00_config')";
		    last;
    		}
    		if ( $int_list_arr_l[0] eq 'no' ) {
    		    $return_str_l="fail [$proc_name_l]. For conf_type='$conf_type_l' int_list must contain interface names, but not 'no' (conf_id='$conf_id_l'). Please, check and correct config-file ('00_config')";
		    last;
    		}
    	    }
    	    
    	    if ( $conf_type_l=~/^just_bond$|^bond\-bridge$|^bond\-vlan$|^bond\-bridge\-vlan$/ ) { #for conf_types where >=2 interfaces
    		if ( $#int_list_arr_l<1 or $#int_list_arr_l!=$#hwaddr_list_arr_l ) {
    		    $return_str_l="fail [$proc_name_l]. For conf_type='$conf_type_l' amount of interfaces must = amount of hwaddr and amount of interfaces must be >= 2 (conf_id='$conf_id_l'). Please, check and correct config-file ('00_config')";
		    last;
    		}
    		foreach $arr_el0_l ( @int_list_arr_l ) {
    		    if ( $arr_el0_l eq 'no' ) {
    			$return_str_l="fail [$proc_name_l]. For conf_type='$conf_type_l' int_list must contain interface names, but not 'no' (conf_id='$conf_id_l'). Please, check and correct config-file ('00_config')";
    			last;
    		    }
    		}
    		$arr_el0_l=undef;
    	    }
	    
	    if ( $return_str_l!~/^OK$/ ) { last; }
    	    #######interfaces + hwaddr count checks for each conf_type
    	    
    	    #######hwaddr check via regexp
	    if ( $conf_type_l!~/^virt_bridge$/ ) {
    		foreach $arr_el0_l ( @hwaddr_list_arr_l ) {
    		    if ( $arr_el0_l!~/^\S{2}\:\S{2}\:\S{2}\:\S{2}\:\S{2}\:\S{2}$/ ) {
    			$return_str_l="fail [$proc_name_l]. HWADDR must be like 'XX:XX:XX:XX:XX:XX' (incorrect value='$arr_el0_l') (conf_id='$conf_id_l'). Please, check and correct config-file ('00_config')";
			last;
    		    }
    		}
	    }
	    else {
		foreach $arr_el0_l ( @hwaddr_list_arr_l ) {
    		    if ( $arr_el0_l!~/^no$/ ) {
    			$return_str_l="fail [$proc_name_l]. HWADDR for virt_bridge must be 'no' (incorrect value='$arr_el0_l') (conf_id='$conf_id_l'). Please, check and correct config-file ('00_config')";
			last;
    		    }
    		}
	    }
	    
	    if ( $return_str_l!~/^OK$/ ) { last; }
    	    #######hwaddr check via regexp
    	    
	    #######NETWORK DATA (ip link) checks
	    if ( $conf_type_l!~/^virt_bridge$/ ) {
		#our %inv_hosts_network_data_g=();
		#read 'ip_link_noqueue' first
		#v1) key0='hwaddr_all', key1=hwaddr, value=inv_host
		#v2) key0='inv_host', key1=inv_host, key2=interface_name, key3=hwaddr
		for ( $arr_i0_l=0; $arr_i0_l<=$#hwaddr_list_arr_l; $arr_i0_l++ ) {
		    if ( exists(${$inv_hosts_network_data_href_l}{'hwaddr_all'}{$hwaddr_list_arr_l[$arr_i0_l]}) && $inv_host_l ne ${$inv_hosts_network_data_href_l}{'hwaddr_all'}{$hwaddr_list_arr_l[$arr_i0_l]} ) {
			$return_str_l="fail [$proc_name_l]. NETWORK DATA check. HWADDR='$hwaddr_list_arr_l[$arr_i0_l]' configured for inv_host='$inv_host_l' is already used by host='${$inv_hosts_network_data_href_l}{'hwaddr_all'}{$hwaddr_list_arr_l[$arr_i0_l]}' (conf_id='$conf_id_l'). Please, check and correct config-file or solve problem with duplicated mac-address";
			last;
		    }
		    
		    if ( !exists(${$inv_hosts_network_data_href_l}{'inv_host'}{$inv_host_l}{$int_list_arr_l[$arr_i0_l]}{$hwaddr_list_arr_l[$arr_i0_l]}) ) {
			$return_str_l="fail [$proc_name_l]. NETWORK DATA check. At inv_host='$inv_host_l' interface='$int_list_arr_l[$arr_i0_l]' not linked with hwaddr='$hwaddr_list_arr_l[$arr_i0_l]' (conf_id='$conf_id_l'). Please, check and correct config-file ('00_config')";
			last;
		    }
		}
		
		if ( $return_str_l!~/^OK$/ ) { last; }
	    }
	    #######NETWORK DATA (ip link) checks
	    
    	    #######uniq checks for all hosts (hwaddr, ipaddr)
    		#$cfg0_uniq_check{'all_hosts'}{hwaddr}=inv_host;
    		#$cfg0_uniq_check{'all_hosts'}{ipaddr}=inv_host; #if ipaddr ne 'dhcp'.
    	    foreach $arr_el0_l ( @hwaddr_list_arr_l ) {
    		if ( !exists($cfg0_uniq_check_l{'all_hosts'}{$arr_el0_l}) ) {
    		    $cfg0_uniq_check_l{'all_hosts'}{$arr_el0_l}=$inv_host_l;
    		}
    		else {
    		    if ( $cfg0_uniq_check_l{'all_hosts'}{$arr_el0_l} ne $inv_host_l ) {
    			$return_str_l="fail [$proc_name_l]. Hwaddr='$arr_el0_l' is already used at host='$cfg0_uniq_check_l{'all_hosts'}{$arr_el0_l}' (conf_id='$conf_id_l'). Please, check and correct config-file ('00_config')";
    			last;
    		    }
    		}
    	    }
	    
	    if ( $return_str_l!~/^OK$/ ) { last; }
    	    
    	    if ( $ipaddr_opts_arr_l[0] ne 'dhcp' ) {
    		if ( !exists($cfg0_uniq_check_l{'all_hosts'}{$ipaddr_opts_arr_l[0]}) ) {
    		    $cfg0_uniq_check_l{'all_hosts'}{$ipaddr_opts_arr_l[0]}=$inv_host_l;
    		}
    		else {
    		    $return_str_l="fail [$proc_name_l]. IPaddr='$ipaddr_opts_arr_l[0]' is already used at host='$cfg0_uniq_check_l{'all_hosts'}{$ipaddr_opts_arr_l[0]}' (conf_id='$conf_id_l'). Please, check and correct config-file ('00_config')";
		    last;
    		}
    	    }
    	    ########uniq checks for all hosts
	    
    	    ########check for uniq bridge names
    	    if ( $bridge_name_l ne 'no' ) {
    	    	if ( !exists($cfg0_uniq_check_l{$inv_host_l}{'common'}{$bridge_name_l}) ) {
    	    	    $cfg0_uniq_check_l{$inv_host_l}{'common'}{$bridge_name_l}=$conf_id_l;
    	    	}
    	    	else {
    	    	    $return_str_l="fail [$proc_name_l]. Bridge_name='$bridge_name_l' (inv_host='$inv_host_l', conf_id='$conf_id_l') is already used at config with id='".$cfg0_uniq_check_l{$inv_host_l}{'common'}{$bridge_name_l}."'. Please, check and correct config-file ('00_config')";
    	    	    last;
    	    	}
    	    }
    	    ########check for uniq bridge names

    	    ########uniq checks (for local params of hosts)
    	    if ( $vlan_id_l=~/^no$/ ) { #if novlan
    	    	###$cfg0_uniq_check{inv_host}{'common'}{interface_name}=conf_id; #if interface_name ne 'no' and vlan_id eq 'no'.
    	    	foreach $arr_el0_l ( @int_list_arr_l ) {
    	    	    if ( $arr_el0_l=~/^no$/ ) { last; }
    	    	    if ( !exists($cfg0_uniq_check_l{$inv_host_l}{'common'}{$arr_el0_l}) ) {
    	    		$cfg0_uniq_check_l{$inv_host_l}{'common'}{$arr_el0_l}=$conf_id_l;
    	    	    }
    	    	    else {
    	    		$return_str_l="fail [$proc_name_l]. Interface_name='$arr_el0_l' (inv_host='$inv_host_l', conf_id='$conf_id_l') is already used at config with id='$cfg0_uniq_check_l{$inv_host_l}{'common'}{$arr_el0_l}'. Please, check and correct config-file ('00_config')";
	    		last;
    	    	    }
    	    	}
	    	
	    	if ( $return_str_l!~/^OK$/ ) { last; }
    	    	###
	    	
    	    	###$cfg0_uniq_check{inv_host}{'common'}{hwaddr}=conf_id; if vlan_id eq 'no'.
    	    	foreach $arr_el0_l ( @hwaddr_list_arr_l ) {
    	    	    if ( !exists($cfg0_uniq_check_l{$inv_host_l}{'common'}{$arr_el0_l}) ) {
    	    		$cfg0_uniq_check_l{$inv_host_l}{'common'}{$arr_el0_l}=$conf_id_l;
    	    	    }
    	    	    else {
    	    		$return_str_l="fail [$proc_name_l]. Hwaddr='$arr_el0_l' (inv_host='$inv_host_l', conf_id='$conf_id_l') is already used at config with id='$cfg0_uniq_check_l{$inv_host_l}{'common'}{$arr_el0_l}'. Please, check and correct config-file ('00_config')";
	    		last;
    	    	    }
    	    	}
	    	
	    	if ( $return_str_l!~/^OK$/ ) { last; }
    	    	###
    	    	
    	    	###$cfg0_uniq_check{inv_host}{'common'}{bond_name}=conf_id; #if bond_name ne 'no' and vlan_id eq 'no'.
    	    	if ( $bond_name_l ne 'no' ) {
    	    	    if ( !exists($cfg0_uniq_check_l{$inv_host_l}{'common'}{$bond_name_l}) ) {
    	    		$cfg0_uniq_check_l{$inv_host_l}{'common'}{$bond_name_l}=$conf_id_l;
    	    	    }
    	    	    else {
    	    		$return_str_l="fail [$proc_name_l]. Bond_name='$bond_name_l' (inv_host='$inv_host_l', conf_id='$conf_id_l') is already used at config with id='$cfg0_uniq_check_l{$inv_host_l}{'common'}{$bond_name_l}'. Please, check and correct config-file ('00_config')";
    	    		last;
    	    	    }
    	    	}
    	    	###
    	    	
    	    	###$cfg0_uniq_check{inv_host}{'common'}{ipaddr}=conf_id; #if ipaddr_opts ne 'dhcp'.
    	    	if ( $ipaddr_opts_arr_l[0] ne 'dhcp' ) {
    	    	    if ( !exists($cfg0_uniq_check_l{$inv_host_l}{'common'}{$ipaddr_opts_arr_l[0]}) ) {
    	    	        $cfg0_uniq_check_l{$inv_host_l}{'common'}{$ipaddr_opts_arr_l[0]}=$conf_id_l;
    	    	    }
    	    	    else {
    	    		$return_str_l="fail [$proc_name_l]. Ipaddr='$ipaddr_opts_arr_l[0]' (inv_host='$inv_host_l', conf_id='$conf_id_l') is already used at config with id='$cfg0_uniq_check_l{$inv_host_l}{'common'}{$ipaddr_opts_arr_l[0]}'. Please, check and correct config-file ('00_config')";
	    		last;
    	    	    }
    	    	}
    	    	###
    	    }
    	    else { #if vlan
    	    	###$cfg0_uniq_check{inv_host}{'vlan'}{vlan_id}=conf_id; #if vlan_id ne 'no'.
    	    	if ( !exists($cfg0_uniq_check_l{$inv_host_l}{'vlan'}{$vlan_id_l}) ) {
    	    	    $cfg0_uniq_check_l{$inv_host_l}{'vlan'}{$vlan_id_l}=$conf_id_l;
    	    	}
    	    	else {
    	    	    $return_str_l="fail [$proc_name_l]. Vlan_id='$vlan_id_l' (inv_host='$inv_host_l', conf_id='$conf_id_l') is already used at config with id='$cfg0_uniq_check_l{$inv_host_l}{'vlan'}{$vlan_id_l}'. Please, check and correct config-file ('00_config')";
	    	    last;
    	    	}
    	    	###
    	    	
    	    	###$cfg0_uniq_check{inv_host}{'vlan'}{interface_name-vlan_id}=conf_id; #if vlan_id ne 'no'.
    	    	foreach $arr_el0_l ( @int_list_arr_l ) {
    	    	    if ( $arr_el0_l=~/^no$/ ) { last; }
    	    	    if ( !exists($cfg0_uniq_check_l{$inv_host_l}{'vlan'}{$arr_el0_l.'-'.$vlan_id_l}) ) {
    	    		$cfg0_uniq_check_l{$inv_host_l}{'vlan'}{$arr_el0_l.'-'.$vlan_id_l}=$conf_id_l;
    	    	    }
    	    	    else {
    	    		$return_str_l="fail [$proc_name_l]. Interface_name='$arr_el0_l' (inv_host='$inv_host_l', conf_id='$conf_id_l', vlan_id='$vlan_id_l') is already used at config with id='".$cfg0_uniq_check_l{$inv_host_l}{'vlan'}{$arr_el0_l.'-'.$vlan_id_l}."'. Please, check and correct config-file ('00_config')";
	    		last;
    	    	    }
    	    	}
	    	
	    	if ( $return_str_l!~/^OK$/ ) { last; }
    	    	###
    	    	
    	    	###$cfg0_uniq_check{inv_host}{'vlan'}{hwaddr-vlan_id}=conf_id; #if vlan_id ne 'no'.
    	    	foreach $arr_el0_l ( @hwaddr_list_arr_l ) {
    	    	    if ( !exists($cfg0_uniq_check_l{$inv_host_l}{'vlan'}{$arr_el0_l.'-'.$vlan_id_l}) ) {
    	    		$cfg0_uniq_check_l{$inv_host_l}{'vlan'}{$arr_el0_l.'-'.$vlan_id_l}=$conf_id_l;
    	    	    }
    	    	    else {
    	    	        $return_str_l="fail [$proc_name_l]. Hwaddr='$arr_el0_l' (inv_host='$inv_host_l', conf_id='$conf_id_l', vlan_id='$vlan_id_l') is already used at config with id='".$cfg0_uniq_check_l{$inv_host_l}{'vlan'}{$arr_el0_l.'-'.$vlan_id_l}."'. Please, check and correct config-file ('00_config')";
	    		last;
    	    	    }
    	    	}
	    	
	    	if ( $return_str_l!~/^OK$/ ) { last; }
    	    	###

                ###$cfg0_uniq_check{inv_host}{'vlan'}{bond_name-vlan_id}=conf_id; #if vlan_id ne 'no' and bond_name ne 'no'.
                if ( $bond_name_l ne 'no' ) {
                    if ( !exists($cfg0_uniq_check_l{$inv_host_l}{'vlan'}{$bond_name_l.'-'.$vlan_id_l}) ) {
                        $cfg0_uniq_check_l{$inv_host_l}{'vlan'}{$bond_name_l.'-'.$vlan_id_l}=$conf_id_l;
                    }
                    else {
                        $return_str_l="fail [$proc_name_l]. Bond_name='$bond_name_l' (inv_host='$inv_host_l', conf_id='$conf_id_l', vlan_id='$vlan_id_l') is already used at config with id='".$cfg0_uniq_check_l{$inv_host_l}{'vlan'}{$bond_name_l.'-'.$vlan_id_l}."'. Please, check and correct config-file ('00_config')";
                        last;
                    }
                }
                ###
    	    }
    	    ########uniq checks
    	    
    	    ########unique conf_id for inventory_host
    	    if ( !exists(${$res_href_l}{$inv_host_l.'-'.$conf_id_l}) ) {
    		#$cfg0_hash_g{$inv_host_l.'-'.$conf_id_l}{$conf_type_l}{'main'}=[$inv_host_l,$conf_id_l,$vlan_id_l,$bond_name_l,$bridge_name_l,$defroute_l];
		${$res_href_l}{$inv_host_l.'-'.$conf_id_l}{$conf_type_l}{'main'}{'_inv_host_'}=$inv_host_l;
		${$res_href_l}{$inv_host_l.'-'.$conf_id_l}{$conf_type_l}{'main'}{'_conf_id_'}=$conf_id_l;
		${$res_href_l}{$inv_host_l.'-'.$conf_id_l}{$conf_type_l}{'main'}{'_vlan_id_'}=$vlan_id_l;
		${$res_href_l}{$inv_host_l.'-'.$conf_id_l}{$conf_type_l}{'main'}{'_bridge_name_'}=$bridge_name_l;
		${$res_href_l}{$inv_host_l.'-'.$conf_id_l}{$conf_type_l}{'main'}{'_defroute_'}=$defroute_l;
		${$res_href_l}{$inv_host_l.'-'.$conf_id_l}{$conf_type_l}{'main'}{'_bond_opts_'}=$bond_opts_str_l;
    		${$res_href_l}{$inv_host_l.'-'.$conf_id_l}{$conf_type_l}{'hwaddr_list'}=[@hwaddr_list_arr_l];
		
		if ( $ipaddr_opts_arr_l[0] ne 'dhcp' ) {
		    ${$res_href_l}{$inv_host_l.'-'.$conf_id_l}{$conf_type_l}{'main'}{'_ipaddr_'}=$ipaddr_opts_arr_l[0];
		    ${$res_href_l}{$inv_host_l.'-'.$conf_id_l}{$conf_type_l}{'main'}{'_gw_'}=$ipaddr_opts_arr_l[1];
		    ${$res_href_l}{$inv_host_l.'-'.$conf_id_l}{$conf_type_l}{'main'}{'_netmask_'}=$ipaddr_opts_arr_l[2];
		}
		else {
		    ${$res_href_l}{$inv_host_l.'-'.$conf_id_l}{$conf_type_l}{'main'}{'_ipaddr_'}='dhcp';
		    ${$res_href_l}{$inv_host_l.'-'.$conf_id_l}{$conf_type_l}{'main'}{'_gw_'}='dhcp';
		    ${$res_href_l}{$inv_host_l.'-'.$conf_id_l}{$conf_type_l}{'main'}{'_netmask_'}='dhcp';
		}
		
		${$res_href_l}{$inv_host_l.'-'.$conf_id_l}{$conf_type_l}{'main'}{'_bond_name_'}=$bond_name_l;
		${$res_href_l}{$inv_host_l.'-'.$conf_id_l}{$conf_type_l}{'int_list'}=[@int_list_arr_l];
		
		if ( $conf_type_l=~/vlan$/ && $vlan_id_l ne 'no' ) { # redefine interface/bond names if VLAN
		    if ( $bond_name_l eq 'no' ) { # for cases there vlan applied to interface (interface-vlan, bridge-vlan)
			${$res_href_l}{$inv_host_l.'-'.$conf_id_l}{$conf_type_l}{'main'}{'_bond_name_'}=$bond_name_l;
			foreach $arr_el0_l (@{${$res_href_l}{$inv_host_l.'-'.$conf_id_l}{$conf_type_l}{'int_list'}}) { $arr_el0_l.='.'.$vlan_id_l; }
		    }
		    elsif ( $bond_name_l ne 'no' ) { # for cases there vlan applied to bond (bond-vlan, bond-bridge-vlan)
			${$res_href_l}{$inv_host_l.'-'.$conf_id_l}{$conf_type_l}{'main'}{'_bond_name_'}=$bond_name_l.'.'.$vlan_id_l;
		    }
		}
    	    }
    	    else {
    		$return_str_l="fail [$proc_name_l]. For inv_host='$inv_host_l' conf_id='$conf_id_l' is already exists. Please, check and correct config-file ('00_config')";
    		last;
    	    }
    	    ########unique conf_id for inventory_host
	    
	    #############
	    @int_list_arr_l=();
	    @hwaddr_list_arr_l=();
	    @ipaddr_opts_arr_l=();
	    	
	    @arr0_l=();
	    ($inv_host_l,$conf_id_l,$conf_type_l,$int_list_str_l,$hwaddr_list_str_l,$vlan_id_l,$bond_name_l,$bridge_name_l,$ipaddr_opts_l,$bond_opts_l,$defroute_l)=(undef,undef,undef,undef,undef,undef,undef,undef,undef,undef,undef);
	    #############
	}
	$line_l=undef;
    }
    close(CONF);
    
    if ( $return_str_l!~/^OK$/ ) { return $return_str_l; }
}

sub recreate_ifcfg_tmplt_based_on_cfg0_hash {
    my ($dyn_ifcfg_common_dir_l,$ifcfg_tmplt_dir_l,$cfg0_hash_href_l,$conf_type_sub_refs_href_l,$res_inv_hosts_hash0_href_l)=@_;
    my $proc_name_l=(caller(0))[3];
    #$dyn_ifcfg_common_dir_l=$dyn_ifcfg_common_dir_g
    #$ifcfg_tmplt_dir_l=$ifcfg_tmplt_dir_g
    #cfg0_hash_href_l=hash ref for %cfg0_hash_g
    #$conf_type_sub_refs_href_l=hash ref for %conf_type_sub_refs_g
    #res_href_inv_hosts_hash0_l=hash ref for %inv_hosts_hash0_g

    my ($hkey0_l,$hval0_l)=(undef,undef);
    my ($hkey1_l,$hval1_l)=(undef,undef);
    my ($inv_host_l,$conf_id_l)=(undef,undef);

    my $return_str_l='OK';

    ###remove prev generated ifcfg
    if ( -d $dyn_ifcfg_common_dir_l ) {
        system("cd $dyn_ifcfg_common_dir_l && ls | grep -v 'info' | xargs rm -rf");
    }
    ###remove prev generated ifcfg

    while ( ($hkey0_l,$hval0_l)=each %{$cfg0_hash_href_l} ) {
        #$hkey0_h = inv_host-conf_id
        ($inv_host_l,$conf_id_l)=split(/\-/,$hkey0_l);
        ${$res_inv_hosts_hash0_href_l}{$inv_host_l}=1;

        system("mkdir -p ".$dyn_ifcfg_common_dir_l.'/'.$inv_host_l.'/fin');
        system("mkdir -p ".$dyn_ifcfg_common_dir_l.'/'.$inv_host_l.'/'.$conf_id_l);

        while ( ($hkey1_l,$hval1_l)=each %{$hval0_l} ) {
            #$hkey1_l = conf_type, $hval1_l = hash ref
            if ( -d $ifcfg_tmplt_dir_l.'/'.$hkey1_l ) {
                &{${$conf_type_sub_refs_href_l}{$hkey1_l}}($ifcfg_tmplt_dir_l.'/'.$hkey1_l,$dyn_ifcfg_common_dir_l.'/'.$inv_host_l.'/'.$conf_id_l,$hval1_l);
                ######
                #$cfg0_hash_g{inv_host-conf_id}{conf_type}-HREF->{'main'}{'_inv_host_'}=inv_host;
                #$cfg0_hash_g{inv_host-conf_id}{conf_type}-HREF->{'main'}{'_conf_id_'}=conf_id;
                #$cfg0_hash_g{inv_host-conf_id}{conf_type}-HREF->{'main'}{'_vlan_id_'}=vlan_id;
                #$cfg0_hash_g{inv_host-conf_id}{conf_type}-HREF->{'main'}{'_bond_name_'}=bond_name;
                #$cfg0_hash_g{inv_host-conf_id}{conf_type}-HREF->{'main'}{'_bridge_name_'}=bridge_name;
                #$cfg0_hash_g{inv_host-conf_id}{conf_type}-HREF->{'main'}{'_defroute_'}=defroute;
                #$cfg0_hash_g{inv_host-conf_id}{conf_type}-HREF->{'main'}{'_ipaddr_'}=ipaddr/dhcp;
                #$cfg0_hash_g{inv_host-conf_id}{conf_type}-HREF->{'main'}{'_gw_'}=gw/dhcp;
                #$cfg0_hash_g{inv_host-conf_id}{conf_type}-HREF->{'main'}{'_netmask_'}=gw/dhcp;
                #$cfg0_hash_g{inv_host-conf_id}{conf_type}-HREF->{'main'}{'_bond_opts_'}=bond_opts_string_for_ifcfg;
                #$cfg0_hash_g{inv_host-conf_id}{conf_type}-HREF->{'int_list'}=[array of interfaces];
                #$cfg0_hash_g{inv_host-conf_id}{conf_type}-HREF->{'hwaddr_list'}=[array of hwaddr];
                
                system("cp $dyn_ifcfg_common_dir_l/$inv_host_l/$conf_id_l/* $dyn_ifcfg_common_dir_l/$inv_host_l/fin/");
            }
            else {
                $return_str_l="fail [$proc_name_l]. Ifcfg tmplt dir='$ifcfg_tmplt_dir_l/$hkey1_l' not exists";
                last;
            }
        }

        ($hkey1_l,$hval1_l)=(undef,undef);
        ($inv_host_l,$conf_id_l)=(undef,undef);

        if ( $return_str_l!~/^OK$/ ) { last; }
    }
    
    ($hkey0_l,$hval0_l)=(undef,undef);
    ($hkey1_l,$hval1_l)=(undef,undef);
    ($inv_host_l,$conf_id_l)=(undef,undef);

    return $return_str_l;
}

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
