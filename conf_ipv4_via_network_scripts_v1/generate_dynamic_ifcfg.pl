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
    'read_conf_common.pl',
    'gen_playbooks.pl',
    'conf_type_subs.pl',
    'read_conf_other.pl',
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

#new. not used yet (begin)
our $f01a_conf_int_hwaddr_inf_path_g=$self_dir_g.'/01_configs/01a_conf_int_hwaddr_inf';
our $f01b_conf_main_path_g=$self_dir_g.'/01_configs/01b_conf_main';
our $f01c_conf_ip_addr_path_g=$self_dir_g.'/01_configs/01c_conf_ip_addr';
our $f01d_conf_bond_opts_path_g=$self_dir_g.'/01_configs/01d_conf_bond_opts';
our $f02_dns_settings_path_g=$self_dir_g.'/01_configs/02_dns_settings';
our $f03_config_del_not_configured_ifcfg_path_g=$self_dir_g.'/01_configs/03_config_del_not_configured_ifcfg';
our $f04_config_temporary_apply_ifcfg_path_g=$self_dir_g.'/01_configs/04_config_temporary_apply_ifcfg';
#new (end)

our $conf_file_g=$self_dir_g.'/01_configs/00_config';
our $conf_dns_g=$self_dir_g.'/01_configs/01_dns_settings'; #for configure resolv.conf
our $conf_file_del_not_configured_g=$self_dir_g.'/01_configs/02_config_del_not_configured_ifcfg';
our $conf_temp_apply_g=$self_dir_g.'/01_configs/03_config_temporary_apply_ifcfg';
###CFG file (end)

############STATIC VARS. Change dir paths if you want just use this script without ansible helper (begin)
our $dyn_ifcfg_common_dir_g=$self_dir_g.'/playbooks/dyn_ifcfg_playbooks/dyn_ifcfg'; # dir for save generated ifcfg-files
our $dyn_resolv_common_dir_g=$self_dir_g.'/playbooks/dyn_ifcfg_playbooks/dyn_resolv_conf'; # dir for save generated resolv-conf-files
our $dyn_ifcfg_playbooks_dir_g=$self_dir_g.'/playbooks/dyn_ifcfg_playbooks'; # dir for save generated dynamic playbooks. Playbooks will be created if changes needed
our $ifcfg_tmplt_dir_g=$self_dir_g.'/playbooks/ifcfg_tmplt'; # dir with ifcfg templates
our $ifcfg_backup_from_remote_dir_g=$self_dir_g.'/playbooks/ifcfg_backup_from_remote/now'; # dir contains actual ifcfg-files downloaded from remote hosts with help of playbook 'ifcfg_backup_playbook.yml' before run this script
our $ifcfg_backup_from_remote_nd_file_g=$self_dir_g.'/playbooks/ifcfg_backup_from_remote/network_data/inv_hosts_interfaces_info.txt'; # dir contains actual network_data (eth, hwaddr) downloaded from remote hosts with help of playbook 'ifcfg_backup_playbook.yml' before run this script
our $remote_dir_for_absible_helper_g='~/ansible_helpers/conf_int_ipv4_via_network_scripts'; # dir for creating/manipulate files at remote side
############STATIC VARS (end)

############VARS (begin)
our ($exec_res_g,$exec_status_g)=(undef,'OK');
######
our %h00_conf_divisions_for_inv_hosts_hash_g=();
#DIVISION_NAME/GROUP_NAME       #LIST_OF_HOSTS
###
#$h00_conf_divisions_for_inv_hosts_hash_g{group_name}{inv-host}=1;
######
######new. Not used yet (begin)
our %h01a_conf_int_hwaddr_inf_hash_g=();
#INV_HOST       #INT            #HWADDR
###
our %h01b_conf_main_hash_g=();
#INV_HOST    #CONF_ID   #CONF_TYPE       #INT_LIST      #VLAN_ID    #BOND_NAME   #BRIDGE_NAME   #DEFROUTE
###
our %h01c_conf_ip_addr_hash_g=();
#INV_HOST    #CONF_ID           #IPv4_ADDR_OPTS
###
our %h01d_conf_bond_opts_hash_g=();
#INV_HOST       #CONF_ID        #BOND_OPTS
###
our %h02_dns_settings_hash_g=();
#key=inv_host/common, value=[array of nameservers]
###
our %h03_config_del_not_configured_ifcfg_hash_g=();
#Key=inv_host
###
our %h04_config_temporary_apply_ifcfg_hash_g=();
#key=inv_host/common, value=rollback_ifcfg_timeout
######new (end)
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
######
our %inv_hosts_hash0_g=(); #key=inv_host, value=1
our %inv_hosts_hash1_g=(); #key0=inv_host, key1=now/fin (generated by this script)/for_upd/for_del, key2=ifcfg_name
our %inv_hosts_ifcfg_del_not_configured_g=(); #for config '02_config_del_not_configured_ifcfg'. Key=inv_host
our %inv_hosts_dns_g=(); #key=inv_host/common, value=[array of nameservers]
our %inv_hosts_tmp_apply_cfg_g=(); #key=inv_host/common, value=rollback_ifcfg_timeout
###
our %inv_hosts_network_data_g=();
#read 'ip_link_noqueue' first
#v1) key0='hwaddr_all', key1=hwaddr, value=inv_host
#v2) key0='inv_host', key1=inv_host, key2=interface_name, key3=hwaddr
###
our %inventory_hosts_g=(); #Key=inventory_host, value=1
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
    
    $exec_res_g=&read_main_config($conf_file_g,\%inv_hosts_network_data_g,\%cfg0_hash_g);
    #$file_l,$inv_hosts_network_data_href_l,$res_href_l
    if ( $exec_res_g=~/^fail/ ) {
	$exec_status_g='FAIL';
	print "$exec_res_g\n";
	last;
    }
    $exec_res_g=undef;
    #print Dumper(\%cfg0_hash_g);
    
    ######
    
    $exec_res_g=&recreate_ifcfg_tmplt_based_on_cfg0_hash($dyn_ifcfg_common_dir_g,$ifcfg_tmplt_dir_g,\%cfg0_hash_g,\%conf_type_sub_refs_g,\%inv_hosts_hash0_g);
    #$dyn_ifcfg_common_dir_l,$ifcfg_tmplt_dir_l,$cfg0_hash_href_l,$conf_type_sub_refs_href_l,$res_inv_hosts_hash0_href_l
    if ( $exec_res_g=~/^fail/ ) {
	$exec_status_g='FAIL';
	print "$exec_res_g\n";
	last;
    }
    $exec_res_g=undef;
    
    ######
    
    if ( $gen_playbooks_next_g==1 ) { # if need to generate dynamic playbooks for ifcfg upd/del and resolv-conf-files at final    
	###READ conf file '01_dns_settings' and generate resolv-conf-files (begin)
	    #$dyn_resolv_common_dir_g=$self_dir_g.'/playbooks/dyn_ifcfg_playbooks/dyn_resolv_conf' -> files: 'inv_host_resolv' or 'common_resolv'
	    #%inv_hosts_dns_g=(); #key=inv_host/common, value=[array of nameservers]
	$exec_res_g=&generate_resolv_conf_files($conf_dns_g,$dyn_resolv_common_dir_g,\%inv_hosts_dns_g);
	#$conf_dns_l,$dyn_resolv_common_dir_l,$res_inv_hosts_dns_href_l
	if ( $exec_res_g=~/^fail/ ) {
	    $exec_status_g='FAIL';
	    print "$exec_res_g\n";
	    last;
	}
	$exec_res_g=undef;
	###READ conf file '01_dns_settings' and generate resolv-conf-files (end)
	
	###READ conf file '02_config_del_not_configured_ifcfg' (begin)
	#%inv_hosts_ifcfg_del_not_configured_g=(); #for config '02_config_del_not_configured_ifcfg'. Key=inv_host
	$exec_res_g=&read_config_del_not_configured_ifcfg($conf_file_del_not_configured_g,\%inv_hosts_ifcfg_del_not_configured_g);
	#$file_l,$res_href_l
	if ( $exec_res_g=~/^fail/ ) {
    	    $exec_status_g='FAIL';
    	    print "$exec_res_g\n";
	    last;
	}
	$exec_res_g=undef;
	###READ conf file '02_config_del_not_configured_ifcfg' (end)
	
	###READ conf file '03_config_temporary_apply_ifcfg' (begin)
	    #%inv_hosts_tmp_apply_cfg_g=(); #key=inv_host/common, value=rollback_ifcfg_timeout
	$exec_res_g=&read_config_temporary_apply_ifcfg($conf_temp_apply_g,\%inv_hosts_tmp_apply_cfg_g);
	#$file_l,$res_href_l
	if ( $exec_res_g=~/^fail/ ) {
    	    $exec_status_g='FAIL';
    	    print "$exec_res_g\n";
	    last;
	}
	$exec_res_g=undef;
	###READ conf file '03_config_temporary_apply_ifcfg' (end)
	
	###FILL %inv_hosts_hash1_g (begin)
	    #$dyn_ifcfg_common_dir/$inv_host = get inv_hosts + fin = get list of interfaces
	    #$ifcfg_backup_from_remote_dir/inv_host = get actual ifcfg-files
	    #%inv_hosts_hash0_g=(); #key=inv_host, value=1
	$exec_res_g=&fill_inv_hosts_hash1_with_fin_n_now_dirs($dyn_ifcfg_common_dir_g,$ifcfg_backup_from_remote_dir_g,\%inv_hosts_hash0_g,\%inv_hosts_hash1_g);
	#$dyn_ifcfg_common_dir_l,$ifcfg_backup_from_remote_dir_l,$inv_hosts_hash0_href_l,$res_href_l
	if ( $exec_res_g=~/^fail/ ) {
    	    $exec_status_g='FAIL';
    	    print "$exec_res_g\n";
	    last;
	}
	$exec_res_g=undef;
	###FILL %inv_hosts_hash1_g (end)
	
	###MODIFY %inv_hosts_hash1_g (begin)
	    #%inv_hosts_hash1_g=(); #key0=inv_host, key1=now/fin (generated by this script)/for_upd/for_del, key2=ifcfg_name
	    #$dyn_ifcfg_common_dir/$inv_host = get inv_hosts + fin = get list of interfaces
	    #$ifcfg_backup_from_remote_dir/inv_host = get actual ifcfg-files
	    #%inv_hosts_hash0_g=(); #key=inv_host, value=1
	$exec_res_g=&modify_inv_hosts_hash1($dyn_ifcfg_common_dir_g,$ifcfg_backup_from_remote_dir_g,$ifcfg_backup_from_remote_nd_file_g,\%inv_hosts_ifcfg_del_not_configured_g,\%inv_hosts_hash1_g);
	#$dyn_ifcfg_common_dir_l,$ifcfg_backup_from_remote_dir_l,$ifcfg_backup_from_remote_nd_file_l,$inv_hosts_ifcfg_del_not_configured_href_l,$res_href_l
	if ( $exec_res_g=~/^fail/ ) {
    	    $exec_status_g='FAIL';
    	    print "$exec_res_g\n";
	    last;
	}
	$exec_res_g=undef;
	###MODIFY %inv_hosts_hash1_g (end)
	
	###GENERATE dynamic playbooks (begin)
	$exec_res_g=&generate_dynamic_playbooks($dyn_ifcfg_playbooks_dir_g,$remote_dir_for_absible_helper_g,$gen_playbooks_next_with_rollback_g,\%inv_hosts_tmp_apply_cfg_g,\%inv_hosts_dns_g,\%inv_hosts_hash1_g);
	#$dyn_ifcfg_playbooks_dir_l,$remote_dir_for_absible_helper_l,$gen_playbooks_next_with_rollback_l,$inv_hosts_tmp_apply_cfg_href_l,$inv_hosts_dns_href_l,$inv_hosts_hash1_href_l
	if ( $exec_res_g=~/^fail/ ) {
    	    $exec_status_g='FAIL';
    	    print "$exec_res_g\n";
	    last;
	}
	$exec_res_g=undef;
	###GENERATE dynamic playbooks (end)
    }
    
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
