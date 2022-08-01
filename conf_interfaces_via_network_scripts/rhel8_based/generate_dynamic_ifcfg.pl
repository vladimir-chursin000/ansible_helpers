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
######
our %cfg0_hash_g=();
#$cfg0_hash_g{inv_host-conf_id}{conf_type}{'main'}=[inv_host,conf_id,vlan_id,bond_name,brigde_name];
#$cfg0_hash_g{inv_host-conf_id}{conf_type}{'int_list'}=[array of interfaces];
#$cfg0_hash_g{inv_host-conf_id}{conf_type}{'hwaddr_list'}=[array of hwaddr];
#$cfg0_hash_g{inv_host-conf_id}{conf_type}{'ipaddr_opts'}=[array of ipaddr opts];
#$cfg0_hash_g{inv_host-conf_id}{conf_type}{'bond_opts'}=[array of bond opts];
######
our %cfg0_uniq_check=();
#Checks (uniq) for novlan interfaces at current inv_host.
#$cfg0_uniq_check{inv_host}{'common'}{interface_name}=1; #if interface_name ne 'no' and vlan_id eq 'no'.
#$cfg0_uniq_check{inv_host}{'common'}{hwaddr}=1; if vlan_id eq 'no'.
#$cfg0_uniq_check{inv_host}{'common'}{bond_name}=1; #if bond_name ne 'no' and vlan_id eq 'no'.
#$cfg0_uniq_check{inv_host}{'common'}{bridge_name}=1; #if bridge_name ne 'no' and vlan_id eq 'no'.
#$cfg0_uniq_check{inv_host}{'common'}{ipaddr}=1; #if ipaddr_opts ne 'dhcp'.
###
#Checks (uniq) for vlan interfaces at current inv_host.
#$cfg0_uniq_check{inv_host}{'vlan'}{vlan_id}=1; #if vlan_id ne 'no'.
#$cfg0_uniq_check{inv_host}{'vlan'}{interface_name-vlan_id}=1; #if vlan_id ne 'no'.
#$cfg0_uniq_check{inv_host}{'vlan'}{hwaddr-vlan_id}=1; #if vlan_id ne 'no'.
#$cfg0_uniq_check{inv_host}{'vlan'}{bond_name-vlan_id}=1; #if vlan_id ne 'no' and bond_name ne 'no'.
#$cfg0_uniq_check{inv_host}{'vlan'}{bridge_name-vlan_id}=1; #if vlan_id ne 'no' and bridge_name ne 'no'.
###
#Checks (uniq) for interfaces at config (for all inv_hosts)
#$cfg0_uniq_check{'all_hosts'}{hwaddr}=inv_host;
#$cfg0_uniq_check{'all_hosts'}{ipaddr}=inv_host; #if ipaddr ne 'dhcp'.
######
our %cfg_ready_hash_g=();
our @int_list_arr_g=();
our @hwaddr_list_arr_g=();
our @ipaddr_opts_arr_g=();
our @bond_opts_arr_g=();
our $bond_opts_str_g='mode=4 xmit_hash_policy=2 lacp_rate=1 miimon=100';
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
	@int_list_arr_g=split(/\,/,$int_list_str_g);
	@hwaddr_list_arr_g=split(/\,/,$hwaddr_list_str_g);
	@ipaddr_opts_arr_g=split(/\,/,$ipaddr_opts_g);
	if ( $bond_opts_g!~/^def$/ ) {
	    $bond_opts_str_g=$bond_opts_g;
	    $bond_opts_str_g=~s/\,/ /g;
	}
	
	#unique conf_id for inventory_host
	if ( !exists($cfg0_hash_g{$inv_host_g.'-'.$conf_id_g}) ) { 
	    $cfg0_hash_g{$inv_host_g.'-'.$conf_id_g}{$conf_type_g}{'main'}=[$inv_host_g,$conf_id_g,$bond_name_g,$brigde_name_g];
	    $cfg0_hash_g{$inv_host_g.'-'.$conf_id_g}{$conf_type_g}{'int_list'}=[@int_list_arr_g];
	    $cfg0_hash_g{$inv_host_g.'-'.$conf_id_g}{$conf_type_g}{'hwaddr_list'}=[@hwaddr_list_arr_g];
	    $cfg0_hash_g{$inv_host_g.'-'.$conf_id_g}{$conf_type_g}{'ipaddr_opts'}=[@ipaddr_opts_arr_g];
	    $cfg0_hash_g{$inv_host_g.'-'.$conf_id_g}{$conf_type_g}{'bond_opts'}=$bond_opts_str_g;
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

