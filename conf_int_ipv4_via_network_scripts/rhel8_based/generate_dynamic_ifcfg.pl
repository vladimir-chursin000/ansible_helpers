#!/usr/bin/perl

use strict;
use warnings;
use Cwd;
use Data::Dumper;

our ($self_dir_g,$script_name_g)=Cwd::abs_path($0)=~/(.*[\/\\])(\S+)$/;

###CFG file
our $conf_file_g=$self_dir_g.'config';
###CFG file

############STATIC VARS
our $dyn_ifcfg_common_dir_g=$self_dir_g.'playbooks/dyn_ifcfg';
our $ifcfg_tmplt_dir_g=$self_dir_g.'playbooks/ifcfg_tmplt';
############STATIC VARS

############VARS
our $line_g=undef;
our $arr_el0_g=undef;
our ($hkey0_g,$hval0_g)=(undef,undef);
our ($hkey1_g,$hval1_g)=(undef,undef);
our $skip_conf_line_g=0;
our ($inv_host_g,$conf_id_g,$conf_type_g,$int_list_str_g,$hwaddr_list_str_g,$vlan_id_g,$bond_name_g,$bridge_name_g,$ipaddr_opts_g,$bond_opts_g,$defroute_g)=(undef,undef,undef,undef,undef,undef,undef,undef,undef,undef,undef);
our @arr0_g=();
######
our %cfg0_hash_g=();
#$cfg0_hash_g{inv_host-conf_id}{conf_type}{'main'}=[inv_host,conf_id,vlan_id,bond_name,bridge_name,defroute];
#$cfg0_hash_g{inv_host-conf_id}{conf_type}{'int_list'}=[array of interfaces];
#$cfg0_hash_g{inv_host-conf_id}{conf_type}{'hwaddr_list'}=[array of hwaddr];
#$cfg0_hash_g{inv_host-conf_id}{conf_type}{'ipaddr_opts'}=[array of ipaddr opts];
#$cfg0_hash_g{inv_host-conf_id}{conf_type}{'bond_opts'}=bond_opts_string_for_ifcfg;
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
our $bond_opts_str_g='mode=4 xmit_hash_policy=2 lacp_rate=1 miimon=100';

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
############VARS

###MAIN SEQ
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
    	    next;
    	}
    	
    	($inv_host_g,$conf_id_g,$conf_type_g,$int_list_str_g,$hwaddr_list_str_g,$vlan_id_g,$bond_name_g,$bridge_name_g,$ipaddr_opts_g,$bond_opts_g,$defroute_g)=@arr0_g;
    	
    	#######check conf_type
    	if ( $conf_type_g!~/^just_interface$|^virt_bridge$|^just_bridge$|^just_bond$|^bond\-bridge$|^interface\-vlan$|^bridge\-vlan$|^bond\-vlan$|^bond\-bridge\-vlan$/ ) {
    	    print "Wrong conf_type='$conf_type_g'. Conf_type must be 'just_interface/virt_bridge/just_bridge/just_bond/bond-bridge/interface-vlan/bridge-vlan/bond-vlan/bond-bridge-vlan'. Please, check and correct config-file\n";
    	    $skip_conf_line_g=1;    
    	}
    	if ( $skip_conf_line_g==1 ) {
            print "Skip conf-line with conf_id='$conf_id_g'\n";
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
    	    next;
    	}
    	#######bond_name/bridge_name simple checks
    	
    	#######IPADDRv4 PREcheck via regexp
    	if ( $ipaddr_opts_g!~/^dhcp$|^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\,\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\,\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/ ) {
    	    print "IPv4_ADDR_OPTS must be 'dhcp' or 'ipv4,gw,netmask'. Please, check and correct config-file\n";
    	    $skip_conf_line_g=1;
    	}
    
    	if ( $skip_conf_line_g==1 ) {
    	    print "Skip conf-line with conf_id='$conf_id_g'\n";
    	    next;
    	}
    	#######IPADDRv4 PREcheck via regexp
    
    	#######extract complex vars
    	@int_list_arr_g=split(/\,/,$int_list_str_g);
    	@hwaddr_list_arr_g=split(/\,/,$hwaddr_list_str_g);
    	@ipaddr_opts_arr_g=split(/\,/,$ipaddr_opts_g);
    	if ( $bond_opts_g!~/^def$/ ) {
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
    	    next;
    	}
    	#######interfaces + hwaddr count checks for each conf_type
    	
    	#######hwaddr check via regexp
    	foreach $arr_el0_g ( @hwaddr_list_arr_g ) {
    	    if ( $arr_el0_g!~/^\S{2}\:\S{2}\:\S{2}\:\S{2}\:\S{2}\:\S{2}$/ ) {
    		print "HWADDR must be like 'XX:XX:XX:XX:XX:XX' (incorrect value='$arr_el0_g'). Please, check and correct config-file\n";
    		$skip_conf_line_g=1;
    	    }
    	}
    
    	if ( $skip_conf_line_g==1 ) {
    	    print "Skip conf-line with conf_id='$conf_id_g'\n";
    	    next;
    	}
    	#######hwaddr check via regexp
    	
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
    		    next;
    		}
    	    }
    	    ###
    	}
    	########uniq checks
    	
    	########unique conf_id for inventory_host
    	if ( !exists($cfg0_hash_g{$inv_host_g.'-'.$conf_id_g}) ) {
    	    $cfg0_hash_g{$inv_host_g.'-'.$conf_id_g}{$conf_type_g}{'main'}=[$inv_host_g,$conf_id_g,$vlan_id_g,$bond_name_g,$bridge_name_g,$defroute_g];
    	    $cfg0_hash_g{$inv_host_g.'-'.$conf_id_g}{$conf_type_g}{'int_list'}=[@int_list_arr_g];
    	    $cfg0_hash_g{$inv_host_g.'-'.$conf_id_g}{$conf_type_g}{'hwaddr_list'}=[@hwaddr_list_arr_g];
    	    $cfg0_hash_g{$inv_host_g.'-'.$conf_id_g}{$conf_type_g}{'ipaddr_opts'}=[@ipaddr_opts_arr_g]; #ip-0, gw-1, netmask-2 / dhcp-0
    	    $cfg0_hash_g{$inv_host_g.'-'.$conf_id_g}{$conf_type_g}{'bond_opts'}=$bond_opts_str_g;
    	}
    	else {
    	    print "For inv_host='$inv_host_g' conf_id='$conf_id_g' is already exists. Please, check and correct config-file\n";
    	    $skip_conf_line_g=1;
    	}
    	if ( $skip_conf_line_g==1 ) {
    	    print "Skip conf-line with conf_id='$conf_id_g'\n";
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
}
close(CONF);

while ( ($hkey0_g,$hval0_g)=each %cfg0_hash_g ) {
    #$hkey0_h = $inv_host_g-$conf_id_g
    ($inv_host_g,$conf_id_g)=split(/\-/,$hkey0_g);
    if ( -d $dyn_ifcfg_common_dir_g.'/'.$inv_host_g ) {
	system("rm -rf ".$dyn_ifcfg_common_dir_g.'/'.$inv_host_g);
    }
    system("mkdir -p ".$dyn_ifcfg_common_dir_g.'/'.$inv_host_g);
    while ( ($hkey1_g,$hval1_g)=each %{$hval0_g} ) {
	#$hkey1_g = $conf_type_g, $hval1_g = hash ref
	if ( -d $ifcfg_tmplt_dir_g.'/'.$hkey1_g ) {
	    &{$conf_type_sub_refs_g{$hkey1_g}}($ifcfg_tmplt_dir_g.'/'.$hkey1_g,$dyn_ifcfg_common_dir_g.'/'.$inv_host_g,$hval1_g);
	    ######
	    #$cfg0_hash_g{inv_host-conf_id}{conf_type}-HREF->{'main'}=[inv_host,conf_id,vlan_id,bond_name,bridge_name,defroute];
	    #$cfg0_hash_g{inv_host-conf_id}{conf_type}-HREF->{'int_list'}=[array of interfaces];
	    #$cfg0_hash_g{inv_host-conf_id}{conf_type}-HREF->{'hwaddr_list'}=[array of hwaddr];
	    #$cfg0_hash_g{inv_host-conf_id}{conf_type}-HREF->{'ipaddr_opts'}=[array of ipaddr opts];
	    #$cfg0_hash_g{inv_host-conf_id}{conf_type}-HREF->{'bond_opts'}=bond_opts_string_for_ifcfg;
	}
	else {
	    print "ERROR. Ifcfg tmplt dir='$ifcfg_tmplt_dir_g/$hkey1_g' not exists\n";
	}
    }
    ($inv_host_g,$conf_id_g)=(undef,undef);
}

###MAIN SEQ

###SUBROUTINES
##INCLUDED to conf_type_sub_refs_g
#common (novlan)
sub just_interface_gen_ifcfg {
    my ($tmplt_dir_l,$dyn_ifcfg_host_dir_l,$prms_href_l)=@_;
    ###if STATIC. TMPLT = playbooks/ifcfg_tmplt/just_interface/ifcfg-eth-static
    #TMPLT_VALUES_FOR_REPLACE:_defroute_, _interface_name_, _hwaddr_, _ipaddr_, _netmask_, _gw_, _conf_id_
    ###
    
    ###if DHCP. TMPLT = playbooks/ifcfg_tmplt/just_interface/ifcfg-eth-dhcp
    #TMPLT_VALUES_FOR_REPLACE:_defroute_, _interface_name_, _hwaddr_, _conf_id_
    ###
    
    ###
    #HREF->{'main'}=[inv_host,conf_id,vlan_id,bond_name,bridge_name,defroute];
    #HREF->{'int_list'}=[array of interfaces];
    #HREF->{'hwaddr_list'}=[array of hwaddr];
    #HREF->{'ipaddr_opts'}=[array of ipaddr opts];
    #HREF->{'bond_opts'}=bond_opts_string_for_ifcfg;
    ###
    my ($inv_host_l,$conf_id_l,$vlan_id_l,$bond_name_l,$bridge_name_l,$defroute_l)=@{${$prms_href_l}{'main'}};
    my $int_name_l=${${$prms_href_l}{'int_list'}}[0];
    my $hwaddr_l=${${$prms_href_l}{'hwaddr_list'}}[0];
    my @ipaddr_opts_l=@{${$prms_href_l}{'ipaddr_opts'}};
}

sub virt_bridge_gen_ifcfg {
    my ($tmplt_dir_l,$dyn_ifcfg_host_dir_l,$prms_href_l)=@_;
    ###if STATIC. TMPLT = playbooks/ifcfg_tmplt/virt_bridge/ifcfg-br-static
    #TMPLT_VALUES_FOR_REPLACE:_bridge_name_, _ipaddr_, _netmask_, _conf_id_
    ###

    ###
    #HREF->{'main'}=[inv_host,conf_id,vlan_id,bond_name,bridge_name,defroute];
    #HREF->{'int_list'}=[array of interfaces];
    #HREF->{'hwaddr_list'}=[array of hwaddr];
    #HREF->{'ipaddr_opts'}=[array of ipaddr opts];
    #HREF->{'bond_opts'}=bond_opts_string_for_ifcfg;
    ###
    my ($inv_host_l,$conf_id_l,$vlan_id_l,$bond_name_l,$bridge_name_l,$defroute_l)=@{${$prms_href_l}{'main'}};
    my $hwaddr_l=${${$prms_href_l}{'hwaddr_list'}}[0];
    my @ipaddr_opts_l=@{${$prms_href_l}{'ipaddr_opts'}};
}

sub just_bridge_gen_ifcfg {
    my ($tmplt_dir_l,$dyn_ifcfg_host_dir_l,$prms_href_l)=@_;
    #interface -> bridge
    
    ###ETH for BRIDGE. tmplt = playbooks/ifcfg_tmplt/just_bridge/ifcfg-eth4br
    #TMPLT_VALUES_FOR_REPLACE:_interface_name_, _bridge_name_, _hwaddr_, _conf_id_
    ###
    
    ###if STATIC. TMPLT = playbooks/ifcfg_tmplt/just_bridge/ifcfg-br-static
    #TMPLT_VALUES_FOR_REPLACE:_defroute_, _bridge_name_, _ipaddr_, _gw_, _netmask_, _conf_id_
    ###

    ###if DHCP. TMPLT = playbooks/ifcfg_tmplt/just_bridge/ifcfg-br-dhcp
    #TMPLT_VALUES_FOR_REPLACE:_defroute_, _bridge_name_, _conf_id_
    ###

    ###
    #HREF->{'main'}=[inv_host,conf_id,vlan_id,bond_name,bridge_name,defroute];
    #HREF->{'int_list'}=[array of interfaces];
    #HREF->{'hwaddr_list'}=[array of hwaddr];
    #HREF->{'ipaddr_opts'}=[array of ipaddr opts];
    #HREF->{'bond_opts'}=bond_opts_string_for_ifcfg;
    ###
    my ($inv_host_l,$conf_id_l,$vlan_id_l,$bond_name_l,$bridge_name_l,$defroute_l)=@{${$prms_href_l}{'main'}};
    my $int_name_l=${${$prms_href_l}{'int_list'}}[0];
    my $hwaddr_l=${${$prms_href_l}{'hwaddr_list'}}[0];
    my @ipaddr_opts_l=@{${$prms_href_l}{'ipaddr_opts'}};
}

sub just_bond_gen_ifcfg {
    my ($tmplt_dir_l,$dyn_ifcfg_host_dir_l,$prms_href_l)=@_;
    #interface1+interface2 -> bond
    
    ###ETH for bond. tmplt = playbooks/ifcfg_tmplt/just_bond/ifcfg-eth4bond
    #TMPLT_VALUES_FOR_REPLACE:_interface_name_, _bond_name_, _hwaddr_, _conf_id_
    ###
    
    ###if STATIC. TMPLT = playbooks/ifcfg_tmplt/just_bond/ifcfg-bond-static
    #TMPLT_VALUES_FOR_REPLACE:_defroute_, _bond_name_, _bond_opts_, _ipaddr_, _gw_, _netmask_, _conf_id_
    ###

    ###if DHCP. TMPLT = playbooks/ifcfg_tmplt/just_bond/ifcfg-bond-dhcp
    #TMPLT_VALUES_FOR_REPLACE:_defroute_, _bond_name_, _bond_opts_, _conf_id_
    ###

    ###
    #HREF->{'main'}=[inv_host,conf_id,vlan_id,bond_name,bridge_name,defroute];
    #HREF->{'int_list'}=[array of interfaces];
    #HREF->{'hwaddr_list'}=[array of hwaddr];
    #HREF->{'ipaddr_opts'}=[array of ipaddr opts];
    #HREF->{'bond_opts'}=bond_opts_string_for_ifcfg;
    ###
    my ($inv_host_l,$conf_id_l,$vlan_id_l,$bond_name_l,$bridge_name_l,$defroute_l)=@{${$prms_href_l}{'main'}};
    my @int_list_l=@{${$prms_href_l}{'int_list'}};
    my @hwaddr_list_l=@{${$prms_href_l}{'hwaddr_list'}};
    my @ipaddr_opts_l=@{${$prms_href_l}{'ipaddr_opts'}};
    my $bond_opts_l=${$prms_href_l}{'bond_opts'};
}

sub bond_bridge_gen_ifcfg {
    my ($tmplt_dir_l,$dyn_ifcfg_host_dir_l,$prms_href_l)=@_;
    #interface1+interface2 -> bond -> bridge
    
    ###ETH for bond. tmplt = playbooks/ifcfg_tmplt/bond-bridge/ifcfg-eth4bond
    #TMPLT_VALUES_FOR_REPLACE:_interface_name_, _bond_name_, _hwaddr_, _conf_id_
    ###
    
    ###BOND for bridge. TMPLT = playbooks/ifcfg_tmplt/bond-bridge/ifcfg-bond4br
    #TMPLT_VALUES_FOR_REPLACE:_bond_name_, _bond_opts_, _bridge_name_, _conf_id_
    ###

    ###if STATIC. TMPLT = playbooks/ifcfg_tmplt/bond-bridge/ifcfg-br-static
    #TMPLT_VALUES_FOR_REPLACE:_defroute_, _bridge_name_, _ipaddr_, _gw_, _netmask_, _conf_id_
    ###

    ###if DHCP. TMPLT = playbooks/ifcfg_tmplt/bond-bridge/ifcfg-br-dhcp
    #TMPLT_VALUES_FOR_REPLACE:_defroute_, _bridge_name_, _conf_id_
    ###

    ###
    #HREF->{'main'}=[inv_host,conf_id,vlan_id,bond_name,bridge_name,defroute];
    #HREF->{'int_list'}=[array of interfaces];
    #HREF->{'hwaddr_list'}=[array of hwaddr];
    #HREF->{'ipaddr_opts'}=[array of ipaddr opts];
    #HREF->{'bond_opts'}=bond_opts_string_for_ifcfg;
    ###
    my ($inv_host_l,$conf_id_l,$vlan_id_l,$bond_name_l,$bridge_name_l,$defroute_l)=@{${$prms_href_l}{'main'}};
    my @int_list_l=@{${$prms_href_l}{'int_list'}};
    my @hwaddr_list_l=@{${$prms_href_l}{'hwaddr_list'}};
    my @ipaddr_opts_l=@{${$prms_href_l}{'ipaddr_opts'}};
    my $bond_opts_l=${$prms_href_l}{'bond_opts'};
}

#vlan
sub interface_vlan_gen_ifcfg {
    my ($tmplt_dir_l,$dyn_ifcfg_host_dir_l,$prms_href_l)=@_;
    ###if STATIC. TMPLT = playbooks/ifcfg_tmplt/interface-vlan/ifcfg-eth4vlan-static
    #TMPLT_VALUES_FOR_REPLACE:_defroute_, _interface_name_, _hwaddr_, _ipaddr_, _netmask_, _gw_, _conf_id_
    ###
    
    ###if DHCP. TMPLT = playbooks/ifcfg_tmplt/interface-vlan/ifcfg-eth4vlan-dhcp
    #TMPLT_VALUES_FOR_REPLACE:_defroute_, _interface_name_, _hwaddr_, _conf_id_
    ###

    ###
    #HREF->{'main'}=[inv_host,conf_id,vlan_id,bond_name,bridge_name,defroute];
    #HREF->{'int_list'}=[array of interfaces];
    #HREF->{'hwaddr_list'}=[array of hwaddr];
    #HREF->{'ipaddr_opts'}=[array of ipaddr opts];
    #HREF->{'bond_opts'}=bond_opts_string_for_ifcfg;
    ###
    my ($inv_host_l,$conf_id_l,$vlan_id_l,$bond_name_l,$bridge_name_l,$defroute_l)=@{${$prms_href_l}{'main'}};
    my $int_name_l=${${$prms_href_l}{'int_list'}}[0];
    my $hwaddr_l=${${$prms_href_l}{'hwaddr_list'}}[0];
    my @ipaddr_opts_l=@{${$prms_href_l}{'ipaddr_opts'}};
}

sub bridge_vlan_gen_ifcfg {
    my ($tmplt_dir_l,$dyn_ifcfg_host_dir_l,$prms_href_l)=@_;
    #interface-vlan -> bridge
    
    ###ETH for BRIDGE-vlan. tmplt = playbooks/ifcfg_tmplt/bridge-vlan/ifcfg-eth4brvlan
    #TMPLT_VALUES_FOR_REPLACE:_interface_name_, _bridge_name_, _hwaddr_, _conf_id_
    ###
    
    ###if STATIC. TMPLT = playbooks/ifcfg_tmplt/bridge-vlan/ifcfg-brvlan-static
    #TMPLT_VALUES_FOR_REPLACE:_defroute_, _bridge_name_, _ipaddr_, _gw_, _netmask_, _conf_id_
    ###

    ###if DHCP. TMPLT = playbooks/ifcfg_tmplt/bridge-vlan/ifcfg-brvlan-dhcp
    #TMPLT_VALUES_FOR_REPLACE:_defroute_, _bridge_name_, _conf_id_
    ###

    ###
    #HREF->{'main'}=[inv_host,conf_id,vlan_id,bond_name,bridge_name,defroute];
    #HREF->{'int_list'}=[array of interfaces];
    #HREF->{'hwaddr_list'}=[array of hwaddr];
    #HREF->{'ipaddr_opts'}=[array of ipaddr opts];
    #HREF->{'bond_opts'}=bond_opts_string_for_ifcfg;
    ###
    my ($inv_host_l,$conf_id_l,$vlan_id_l,$bond_name_l,$bridge_name_l,$defroute_l)=@{${$prms_href_l}{'main'}};
    my $int_name_l=${${$prms_href_l}{'int_list'}}[0];
    my $hwaddr_l=${${$prms_href_l}{'hwaddr_list'}}[0];
    my @ipaddr_opts_l=@{${$prms_href_l}{'ipaddr_opts'}};
}

sub bond_vlan_gen_ifcfg {
    my ($tmplt_dir_l,$dyn_ifcfg_host_dir_l,$prms_href_l)=@_;
    #interface1+interface2 -> bond-vlan
    
    ###ETH for bond-vlan. tmplt = playbooks/ifcfg_tmplt/bond-vlan/ifcfg-eth4bondvlan
    #TMPLT_VALUES_FOR_REPLACE:_interface_name_, _bond_name_, _hwaddr_, _conf_id_
    ###
    
    ###if STATIC. TMPLT = playbooks/ifcfg_tmplt/bond-vlan/ifcfg-bondvlan-static
    #TMPLT_VALUES_FOR_REPLACE:_defroute_, _bond_name_, _bond_opts_, _ipaddr_, _gw_, _netmask_, _conf_id_
    ###

    ###if DHCP. TMPLT = playbooks/ifcfg_tmplt/bond-vlan/ifcfg-bondvlan-dhcp
    #TMPLT_VALUES_FOR_REPLACE:_defroute_, _bond_name_, _bond_opts_, _conf_id_
    ###

    ###
    #HREF->{'main'}=[inv_host,conf_id,vlan_id,bond_name,bridge_name,defroute];
    #HREF->{'int_list'}=[array of interfaces];
    #HREF->{'hwaddr_list'}=[array of hwaddr];
    #HREF->{'ipaddr_opts'}=[array of ipaddr opts];
    #HREF->{'bond_opts'}=bond_opts_string_for_ifcfg;
    ###
    my ($inv_host_l,$conf_id_l,$vlan_id_l,$bond_name_l,$bridge_name_l,$defroute_l)=@{${$prms_href_l}{'main'}};
    my @int_list_l=@{${$prms_href_l}{'int_list'}};
    my @hwaddr_list_l=@{${$prms_href_l}{'hwaddr_list'}};
    my @ipaddr_opts_l=@{${$prms_href_l}{'ipaddr_opts'}};
    my $bond_opts_l=${$prms_href_l}{'bond_opts'};
}

sub bond_bridge_vlan_gen_ifcfg {
    my ($tmplt_dir_l,$dyn_ifcfg_host_dir_l,$prms_href_l)=@_;
    #interface1+interface2 -> bondbrvlan -> bond-bridge-vlan
    
    ###ETH for bond4bondbrvlan. tmplt = playbooks/ifcfg_tmplt/bond-bridge-vlan/ifcfg-eth4bondbrvlan
    #TMPLT_VALUES_FOR_REPLACE:_interface_name_, _bond_name_, _hwaddr_, _conf_id_
    ###
    
    ###BOND for bondbrvlan. TMPLT = playbooks/ifcfg_tmplt/bond-bridge-vlan/ifcfg-bond4bondbrvlan
    #TMPLT_VALUES_FOR_REPLACE:_bond_name_, _bond_opts_, _bridge_name_, _conf_id_
    ###

    ###if STATIC. TMPLT = playbooks/ifcfg_tmplt/bond-bridge-vlan/ifcfg-bonbrvlan-static
    #TMPLT_VALUES_FOR_REPLACE:_defroute_, _bridge_name_, _ipaddr_, _gw_, _netmask_, _conf_id_
    ###

    ###if DHCP. TMPLT = playbooks/ifcfg_tmplt/bond-bridge-vlan/ifcfg-bondbrvlan-dhcp
    #TMPLT_VALUES_FOR_REPLACE:_defroute_, _bridge_name_, _conf_id_
    ###

    ###
    #HREF->{'main'}=[inv_host,conf_id,vlan_id,bond_name,bridge_name,defroute];
    #HREF->{'int_list'}=[array of interfaces];
    #HREF->{'hwaddr_list'}=[array of hwaddr];
    #HREF->{'ipaddr_opts'}=[array of ipaddr opts];
    #HREF->{'bond_opts'}=bond_opts_string_for_ifcfg;
    ###
    my ($inv_host_l,$conf_id_l,$vlan_id_l,$bond_name_l,$bridge_name_l,$defroute_l)=@{${$prms_href_l}{'main'}};
    my @int_list_l=@{${$prms_href_l}{'int_list'}};
    my @hwaddr_list_l=@{${$prms_href_l}{'hwaddr_list'}};
    my @ipaddr_opts_l=@{${$prms_href_l}{'ipaddr_opts'}};
    my $bond_opts_l=${$prms_href_l}{'bond_opts'};
}
##INCLUDED to conf_type_sub_refs_g

##other
##other
###SUBROUTINES

