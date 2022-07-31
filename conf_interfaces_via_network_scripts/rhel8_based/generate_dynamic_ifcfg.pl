#!/usr/bin/perl

use strict;
use warnings;
use Cwd;

our ($self_dir_g,$script_name_g)=Cwd::abs_path($0)=~/(.*[\/\\])(\S+)$/;

###CFG
our $conf_file_g=$self_dir_g.'config';
###CFG

############VARS
our $line_g=undef;
our $common_uniq_criteria_yes_g=0;
our ($inv_host_g,$conf_id_g,$conf_type_g,$int_list_str_g,$hwaddr_list_str_g,$vlan_id_g,$bond_name_g,$brigde_name_g,$ipaddr_opts_g,$bond_opts_g)=(undef,undef,undef,undef,undef,undef,undef,undef,undef,undef);
our %cfg0_hash_g=();
#our %cfg0_uniq_interface_check_g=();
#our %cfg0_novlan_uniq_hwaddr_check_g=();
#our %cfg0_novlan_uniq_vlan_check_g=();
#our %cfg0_novlan_uniq_bondname_check_g=();
#our %cfg0_novlan_uniq_bridge_name_check_g=();
#our %cfg0_novlan_iniq_ip_check_g=();
######
our %cfg0_uniq_check=();
#$cfg0_uniq_check{'common'}{interface_name}=1; #if interface_name ne 'no'
#$cfg0_uniq_check{'common'}{hwaddr}=1;
#$cfg0_uniq_check{'common'}{bond_name}=1; #if bond_name ne 'no'
#$cfg0_uniq_check{'common'}{bridge_name}=1; #if bridge_name ne 'no'
#$cfg0_uniq_check{'common'}{ipaddr}=1;
###
#$cfg0_uniq_check{'vlan'}{interface_name+}=1;
#$cfg0_uniq_check{'vlan'}{vlan_id}=1;
######
our %cfg_ready_hash_g=();
############VARS

###MAIN SEQ
open(CONF,'<',$conf_file_g);
while ( <CONF> ) {
    $line_g=$_;
    $line_g=~s/\n$|\r$|\n\r$|\r\n$//g;
    while ($line_g=~/\t/) { $line_g=~s/\t/ /g; }
    $line_g=~s/\s+/ /g;
    $line_g=~s/^ //g;
    if ( $line_g!~/^\#/ ) {
	$line_g=~s/ \,/\,/g;
	$line_g=~s/\, /\,/g;
	$line_g=~s/ \, /\,/g;
	($inv_host_g,$conf_id_g,$conf_type_g,$int_list_str_g,$hwaddr_list_str_g,$vlan_id_g,$bond_name_g,$brigde_name_g,$ipaddr_opts_g,$bond_opts_g)=split(' ',$line_g);
	
	#unique conf_id for inventory_host
	if ( !exists($cfg0_hash_g{$inv_host_g.'-'.$conf_id_g}) ) { 
	    $cfg0_hash_g{$inv_host_g.'-'.$conf_id_g}=[$inv_host_g,$conf_id_g,$conf_type_g,$int_list_str_g,$hwaddr_list_str_g,$vlan_id_g,$bond_name_g,$brigde_name_g,$ipaddr_opts_g,$bond_opts_g];
	}
	else { print "For inv_host='$inv_host_g' conf_id='$conf_id_g}' is already exists. Please, check config-file\n"; }
	#unique conf_id for inventory_host
	
	#print "'($inv_host_g,$conf_id_g,$conf_type_g,$int_list_str_g,$hwaddr_list_str_g,$vlan_id_g,$bond_name_g,$brigde_name_g,$ipaddr_opts_g,$bond_opts_g)'\n";
    }
}
close(CONF);
###MAIN SEQ

###SUBROUTINES
###SUBROUTINES

