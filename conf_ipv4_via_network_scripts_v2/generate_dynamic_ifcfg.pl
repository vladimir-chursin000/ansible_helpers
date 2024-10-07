#!/usr/bin/perl

###SCRIPT for generate ifcfg-files, resolv.conf for each inventory host and dynamic playbooks for ifcfg and resolv.conf

use strict;
use warnings;
use Cwd;
use Data::Dumper;

our ($self_dir_g,$script_name_g)=Cwd::abs_path($0)=~/(.*[\/\\])(\S+)$/;
$self_dir_g=~s/\/$//g;

###LOAD SUBROUTINES (begin)
our @do_arr_g=(
    'read_00_conf.pl',
    'read_01_conf.pl',
    'read_02_conf.pl',
    'read_03_conf.pl',
    'read_04_conf.pl',
    'read_conf_common.pl',
    'read_conf_other.pl',
    'value_check.pl',
    'other.pl',
);

foreach my $do_g ( @do_arr_g ) {
    do ($self_dir_g.'/perl_subs/'.$do_g);
    if ( $@ ) { die "'$do_g' error:$@"; }
}
###LOAD SUBROUTINES (end)

###ARGV (begin)
our $gen_playbooks_next_g=0;
our $gen_playbooks_next_with_rollback_g=0;
if ( defined($ARGV[0]) && $ARGV[0]=~/^gen_dyn_playbooks$/ ) {
    $gen_playbooks_next_g=1;
}
elsif ( defined($ARGV[0]) && $ARGV[0]=~/^gen_dyn_playbooks_with_rollback$/ ) {
    $gen_playbooks_next_g=1;
    $gen_playbooks_next_with_rollback_g=1;
}
###ARGV (end)

###CFG file (begin)
our $inventory_conf_path_g=$self_dir_g.'/conf_network_scripts_hosts';
our $f00_conf_divisions_for_inv_hosts_path_g=$self_dir_g.'/01_configs/00_conf_divisions_for_inv_hosts';

our $f01a_conf_int_hwaddr_inf_path_g=$self_dir_g.'/01_configs/01a_conf_int_hwaddr_inf';
our $f01b_conf_main_path_g=$self_dir_g.'/01_configs/01b_conf_main';
our $f01c_conf_ip_addr_path_g=$self_dir_g.'/01_configs/01c_conf_ip_addr';
our $f01d_conf_bond_opts_path_g=$self_dir_g.'/01_configs/01d_conf_bond_opts';
our $f02_conf_dns_path_g=$self_dir_g.'/01_configs/02_conf_dns';
our $f03_conf_routes_path_g=$self_dir_g.'/01_configs/03_conf_routes';
our $f04_not_configured_interfaces_path_g=$self_dir_g.'/01_configs/04_not_configured_interfaces';
our $f05_conf_temp_apply_path_g=$self_dir_g.'/01_configs/05_conf_temp_apply';
###CFG file (end)

############STATIC VARS. Change dir paths if you want just use this script without ansible helper (begin)
our $ifcfg_backup_from_remote_dir_g=$self_dir_g.'/playbooks/ifcfg_backup_from_remote/now'; # dir contains actual ifcfg-files downloaded from remote hosts with help of playbook 'ifcfg_backup_playbook.yml' before run this script
our $ifcfg_backup_from_remote_nd_file_g=$self_dir_g.'/playbooks/ifcfg_backup_from_remote/network_data/inv_hosts_interfaces_info.txt'; # dir contains actual network_data (eth, hwaddr) downloaded from remote hosts with help of playbook 'ifcfg_backup_playbook.yml' before run this script
our $remote_dir_for_absible_helper_g='~/ansible_helpers/conf_int_ipv4_via_network_scripts'; # dir for creating/manipulate files at remote side
############STATIC VARS (end)

############VARS (begin)
our ($exec_res_g,$exec_status_g)=(undef,'OK');
######
our %inventory_hosts_g=(); #Key=inventory_host, value=1
######
our %h00_conf_divisions_for_inv_hosts_hash_g=();
#DIVISION_NAME/GROUP_NAME       #LIST_OF_HOSTS
###
#$h00_conf_divisions_for_inv_hosts_hash_g{group_name}{inv-host}=1;
######
our %inv_hosts_network_data_g=();
#read 'ip_link_noqueue' first
#v1) key0='hwaddr_all', key1=hwaddr, value=inv_host
#v2) key0='inv_host', key1=inv_host, key2=interface_name, key3=hwaddr
######
our %h01a_conf_int_hwaddr_inf_hash_g=();
#INV_HOST       #INT            #HWADDR
#key0=inv-host, key1=interface, key2=hwaddr, value=1
###
our %h01b_conf_main_hash_g=();
#INV_HOST    #CONF_ID   #CONF_TYPE       #INT_LIST      #VLAN_ID    #BOND_NAME   #BRIDGE_NAME   #DEFROUTE
#h01b_conf_main_hash_g{inv-host}{conf-id}{'conf_type'}=conf-type-value
#h01b_conf_main_hash_g{inv-host}{conf-id}{'bond_name'}=bond-name-value
#h01b_conf_main_hash_g{inv-host}{conf-id}{'bridge_name'}=bridge-name-value
#h01b_conf_main_hash_g{inv-host}{conf-id}{'defroute'}=yes/no
#h01b_conf_main_hash_g{inv-host}{conf-id}{'vlan_id'}=vlan-id-value
#h01b_conf_main_hash_g{inv-host}{conf-id}{'int_list'}=[interface0,interface1...etc]
###
our %h01c_conf_ip_addr_hash_g=();
#INV_HOST    #CONF_ID           #IPv4_ADDR_OPTS (ip,gw,prefix)
#h01c_conf_ip_addr_hash_g{inv-host}{conf-id}{'ipv4'}=ip-value (or 'dhcp')
#h01c_conf_ip_addr_hash_g{inv-host}{conf-id}{'gw_ipv4'}=gw-value (empty if 'dhcp')
#h01c_conf_ip_addr_hash_g{inv-host}{conf-id}{'prefix_ipv4'}=prefix-value (empty if 'dhcp')
###
our %h01d_conf_bond_opts_hash_g=();
#INV_HOST       #CONF_ID        #BOND_OPTS
#h01d_conf_bond_opts_hash_g{inv-host}{conf-id}=bond-opts-value
#If bond-opts-value=def -> 'mode=4,xmit_hash_policy=2,lacp_rate=1,miimon=100'.
#Else -> 'bond-opts-value'.
###
our %h02_conf_dns_hash_g=();
#key=inv_host, value=[search-domain(optional), array of nameservers] or ['no-name-servers/do-not-touch']
###
our %h03_conf_routes_hash_g=();
#key=inv-host, value=[array of routes]
###
our %h04_not_configured_interfaces_hash_g=();
#Key=inv_host, value=do-not-touch/reconfigure
###
our %h05_conf_temp_apply_hash_g=();
#key=inv_host, value=rollback_timeout
######
############VARS (end)

######MAIN SEQ (begin)
while ( 1 ) { # ONE RUN CYCLE (begin)
    $exec_res_g=&read_inventory_file($inventory_conf_path_g,\%inventory_hosts_g);
    #$file_l,$res_href_l
    if ( $exec_res_g=~/^fail/ ) {
        $exec_status_g='FAIL';
        print "$exec_res_g\n";
        last;
    }
    $exec_res_g=undef;
    #print Dumper(\%inventory_hosts_g);
    
    ######
        
    $exec_res_g=&read_network_data_for_checks($ifcfg_backup_from_remote_nd_file_g,\%inv_hosts_network_data_g);
    #$file_l,$res_href_l
    if ( $exec_res_g=~/^fail/ ) {
    	$exec_status_g='FAIL';
    	print "$exec_res_g\n";
    	last;
    }
    $exec_res_g=undef;
    #print Dumper(\%inv_hosts_network_data_g);
    
    ######
    
    $exec_res_g=&read_00_conf_divisions_for_inv_hosts($f00_conf_divisions_for_inv_hosts_path_g,\%inventory_hosts_g,\%h00_conf_divisions_for_inv_hosts_hash_g);
    #$file_l,$inv_hosts_href_l,$res_href_l
    if ( $exec_res_g=~/^fail/ ) {
        $exec_status_g='FAIL';
        print "$exec_res_g\n";
        last;
    }
    $exec_res_g=undef;
    #print Dumper(\%h00_conf_divisions_for_inv_hosts_hash_g);
    
    ######
    
    $exec_res_g=&read_01a_conf_int_hwaddr($f01a_conf_int_hwaddr_inf_path_g,\%inventory_hosts_g,\%inv_hosts_network_data_g,\%h01a_conf_int_hwaddr_inf_hash_g);
    #$file_l,$inv_hosts_href_l,$inv_hosts_network_data_href_l,$res_href_l
    if ( $exec_res_g=~/^fail/ ) {
        $exec_status_g='FAIL';
        print "$exec_res_g\n";
        last;
    }
    $exec_res_g=undef;
    #print Dumper(\%h01a_conf_int_hwaddr_inf_hash_g);
    
    ######
    
    $exec_res_g=&read_01b_conf_main($f01b_conf_main_path_g,\%inventory_hosts_g,\%inv_hosts_network_data_g,\%h01a_conf_int_hwaddr_inf_hash_g,\%h01b_conf_main_hash_g);
    #$file_l,$inv_hosts_href_l,$inv_hosts_network_data_href_l,$h01a_conf_int_hwaddr_inf_hash_l,$res_href_l
    if ( $exec_res_g=~/^fail/ ) {
        $exec_status_g='FAIL';
        print "$exec_res_g\n";
        last;
    }
    $exec_res_g=undef;
    #print Dumper(\%h01b_conf_main_hash_g);
    
    ######
    
    $exec_res_g=&read_01c_conf_ip_addr($f01c_conf_ip_addr_path_g,\%inventory_hosts_g,\%h01b_conf_main_hash_g,\%h01c_conf_ip_addr_hash_g);
    #$file_l,$inv_hosts_href_l,$h01b_conf_main_href_l,$res_href_l
    if ( $exec_res_g=~/^fail/ ) {
        $exec_status_g='FAIL';
        print "$exec_res_g\n";
        last;
    }
    $exec_res_g=undef;
    #print Dumper(\%h01c_conf_ip_addr_hash_g);
    
    ######
    
    $exec_res_g=&read_01d_conf_bond_opts($f01d_conf_bond_opts_path_g,\%inventory_hosts_g,\%h01b_conf_main_hash_g,\%h01d_conf_bond_opts_hash_g);
    #$file_l,$inv_hosts_href_l,$h01b_conf_main_href_l,$res_href_l
    if ( $exec_res_g=~/^fail/ ) {
        $exec_status_g='FAIL';
        print "$exec_res_g\n";
        last;
    }
    $exec_res_g=undef;
    #print Dumper(\%h01d_conf_bond_opts_hash_g);
    
    ######
        
    $exec_res_g=&read_02_conf_dns($f02_conf_dns_path_g,\%inventory_hosts_g,\%h00_conf_divisions_for_inv_hosts_hash_g,\%h02_conf_dns_hash_g);
    #$file_l,$inv_hosts_href_l,$divisions_for_inv_hosts_href_l,$res_href_l
    if ( $exec_res_g=~/^fail/ ) {
    	$exec_status_g='FAIL';
    	print "$exec_res_g\n";
    	last;
    }
    $exec_res_g=undef;
    #print Dumper(\%h02_conf_dns_hash_g);
    
    ######
    
    last;
} # ONE RUN CYCLE (end)

system("echo $exec_status_g > GEN_DYN_IFCFG_STATUS");
if ( $exec_status_g!~/^OK$/ ) {
    print "EXEC_STATUS not OK. Exit!\n\n";
    exit;
}
######MAIN SEQ (end)

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
