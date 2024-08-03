sub ifcfg_diff_with_zone_param_save {
    #FOR REPLACE THIS=`diff $dyn_ifcfg_common_dir_g/$hkey0_g/fin/$hkey1_g $ifcfg_backup_from_remote_dir_g/$hkey0_g/$hkey1_g | wc -l`.
    #Compare file and add "firewall ZONE=*" (from_remote) to generated ifcfg.
    my ($ifcfg_generated_file_l,$ifcfg_from_remote_file_l)=@_;
    my ($zone_substr_l,$exec_res_l)=(undef,undef);
    
    $zone_substr_l=`grep -i zone $ifcfg_from_remote_file_l`;
    
    if ( defined($zone_substr_l) && length($zone_substr_l)>0 ) {
        $zone_substr_l=~s/\n|\r|\n\r|\r\n//g;
        $exec_res_l=`echo $zone_substr_l >> $ifcfg_generated_file_l`;
        $exec_res_l=undef;
    }
    
    $exec_res_l=`diff $ifcfg_generated_file_l $ifcfg_from_remote_file_l | wc -l`;
    $exec_res_l=~s/\n|\r|\n\r|\r\n//g;
    $exec_res_l=int($exec_res_l);
    
    return $exec_res_l;
}

sub replace_values_in_file {
    my ($file_path_l,$file_type_l,$int_name_l,$hwaddr_l,$prms_href_l)=@_;
    ###if STATIC.               virt_bridge/ifcfg-bridge-static:        _bridge_name_, _ipaddr_, _netmask_, _conf_id_
    
    ###if STATIC.               just_interface/ifcfg-eth-static:        _defroute_, _interface_name_, _hwaddr_, _ipaddr_, _netmask_, _gw_, _conf_id_
    ###if DHCP.                 just_interface/ifcfg-eth-dhcp:          _defroute_, _interface_name_, _hwaddr_, _conf_id_
    
    ###ETH for BRIDGE.          just_bridge/ifcfg-eth:                  _interface_name_, _bridge_name_, _hwaddr_, _conf_id_
    ###if STATIC.               just_bridge/ifcfg-bridge-static:        _defroute_, _bridge_name_, _ipaddr_, _gw_, _netmask_, _conf_id_
    ###if DHCP.                 just_bridge/ifcfg-bridge-dhcp:          _defroute_, _bridge_name_, _conf_id_
    
    ###ETH for bond.            just_bond/ifcfg-eth:                    _interface_name_, _bond_name_, _hwaddr_, _conf_id_
    ###if STATIC.               just_bond/ifcfg-bond-static:            _defroute_, _bond_name_, _bond_opts_, _ipaddr_, _gw_, _netmask_, _conf_id_
    ###if DHCP.                 just_bond/ifcfg-bond-dhcp:              _defroute_, _bond_name_, _bond_opts_, _conf_id_
    
    ###ETH for bond.            bond-bridge/ifcfg-eth:                  _interface_name_, _bond_name_, _hwaddr_, _conf_id_
    ###BOND for bridge.         bond-bridge/ifcfg-bond:                 _bond_name_, _bond_opts_, _bridge_name_, _conf_id_
    ###if STATIC.               bond-bridge/ifcfg-bridge-static:        _defroute_, _bridge_name_, _ipaddr_, _gw_, _netmask_, _conf_id_
    ###if DHCP.                 bond-bridge/ifcfg-bridge-dhcp:          _defroute_, _bridge_name_, _conf_id_
    
    ###if STATIC.               interface-vlan/ifcfg-eth-static:        _defroute_, _interface_name_, _hwaddr_, _ipaddr_, _netmask_, _gw_, _conf_id_
    ###if DHCP.                 interface-vlan/ifcfg-eth-dhcp:          _defroute_, _interface_name_, _hwaddr_, _conf_id_
    
    ###ETH for BRIDGE-vlan.     bridge-vlan/ifcfg-eth:                  _interface_name_, _bridge_name_, _hwaddr_, _conf_id_
    ###if STATIC.               bridge-vlan/ifcfg-bridge-static:        _defroute_, _bridge_name_, _ipaddr_, _gw_, _netmask_, _conf_id_
    ###if DHCP.                 bridge-vlan/ifcfg-bridge-dhcp:          _defroute_, _bridge_name_, _conf_id_
    
    ###ETH for bond-vlan.       bond-vlan/ifcfg-eth:                    _interface_name_, _bond_name_, _hwaddr_, _conf_id_
    ###if STATIC.               bond-vlan/ifcfg-bond-static:            _defroute_, _bond_name_, _bond_opts_, _ipaddr_, _gw_, _netmask_, _conf_id_
    ###if DHCP.                 bond-vlan/ifcfg-bond-dhcp:              _defroute_, _bond_name_, _bond_opts_, _conf_id_
    
    ###ETH for bond4bondbrvlan. bond-bridge-vlan/ifcfg-eth:             _interface_name_, _bond_name_, _hwaddr_, _conf_id_
    ###BOND for bondbrvlan.     bond-bridge-vlan/ifcfg-bond:            _bond_name_, _bond_opts_, _bridge_name_, _conf_id_
    ###if STATIC.               bond-bridge-vlan/ifcfg-bridge-static:   _defroute_, _bridge_name_, _ipaddr_, _gw_, _netmask_, _conf_id_
    ###if DHCP.                 bond-bridge-vlan/ifcfg-bridge-dhcp:     _defroute_, _bridge_name_, _conf_id_
    
    my $arr_el0_l=undef;
    
    my %file_type_hash_l=(
        'virt-bridge'=>         ['_bridge_name_','_ipaddr_','_netmask_','_conf_id_'],
        ###
        #just_bond, bond-bridge, bond-vlan, bond-bridge-vlan
        'eth-for-bond'=>        ['_bond_name_','_conf_id_'],
        ###
        #just_bridge, bridge-vlan
        'eth-for-bridge'=>      ['_bridge_name_','_conf_id_'],
        ###
        ##just_interface, interface-vlan
        'eth-static'=>          ['_defroute_','_ipaddr_','_netmask_','_gw_','_conf_id_'],
        'eth-dhcp'=>            ['_defroute_','_conf_id_'],
        ###
        #just_bridge, bridge-vlan, bond-bridge-vlan
        'bridge-static'=>       ['_defroute_','_bridge_name_','_ipaddr_','_gw_','_netmask_','_conf_id_'],
        'bridge-dhcp'=>         ['_defroute_','_bridge_name_','_conf_id_'],
        ###
        #just_bond
        'bond-static'=>         ['_defroute_','_bond_name_','_bond_opts_','_ipaddr_','_gw_','_netmask_','_conf_id_'],
        'bond-dhcp'=>           ['_defroute_','_bond_name_','_bond_opts_','_conf_id_'],
        ###
        #bond-bridge-vlan, bond-bridge
        'bond-for-bridge'=>     ['_bond_name_','_bond_opts_','_bridge_name_','_conf_id_']
    );
    
    if ( $hwaddr_l ne 'no' ) { system("sed -i -e 's/_hwaddr_/$hwaddr_l/g' $file_path_l"); }
    
    #if ( ${$prms_href_l}{'main'}{'_vlan_id_'} )
    if ( $int_name_l ne 'no' ) { system("sed -i -e 's/_interface_name_/$int_name_l/g' $file_path_l"); }
    foreach $arr_el0_l ( @{$file_type_hash_l{$file_type_l}} ) {
        system("sed -i -e 's/$arr_el0_l/${$prms_href_l}{'main'}{$arr_el0_l}/g' $file_path_l");
    }
}
