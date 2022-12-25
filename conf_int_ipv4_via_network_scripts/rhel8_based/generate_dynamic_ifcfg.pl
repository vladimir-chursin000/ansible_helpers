#!/usr/bin/perl

###SCRIPT for generate ifcfg-files, resolv.conf for each inventory host and dynamic playbooks for ifcfg and resolv.conf

use strict;
use warnings;
use Cwd;
use Data::Dumper;

our ($self_dir_g,$script_name_g)=Cwd::abs_path($0)=~/(.*[\/\\])(\S+)$/;

###ARGV
our $gen_playbooks_next_g=0;
our $gen_playbooks_next_with_rollback_g=0;
if ( defined($ARGV[0]) && $ARGV[0]=~/^gen_dyn_playbooks$/ ) {
    $gen_playbooks_next_g=1;
}
elsif ( defined($ARGV[0]) && $ARGV[0]=~/^gen_dyn_playbooks_with_rollback$/ ) {
    $gen_playbooks_next_g=1;
    $gen_playbooks_next_with_rollback_g=1;
}
###ARGV

###CFG file
our $conf_file_g=$self_dir_g.'config';
our $conf_file_del_not_configured_g=$self_dir_g.'/additional_configs/config_del_not_configured_ifcfg';
our $conf_temp_apply_g=$self_dir_g.'/additional_configs/config_temporary_apply_ifcfg';
our $conf_dns_g=$self_dir_g.'/additional_configs/dns_settings'; #for configure resolv.conf
###CFG file

############STATIC VARS. Change dir paths if you want just use this script without ansible helper
our $dyn_ifcfg_common_dir_g=$self_dir_g.'playbooks/dyn_ifcfg_playbooks/dyn_ifcfg'; # dir for save generated ifcfg-files
our $dyn_resolv_common_dir_g=$self_dir_g.'playbooks/dyn_ifcfg_playbooks/dyn_resolv_conf'; # dir for save generated resolv-conf-files
our $dyn_ifcfg_playbooks_dir_g=$self_dir_g.'playbooks/dyn_ifcfg_playbooks'; # dir for save generated dynamic playbooks. Playbooks will be created if changes needed
our $ifcfg_tmplt_dir_g=$self_dir_g.'playbooks/ifcfg_tmplt'; # dir with ifcfg templates
our $ifcfg_backup_from_remote_dir_g=$self_dir_g.'playbooks/ifcfg_backup_from_remote/now'; # dir contains actual ifcfg-files downloaded from remote hosts with help of playbook 'ifcfg_backup_playbook.yml' before run this script
our $ifcfg_backup_from_remote_nd_file_g=$self_dir_g.'playbooks/ifcfg_backup_from_remote/network_data/inv_hosts_interfaces_info.txt'; # dir contains actual network_data (eth, hwaddr) downloaded from remote hosts with help of playbook 'ifcfg_backup_playbook.yml' before run this script
our $remote_dir_for_absible_helper_g='~/ansible_helpers/conf_int_ipv4_via_network_scripts'; # dir for creating/manipulate files at remote side
############STATIC VARS

############VARS
our $tmp_file0_g=undef; #for put file paths while processing
our ($line_g,$arr_el0_g,$exec_res_g,$tmp_var_g,$arr_i0_g)=(undef,undef,undef,undef,undef);
our ($hkey0_g,$hval0_g)=(undef,undef);
our ($hkey1_g,$hval1_g)=(undef,undef);
our ($skip_conf_line_g,$exec_status_g)=(0,'OK');
our ($inv_host_g,$conf_id_g,$conf_type_g,$int_list_str_g,$hwaddr_list_str_g,$vlan_id_g,$bond_name_g,$bridge_name_g,$ipaddr_opts_g,$bond_opts_g,$defroute_g)=(undef,undef,undef,undef,undef,undef,undef,undef,undef,undef,undef);
our @arr0_g=();
######
our %cfg0_hash_g=();
#$cfg0_hash_g{inv_host-conf_id}{conf_type}{'main'}{'_inv_host_'}=inv_host;
#$cfg0_hash_g{inv_host-conf_id}{conf_type}{'main'}{'_conf_id_'}=conf_id;
#$cfg0_hash_g{inv_host-conf_id}{conf_type}{'main'}{'_vlan_id_'}=vlan_id;
#$cfg0_hash_g{inv_host-conf_id}{conf_type}{'main'}{'_bond_name_'}=bond_name;
#$cfg0_hash_g{inv_host-conf_id}{conf_type}{'main'}{'_bridge_name_'}=bridge_name;
#$cfg0_hash_g{inv_host-conf_id}{conf_type}{'main'}{'_defroute_'}=defroute;
#$cfg0_hash_g{inv_host-conf_id}{conf_type}{'main'}{'_ipaddr_'}=ipaddr/dhcp;
#$cfg0_hash_g{inv_host-conf_id}{conf_type}{'main'}{'_gw_'}=gw/dhcp;
#$cfg0_hash_g{inv_host-conf_id}{conf_type}{'main'}{'_netmask_'}=gw/dhcp;
#$cfg0_hash_g{inv_host-conf_id}{conf_type}{'main'}{'_bond_opts_'}=bond_opts_string_for_ifcfg;
#$cfg0_hash_g{inv_host-conf_id}{conf_type}{'int_list'}=[array of interfaces];
#$cfg0_hash_g{inv_host-conf_id}{conf_type}{'hwaddr_list'}=[array of hwaddr];
######
our %cfg0_uniq_check=();
#Checks (uniq) for novlan interfaces at current inv_host.
#$cfg0_uniq_check{inv_host}{'common'}{interface_name}=conf_id; #if interface_name ne 'no' and vlan_id eq 'no'.
#$cfg0_uniq_check{inv_host}{'common'}{hwaddr}=conf_id; if vlan_id eq 'no'.
#$cfg0_uniq_check{inv_host}{'common'}{bond_name}=conf_id; #if bond_name ne 'no' and vlan_id eq 'no'.
#$cfg0_uniq_check{inv_host}{'common'}{bridge_name}=conf_id; #if bridge_name ne 'no' and vlan_id eq 'no'.
#$cfg0_uniq_check{inv_host}{'common'}{ipaddr}=conf_id; #if ipaddr_opts ne 'dhcp'.
###
#Checks (uniq) for vlan interfaces at current inv_host.
#$cfg0_uniq_check{inv_host}{'vlan'}{vlan_id}=conf_id; #if vlan_id ne 'no'.
#$cfg0_uniq_check{inv_host}{'vlan'}{interface_name-vlan_id}=conf_id; #if vlan_id ne 'no'.
#$cfg0_uniq_check{inv_host}{'vlan'}{hwaddr-vlan_id}=conf_id; #if vlan_id ne 'no'.
#$cfg0_uniq_check{inv_host}{'vlan'}{bond_name-vlan_id}=conf_id; #if vlan_id ne 'no' and bond_name ne 'no'.
#$cfg0_uniq_check{inv_host}{'vlan'}{bridge_name-vlan_id}=conf_id; #if vlan_id ne 'no' and bridge_name ne 'no'.
###
#Checks (uniq) for interfaces at config (for all inv_hosts)
#$cfg0_uniq_check{'all_hosts'}{hwaddr}=inv_host;
#$cfg0_uniq_check{'all_hosts'}{ipaddr}=inv_host; #if ipaddr ne 'dhcp'.
######
our %defroute_check_g=();
#$defroute_check_g{inv_host}=conf_id;
######
our %cfg_ready_hash_g=();
our @int_list_arr_g=();
our @hwaddr_list_arr_g=();
our @ipaddr_opts_arr_g=();
our @bond_opts_arr_g=();
our $bond_opts_str_def_g='mode=4 xmit_hash_policy=2 lacp_rate=1 miimon=100';
our $bond_opts_str_g=$bond_opts_str_def_g;

our %conf_type_sub_refs_g=(
    #common (novlan)
    'just_interface'=>\&just_interface_gen_ifcfg,
    'virt_bridge'=>\&virt_bridge_gen_ifcfg,
    'just_bridge'=>\&just_bridge_gen_ifcfg,
    'just_bond'=>\&just_bond_gen_ifcfg,
    'bond-bridge'=>\&bond_bridge_gen_ifcfg,
    #
    #vlan
    'interface-vlan'=>\&interface_vlan_gen_ifcfg,
    'bridge-vlan'=>\&bridge_vlan_gen_ifcfg,
    'bond-vlan'=>\&bond_vlan_gen_ifcfg,
    'bond-bridge-vlan'=>\&bond_bridge_vlan_gen_ifcfg,
);

our %inv_hosts_hash0_g=(); #key=inv_host, value=1
our %inv_hosts_hash1_g=(); #key0=inv_host, key1=now/fin (generated by this script)/for_upd/for_del, key2=ifcfg_name
our %inv_hosts_ifcfg_del_not_configured_g=(); #for config 'config_del_not_configured_ifcfg'. Key=inv_host
our %inv_hosts_dns_g=(); #key=inv_host/common, value=[array of nameservers]
our %inv_hosts_tmp_apply_cfg_g=(); #key=inv_host/common, value=rollback_ifcfg_timeout
###
our %inv_hosts_network_data_g=();
#read 'ip_link_noqueue' first
#v1) key0='hwaddr_all', key1=hwaddr, value=inv_host
#v2) key0='inv_host', key1=inv_host, key2=interface_name, key3=hwaddr
############VARS

######MAIN SEQ

###READ network data for checks
$exec_res_g=&read_network_data_for_checks($ifcfg_backup_from_remote_nd_file_g,\%inv_hosts_network_data_g);
#$file_l,$res_href_l
if ( $exec_res_g=~/^fail/ ) {
    $exec_status_g='FAIL';
    print "$exec_res_g\n";
}
###READ network data for checks

###READ config
open(CONF,'<',$conf_file_g);
while ( <CONF> ) {
    $line_g=$_;
    $line_g=~s/\n$|\r$|\n\r$|\r\n$//g;
    while ($line_g=~/\t/) { $line_g=~s/\t/ /g; }
    $line_g=~s/\s+/ /g;
    $line_g=~s/^ //g;
    if ( length($line_g)>0 && $line_g!~/^\#/ ) {
    	$line_g=~s/ \,/\,/g;
    	$line_g=~s/\, /\,/g;
    	$line_g=~s/ \, /\,/g;
    	
    	$line_g=~s/ \./\./g;
    	$line_g=~s/\. /\./g;
    	$line_g=~s/ \. /\./g;
    	
    	$skip_conf_line_g=0;
    	@arr0_g=split(' ',$line_g);
    	if ( $#arr0_g!=10 ) {
    	    print "Conf-line='$line_g' must contain 11 params. Please, check and correct config-file\n";
	    if ( $exec_status_g=~/^OK$/ ) { $exec_status_g='FAIL'; }
    	    next;
    	}
    	
    	($inv_host_g,$conf_id_g,$conf_type_g,$int_list_str_g,$hwaddr_list_str_g,$vlan_id_g,$bond_name_g,$bridge_name_g,$ipaddr_opts_g,$bond_opts_g,$defroute_g)=@arr0_g;
	
	$hwaddr_list_str_g=lc($hwaddr_list_str_g);
    	
    	#######check conf_type
    	if ( $conf_type_g!~/^just_interface$|^virt_bridge$|^just_bridge$|^just_bond$|^bond\-bridge$|^interface\-vlan$|^bridge\-vlan$|^bond\-vlan$|^bond\-bridge\-vlan$/ ) {
    	    print "Wrong conf_type='$conf_type_g'. Conf_type must be 'just_interface/virt_bridge/just_bridge/just_bond/bond-bridge/interface-vlan/bridge-vlan/bond-vlan/bond-bridge-vlan'. Please, check and correct config-file\n";
    	    $skip_conf_line_g=1;    
    	}
	if ( $conf_type_g=~/\-vlan$/ && $vlan_id_g eq 'no' ) {
	    print "For vlan-config-type param vlan_id must be a NUMBER. Please, check and correct config-file\n";
	    $skip_conf_line_g=1;
	}

    	if ( $skip_conf_line_g==1 ) {
            print "Skip conf-line with conf_id='$conf_id_g'\n";
	    if ( $exec_status_g=~/^OK$/ ) { $exec_status_g='FAIL'; }
            next;
        }
    	#######check conf_type
    	
    	#######defroute check
    	    #$defroute_check_g{inv_host}=conf_id;
    	if ( !exists($defroute_check_g{$inv_host_g}) && $defroute_g eq 'yes' ) {
    	    $defroute_check_g{$inv_host_g}=$conf_id_g;
    	}
    	elsif ( exists($defroute_check_g{$inv_host_g}) && $defroute_g eq 'yes' ) {
    	    print "Defroute for inv_host='$inv_host_g' is already defined by conf_id='$defroute_check_g{$inv_host_g}'. Set 'defroute=no' for conf_id='$conf_id_g'. Please, check and correct config-file\n";
    	    $defroute_g='no';
    	}
    	#######defroute check
    	
    	#######bond_name/bridge_name simple checks
    	if ( $conf_type_g=~/^just_interface$|^interface\-vlan$/ ) {
    	    if ( $bond_name_g ne 'no' ) {
    		print "For conf_types='just_interface/interface-vlan' bond_name must be 'no'. Set value from '$bond_name_g' to 'no' (conf_id='$conf_id_g'). Please, check and correct config-file\n";
    		$bond_name_g='no';
    	    }
    	    if ( $bridge_name_g ne 'no' ) {
    		print "For conf_types='just_interface/interface-vlan' bridge_name must be 'no'. Set value from '$bridge_name_g' to 'no' (conf_id='$conf_id_g'). Please, check and correct config-file\n";
    		$bridge_name_g='no';
    	    }
    	}
    	
    	if ( $conf_type_g=~/^virt_bridge$|^just_bridge$|^bridge\-vlan$/ ) {
    	    if ( $bond_name_g ne 'no' ) {
    		print "For conf_types='virt_bridge/just_bridge/bridge-vlan' bond_name must be 'no'. Set value from '$bond_name_g' to 'no' (conf_id='$conf_id_g'). Please, check and correct config-file\n";
    		$bond_name_g='no';
    	    }
    	    if ( $bridge_name_g eq 'no' ) {
    		print "For conf_types='virt_bridge/just_bridge/bridge-vlan' bridge_name must be NOT 'no'. Please, check and correct config-file\n";
    		$skip_conf_line_g=1;
    	    }
    	}
    	
    	if ( $conf_type_g=~/^just_bond$|^bond\-vlan$/ ) {
    	    if ( $bridge_name_g ne 'no' ) {
    		print "For conf_types='just_bond/bond-vlan' bridge_name must be 'no'. Set value from '$bridge_name_g' to 'no' (conf_id='$conf_id_g'). Please, check and correct config-file\n";
    		$bond_name_g='no';
    	    }
    	    if ( $bond_name_g eq 'no' ) {
    		print "For conf_types='just_bond/bond-vlan' bond_name must be NOT 'no'. Please, check and correct config-file\n";
    		$skip_conf_line_g=1;
    	    }
    	}
    	
    	if ( $conf_type_g=~/^bond\-bridge$|^bond\-bridge\-vlan$/ ) {
    	    if ( $bridge_name_g eq 'no' ) {
    		print "For conf_types='bond-bridge/bond-bridge-vlan' bridge_name must be NOT 'no'. Please, check and correct config-file\n";
    		$skip_conf_line_g=1;
    	    }
    	    if ( $bond_name_g eq 'no' ) {
    		print "For conf_types='bond-bridge/bond-bridge-vlan' bond_name must be NOT 'no'. Please, check and correct config-file\n";
    		$skip_conf_line_g=1;
    	    }
    	}
	
    	if ( $skip_conf_line_g==1 ) {
    	    print "Skip conf-line with conf_id='$conf_id_g'\n";
	    if ( $exec_status_g=~/^OK$/ ) { $exec_status_g='FAIL'; }
    	    next;
    	}
    	#######bond_name/bridge_name simple checks
	
	#######bond_name check if vlan
	if ( $conf_type_g=~/^bond\-vlan$|^bond\-bridge\-vlan$/ && $vlan_id_g ne 'no' && $bond_name_g!~/\.$vlan_id_g$/ ) {
	    print "For vlan configurations like 'bond-vlan/bond-bridge-vlan' bond name must include vlan_id. Now bond_name='$bond_name_g', correct bond_name='$bond_name_g.$vlan_id_g'. Please, check and correct config-file\n";
	    $skip_conf_line_g=1;
	}
	
    	if ( $skip_conf_line_g==1 ) {
    	    print "Skip conf-line with conf_id='$conf_id_g'\n";
	    if ( $exec_status_g=~/^OK$/ ) { $exec_status_g='FAIL'; }
    	    next;
    	}
	#######bond_name check if vlan
    	
    	#######IPADDRv4 PREcheck via regexp
    	if ( $conf_type_g!~/^virt_bridge$/ && $ipaddr_opts_g!~/^dhcp$|^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\,\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\,\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/ ) {
    	    print "IPv4_ADDR_OPTS must be 'dhcp' or 'ipv4,gw,netmask'. Please, check and correct config-file\n";
    	    $skip_conf_line_g=1;
    	}
    	elsif ( $conf_type_g=~/^virt_bridge$/ && $ipaddr_opts_g!~/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\,nogw\,\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/ ) {
    	    print "IPv4_ADDR_OPTS for conf_type='virt-bridge' must be 'ipv4,nogw,netmask' (for example '10.1.1.1,nogw,255.255.255.0'). Please, check and correct config-file\n";
    	    $skip_conf_line_g=1;
    	}
	
    
    	if ( $skip_conf_line_g==1 ) {
    	    print "Skip conf-line with conf_id='$conf_id_g'\n";
	    if ( $exec_status_g=~/^OK$/ ) { $exec_status_g='FAIL'; }
    	    next;
    	}
    	#######IPADDRv4 PREcheck via regexp
    
    	#######extract complex vars
    	@int_list_arr_g=split(/\,/,$int_list_str_g);
    	@hwaddr_list_arr_g=split(/\,/,$hwaddr_list_str_g);
    	@ipaddr_opts_arr_g=split(/\,/,$ipaddr_opts_g);
	$bond_opts_str_g=$bond_opts_str_def_g;
    	if ( $conf_type_g=~/^just_bond$|^bond\-vlan$|^bond\-bridge$|^bond\-bridge\-vlan$/ && $bond_opts_g!~/^def$/ ) {
    	    $bond_opts_str_g=$bond_opts_g;
    	    $bond_opts_str_g=~s/\,/ /g;
    	}
    	#######extract complex vars
    	
    	#######interfaces + hwaddr count checks for each conf_type
    	if ( $conf_type_g=~/^virt_bridge$/ ) { #for conf_type=virt_bridge. No interfaces
    	    if ( $#hwaddr_list_arr_g!=0 ) {
    		print "For conf_type='$conf_type_g' must be configured only one HWADDR. Please, check and correct config-file\n";
    		$skip_conf_line_g=1;
    	    }
    	    if ( $#int_list_arr_g>0 or $int_list_arr_g[0] ne 'no' ) {
    		@int_list_arr_g=('no');
    		print "For conf_type='$conf_type_g' int_list must contain only 'no'. Please, check and correct config-file\n";
    	    }
    	}
    	
    	if ( $conf_type_g=~/^just_interface$|^just_bridge$|^interface\-vlan$|^bridge\-vlan$/ ) { #for conf_types where possible using only one interface
    	    if ( ($#int_list_arr_g==$#hwaddr_list_arr_g && $#int_list_arr_g!=0) or $#int_list_arr_g!=$#hwaddr_list_arr_g ) {
    		print "For conf_type='$conf_type_g' must be configured only one HWADDR. Please, check and correct config-file\n";
    		$skip_conf_line_g=1;
    	    }
    	    if ( $int_list_arr_g[0] eq 'no' ) {
    		print "For conf_type='$conf_type_g' int_list must contain interface names, but not 'no'. Please, check and correct config-file\n";
    		$skip_conf_line_g=1;
    	    }
    	}
    	
    	if ( $conf_type_g=~/^just_bond$|^bond\-bridge$|^bond\-vlan$|^bond\-bridge\-vlan$/ ) { #for conf_types where >=2 interfaces
    	    if ( $#int_list_arr_g<1 or $#int_list_arr_g!=$#hwaddr_list_arr_g ) {
    		print "For conf_type='$conf_type_g' amount of interfaces must = amount of hwaddr and amount of interfaces must be >= 2. Please, check and correct config-file\n";
    		$skip_conf_line_g=1;
    	    }
    	    foreach $arr_el0_g ( @int_list_arr_g ) {
    		if ( $arr_el0_g eq 'no' ) {
    		    print "For conf_type='$conf_type_g' int_list must contain interface names, but not 'no'. Please, check and correct config-file\n";
    		    $skip_conf_line_g=1;
    		    last;
    		}
    	    }
    	    $arr_el0_g=undef;
    	}
    
    	if ( $skip_conf_line_g==1 ) {
    	    print "Skip conf-line with conf_id='$conf_id_g'\n";
	    if ( $exec_status_g=~/^OK$/ ) { $exec_status_g='FAIL'; }
    	    next;
    	}
    	#######interfaces + hwaddr count checks for each conf_type
    	
    	#######hwaddr check via regexp
	if ( $conf_type_g!~/^virt_bridge$/ ) {
    	    foreach $arr_el0_g ( @hwaddr_list_arr_g ) {
    		if ( $arr_el0_g!~/^\S{2}\:\S{2}\:\S{2}\:\S{2}\:\S{2}\:\S{2}$/ ) {
    		    print "HWADDR must be like 'XX:XX:XX:XX:XX:XX' (incorrect value='$arr_el0_g'). Please, check and correct config-file\n";
    		    $skip_conf_line_g=1;
    		}
    	    }
	}
	else {
	    foreach $arr_el0_g ( @hwaddr_list_arr_g ) {
    		if ( $arr_el0_g!~/^no$/ ) {
    		    print "HWADDR for virt_bridge must be 'no' (incorrect value='$arr_el0_g'). Set new value='no'. Please, check and correct config-file\n";
    		    $skip_conf_line_g=1;
    		}
    	    }
	}
    
    	if ( $skip_conf_line_g==1 ) {
    	    print "Skip conf-line with conf_id='$conf_id_g'\n";
	    if ( $exec_status_g=~/^OK$/ ) { $exec_status_g='FAIL'; }
    	    next;
    	}
    	#######hwaddr check via regexp
    	
	#######NETWORK DATA (ip link) checks
	if ( $conf_type_g!~/^virt_bridge$/ ) {
	    #our %inv_hosts_network_data_g=();
	    #read 'ip_link_noqueue' first
	    #v1) key0='hwaddr_all', key1=hwaddr, value=inv_host
	    #v2) key0='inv_host', key1=inv_host, key2=interface_name, key3=hwaddr
	    for ( $arr_i0_g=0; $arr_i0_g<=$#hwaddr_list_arr_g; $arr_i0_g++ ) {
		if ( exists($inv_hosts_network_data_g{'hwaddr_all'}{$hwaddr_list_arr_g[$arr_i0_g]}) && $inv_host_g ne $inv_hosts_network_data_g{'hwaddr_all'}{$hwaddr_list_arr_g[$arr_i0_g]} ) {
		    print "NETWORK DATA check. HWADDR='$hwaddr_list_arr_g[$arr_i0_g]' configured for inv_host='$inv_host_g' is already used by host='$inv_hosts_network_data_g{'hwaddr_all'}{$hwaddr_list_arr_g[$arr_i0_g]}'. Please, check and correct config-file or solve problem with duplicated mac-address\n";
		    $skip_conf_line_g=1;
		}
		
		if ( !exists($inv_hosts_network_data_g{'inv_host'}{$inv_host_g}{$int_list_arr_g[$arr_i0_g]}{$hwaddr_list_arr_g[$arr_i0_g]}) ) {
		    print "NETWORK DATA check. At inv_host='$inv_host_g' interface='$int_list_arr_g[$arr_i0_g]' not linked with hwaddr='$hwaddr_list_arr_g[$arr_i0_g]'. Please, check and correct config-file\n";
		    $skip_conf_line_g=1;
		}
	    }

    	    if ( $skip_conf_line_g==1 ) {
    		print "Skip conf-line with conf_id='$conf_id_g'\n";
		if ( $exec_status_g=~/^OK$/ ) { $exec_status_g='FAIL'; }
    		next;
    	    }
	}
	#######NETWORK DATA (ip link) checks

    	#######uniq checks for all hosts (hwaddr, ipaddr)
    	    #$cfg0_uniq_check{'all_hosts'}{hwaddr}=inv_host;
    	    #$cfg0_uniq_check{'all_hosts'}{ipaddr}=inv_host; #if ipaddr ne 'dhcp'.
    	foreach $arr_el0_g ( @hwaddr_list_arr_g ) {
    	    if ( !exists($cfg0_uniq_check{'all_hosts'}{$arr_el0_g}) ) {
    		$cfg0_uniq_check{'all_hosts'}{$arr_el0_g}=$inv_host_g;
    	    }
    	    else {
    		if ( $cfg0_uniq_check{'all_hosts'}{$arr_el0_g} ne $inv_host_g ) {
    		    print "Hwaddr='$arr_el0_g' is already used at host='$cfg0_uniq_check{'all_hosts'}{$arr_el0_g}'. Please, check and correct config-file\n";
    		    $skip_conf_line_g=1;
    		}
    	    }
    	}
    	if ( $skip_conf_line_g==1 ) {
    	    print "Skip conf-line with conf_id='$conf_id_g'\n";
	    if ( $exec_status_g=~/^OK$/ ) { $exec_status_g='FAIL'; }
    	    next;
    	}
    	
    	if ( $ipaddr_opts_arr_g[0] ne 'dhcp' ) {
    	    if ( !exists($cfg0_uniq_check{'all_hosts'}{$ipaddr_opts_arr_g[0]}) ) {
    		$cfg0_uniq_check{'all_hosts'}{$ipaddr_opts_arr_g[0]}=$inv_host_g;
    	    }
    	    else {
    		print "IPaddr='$ipaddr_opts_arr_g[0]' is already used at host='$cfg0_uniq_check{'all_hosts'}{$ipaddr_opts_arr_g[0]}'. Please, check and correct config-file\n";
    		$skip_conf_line_g=1;
    	    }

    	    if ( $skip_conf_line_g==1 ) {
    		print "Skip conf-line with conf_id='$conf_id_g'\n";
		if ( $exec_status_g=~/^OK$/ ) { $exec_status_g='FAIL'; }
    		next;
    	    }
    	}
    	########uniq checks for all hosts
    
    	########uniq checks (for local params of hosts)
    	if ( $vlan_id_g=~/^no$/ ) { #if novlan
    	    ###$cfg0_uniq_check{inv_host}{'common'}{interface_name}=conf_id; #if interface_name ne 'no' and vlan_id eq 'no'.
    	    foreach $arr_el0_g ( @int_list_arr_g ) {
    		if ( $arr_el0_g=~/^no$/ ) { last; }
    		if ( !exists($cfg0_uniq_check{$inv_host_g}{'common'}{$arr_el0_g}) ) {
    		    $cfg0_uniq_check{$inv_host_g}{'common'}{$arr_el0_g}=$conf_id_g;
    		}
    		else {
    		    print "Interface_name='$arr_el0_g' (inv_host='$inv_host_g') is already used at config with id='$cfg0_uniq_check{$inv_host_g}{'common'}{$arr_el0_g}'. Please, check and correct config-file\n";
    		    $skip_conf_line_g=1;
    		}
    	    }
    	    if ( $skip_conf_line_g==1 ) {
    		print "Skip conf-line with conf_id='$conf_id_g'\n";
		if ( $exec_status_g=~/^OK$/ ) { $exec_status_g='FAIL'; }
    		next;
    	    }
    	    ###
    
    	    ###$cfg0_uniq_check{inv_host}{'common'}{hwaddr}=conf_id; if vlan_id eq 'no'.
    	    foreach $arr_el0_g ( @hwaddr_list_arr_g ) {
    		if ( !exists($cfg0_uniq_check{$inv_host_g}{'common'}{$arr_el0_g}) ) {
    		    $cfg0_uniq_check{$inv_host_g}{'common'}{$arr_el0_g}=$conf_id_g;
    		}
    		else {
    		    print "Hwaddr='$arr_el0_g' (inv_host='$inv_host_g') is already used at config with id='$cfg0_uniq_check{$inv_host_g}{'common'}{$arr_el0_g}'. Please, check and correct config-file\n";
    		    $skip_conf_line_g=1;
    		}
    	    }
    	    if ( $skip_conf_line_g==1 ) {
    		print "Skip conf-line with conf_id='$conf_id_g'\n";
		if ( $exec_status_g=~/^OK$/ ) { $exec_status_g='FAIL'; }
    		next;
    	    }
    	    ###
    	    
    	    ###$cfg0_uniq_check{inv_host}{'common'}{bond_name}=conf_id; #if bond_name ne 'no' and vlan_id eq 'no'.
    	    if ( $bond_name_g ne 'no' ) {
    		if ( !exists($cfg0_uniq_check{$inv_host_g}{'common'}{$bond_name_g}) ) {
    		    $cfg0_uniq_check{$inv_host_g}{'common'}{$bond_name_g}=$conf_id_g;
    		}
    		else {
    		    print "Bond_name='$bond_name_g' (inv_host='$inv_host_g') is already used at config with id='$cfg0_uniq_check{$inv_host_g}{'common'}{$bond_name_g}'. Please, check and correct config-file\n";
    		    $skip_conf_line_g=1;
    		}
    		if ( $skip_conf_line_g==1 ) {
    		    print "Skip conf-line with conf_id='$conf_id_g'\n";
		    if ( $exec_status_g=~/^OK$/ ) { $exec_status_g='FAIL'; }
    		    next;
    		}
    	    }
    	    ###
    	    
    	    ###$cfg0_uniq_check{inv_host}{'common'}{bridge_name}=conf_id; #if bridge_name ne 'no' and vlan_id eq 'no'.
    	    if ( $bridge_name_g ne 'no' ) {
    		if ( !exists($cfg0_uniq_check{$inv_host_g}{'common'}{$bridge_name_g}) ) {
    		    $cfg0_uniq_check{$inv_host_g}{'common'}{$bridge_name_g}=$conf_id_g;
    		}
    		else {
    		    print "Bridge_name='$bridge_name_g' (inv_host='$inv_host_g') is already used at config with id='$cfg0_uniq_check{$inv_host_g}{'common'}{$bridge_name_g}'. Please, check and correct config-file\n";
    		    $skip_conf_line_g=1;
    		}
		
    		if ( $skip_conf_line_g==1 ) {
    		    print "Skip conf-line with conf_id='$conf_id_g'\n";
		    if ( $exec_status_g=~/^OK$/ ) { $exec_status_g='FAIL'; }
    		    next;
    		}
    	    }
    	    ###
    	    
    	    ###$cfg0_uniq_check{inv_host}{'common'}{ipaddr}=conf_id; #if ipaddr_opts ne 'dhcp'.
    	    if ( $ipaddr_opts_arr_g[0] ne 'dhcp' ) {
    		if ( !exists($cfg0_uniq_check{$inv_host_g}{'common'}{$ipaddr_opts_arr_g[0]}) ) {
    		    $cfg0_uniq_check{$inv_host_g}{'common'}{$ipaddr_opts_arr_g[0]}=$conf_id_g;
    		}
    		else {
    		    print "Ipaddr='$ipaddr_opts_arr_g[0]' (inv_host='$inv_host_g') is already used at config with id='$cfg0_uniq_check{$inv_host_g}{'common'}{$ipaddr_opts_arr_g[0]}'. Please, check and correct config-file\n";
    		    $skip_conf_line_g=1;
    		}
		
    		if ( $skip_conf_line_g==1 ) {
    		    print "Skip conf-line with conf_id='$conf_id_g'\n";
		    if ( $exec_status_g=~/^OK$/ ) { $exec_status_g='FAIL'; }
    		    next;
    		}
    	    }
    	    ###
    	}
    	else { #if vlan
    	    ###$cfg0_uniq_check{inv_host}{'vlan'}{vlan_id}=conf_id; #if vlan_id ne 'no'.
    	    if ( !exists($cfg0_uniq_check{$inv_host_g}{'vlan'}{$vlan_id_g}) ) {
    		$cfg0_uniq_check{$inv_host_g}{'vlan'}{$vlan_id_g}=$conf_id_g;
    	    }
    	    else {
    		print "Vlan_id='$vlan_id_g' (inv_host='$inv_host_g') is already used at config with id='$cfg0_uniq_check{$inv_host_g}{'vlan'}{$vlan_id_g}'. Please, check and correct config-file\n";
    		$skip_conf_line_g=1;
    	    }
	    
    	    if ( $skip_conf_line_g==1 ) {
    		print "Skip conf-line with conf_id='$conf_id_g'\n";
		if ( $exec_status_g=~/^OK$/ ) { $exec_status_g='FAIL'; }
    		next;
    	    }
    	    ###
    	    
    	    ###$cfg0_uniq_check{inv_host}{'vlan'}{interface_name-vlan_id}=conf_id; #if vlan_id ne 'no'.
    	    foreach $arr_el0_g ( @int_list_arr_g ) {
    		if ( $arr_el0_g=~/^no$/ ) { last; }
    		if ( !exists($cfg0_uniq_check{$inv_host_g}{'vlan'}{$arr_el0_g.'-'.$vlan_id_g}) ) {
    		    $cfg0_uniq_check{$inv_host_g}{'vlan'}{$arr_el0_g.'-'.$vlan_id_g}=$conf_id_g;
    		}
    		else {
    		    print "Interface_name='$arr_el0_g' (inv_host='$inv_host_g') is already used at config with id='".$cfg0_uniq_check{$inv_host_g}{'vlan'}{$arr_el0_g.'-'.$vlan_id_g}."'. Please, check and correct config-file\n";
    		    $skip_conf_line_g=1;
    		}
    	    }
	    
    	    if ( $skip_conf_line_g==1 ) {
    		print "Skip conf-line with conf_id='$conf_id_g'\n";
		if ( $exec_status_g=~/^OK$/ ) { $exec_status_g='FAIL'; }
    		next;
    	    }
    	    ###
    	    
    	    ###$cfg0_uniq_check{inv_host}{'vlan'}{hwaddr-vlan_id}=conf_id; #if vlan_id ne 'no'.
    	    foreach $arr_el0_g ( @hwaddr_list_arr_g ) {
    		if ( !exists($cfg0_uniq_check{$inv_host_g}{'vlan'}{$arr_el0_g.'-'.$vlan_id_g}) ) {
    		    $cfg0_uniq_check{$inv_host_g}{'vlan'}{$arr_el0_g.'-'.$vlan_id_g}=$conf_id_g;
    		}
    		else {
    		    print "Hwaddr='$arr_el0_g' (inv_host='$inv_host_g') is already used at config with id='".$cfg0_uniq_check{$inv_host_g}{'vlan'}{$arr_el0_g.'-'.$vlan_id_g}."'. Please, check and correct config-file\n";
    		    $skip_conf_line_g=1;
    		}
    	    }
	    
    	    if ( $skip_conf_line_g==1 ) {
    		print "Skip conf-line with conf_id='$conf_id_g'\n";
		if ( $exec_status_g=~/^OK$/ ) { $exec_status_g='FAIL'; }
    		next;
    	    }
    	    ###
    	    
    	    ###$cfg0_uniq_check{inv_host}{'vlan'}{bond_name-vlan_id}=conf_id; #if vlan_id ne 'no' and bond_name ne 'no'.
    	    if ( $bond_name_g ne 'no' ) {
    		if ( !exists($cfg0_uniq_check{$inv_host_g}{'vlan'}{$bond_name_g.'-'.$vlan_id_g}) ) {
    		    $cfg0_uniq_check{$inv_host_g}{'vlan'}{$bond_name_g.'-'.$vlan_id_g}=$conf_id_g;
    		}
    		else {
    		    print "Bond_name='$bond_name_g' (inv_host='$inv_host_g') is already used at config with id='".$cfg0_uniq_check{$inv_host_g}{'vlan'}{$bond_name_g.'-'.$vlan_id_g}."'. Please, check and correct config-file\n";
    		    $skip_conf_line_g=1;
    		}
		
    		if ( $skip_conf_line_g==1 ) {
    		    print "Skip conf-line with conf_id='$conf_id_g'\n";
		    if ( $exec_status_g=~/^OK$/ ) { $exec_status_g='FAIL'; }
    		    next;
    		}
    	    }
    	    ###
    	    
    	    ###$cfg0_uniq_check{inv_host}{'vlan'}{bridge_name-vlan_id}=conf_id; #if vlan_id ne 'no' and bridge_name ne 'no'.
    	    if ( $bridge_name_g ne 'no' ) {
    		if ( !exists($cfg0_uniq_check{$inv_host_g}{'vlan'}{$bridge_name_g.'-'.$vlan_id_g}) ) {
    		    $cfg0_uniq_check{$inv_host_g}{'vlan'}{$bridge_name_g.'-'.$vlan_id_g}=$conf_id_g;
    		}
    		else {
    		    print "Bridge_name='$bond_name_g' (inv_host='$inv_host_g') is already used at config with id='".$cfg0_uniq_check{$inv_host_g}{'vlan'}{$bridge_name_g.'-'.$vlan_id_g}."'. Please, check and correct config-file\n";
    		    $skip_conf_line_g=1;
    		}
		
    		if ( $skip_conf_line_g==1 ) {
    		    print "Skip conf-line with conf_id='$conf_id_g'\n";
		    if ( $exec_status_g=~/^OK$/ ) { $exec_status_g='FAIL'; }
    		    next;
    		}
    	    }
    	    ###
    	}
    	########uniq checks
    	
    	########unique conf_id for inventory_host
    	if ( !exists($cfg0_hash_g{$inv_host_g.'-'.$conf_id_g}) ) {
    	    #$cfg0_hash_g{$inv_host_g.'-'.$conf_id_g}{$conf_type_g}{'main'}=[$inv_host_g,$conf_id_g,$vlan_id_g,$bond_name_g,$bridge_name_g,$defroute_g];
	    $cfg0_hash_g{$inv_host_g.'-'.$conf_id_g}{$conf_type_g}{'main'}{'_inv_host_'}=$inv_host_g;
	    $cfg0_hash_g{$inv_host_g.'-'.$conf_id_g}{$conf_type_g}{'main'}{'_conf_id_'}=$conf_id_g;
	    $cfg0_hash_g{$inv_host_g.'-'.$conf_id_g}{$conf_type_g}{'main'}{'_vlan_id_'}=$vlan_id_g;
	    $cfg0_hash_g{$inv_host_g.'-'.$conf_id_g}{$conf_type_g}{'main'}{'_bond_name_'}=$bond_name_g;
	    $cfg0_hash_g{$inv_host_g.'-'.$conf_id_g}{$conf_type_g}{'main'}{'_bridge_name_'}=$bridge_name_g;
	    $cfg0_hash_g{$inv_host_g.'-'.$conf_id_g}{$conf_type_g}{'main'}{'_defroute_'}=$defroute_g;
	    if ( $ipaddr_opts_arr_g[0] ne 'dhcp' ) {
		$cfg0_hash_g{$inv_host_g.'-'.$conf_id_g}{$conf_type_g}{'main'}{'_ipaddr_'}=$ipaddr_opts_arr_g[0];
		$cfg0_hash_g{$inv_host_g.'-'.$conf_id_g}{$conf_type_g}{'main'}{'_gw_'}=$ipaddr_opts_arr_g[1];
		$cfg0_hash_g{$inv_host_g.'-'.$conf_id_g}{$conf_type_g}{'main'}{'_netmask_'}=$ipaddr_opts_arr_g[2];
	    }
	    else {
		$cfg0_hash_g{$inv_host_g.'-'.$conf_id_g}{$conf_type_g}{'main'}{'_ipaddr_'}='dhcp';
		$cfg0_hash_g{$inv_host_g.'-'.$conf_id_g}{$conf_type_g}{'main'}{'_gw_'}='dhcp';
		$cfg0_hash_g{$inv_host_g.'-'.$conf_id_g}{$conf_type_g}{'main'}{'_netmask_'}='dhcp';
	    }
	    $cfg0_hash_g{$inv_host_g.'-'.$conf_id_g}{$conf_type_g}{'main'}{'_bond_opts_'}=$bond_opts_str_g;
    	    $cfg0_hash_g{$inv_host_g.'-'.$conf_id_g}{$conf_type_g}{'int_list'}=[@int_list_arr_g];
    	    $cfg0_hash_g{$inv_host_g.'-'.$conf_id_g}{$conf_type_g}{'hwaddr_list'}=[@hwaddr_list_arr_g];
    	}
    	else {
    	    print "For inv_host='$inv_host_g' conf_id='$conf_id_g' is already exists. Please, check and correct config-file\n";
    	    $skip_conf_line_g=1;
    	}
	
    	if ( $skip_conf_line_g==1 ) {
    	    print "Skip conf-line with conf_id='$conf_id_g'\n";
	    if ( $exec_status_g=~/^OK$/ ) { $exec_status_g='FAIL'; }
    	    next;
    	}
    	########unique conf_id for inventory_host
	
	#############
	@int_list_arr_g=();
	@hwaddr_list_arr_g=();
	@ipaddr_opts_arr_g=();
	
	@arr0_g=();
	($inv_host_g,$conf_id_g,$conf_type_g,$int_list_str_g,$hwaddr_list_str_g,$vlan_id_g,$bond_name_g,$bridge_name_g,$ipaddr_opts_g,$bond_opts_g,$defroute_g)=(undef,undef,undef,undef,undef,undef,undef,undef,undef,undef,undef);
	#############
    }
    $skip_conf_line_g=undef;
    $line_g=undef;
}
close(CONF);
###READ config

###remove prev generated ifcfg
if ( -d $dyn_ifcfg_common_dir_g ) {
    system("cd $dyn_ifcfg_common_dir_g && ls | grep -v 'info' | xargs rm -rf");
}
###remove prev generated ifcfg

while ( ($hkey0_g,$hval0_g)=each %cfg0_hash_g ) {
    #$hkey0_h = $inv_host_g-$conf_id_g
    ($inv_host_g,$conf_id_g)=split(/\-/,$hkey0_g);
    $inv_hosts_hash0_g{$inv_host_g}=1;
    
    system("mkdir -p ".$dyn_ifcfg_common_dir_g.'/'.$inv_host_g.'/fin');
    system("mkdir -p ".$dyn_ifcfg_common_dir_g.'/'.$inv_host_g.'/'.$conf_id_g);
    
    while ( ($hkey1_g,$hval1_g)=each %{$hval0_g} ) {
	#$hkey1_g = $conf_type_g, $hval1_g = hash ref
	if ( -d $ifcfg_tmplt_dir_g.'/'.$hkey1_g ) {
	    &{$conf_type_sub_refs_g{$hkey1_g}}($ifcfg_tmplt_dir_g.'/'.$hkey1_g,$dyn_ifcfg_common_dir_g.'/'.$inv_host_g.'/'.$conf_id_g,$hval1_g);
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
	    
	    system("cp $dyn_ifcfg_common_dir_g/$inv_host_g/$conf_id_g/* $dyn_ifcfg_common_dir_g/$inv_host_g/fin/");
	}
	else {
	    print "ERROR. Ifcfg tmplt dir='$ifcfg_tmplt_dir_g/$hkey1_g' not exists\n";
	}
    }
    ($inv_host_g,$conf_id_g)=(undef,undef);
}

if ( $gen_playbooks_next_g==1 ) { # if need to generate dynamic playbooks for ifcfg upd/del and resolv-conf-files at final
    if ( -d $dyn_resolv_common_dir_g ) {
	system("cd $dyn_resolv_common_dir_g && ls | grep -v 'info' | xargs rm -rf");
    }
    system("rm -rf ".$dyn_ifcfg_playbooks_dir_g."/*_ifcfg_change.yml");
    
    ###READ conf file 'dns_settings' and generate resolv-conf-files
	#$dyn_resolv_common_dir_g=$self_dir_g.'playbooks/dyn_ifcfg_playbooks/dyn_resolv_conf' -> files: 'inv_host_resolv' or 'common_resolv'
	#%inv_hosts_dns_g=(); #key=inv_host/common, value=[array of nameservers]
    open(CONF_DNS,'<',$conf_dns_g);
    while ( <CONF_DNS> ) {
	$line_g=$_;
	$line_g=~s/\n$|\r$|\n\r$|\r\n$//g;
	while ($line_g=~/\t/) { $line_g=~s/\t/ /g; }
	$line_g=~s/\s+/ /g;
	$line_g=~s/^ //g;
	if ( length($line_g)>0 && $line_g!~/^\#/ && $line_g=~/^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}|common) (\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})$/ ) {
	    push(@{$inv_hosts_dns_g{$1}},$2);
	}
    }
    close(CONF_DNS);
    
    while ( ($hkey0_g,$hval0_g)=each %inv_hosts_dns_g ) {
	#hkey0_g=inv_host
	open(RESOLV,'>',$dyn_resolv_common_dir_g.'/'.$hkey0_g.'_resolv');
	print RESOLV "Generated by ansible scenario 'conf_int_ipv4_via_network_scripts'\n";
	foreach $arr_el0_g ( @{$hval0_g} ) {
	    print RESOLV "nameserver $arr_el0_g\n";
	}
	close(RESOLV);
    }
    ($hkey0_g,$hval0_g)=(undef,undef);
    ###READ conf file 'dns_settings' and generate resolv-conf-files
    
    ###READ conf file 'config_del_not_configured_ifcfg'
    #%inv_hosts_ifcfg_del_not_configured_g=(); #for config 'config_del_not_configured_ifcfg'. Key=inv_host
    open(CONF_DEL,'<',$conf_file_del_not_configured_g);
    while ( <CONF_DEL> ) {
	$line_g=$_;
	$line_g=~s/\n$|\r$|\n\r$|\r\n$//g;
	while ($line_g=~/\t/) { $line_g=~s/\t/ /g; }
	$line_g=~s/\s+/ /g;
	$line_g=~s/^ //g;
	if ( length($line_g)>0 && $line_g!~/^\#/ && $line_g=~/^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})$/ ) {
	    $inv_hosts_ifcfg_del_not_configured_g{$1}=1;
	}
    }
    close(CONF_DEL);
    $line_g=undef;
    ###READ conf file 'config_del_not_configured_ifcfg'
    
    ###READ conf file 'config_temporary_apply_ifcfg'
	#%inv_hosts_tmp_apply_cfg_g=(); #key=inv_host/common, value=rollback_ifcfg_timeout
    open(CONF_TMP_APPLY,'<',$conf_temp_apply_g);
    while ( <CONF_TMP_APPLY> ) {
	$line_g=$_;
	$line_g=~s/\n$|\r$|\n\r$|\r\n$//g;
	while ($line_g=~/\t/) { $line_g=~s/\t/ /g; }
	$line_g=~s/\s+/ /g;
	$line_g=~s/^ //g;
	if ( length($line_g)>0 && $line_g!~/^\#/ && $line_g=~/^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}|common) (\d+)$/ ) {
	    $inv_hosts_tmp_apply_cfg_g{$1}=$2;
	}
    }
    close(CONF_TMP_APPLY);
    $line_g=undef;
    ###READ conf file 'config_temporary_apply_ifcfg'
    
    #$dyn_ifcfg_common_dir_g/$inv_host_g = get inv_hosts + fin = get list of interfaces
    #$ifcfg_backup_from_remote_dir_g/inv_host = get actual ifcfg-files
    #%inv_hosts_hash0_g=(); #key=inv_host, value=1
    #%inv_hosts_hash1_g=(); #key0=inv_host, key1=now/fin (generated by this script)/for_upd/for_del, key2=ifcfg_name
    
    while ( ($hkey0_g,$hval0_g)=each %inv_hosts_hash0_g ) {
	#hkey0_g=inv_host
	opendir(DIR_FIN,$dyn_ifcfg_common_dir_g.'/'.$hkey0_g.'/fin');
	while ( readdir DIR_FIN ) {
	    $line_g=$_;
	    if ( $line_g!~/^\./ ) {
		$inv_hosts_hash1_g{$hkey0_g}{'fin'}{$line_g}=1;
	    }
	}
	closedir(DIR_FIN);
	
	opendir(DIR_NOW,$ifcfg_backup_from_remote_dir_g.'/'.$hkey0_g);
	while ( readdir DIR_NOW ) {
	    $line_g=$_;
	    if ( $line_g!~/^\.|^ifcfg\-lo$/ ) {
		$inv_hosts_hash1_g{$hkey0_g}{'now'}{$line_g}=1;
	    }
	}
	closedir(DIR_NOW);
	
	delete($inv_hosts_hash0_g{$hkey0_g});
    }
    ($hkey0_g,$hval0_g)=(undef,undef);
    
    while ( ($hkey0_g,$hval0_g)=each %inv_hosts_hash1_g ) {
	#hkey0_g=inv_host, hval0_g=hash
	while ( ($hkey1_g,$hval1_g)=each %{${$hval0_g}{'fin'}} ) { #just only configure interfaces from 'config'
	    #hkey1_g=ifcfg_name
	    if ( !exists(${$hval0_g}{'now'}{$hkey1_g}) ) { #new interface -> for_upd
	        $inv_hosts_hash1_g{$hkey0_g}{'for_upd'}{$hkey1_g}=1;
	    }
	    else {
		$exec_res_g=&ifcfg_diff_with_zone_param_save("$dyn_ifcfg_common_dir_g/$hkey0_g/fin/$hkey1_g","$ifcfg_backup_from_remote_dir_g/$hkey0_g/$hkey1_g");
		#$ifcfg_generated_file_l,$ifcfg_from_remote_file_l
		
		if ( $exec_res_g>0 ) { #if generated ifcfg (fin) not eq actual (now) -> for_upd
		    $inv_hosts_hash1_g{$hkey0_g}{'for_upd'}{$hkey1_g}=1;
		}
	    }
	}
	($hkey1_g,$hval1_g)=(undef,undef);
	
	if ( exists($inv_hosts_ifcfg_del_not_configured_g{$hkey0_g}) ) { #if need to configure AND to delete not configured at 'config' interfaces
	    while ( ($hkey1_g,$hval1_g)=each %{${$hval0_g}{'now'}} ) {
		#hkey1_g=ifcfg_name
		
		#$ifcfg_backup_from_remote_nd_file_g = file for grep-check. If ifcfg-int at this file for cur inv_host -> no 'ip link delete'
		if ( !exists(${$hval0_g}{'fin'}{$hkey1_g}) ) { #interface for delete -> for_del
		    $tmp_var_g=$hkey1_g;
		    $tmp_var_g=~s/^ifcfg\-//g;
		    $exec_res_g=`grep -a $hkey0_g $ifcfg_backup_from_remote_nd_file_g | grep $tmp_var_g | wc -l`;
		    $exec_res_g=~s/\n|\r|\n\r|\r\n//g;
		    $exec_res_g=int($exec_res_g);
		    
		    $inv_hosts_hash1_g{$hkey0_g}{'for_del'}{$hkey1_g}=1; # just shutdown and delete ifcfg-file
		    
		    if ( $exec_res_g!=1 ) {
			$inv_hosts_hash1_g{$hkey0_g}{'for_del_ip_link'}{$tmp_var_g}=1; # if included (means not interface-ifcfg) -> 'ip link delete'
		    }
		    ($tmp_var_g,$exec_res_g)=(undef,undef);
		}
	    }
	    ($hkey1_g,$hval1_g)=(undef,undef);
	    ($tmp_var_g,$exec_res_g)=(undef,undef);
	}
    }
    ($hkey0_g,$hval0_g)=(undef,undef);
    ($hkey1_g,$hval1_g)=(undef,undef);

    while ( ($hkey0_g,$hval0_g)=each %inv_hosts_hash1_g ) {
	#hkey0_g=inv_host, hval0_g=hash
	
	$tmp_file0_g=$dyn_ifcfg_playbooks_dir_g.'/'.$hkey0_g.'_ifcfg_change.yml';
	    
	open(DYN_YML,'>',$tmp_file0_g);
	if ( exists(${$hval0_g}{'for_del'}) ) { #if need to remove ifcfg
	    print DYN_YML "- name: shutdown interfaces before delete\n";
	    print DYN_YML "  ansible.builtin.command: \"ifdown {{item}}\"\n";
	    print DYN_YML "  with_items:\n";
	    while ( ($hkey1_g,$hval1_g)=each %{${$hval0_g}{'for_del'}} ) {
		#hkey1_g=ifcfg_name
		print DYN_YML "    - $hkey1_g\n";
	    }
	    ($hkey1_g,$hval1_g)=(undef,undef);
	    print DYN_YML "\n";
	    print DYN_YML "######################################################\n";
	    print DYN_YML "\n";
	    
	    print DYN_YML "- name: delete unconfigured ifcfg-files\n";
	    print DYN_YML "  ansible.builtin.file:\n";
	    print DYN_YML "    path: \"/etc/sysconfig/network-scripts/{{item}}\"\n";
	    print DYN_YML "    state: absent\n";
	    print DYN_YML "  with_items:\n";
	    while ( ($hkey1_g,$hval1_g)=each %{${$hval0_g}{'for_del'}} ) {
		#hkey1_g=ifcfg_name
		print DYN_YML "    - $hkey1_g\n";
	    }
	    ($hkey1_g,$hval1_g)=(undef,undef);
	    print DYN_YML "\n";
	    print DYN_YML "######################################################\n";
	    print DYN_YML "\n";
	}
	
	if ( exists(${$hval0_g}{'for_del_ip_link'}) ) { # if need to 'ip link delete' (for bridges/bond ifcfg)
	    print DYN_YML "- name: ip link delete for unconfigured bridge/bonds/vlan-interfaces\n";
	    print DYN_YML "  ansible.builtin.command: \"ip link delete {{item}}\"\n";
	    print DYN_YML "  with_items:\n";
	    while ( ($hkey1_g,$hval1_g)=each %{${$hval0_g}{'for_del_ip_link'}} ) {
		#hkey1_g=link-name
		print DYN_YML "    - $hkey1_g\n";
	    }
	    ($hkey1_g,$hval1_g)=(undef,undef);
	    print DYN_YML "\n";
	    print DYN_YML "######################################################\n";
	    print DYN_YML "\n";
	}

	if ( exists(${$hval0_g}{'for_upd'}) ) { #if need to upd ifcfg
	    print DYN_YML "- name: copy/upd ifcfg-files\n";
	    print DYN_YML "  ansible.builtin.copy:\n";
	    print DYN_YML "    src: \"{{playbook_dir}}/dyn_ifcfg/{{inventory_hostname}}/fin/{{item}}\"\n";
	    print DYN_YML "    dest: \"/etc/sysconfig/network-scripts/{{item}}\"\n";
    	    print DYN_YML "    owner: root\n";
    	    print DYN_YML "    group: root\n";
    	    print DYN_YML "    mode: '0600'\n";
    	    print DYN_YML "    seuser: system_u\n";
    	    print DYN_YML "    setype: net_conf_t\n";
    	    print DYN_YML "    serole: object_r\n";
    	    print DYN_YML "    selevel: s0\n";
	    print DYN_YML "  with_items:\n";
	    if ( exists(${$hval0_g}{'for_upd'}) ) { #if need to add/upd ifcfg
		while ( ($hkey1_g,$hval1_g)=each %{${$hval0_g}{'for_upd'}} ) {
		    #hkey1_g=ifcfg_name
		    print DYN_YML "    - $hkey1_g\n";
		}
		($hkey1_g,$hval1_g)=(undef,undef);
	    }
	    print DYN_YML "\n";
	    print DYN_YML "######################################################\n";
	    print DYN_YML "\n";
	    
	    ###task for config_temporary_apply_ifcfg (FOR start RUN BEFORE network restart)
		#%inv_hosts_tmp_apply_cfg_g=(); #key=inv_host/common, value=rollback_ifcfg_timeout
	    if ( $gen_playbooks_next_with_rollback_g==1 && (exists($inv_hosts_tmp_apply_cfg_g{$hkey0_g}) or exists($inv_hosts_tmp_apply_cfg_g{'common'})) ) {
		#tmp_var_g=rollback_ifcfg_timeout
		if ( exists($inv_hosts_tmp_apply_cfg_g{$hkey0_g}) ) { $tmp_var_g=$inv_hosts_tmp_apply_cfg_g{$hkey0_g}; }
		elsif ( exists($inv_hosts_tmp_apply_cfg_g{'common'}) ) { $tmp_var_g=$inv_hosts_tmp_apply_cfg_g{'common'}; }
		
		print DYN_YML "- name: copy script 'rollback_ifcfg_changes.sh' to remote\n";
		print DYN_YML "  ansible.builtin.copy:\n";
		print DYN_YML "    src: \"{{playbook_dir}}/../scripts_for_remote/rollback_ifcfg_changes.sh\"\n";
		print DYN_YML "    dest: \"$remote_dir_for_absible_helper_g/rollback_ifcfg_changes.sh\"\n";
    		print DYN_YML "    mode: '0700'\n";
		print DYN_YML "\n";
		print DYN_YML "######################################################\n";
		print DYN_YML "\n";
		
		print DYN_YML "- name: run script 'rollback_ifcfg_changes.sh' as process\n";
		print DYN_YML "  ansible.builtin.raw: \"nohup sh -c '$remote_dir_for_absible_helper_g/rollback_ifcfg_changes.sh $tmp_var_g >/dev/null 2>&1' & sleep 3\"\n";
		print DYN_YML "\n";
		print DYN_YML "######################################################\n";
		print DYN_YML "\n";

	    }
	    ###task for config_temporary_apply_ifcfg

	    print DYN_YML "- name: restart network.service\n";
	    print DYN_YML "  ansible.builtin.systemd:\n";
	    print DYN_YML "    name: network.service\n";
	    print DYN_YML "    state: restarted\n";
	    print DYN_YML "\n";
	    print DYN_YML "######################################################\n";
	    print DYN_YML "\n";
	}
	
	###task for copy resolv.conf
	if ( exists($inv_hosts_dns_g{$hkey0_g}) ) { #use special resolv.conf for inv_host
	    print DYN_YML "- name: copy/upd resolv.conf\n";
	    print DYN_YML "  ansible.builtin.copy:\n";
	    print DYN_YML "    src: \"{{playbook_dir}}/dyn_resolv_conf/{{inventory_hostname}}_resolv\"\n";
	    print DYN_YML "    dest: \"/etc/resolv.conf\"\n";
    	    print DYN_YML "    owner: root\n";
    	    print DYN_YML "    group: root\n";
    	    print DYN_YML "    mode: '0600'\n";
    	    print DYN_YML "    seuser: system_u\n";
    	    print DYN_YML "    setype: net_conf_t\n";
    	    print DYN_YML "    serole: object_r\n";
    	    print DYN_YML "    selevel: s0\n";
    	    print DYN_YML "    backup: yes\n";
	}
	elsif ( $inv_hosts_dns_g{'common'} ) { #use common resolv.conf
	    print DYN_YML "- name: copy/upd ifcfg-files\n";
	    print DYN_YML "  ansible.builtin.copy:\n";
	    print DYN_YML "    src: \"{{playbook_dir}}/dyn_resolv_conf/common_resolv\"\n";
	    print DYN_YML "    dest: \"/etc/resolv.conf\"\n";
    	    print DYN_YML "    owner: root\n";
    	    print DYN_YML "    group: root\n";
    	    print DYN_YML "    mode: '0600'\n";
    	    print DYN_YML "    seuser: system_u\n";
    	    print DYN_YML "    setype: net_conf_t\n";
    	    print DYN_YML "    serole: object_r\n";
    	    print DYN_YML "    selevel: s0\n";
    	    print DYN_YML "    backup: yes\n";
	}
	print DYN_YML "\n";
	print DYN_YML "######################################################\n";
	print DYN_YML "\n";
	###task for copy resolv.conf
	
	###for cancel operation of rollback ifcfg changes if run 'apply_immediately_ifcfg.sh' with GEN_DYN_IFCFG_RUN='yes'
	if ( $gen_playbooks_next_with_rollback_g==0 ) {
	    print DYN_YML "- name: cancel rollback operation (rollback_ifcfg_changes.sh) if need\n";
	    print DYN_YML "  ansible.builtin.command: \"pkill -9 -f rollback_ifcfg_changes\"\n";
	    print DYN_YML "  ignore_errors: yes\n";
	    print DYN_YML "\n";
	    print DYN_YML "######################################################\n";
	    print DYN_YML "\n";
	}
	###for cancel operation of rollback ifcfg changes if run 'apply_immediately_ifcfg.sh' with GEN_DYN_IFCFG_RUN='yes'
	
	close(DYN_YML);
	$tmp_file0_g=undef;
    }
    ($hkey0_g,$hval0_g)=(undef,undef);
    ($hkey1_g,$hval1_g)=(undef,undef);
    $tmp_file0_g=undef;
}

system("echo $exec_status_g > GEN_DYN_IFCFG_STATUS");
if ( $exec_status_g!~/^OK$/ ) {
    print "EXEC_STATUS not OK. Exit!\n\n";
    exit;
}
######MAIN SEQ

###SUBROUTINES
##INCLUDED to conf_type_sub_refs_g
#common (novlan)
sub read_network_data_for_checks {
    my ($file_l,$res_href_l)=@_;
    #file_l=$ifcfg_backup_from_remote_nd_file_g
    #res_href_l=hash-ref for %inv_hosts_network_data_g
    my $proc_name_l='read_network_data_for_checks';
    
    my ($line_l,$value_cnt_l)=(undef,0);
    my @arr0_l=undef;
    
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
	    #INV_HOST-0       #INT_NAME-1       #HWADDR-2
	    @arr0_l=split(' ',$line_l);
	    ${$res_href_l}{'hwaddr_all'}{$arr0_l[2]}=$arr0_l[0];
	    ${$res_href_l}{'inv_host'}{$arr0_l[0]}{$arr0_l[1]}{$arr0_l[2]}=1;
	    $value_cnt_l++; 
	}
    }
    close(NDATA);

    $line_l=undef;

    if ( $value_cnt_l<1 ) { return "fail [$proc_name_l]. No needed data at file='$file_l'"; }

    return 'OK';
}

sub just_interface_gen_ifcfg {
    my ($tmplt_dir_l,$target_dyn_ifcfg_dir_l,$prms_href_l)=@_;
    ###if STATIC. TMPLT = playbooks/ifcfg_tmplt/just_interface/ifcfg-eth-static
    #TMPLT_VALUES_FOR_REPLACE:_defroute_, _interface_name_, _hwaddr_, _ipaddr_, _netmask_, _gw_, _conf_id_
    ###
    
    ###if DHCP. TMPLT = playbooks/ifcfg_tmplt/just_interface/ifcfg-eth-dhcp
    #TMPLT_VALUES_FOR_REPLACE:_defroute_, _interface_name_, _hwaddr_, _conf_id_
    ###
    
    ###
    #HREF->{'main'}{'_inv_host_'}=inv_host;
    #HREF->{'main'}{'_conf_id_'}=conf_id;
    #HREF->{'main'}{'_vlan_id_'}=vlan_id;
    #HREF->{'main'}{'_bond_name_'}=bond_name;
    #HREF->{'main'}{'_bridge_name_'}=bridge_name;
    #HREF->{'main'}{'_defroute_'}=defroute;
    #HREF->{'main'}{'_ipaddr_'}=ipaddr/dhcp;
    #HREF->{'main'}{'_gw_'}=gw/dhcp;
    #HREF->{'main'}{'_netmask_'}=gw/dhcp;
    #HREF->{'main'}{'_bond_opts_'}=bond_opts_string_for_ifcfg;
    #HREF->{'int_list'}=[array of interfaces];
    #HREF->{'hwaddr_list'}=[array of hwaddr];
    ###
    
    my @int_list_l=@{${$prms_href_l}{'int_list'}};
    my @hwaddr_list_l=@{${$prms_href_l}{'hwaddr_list'}};

    ###vars
    my $arr_i0_l=0;
    my $ifcfg_file_path_l=undef;
    ###vars
        
    for ( $arr_i0_l=0; $arr_i0_l<=$#int_list_l; $arr_i0_l++ ) {
	$ifcfg_file_path_l=$target_dyn_ifcfg_dir_l.'/ifcfg-'.$int_list_l[$arr_i0_l];
	if ( ${$prms_href_l}{'main'}{'_ipaddr_'} eq 'dhcp' ) {
	    system("cp ".$tmplt_dir_l.'/ifcfg-eth-dhcp'.' '.$ifcfg_file_path_l);
	    
	    &replace_values_in_file($ifcfg_file_path_l,'eth-dhcp',$int_list_l[$arr_i0_l],$hwaddr_list_l[$arr_i0_l],$prms_href_l);
	    #$file_path_l,$file_type_l,$int_name_l,$hwaddr_l,$prms_href_l
	}
	else {
	    system("cp ".$tmplt_dir_l.'/ifcfg-eth-static'.' '.$ifcfg_file_path_l);

	    &replace_values_in_file($ifcfg_file_path_l,'eth-static',$int_list_l[$arr_i0_l],$hwaddr_list_l[$arr_i0_l],$prms_href_l);
	    #$file_path_l,$file_type_l,$int_name_l,$hwaddr_l,$prms_href_l
	}
    }

    ###some other specific operations if need
}

sub virt_bridge_gen_ifcfg {
    my ($tmplt_dir_l,$target_dyn_ifcfg_dir_l,$prms_href_l)=@_;
    ###if STATIC. TMPLT = playbooks/ifcfg_tmplt/virt_bridge/ifcfg-bridge-static
    #TMPLT_VALUES_FOR_REPLACE:_bridge_name_, _ipaddr_, _netmask_, _conf_id_
    ###

    ###
    #HREF->{'main'}{'_inv_host_'}=inv_host;
    #HREF->{'main'}{'_conf_id_'}=conf_id;
    #HREF->{'main'}{'_vlan_id_'}=vlan_id;
    #HREF->{'main'}{'_bond_name_'}=bond_name;
    #HREF->{'main'}{'_bridge_name_'}=bridge_name;
    #HREF->{'main'}{'_defroute_'}=defroute;
    #HREF->{'main'}{'_ipaddr_'}=ipaddr/dhcp;
    #HREF->{'main'}{'_gw_'}=gw/dhcp;
    #HREF->{'main'}{'_netmask_'}=gw/dhcp;
    #HREF->{'main'}{'_bond_opts_'}=bond_opts_string_for_ifcfg;
    #HREF->{'int_list'}=[array of interfaces];
    #HREF->{'hwaddr_list'}=[array of hwaddr];
    ###
    my @int_list_l=@{${$prms_href_l}{'int_list'}};
    my @hwaddr_list_l=@{${$prms_href_l}{'hwaddr_list'}};
    
    ###vars
    my $ifcfg_file_path_l=$target_dyn_ifcfg_dir_l.'/ifcfg-'.${$prms_href_l}{'main'}{'_bridge_name_'};
    ###vars
    
    system("cp ".$tmplt_dir_l.'/ifcfg-bridge-static'.' '.$ifcfg_file_path_l);
    
    &replace_values_in_file($ifcfg_file_path_l,'virt-bridge','no','no',$prms_href_l);
    #$file_path_l,$file_type_l,$int_name_l,$hwaddr_l,$prms_href_l

    ###some other specific operations if need
}

sub just_bridge_gen_ifcfg {
    my ($tmplt_dir_l,$target_dyn_ifcfg_dir_l,$prms_href_l)=@_;
    #interface -> bridge
    
    ###ETH for BRIDGE. tmplt = playbooks/ifcfg_tmplt/just_bridge/ifcfg-eth
    #TMPLT_VALUES_FOR_REPLACE:_interface_name_, _bridge_name_, _hwaddr_, _conf_id_
    ###
    
    ###if STATIC. TMPLT = playbooks/ifcfg_tmplt/just_bridge/ifcfg-bridge-static
    #TMPLT_VALUES_FOR_REPLACE:_defroute_, _bridge_name_, _ipaddr_, _gw_, _netmask_, _conf_id_
    ###

    ###if DHCP. TMPLT = playbooks/ifcfg_tmplt/just_bridge/ifcfg-bridge-dhcp
    #TMPLT_VALUES_FOR_REPLACE:_defroute_, _bridge_name_, _conf_id_
    ###

    ###
    #HREF->{'main'}{'_inv_host_'}=inv_host;
    #HREF->{'main'}{'_conf_id_'}=conf_id;
    #HREF->{'main'}{'_vlan_id_'}=vlan_id;
    #HREF->{'main'}{'_bond_name_'}=bond_name;
    #HREF->{'main'}{'_bridge_name_'}=bridge_name;
    #HREF->{'main'}{'_defroute_'}=defroute;
    #HREF->{'main'}{'_ipaddr_'}=ipaddr/dhcp;
    #HREF->{'main'}{'_gw_'}=gw/dhcp;
    #HREF->{'main'}{'_netmask_'}=gw/dhcp;
    #HREF->{'main'}{'_bond_opts_'}=bond_opts_string_for_ifcfg;
    #HREF->{'int_list'}=[array of interfaces];
    #HREF->{'hwaddr_list'}=[array of hwaddr];
    ###
    my @int_list_l=@{${$prms_href_l}{'int_list'}};
    my @hwaddr_list_l=@{${$prms_href_l}{'hwaddr_list'}};

    ###vars
    my $arr_i0_l=0;
    my $ifcfg_file_path_l=undef;
    ###vars

    for ( $arr_i0_l=0; $arr_i0_l<=$#int_list_l; $arr_i0_l++ ) {
	$ifcfg_file_path_l=$target_dyn_ifcfg_dir_l.'/ifcfg-'.$int_list_l[$arr_i0_l];
	system("cp ".$tmplt_dir_l.'/ifcfg-eth'.' '.$ifcfg_file_path_l);
	
	&replace_values_in_file($ifcfg_file_path_l,'eth-for-bridge',$int_list_l[$arr_i0_l],$hwaddr_list_l[$arr_i0_l],$prms_href_l);
	#$file_path_l,$file_type_l,$int_name_l,$hwaddr_l,$prms_href_l
    }
    $ifcfg_file_path_l=undef;

    $ifcfg_file_path_l=$target_dyn_ifcfg_dir_l.'/ifcfg-'.${$prms_href_l}{'main'}{'_bridge_name_'};
    if ( ${$prms_href_l}{'main'}{'_ipaddr_'} eq 'dhcp' ) {
	system("cp ".$tmplt_dir_l.'/ifcfg-bridge-dhcp'.' '.$ifcfg_file_path_l);
	
	&replace_values_in_file($ifcfg_file_path_l,'bridge-dhcp','no','no',$prms_href_l);
	#$file_path_l,$file_type_l,$int_name_l,$hwaddr_l,$prms_href_l
    }
    else {
	system("cp ".$tmplt_dir_l.'/ifcfg-bridge-static'.' '.$ifcfg_file_path_l);
	
	&replace_values_in_file($ifcfg_file_path_l,'bridge-static','no','no',$prms_href_l);
	#$file_path_l,$file_type_l,$int_name_l,$hwaddr_l,$prms_href_l
    }

    ###some other specific operations if need
}

sub just_bond_gen_ifcfg {
    my ($tmplt_dir_l,$target_dyn_ifcfg_dir_l,$prms_href_l)=@_;
    #interface1+interface2 -> bond
    
    ###ETH for bond. tmplt = playbooks/ifcfg_tmplt/just_bond/ifcfg-eth
    #TMPLT_VALUES_FOR_REPLACE:_interface_name_, _bond_name_, _hwaddr_, _conf_id_
    ###
    
    ###if STATIC. TMPLT = playbooks/ifcfg_tmplt/just_bond/ifcfg-bond-static
    #TMPLT_VALUES_FOR_REPLACE:_defroute_, _bond_name_, _bond_opts_, _ipaddr_, _gw_, _netmask_, _conf_id_
    ###

    ###if DHCP. TMPLT = playbooks/ifcfg_tmplt/just_bond/ifcfg-bond-dhcp
    #TMPLT_VALUES_FOR_REPLACE:_defroute_, _bond_name_, _bond_opts_, _conf_id_
    ###

    ###
    #HREF->{'main'}{'_inv_host_'}=inv_host;
    #HREF->{'main'}{'_conf_id_'}=conf_id;
    #HREF->{'main'}{'_vlan_id_'}=vlan_id;
    #HREF->{'main'}{'_bond_name_'}=bond_name;
    #HREF->{'main'}{'_bridge_name_'}=bridge_name;
    #HREF->{'main'}{'_defroute_'}=defroute;
    #HREF->{'main'}{'_ipaddr_'}=ipaddr/dhcp;
    #HREF->{'main'}{'_gw_'}=gw/dhcp;
    #HREF->{'main'}{'_netmask_'}=gw/dhcp;
    #HREF->{'main'}{'_bond_opts_'}=bond_opts_string_for_ifcfg;
    #HREF->{'int_list'}=[array of interfaces];
    #HREF->{'hwaddr_list'}=[array of hwaddr];
    ###
    my @int_list_l=@{${$prms_href_l}{'int_list'}};
    my @hwaddr_list_l=@{${$prms_href_l}{'hwaddr_list'}};

    ###vars
    my $arr_i0_l=0;
    my $ifcfg_file_path_l=undef;
    ###vars

    for ( $arr_i0_l=0; $arr_i0_l<=$#int_list_l; $arr_i0_l++ ) {
	$ifcfg_file_path_l=$target_dyn_ifcfg_dir_l.'/ifcfg-'.$int_list_l[$arr_i0_l];
	system("cp ".$tmplt_dir_l.'/ifcfg-eth'.' '.$ifcfg_file_path_l);
	
	&replace_values_in_file($ifcfg_file_path_l,'eth-for-bond',$int_list_l[$arr_i0_l],$hwaddr_list_l[$arr_i0_l],$prms_href_l);
	#$file_path_l,$file_type_l,$int_name_l,$hwaddr_l,$prms_href_l
    }
    $ifcfg_file_path_l=undef;

    $ifcfg_file_path_l=$target_dyn_ifcfg_dir_l.'/ifcfg-'.${$prms_href_l}{'main'}{'_bond_name_'};
    if ( ${$prms_href_l}{'main'}{'_ipaddr_'} eq 'dhcp' ) {
	system("cp ".$tmplt_dir_l.'/ifcfg-bond-dhcp'.' '.$ifcfg_file_path_l);
	
	&replace_values_in_file($ifcfg_file_path_l,'bond-dhcp','no','no',$prms_href_l);
	#$file_path_l,$file_type_l,$int_name_l,$hwaddr_l,$prms_href_l
    }
    else {
	system("cp ".$tmplt_dir_l.'/ifcfg-bond-static'.' '.$ifcfg_file_path_l);
	
	&replace_values_in_file($ifcfg_file_path_l,'bond-static','no','no',$prms_href_l);
	#$file_path_l,$file_type_l,$int_name_l,$hwaddr_l,$prms_href_l
    }

    ###some other specific operations if need
}

sub bond_bridge_gen_ifcfg {
    my ($tmplt_dir_l,$target_dyn_ifcfg_dir_l,$prms_href_l)=@_;
    #interface1+interface2 -> bond -> bridge
    
    ###ETH for bond. tmplt = playbooks/ifcfg_tmplt/bond-bridge/ifcfg-eth
    #TMPLT_VALUES_FOR_REPLACE:_interface_name_, _bond_name_, _hwaddr_, _conf_id_
    ###
    
    ###BOND for bridge. TMPLT = playbooks/ifcfg_tmplt/bond-bridge/ifcfg-bond
    #TMPLT_VALUES_FOR_REPLACE:_bond_name_, _bond_opts_, _bridge_name_, _conf_id_
    ###

    ###if STATIC. TMPLT = playbooks/ifcfg_tmplt/bond-bridge/ifcfg-bridge-static
    #TMPLT_VALUES_FOR_REPLACE:_defroute_, _bridge_name_, _ipaddr_, _gw_, _netmask_, _conf_id_
    ###

    ###if DHCP. TMPLT = playbooks/ifcfg_tmplt/bond-bridge/ifcfg-bridge-dhcp
    #TMPLT_VALUES_FOR_REPLACE:_defroute_, _bridge_name_, _conf_id_
    ###

    ###
    #HREF->{'main'}{'_inv_host_'}=inv_host;
    #HREF->{'main'}{'_conf_id_'}=conf_id;
    #HREF->{'main'}{'_vlan_id_'}=vlan_id;
    #HREF->{'main'}{'_bond_name_'}=bond_name;
    #HREF->{'main'}{'_bridge_name_'}=bridge_name;
    #HREF->{'main'}{'_defroute_'}=defroute;
    #HREF->{'main'}{'_ipaddr_'}=ipaddr/dhcp;
    #HREF->{'main'}{'_gw_'}=gw/dhcp;
    #HREF->{'main'}{'_netmask_'}=gw/dhcp;
    #HREF->{'main'}{'_bond_opts_'}=bond_opts_string_for_ifcfg;
    #HREF->{'int_list'}=[array of interfaces];
    #HREF->{'hwaddr_list'}=[array of hwaddr];
    ###
    my @int_list_l=@{${$prms_href_l}{'int_list'}};
    my @hwaddr_list_l=@{${$prms_href_l}{'hwaddr_list'}};

    ###vars
    my $arr_i0_l=0;
    my $ifcfg_file_path_l=undef;
    ###vars

    for ( $arr_i0_l=0; $arr_i0_l<=$#int_list_l; $arr_i0_l++ ) {
	$ifcfg_file_path_l=$target_dyn_ifcfg_dir_l.'/ifcfg-'.$int_list_l[$arr_i0_l];
	system("cp ".$tmplt_dir_l.'/ifcfg-eth'.' '.$ifcfg_file_path_l);
	
	&replace_values_in_file($ifcfg_file_path_l,'eth-for-bond',$int_list_l[$arr_i0_l],$hwaddr_list_l[$arr_i0_l],$prms_href_l);
	#$file_path_l,$file_type_l,$int_name_l,$hwaddr_l,$prms_href_l
    }
    $ifcfg_file_path_l=undef;

    $ifcfg_file_path_l=$target_dyn_ifcfg_dir_l.'/ifcfg-'.${$prms_href_l}{'main'}{'_bond_name_'};
    system("cp ".$tmplt_dir_l.'/ifcfg-bond'.' '.$ifcfg_file_path_l);
	
    &replace_values_in_file($ifcfg_file_path_l,'bond-for-bridge','no','no',$prms_href_l);
    #$file_path_l,$file_type_l,$int_name_l,$hwaddr_l,$prms_href_l
    $ifcfg_file_path_l=undef;

    $ifcfg_file_path_l=$target_dyn_ifcfg_dir_l.'/ifcfg-'.${$prms_href_l}{'main'}{'_bridge_name_'};
    if ( ${$prms_href_l}{'main'}{'_ipaddr_'} eq 'dhcp' ) {
	system("cp ".$tmplt_dir_l.'/ifcfg-bridge-dhcp'.' '.$ifcfg_file_path_l);
	
	&replace_values_in_file($ifcfg_file_path_l,'bridge-dhcp','no','no',$prms_href_l);
	#$file_path_l,$file_type_l,$int_name_l,$hwaddr_l,$prms_href_l
    }
    else {
	system("cp ".$tmplt_dir_l.'/ifcfg-bridge-static'.' '.$ifcfg_file_path_l);
	
	&replace_values_in_file($ifcfg_file_path_l,'bridge-static','no','no',$prms_href_l);
	#$file_path_l,$file_type_l,$int_name_l,$hwaddr_l,$prms_href_l
    }

    ###some other specific operations if need
}

#vlan
sub interface_vlan_gen_ifcfg {
    my ($tmplt_dir_l,$target_dyn_ifcfg_dir_l,$prms_href_l)=@_;
    ###if STATIC. TMPLT = playbooks/ifcfg_tmplt/interface-vlan/ifcfg-eth-static
    #TMPLT_VALUES_FOR_REPLACE:_defroute_, _interface_name_, _hwaddr_, _ipaddr_, _netmask_, _gw_, _conf_id_
    ###
    
    ###if DHCP. TMPLT = playbooks/ifcfg_tmplt/interface-vlan/ifcfg-eth-dhcp
    #TMPLT_VALUES_FOR_REPLACE:_defroute_, _interface_name_, _hwaddr_, _conf_id_
    ###

    ###
    #HREF->{'main'}{'_inv_host_'}=inv_host;
    #HREF->{'main'}{'_conf_id_'}=conf_id;
    #HREF->{'main'}{'_vlan_id_'}=vlan_id;
    #HREF->{'main'}{'_bond_name_'}=bond_name;
    #HREF->{'main'}{'_bridge_name_'}=bridge_name;
    #HREF->{'main'}{'_defroute_'}=defroute;
    #HREF->{'main'}{'_ipaddr_'}=ipaddr/dhcp;
    #HREF->{'main'}{'_gw_'}=gw/dhcp;
    #HREF->{'main'}{'_netmask_'}=gw/dhcp;
    #HREF->{'main'}{'_bond_opts_'}=bond_opts_string_for_ifcfg;
    #HREF->{'int_list'}=[array of interfaces];
    #HREF->{'hwaddr_list'}=[array of hwaddr];
    ###
    my @int_list_l=@{${$prms_href_l}{'int_list'}};
    my @hwaddr_list_l=@{${$prms_href_l}{'hwaddr_list'}};

    ###vars
    my $arr_i0_l=0;
    my $ifcfg_file_path_l=undef;
    ###vars
        
    for ( $arr_i0_l=0; $arr_i0_l<=$#int_list_l; $arr_i0_l++ ) {
	$ifcfg_file_path_l=$target_dyn_ifcfg_dir_l.'/ifcfg-'.$int_list_l[$arr_i0_l];
	if ( ${$prms_href_l}{'main'}{'_ipaddr_'} eq 'dhcp' ) {
	    system("cp ".$tmplt_dir_l.'/ifcfg-eth-dhcp'.' '.$ifcfg_file_path_l);
	    
	    &replace_values_in_file($ifcfg_file_path_l,'eth-dhcp',$int_list_l[$arr_i0_l],$hwaddr_list_l[$arr_i0_l],$prms_href_l);
	    #$file_path_l,$file_type_l,$int_name_l,$hwaddr_l,$prms_href_l
	}
	else {
	    system("cp ".$tmplt_dir_l.'/ifcfg-eth-static'.' '.$ifcfg_file_path_l);

	    &replace_values_in_file($ifcfg_file_path_l,'eth-static',$int_list_l[$arr_i0_l],$hwaddr_list_l[$arr_i0_l],$prms_href_l);
	    #$file_path_l,$file_type_l,$int_name_l,$hwaddr_l,$prms_href_l
	}
    }

    ###some other specific operations if need
}

sub bridge_vlan_gen_ifcfg {
    my ($tmplt_dir_l,$target_dyn_ifcfg_dir_l,$prms_href_l)=@_;
    #interface-vlan -> bridge
    
    ###ETH for BRIDGE-vlan. tmplt = playbooks/ifcfg_tmplt/bridge-vlan/ifcfg-eth
    #TMPLT_VALUES_FOR_REPLACE:_interface_name_, _bridge_name_, _hwaddr_, _conf_id_
    ###
    
    ###if STATIC. TMPLT = playbooks/ifcfg_tmplt/bridge-vlan/ifcfg-bridge-static
    #TMPLT_VALUES_FOR_REPLACE:_defroute_, _bridge_name_, _ipaddr_, _gw_, _netmask_, _conf_id_
    ###

    ###if DHCP. TMPLT = playbooks/ifcfg_tmplt/bridge-vlan/ifcfg-bridge-dhcp
    #TMPLT_VALUES_FOR_REPLACE:_defroute_, _bridge_name_, _conf_id_
    ###

    ###
    #HREF->{'main'}{'_inv_host_'}=inv_host;
    #HREF->{'main'}{'_conf_id_'}=conf_id;
    #HREF->{'main'}{'_vlan_id_'}=vlan_id;
    #HREF->{'main'}{'_bond_name_'}=bond_name;
    #HREF->{'main'}{'_bridge_name_'}=bridge_name;
    #HREF->{'main'}{'_defroute_'}=defroute;
    #HREF->{'main'}{'_ipaddr_'}=ipaddr/dhcp;
    #HREF->{'main'}{'_gw_'}=gw/dhcp;
    #HREF->{'main'}{'_netmask_'}=gw/dhcp;
    #HREF->{'main'}{'_bond_opts_'}=bond_opts_string_for_ifcfg;
    #HREF->{'int_list'}=[array of interfaces];
    #HREF->{'hwaddr_list'}=[array of hwaddr];
    ###
    my @int_list_l=@{${$prms_href_l}{'int_list'}};
    my @hwaddr_list_l=@{${$prms_href_l}{'hwaddr_list'}};

    ###vars
    my $arr_i0_l=0;
    my $ifcfg_file_path_l=undef;
    ###vars

    for ( $arr_i0_l=0; $arr_i0_l<=$#int_list_l; $arr_i0_l++ ) {
	$ifcfg_file_path_l=$target_dyn_ifcfg_dir_l.'/ifcfg-'.$int_list_l[$arr_i0_l];
	system("cp ".$tmplt_dir_l.'/ifcfg-eth'.' '.$ifcfg_file_path_l);
	
	&replace_values_in_file($ifcfg_file_path_l,'eth-for-bridge',$int_list_l[$arr_i0_l],$hwaddr_list_l[$arr_i0_l],$prms_href_l);
	#$file_path_l,$file_type_l,$int_name_l,$hwaddr_l,$prms_href_l
    }
    $ifcfg_file_path_l=undef;

    $ifcfg_file_path_l=$target_dyn_ifcfg_dir_l.'/ifcfg-'.${$prms_href_l}{'main'}{'_bridge_name_'};
    if ( ${$prms_href_l}{'main'}{'_ipaddr_'} eq 'dhcp' ) {
	system("cp ".$tmplt_dir_l.'/ifcfg-bridge-dhcp'.' '.$ifcfg_file_path_l);
	
	&replace_values_in_file($ifcfg_file_path_l,'bridge-dhcp','no','no',$prms_href_l);
	#$file_path_l,$file_type_l,$int_name_l,$hwaddr_l,$prms_href_l
    }
    else {
	system("cp ".$tmplt_dir_l.'/ifcfg-bridge-static'.' '.$ifcfg_file_path_l);
	
	&replace_values_in_file($ifcfg_file_path_l,'bridge-static','no','no',$prms_href_l);
	#$file_path_l,$file_type_l,$int_name_l,$hwaddr_l,$prms_href_l
    }

    ###some other specific operations if need
}

sub bond_vlan_gen_ifcfg {
    my ($tmplt_dir_l,$target_dyn_ifcfg_dir_l,$prms_href_l)=@_;
    #interface1+interface2 -> bond-vlan
    
    ###ETH for bond-vlan. tmplt = playbooks/ifcfg_tmplt/bond-vlan/ifcfg-eth
    #TMPLT_VALUES_FOR_REPLACE:_interface_name_, _bond_name_, _hwaddr_, _conf_id_
    ###
    
    ###if STATIC. TMPLT = playbooks/ifcfg_tmplt/bond-vlan/ifcfg-bond-static
    #TMPLT_VALUES_FOR_REPLACE:_defroute_, _bond_name_, _bond_opts_, _ipaddr_, _gw_, _netmask_, _conf_id_
    ###

    ###if DHCP. TMPLT = playbooks/ifcfg_tmplt/bond-vlan/ifcfg-bond-dhcp
    #TMPLT_VALUES_FOR_REPLACE:_defroute_, _bond_name_, _bond_opts_, _conf_id_
    ###

    ###
    #HREF->{'main'}{'_inv_host_'}=inv_host;
    #HREF->{'main'}{'_conf_id_'}=conf_id;
    #HREF->{'main'}{'_vlan_id_'}=vlan_id;
    #HREF->{'main'}{'_bond_name_'}=bond_name;
    #HREF->{'main'}{'_bridge_name_'}=bridge_name;
    #HREF->{'main'}{'_defroute_'}=defroute;
    #HREF->{'main'}{'_ipaddr_'}=ipaddr/dhcp;
    #HREF->{'main'}{'_gw_'}=gw/dhcp;
    #HREF->{'main'}{'_netmask_'}=gw/dhcp;
    #HREF->{'main'}{'_bond_opts_'}=bond_opts_string_for_ifcfg;
    #HREF->{'int_list'}=[array of interfaces];
    #HREF->{'hwaddr_list'}=[array of hwaddr];
    ###
    my @int_list_l=@{${$prms_href_l}{'int_list'}};
    my @hwaddr_list_l=@{${$prms_href_l}{'hwaddr_list'}};

    ###vars
    my $arr_i0_l=0;
    my $ifcfg_file_path_l=undef;
    ###vars

    for ( $arr_i0_l=0; $arr_i0_l<=$#int_list_l; $arr_i0_l++ ) {
	$ifcfg_file_path_l=$target_dyn_ifcfg_dir_l.'/ifcfg-'.$int_list_l[$arr_i0_l];
	system("cp ".$tmplt_dir_l.'/ifcfg-eth'.' '.$ifcfg_file_path_l);
	
	&replace_values_in_file($ifcfg_file_path_l,'eth-for-bond',$int_list_l[$arr_i0_l],$hwaddr_list_l[$arr_i0_l],$prms_href_l);
	#$file_path_l,$file_type_l,$int_name_l,$hwaddr_l,$prms_href_l
    }
    $ifcfg_file_path_l=undef;

    $ifcfg_file_path_l=$target_dyn_ifcfg_dir_l.'/ifcfg-'.${$prms_href_l}{'main'}{'_bond_name_'};
    if ( ${$prms_href_l}{'main'}{'_ipaddr_'} eq 'dhcp' ) {
	system("cp ".$tmplt_dir_l.'/ifcfg-bond-dhcp'.' '.$ifcfg_file_path_l);
	
	&replace_values_in_file($ifcfg_file_path_l,'bond-dhcp','no','no',$prms_href_l);
	#$file_path_l,$file_type_l,$int_name_l,$hwaddr_l,$prms_href_l
    }
    else {
	system("cp ".$tmplt_dir_l.'/ifcfg-bond-static'.' '.$ifcfg_file_path_l);
	
	&replace_values_in_file($ifcfg_file_path_l,'bond-static','no','no',$prms_href_l);
	#$file_path_l,$file_type_l,$int_name_l,$hwaddr_l,$prms_href_l
    }

    ###some other specific operations if need
}

sub bond_bridge_vlan_gen_ifcfg {
    my ($tmplt_dir_l,$target_dyn_ifcfg_dir_l,$prms_href_l)=@_;
    #interface1+interface2 -> bondbrvlan -> bond-bridge-vlan
    
    ###ETH for bond4bondbrvlan. tmplt = playbooks/ifcfg_tmplt/bond-bridge-vlan/ifcfg-eth
    #TMPLT_VALUES_FOR_REPLACE:_interface_name_, _bond_name_, _hwaddr_, _conf_id_
    ###
    
    ###BOND for bondbrvlan. TMPLT = playbooks/ifcfg_tmplt/bond-bridge-vlan/ifcfg-bond
    #TMPLT_VALUES_FOR_REPLACE:_bond_name_, _bond_opts_, _bridge_name_, _conf_id_
    ###

    ###if STATIC. TMPLT = playbooks/ifcfg_tmplt/bond-bridge-vlan/ifcfg-bridge-static
    #TMPLT_VALUES_FOR_REPLACE:_defroute_, _bridge_name_, _ipaddr_, _gw_, _netmask_, _conf_id_
    ###

    ###if DHCP. TMPLT = playbooks/ifcfg_tmplt/bond-bridge-vlan/ifcfg-bridge-dhcp
    #TMPLT_VALUES_FOR_REPLACE:_defroute_, _bridge_name_, _conf_id_
    ###

    ###
    #HREF->{'main'}{'_inv_host_'}=inv_host;
    #HREF->{'main'}{'_conf_id_'}=conf_id;
    #HREF->{'main'}{'_vlan_id_'}=vlan_id;
    #HREF->{'main'}{'_bond_name_'}=bond_name;
    #HREF->{'main'}{'_bridge_name_'}=bridge_name;
    #HREF->{'main'}{'_defroute_'}=defroute;
    #HREF->{'main'}{'_ipaddr_'}=ipaddr/dhcp;
    #HREF->{'main'}{'_gw_'}=gw/dhcp;
    #HREF->{'main'}{'_netmask_'}=gw/dhcp;
    #HREF->{'main'}{'_bond_opts_'}=bond_opts_string_for_ifcfg;
    #HREF->{'int_list'}=[array of interfaces];
    #HREF->{'hwaddr_list'}=[array of hwaddr];
    ###
    my @int_list_l=@{${$prms_href_l}{'int_list'}};
    my @hwaddr_list_l=@{${$prms_href_l}{'hwaddr_list'}};

    ###vars
    my $arr_i0_l=0;
    my $ifcfg_file_path_l=undef;
    ###vars

    for ( $arr_i0_l=0; $arr_i0_l<=$#int_list_l; $arr_i0_l++ ) {
	$ifcfg_file_path_l=$target_dyn_ifcfg_dir_l.'/ifcfg-'.$int_list_l[$arr_i0_l];
	system("cp ".$tmplt_dir_l.'/ifcfg-eth'.' '.$ifcfg_file_path_l);
	
	&replace_values_in_file($ifcfg_file_path_l,'eth-for-bond',$int_list_l[$arr_i0_l],$hwaddr_list_l[$arr_i0_l],$prms_href_l);
	#$file_path_l,$file_type_l,$int_name_l,$hwaddr_l,$prms_href_l
    }
    $ifcfg_file_path_l=undef;

    $ifcfg_file_path_l=$target_dyn_ifcfg_dir_l.'/ifcfg-'.${$prms_href_l}{'main'}{'_bond_name_'};
    system("cp ".$tmplt_dir_l.'/ifcfg-bond'.' '.$ifcfg_file_path_l);
	
    &replace_values_in_file($ifcfg_file_path_l,'bond-for-bridge','no','no',$prms_href_l);
    #$file_path_l,$file_type_l,$int_name_l,$hwaddr_l,$prms_href_l
    $ifcfg_file_path_l=undef;

    $ifcfg_file_path_l=$target_dyn_ifcfg_dir_l.'/ifcfg-'.${$prms_href_l}{'main'}{'_bridge_name_'};
    if ( ${$prms_href_l}{'main'}{'_ipaddr_'} eq 'dhcp' ) {
	system("cp ".$tmplt_dir_l.'/ifcfg-bridge-dhcp'.' '.$ifcfg_file_path_l);
	
	&replace_values_in_file($ifcfg_file_path_l,'bridge-dhcp','no','no',$prms_href_l);
	#$file_path_l,$file_type_l,$int_name_l,$hwaddr_l,$prms_href_l
    }
    else {
	system("cp ".$tmplt_dir_l.'/ifcfg-bridge-static'.' '.$ifcfg_file_path_l);
	
	&replace_values_in_file($ifcfg_file_path_l,'bridge-static','no','no',$prms_href_l);
	#$file_path_l,$file_type_l,$int_name_l,$hwaddr_l,$prms_href_l
    }

    ###some other specific operations if need
}
##INCLUDED to conf_type_sub_refs_g

##other
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
    ###if STATIC. 		virt_bridge/ifcfg-bridge-static:	_bridge_name_, _ipaddr_, _netmask_, _conf_id_
    
    ###if STATIC.		just_interface/ifcfg-eth-static:	_defroute_, _interface_name_, _hwaddr_, _ipaddr_, _netmask_, _gw_, _conf_id_
    ###if DHCP. 		just_interface/ifcfg-eth-dhcp:		_defroute_, _interface_name_, _hwaddr_, _conf_id_
    
    ###ETH for BRIDGE. 		just_bridge/ifcfg-eth:			_interface_name_, _bridge_name_, _hwaddr_, _conf_id_
    ###if STATIC. 		just_bridge/ifcfg-bridge-static:	_defroute_, _bridge_name_, _ipaddr_, _gw_, _netmask_, _conf_id_
    ###if DHCP. 		just_bridge/ifcfg-bridge-dhcp:		_defroute_, _bridge_name_, _conf_id_
    
    ###ETH for bond. 		just_bond/ifcfg-eth:			_interface_name_, _bond_name_, _hwaddr_, _conf_id_
    ###if STATIC. 		just_bond/ifcfg-bond-static:		_defroute_, _bond_name_, _bond_opts_, _ipaddr_, _gw_, _netmask_, _conf_id_
    ###if DHCP. 		just_bond/ifcfg-bond-dhcp:		_defroute_, _bond_name_, _bond_opts_, _conf_id_
    
    ###ETH for bond. 		bond-bridge/ifcfg-eth:			_interface_name_, _bond_name_, _hwaddr_, _conf_id_
    ###BOND for bridge. 	bond-bridge/ifcfg-bond:			_bond_name_, _bond_opts_, _bridge_name_, _conf_id_
    ###if STATIC. 		bond-bridge/ifcfg-bridge-static:	_defroute_, _bridge_name_, _ipaddr_, _gw_, _netmask_, _conf_id_
    ###if DHCP. 		bond-bridge/ifcfg-bridge-dhcp:		_defroute_, _bridge_name_, _conf_id_
    
    ###if STATIC. 		interface-vlan/ifcfg-eth-static:	_defroute_, _interface_name_, _hwaddr_, _ipaddr_, _netmask_, _gw_, _conf_id_
    ###if DHCP. 		interface-vlan/ifcfg-eth-dhcp:		_defroute_, _interface_name_, _hwaddr_, _conf_id_
    
    ###ETH for BRIDGE-vlan.	bridge-vlan/ifcfg-eth:			_interface_name_, _bridge_name_, _hwaddr_, _conf_id_
    ###if STATIC. 		bridge-vlan/ifcfg-bridge-static:	_defroute_, _bridge_name_, _ipaddr_, _gw_, _netmask_, _conf_id_
    ###if DHCP. 		bridge-vlan/ifcfg-bridge-dhcp:		_defroute_, _bridge_name_, _conf_id_
    
    ###ETH for bond-vlan. 	bond-vlan/ifcfg-eth:			_interface_name_, _bond_name_, _hwaddr_, _conf_id_
    ###if STATIC. 		bond-vlan/ifcfg-bond-static:		_defroute_, _bond_name_, _bond_opts_, _ipaddr_, _gw_, _netmask_, _conf_id_
    ###if DHCP. 		bond-vlan/ifcfg-bond-dhcp:		_defroute_, _bond_name_, _bond_opts_, _conf_id_
    
    ###ETH for bond4bondbrvlan. bond-bridge-vlan/ifcfg-eth:		_interface_name_, _bond_name_, _hwaddr_, _conf_id_
    ###BOND for bondbrvlan. 	bond-bridge-vlan/ifcfg-bond:		_bond_name_, _bond_opts_, _bridge_name_, _conf_id_
    ###if STATIC. 		bond-bridge-vlan/ifcfg-bridge-static:	_defroute_, _bridge_name_, _ipaddr_, _gw_, _netmask_, _conf_id_
    ###if DHCP. 		bond-bridge-vlan/ifcfg-bridge-dhcp:	_defroute_, _bridge_name_, _conf_id_
    
    my $arr_el0_l=undef;
    
    my %file_type_hash_l=(
	'virt-bridge'=>		['_bridge_name_','_ipaddr_','_netmask_','_conf_id_'],
	###
	#just_bond, bond-bridge, bond-vlan, bond-bridge-vlan
	'eth-for-bond'=>	['_bond_name_','_conf_id_'], 
	###
	#just_bridge, bridge-vlan
	'eth-for-bridge'=>	['_bridge_name_','_conf_id_'],
	###
	##just_interface, interface-vlan
	'eth-static'=>		['_defroute_','_ipaddr_','_netmask_','_gw_','_conf_id_'],
	'eth-dhcp'=>		['_defroute_','_conf_id_'],
	###
	#just_bridge, bridge-vlan, bond-bridge-vlan
	'bridge-static'=>	['_defroute_','_bridge_name_','_ipaddr_','_gw_','_netmask_','_conf_id_'],
	'bridge-dhcp'=>		['_defroute_','_bridge_name_','_conf_id_'],
	###
	#just_bond
	'bond-static'=>		['_defroute_','_bond_name_','_bond_opts_','_ipaddr_','_gw_','_netmask_','_conf_id_'],
	'bond-dhcp'=>		['_defroute_','_bond_name_','_bond_opts_','_conf_id_'],
	###
	#bond-bridge-vlan, bond-bridge
	'bond-for-bridge'=>	['_bond_name_','_bond_opts_','_bridge_name_','_conf_id_']
    );
    
    if ( $int_name_l ne 'no' ) { system("sed -i -e 's/_interface_name_/$int_name_l/g' $file_path_l"); }
    if ( $hwaddr_l ne 'no' ) { system("sed -i -e 's/_hwaddr_/$hwaddr_l/g' $file_path_l"); }
    
    foreach $arr_el0_l ( @{$file_type_hash_l{$file_type_l}} ) {
	system("sed -i -e 's/$arr_el0_l/${$prms_href_l}{'main'}{$arr_el0_l}/g' $file_path_l");
    }
}
##other
###SUBROUTINES


#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
