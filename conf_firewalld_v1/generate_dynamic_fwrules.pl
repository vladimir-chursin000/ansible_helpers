#!/usr/bin/perl

###SCRIPT for generate firewall rules for each inventory host

use strict;
use warnings;
use Cwd;
use Data::Dumper;
use Time::Local;

our ($self_dir_g,$script_name_g)=Cwd::abs_path($0)=~/(.*[\/\\])(\S+)$/;
$self_dir_g=~s/\/$//g;

###LOAD SUBROUTINES
our @do_arr_g=(
    'log_operations.pl',
    'file_operations.pl',
    'datetime.pl',
    'generate_conf.pl',
    'generate_shell_for_fwzones.pl',
    'generate_shell_for_ipsets.pl',
    'generate_shell_for_policies.pl',
    'generate_shell_for_rollback.pl',
    'read_00_conf_fwrules.pl',
    'read_01_conf_fwrules.pl',
    'read_02_1_conf_fwrules.pl',
    'read_02_2_conf_fwrules.pl',
    'read_02_3_conf_fwrules.pl',
    'read_02_4_conf_fwrules.pl',
    'read_02_conf_fwrules.pl',
    'read_03_conf_fwrules.pl',
    'read_04_conf_fwrules.pl',
    'read_05_conf_fwrules.pl',
    'read_65_conf_fwrules.pl',
    'read_66_conf_fwrules.pl',
    'read_77_conf_fwrules.pl',
    'read_88_conf_fwrules.pl',
    'read_conf_fwrules_common.pl',
    'read_conf_other.pl',
    'value_check.pl',
    'apply_IPSET_files_operation.pl'
);

foreach my $do_g ( @do_arr_g ) {
    do ($self_dir_g.'/perl_subs/'.$do_g);
    if ( $@ ) { die "'$do_g' error:$@"; }
}
###LOAD SUBROUTINES

############ARGV
our $with_rollback_g=0;

if ( defined($ARGV[0]) && length($ARGV[0])>0 && $ARGV[0]=~/^with_rollback$/ ) {
    $with_rollback_g=1;
}
############ARGV

############CFG file
#inventory_path
#00_conf_divisions_for_inv_hosts
#00_conf_firewalld
#01_conf_ipset_templates
#02_1_conf_allowed_services_sets
#02_2_conf_allowed_ports_sets
#02_3_conf_allowed_protocols_sets
#02_4_conf_icmp_blocks_sets
#02_conf_custom_firewall_zones_templates
#02_conf_standard_firewall_zones_templates
#03_conf_policy_templates
#04_conf_forward_ports_sets
#05_conf_rich_rules_sets
#66_conf_ipsets_FIN
#77_conf_zones_FIN
#88_conf_policies_FIN
###
our $inventory_conf_path_g=$self_dir_g.'/conf_firewall_hosts';
our $f00_conf_divisions_for_inv_hosts_path_g=$self_dir_g.'/01_fwrules_configs/00_conf_divisions_for_inv_hosts';
our $f00_conf_firewalld_path_g=$self_dir_g.'/01_fwrules_configs/00_conf_firewalld';
our $f01_conf_ipset_templates_path_g=$self_dir_g.'/01_fwrules_configs/01_conf_ipset_templates';
our $f02_1_conf_allowed_services_sets_path_g=$self_dir_g.'/01_fwrules_configs/02_1_conf_allowed_services_sets';
our $f02_2_conf_allowed_ports_sets_path_g=$self_dir_g.'/01_fwrules_configs/02_2_conf_allowed_ports_sets';
our $f02_3_conf_allowed_protocols_sets_path_g=$self_dir_g.'/01_fwrules_configs/02_3_conf_allowed_protocols_sets';
our $f02_4_conf_icmp_blocks_sets_path_g=$self_dir_g.'/01_fwrules_configs/02_4_conf_icmp_blocks_sets';
our $f02_conf_custom_firewall_zones_templates_path_g=$self_dir_g.'/01_fwrules_configs/02_conf_custom_firewall_zones_templates';
our $f02_conf_standard_firewall_zones_templates_path_g=$self_dir_g.'/01_fwrules_configs/02_conf_standard_firewall_zones_templates';
our $f03_conf_policy_templates_path_g=$self_dir_g.'/01_fwrules_configs/03_conf_policy_templates';
our $f04_conf_forward_ports_sets_path_g=$self_dir_g.'/01_fwrules_configs/04_conf_forward_ports_sets';
our $f05_conf_rich_rules_sets_path_g=$self_dir_g.'/01_fwrules_configs/05_conf_rich_rules_sets';
our $f65_conf_initial_ipsets_content_FIN_path_g=$self_dir_g.'/01_fwrules_configs/65_conf_initial_ipsets_content_FIN';
our $f66_conf_ipsets_FIN_path_g=$self_dir_g.'/01_fwrules_configs/66_conf_ipsets_FIN';
our $f77_conf_zones_FIN_path_g=$self_dir_g.'/01_fwrules_configs/77_conf_zones_FIN';
our $f88_conf_policies_FIN_path_g=$self_dir_g.'/01_fwrules_configs/88_conf_policies_FIN';
###
our $ifcfg_backup_from_remote_nd_file_g=$self_dir_g.'/playbooks/fwrules_backup_from_remote/network_data/inv_hosts_interfaces_info.txt'; # dir contains actual network_data (eth) downloaded from remote hosts with help of playbook 'fwrules_backup_playbook.yml' before run this script
############CFG file

############STATIC VARS
our $remote_dir_for_absible_helper_g='$HOME/ansible_helpers/conf_firewalld'; # dir for creating/manipulate files at remote side
our $scripts_for_remote_dir_g=$self_dir_g.'/playbooks/scripts_for_remote';
our $dyn_fwrules_files_dir_g=$scripts_for_remote_dir_g.'/fwrules_files'; # dir for recreate shell-scripts for executing it at remote side (if need)

#for IPSET_files_operation.pl (sub=apply_IPSET_files_operation_main)
our $ipset_input_dir_g=$self_dir_g.'/02_ipset_input';
our $ipset_actual_data_dir_g=$self_dir_g.'/03_ipset_actual_data';
###
############STATIC VARS

############VARS
######
our %inventory_hosts_g=(); # for checks of h00_conf_firewalld_hash_g/h66_conf_ipsets_FIN_hash_g/h77_conf_zones_FIN_hash_g/h88_conf_policies_FIN_hash_g 
# and operate with 'all' (apply for all inv hosts) options
###
#Key=inventory_host, value=1
######

######
our %inv_hosts_network_data_g=();
#INV_HOST       #INT_NAME       #IPADDR
###
#$inv_hosts_network_data_g{inv_host}{int_name}=ipaddr
######

######
our %h00_conf_divisions_for_inv_hosts_hash_g=();
#DIVISION_NAME/GROUP_NAME       #LIST_OF_HOSTS
###
#$h00_conf_divisions_for_inv_hosts_hash_g{group_name}{inv-host}=1;
######

######
our %h00_conf_firewalld_hash_g=();
#[firewall_conf_for_all--TMPLT:BEGIN]
#host_list_for_apply=all
#unconfigured_custom_firewall_zones_action=no_action
#temporary_apply_fwrules_timeout=10
#if_no_ipsets_conf_action=no_action
#if_no_zones_conf_action=no_action
#if_no_policies_conf_action=no_action
#DefaultZone=public
#CleanupOnExit=yes
#CleanupModulesOnExit=yes
#Lockdown=no
#IPv6_rpfilter=yes
#IndividualCalls=no
#LogDenied=off
#enable_logging_of_dropped_packets=no
#FirewallBackend=nftables
#FlushAllOnReload=yes
#RFC3964_IPv4=yes
#AllowZoneDrifting=no
#[firewall_conf_for_all--TMPLT:END]
###
#$h00_conf_firewalld_hash_g{inventory_host}->
#{'unconfigured_custom_firewall_zones_action'}=no_action|remove
#{'temporary_apply_fwrules_timeout'}=NUM
#{'if_no_ipsets_conf_action'}=remove|no_action
#{'if_no_zones_conf_action'}=restore_defaults|no_action
#{'if_no_policies_conf_action'}=remove|no_action
#{'DefaultZone'}=name_of_default_zone
#{'CleanupOnExit'}=yes|no
#{'CleanupModulesOnExit'}=yes|no
#{'Lockdown'}=yes|no
#{'IPv6_rpfilter'}=yes|no
#{'IndividualCalls'}=yes|no
#{'LogDenied'}=all|unicast|broadcast|multicast|off
#{'enable_logging_of_dropped_packets'}=yes|no
#{'FirewallBackend'}=nftables|iptables
#{'FlushAllOnReload'}=yes|no
#{'RFC3964_IPv4'}=yes|no
#{'AllowZoneDrifting'}=yes|no
######

######
our %h01_conf_ipset_templates_hash_g=();
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
######

######
our %h02_1_conf_allowed_services_sets_hash_g=();
#[serv_set1:BEGIN]
#all=http,https
#gr_some_example_group=http,https,ssh
#192.168.144.12,192.168.100.14,192.110.144.16=http,https,ssh,dns
#192.168.144.12=samba
#[serv_set1:END]
###
#$h02_1_conf_allowed_services_sets_hash_g{set-name}{inv-host}->
    #{'serv-0'}=1
    #{'serv-1'}=1
    #etc
    #{'seq'}=[val-0,val-1] (val=serv)
######

######
our %h02_2_conf_allowed_ports_sets_hash_g=();
#[ports_set1:BEGIN]
#all=1122/tcp,1133/udp
#gr_some_example_group=1122/tcp,1133/tcp,1133/udp
#192.168.144.12,192.168.100.14,192.110.144.16=11221/tcp,11331/udp
#192.168.144.12=11222-11333/tcp
#[ports_set1:END]
###
#$h02_2_conf_allowed_ports_sets_hash_g{set-name}{inv-host}->
    #{'port-0'}=1
    #{'port-1'}=1
    #etc
    #{'seq'}=[val-0,val-1] (val=port)
######

######
our %h02_3_conf_allowed_protocols_sets_hash_g=();
#[protocols_set1:BEGIN]
#all=tcp,udp
#gr_some_example_group=tcp,udp,gre
#192.168.144.12,192.168.100.14,192.110.144.16=tcp,udp,gre,dccp
#192.168.144.12=tcp
#[protocols_set1:END]
###
#$h02_3_conf_allowed_protocols_sets_hash_g{set-name}{inv-host}->
    #{'proto-0'}=1
    #{'proto-1'}=1
    #etc
    #{'seq'}=[val-0,val-1] (val=proto)
######

######
our %h02_4_conf_icmp_blocks_sets_hash_g=();
#[icmp_blocks_set1:BEGIN]
#NO:all=address-unreachable,bad-header
#NO:gr_some_example_group=address-unreachable,bad-header,beyond-scope
#NO:192.168.144.12,192.168.100.14,192.110.144.16=address-unreachable,bad-header,beyond-scope,communication-prohibited
#YES:192.168.144.12=address-unreachable
#[icmp_blocks_set1:END]
###
#$h02_4_conf_icmp_blocks_sets_hash_g{set-name}{inv-host}->
    #{'icmp_block-0'}=1
    #{'icmp_block-1'}=1
    #etc
    #{'seq'}=[val-0,val-1] (val=icmp_block)
    #{'inversion'}=yes/no
######

######
our %h02_conf_custom_firewall_zones_templates_hash_g=();
#[some_zone--TMPLT:BEGIN]
#zone_name=some_zone--custom
#zone_description=
#zone_short_description=
#zone_target=
#zone_allowed_services=
#zone_allowed_ports=
#zone_allowed_protocols=
#zone_forward=
#zone_masquerade_general=
#zone_allowed_source_ports=
#zone_icmp_block_inversion=
#zone_icmp_block=
#[some_zone--TMPLT:END]
###
#$h02_conf_custom_firewall_zones_templates_hash_g{zone_teplate_name--TMPLT}->
#{'zone_name'}=some_zone--custom
#{'zone_description'}=empty|value
#{'zone_short_description'}=empty|value
#{'zone_target'}=ACCEPT|REJECT|DROP|default
#{'zone_allowed_services'}->
    #{'empty'}=1 or
    #{'list'}->
	#{'service-0'}=1
	#{'service-1'}=1
	#etc
    #{'seq'}=[val-0,val-1] (val=service)
#{'zone_allowed_ports'}->
    #{'empty'}=1 or
    #{'list'}->
	#{'port-0'}=1
	#{'port-1'}=1
	#etc
    #{'seq'}=[val-0,val-1] (val=port)
#{'zone_allowed_protocols'}->
    #{'empty'}=1 or
    #{'list'}->
	#{'proto-0'}=1
	#{'proto-1'}=1
	#etc
    #{'seq'}=[val-0,val-1] (val=proto)
#{'zone_forward'}=yes|no
#{'zone_masquerade_general'}=yes|no
#{'zone_allowed_source_ports'}->
    #{'empty'}=1 or
    #{'list'}->
	#{'port-0'}=1
	#{'port-1'}=1
	#etc
    #{'seq'}=[val-0,val-1] (val=port)
#{'zone_icmp_block_inversion'}=yes|no
#{'zone_icmp_block'}->
    #{'empty'}=1 or
    #{'list'}->
	#{'icmptype-0'}=1
	#{'icmptype-1'}=1
	#etc
    #{'seq'}=[val-0,val-1] (val=icmptype)
######

######
our %h02_conf_standard_firewall_zones_templates_hash_g=();
#[public--TMPLT:BEGIN]
#zone_name=public
#zone_target=default
#zone_allowed_services=cockpit,dhcpv6-client,ssh
#zone_allowed_ports=empty
#zone_allowed_protocols=empty
#zone_forward=no
#zone_masquerade_general=no
#zone_allowed_source_ports=empty
#zone_icmp_block_inversion=no
#zone_icmp_block=empty
#[public--TMPLT:END]
###
#$h02_conf_standard_firewall_zones_templates_hash_g{zone_teplate_name--TMPLT}->
#{'zone_name'}=std_zone_name
#{'zone_target'}=ACCEPT|REJECT|DROP|default
#{'zone_allowed_services'}->
    #{'empty'}=1 or
    #{'list'}->
	#{'service-0'}=1
	#{'service-1'}=1
	#etc
    #{'seq'}=[val-0,val-1] (val=service)
#{'zone_allowed_ports'}->
    #{'empty'}=1 or
    #{'list'}->
	#{'port-0'}=1
	#{'port-1'}=1
	#etc
    #{'seq'}=[val-0,val-1] (val=proto)
#{'zone_allowed_protocols'}->
    #{'empty'}=1 or
    #{'list'}->
	#{'proto-0'}=1
	#{'proto-1'}=1
	#etc
    #{'seq'}=[val-0,val-1] (val=proto)
#{'zone_forward'}=yes|no
#{'zone_masquerade_general'}=yes|no
#{'zone_allowed_source_ports'}->
    #{'empty'}=1 or
    #{'list'}->
	#{'port-0'}=1
	#{'port-1'}=1
	#etc
    #{'seq'}=[val-0,val-1] (val=port)
#{'zone_icmp_block_inversion'}=yes|no
#{'zone_icmp_block'}->
    #{'empty'}=1 or
    #{'list'}->
	#{'icmptype-0'}=1
	#{'icmptype-1'}=1
	#etc
    #{'seq'}=[val-0,val-1] (val=icmptype)
######

######
our %h03_conf_policy_templates_hash_g=();
#[some_policy--TMPLT:BEGIN]
#policy_name=some_policy_name
#policy_description=empty
#policy_short_description=empty
#policy_target=CONTINUE
#policy_priority=-1
#policy_allowed_services=empty
#policy_allowed_ports=empty
#policy_allowed_protocols=empty
#policy_masquerade_general=no
#policy_allowed_source_ports=empty
#policy_icmp_block=empty
#[some_policy--TMPLT:END]
###
#$h03_conf_policy_templates_hash_g{policy_tmplt_name--TMPLT}->
#{'policy_name'}=value
#{'policy_description'}=empty|value
#{'policy_short_description'}=empty|value
#{'policy_target'}=ACCEPT|REJECT|DROP|CONTINUE
#{'policy_priority'}=num (+/-)
#{'policy_allowed_services'}->
    #{'empty'}=1 or
    #{'list'}->
	#{'service-0'}=1
	#{'service-1'}=1
	#etc
    #{'seq'}=[val-0,val-1] (val=service)
#{'policy_allowed_ports'}->
    #{'empty'}=1 or
    #{'list'}->
	#{'port-0'}=1
	#{'port-1'}=1
	#etc
    #{'seq'}=[val-0,val-1] (val=port)
#{'policy_allowed_protocols'}->
    #{'empty'}=1 or
    #{'list'}->
	#{'proto-0'}=1
	#{'proto-1'}=1
	#etc
    #{'seq'}=[val-0,val-1] (val=proto)
#{'policy_masquerade_general'}=yes|no
#{'policy_allowed_source_ports'}->
    #{'empty'}=1 or
    #{'list'}->
	#{'port-0'}=1
	#{'port-1'}=1
	#etc
    #{'seq'}=[val-0,val-1] (val=port)
#{'policy_icmp_block'}->
    #{'empty'}=1 or
    #{'list'}->
	#{'icmptype-0'}=1
	#{'icmptype-1'}=1
	#etc
    #{'seq'}=[val-0,val-1] (val=icmptype)
######

######
our %h04_conf_forward_ports_sets_hash_g=();
#[some_forward_ports_set_name:BEGIN]
##INVENTORY_HOST                #fw_port        #fw_proto       #fw_toport      #fw_toaddr
#all                    80              tcp             8080            192.168.1.60 (example, prio = 0)
#gr_some_example_group  80              tcp             8080            192.168.1.60 (example, prio = 1)
#10.1.2.2,10.1.2.4      80              tcp             8080            192.168.1.60 (example, prio = 2)
#10.1.2.2               80              tcp             8080            192.168.1.60 (example, prio => 2)
#[some_forward_ports_set_name:END]
###
#$h04_conf_forward_ports_sets_hash_g{inv-host}{set_name}->
    #{'rule-0'}=1 #rule like 'port=80:proto=tcp:toport=8080:toaddr=192.168.1.60'
    #{'rule-1'}=1
    #etc
    #{'seq'}=[val-0,val-1] (val=rule)
######

######
our %h05_conf_rich_rules_sets_hash_g=();
#[some_rich_rules_set_name:BEGIN]
##INVENTORY_HOST                #RICH_RULE
#all                    "some_rich_rule_N1-content" (example, prio = 0)
#gr_some_example_group  "some_rich_rule_N1-content" (example, prio = 1)
#10.1.2.2,10.1.2.4      "some_rich_rule_N1-content" (example, prio = 2)
#10.1.2.2               "some_rich_rule_N1-content" (example, prio => 2)
#[some_rich_rules_set_name:END]
###
#$h05_conf_rich_rules_sets_hash_g{inv-host}{set_name}->
    #{'rule-0'}=1
    #{'rule-1'}=1
    #etc
    #{'seq'}=[val-0,val-1] (val=rule)
######

######
our %h65_conf_initial_ipsets_content_FIN_hash_g=();
# This CFG only for permanent ipset templates (if "#ipset_create_option_timeout=0").
#[IPSET_TEMPLATE_NAME:BEGIN]
# one row = "all/group_name/list_of_hosts/host=ipset_entry0,ipset_entry1,ipset_entry2,ipset_entryN"
    # If "all" -> the configuration will be applied to all inventory hosts.
    # Priority (from lower to higher): all (0), group name from conf '00_conf_divisions_for_inv_hosts' (1), list of inventory hosts separated by "," or individual hosts (2).
    # ipset_entries -> accoring to "#ipset_type" of conf file "01_conf_ipset_templates"
#[IPSET_TEMPLATE_NAME:END]
###
#$h65_conf_initial_ipsets_content_FIN_hash_g{inv-host}{ipset_template_name}->
    #{'record-0'}=1 (record=ipset_entry)
    #{'rerord-1'}=1
    #etc
    #{'seq'}=[val-0,val-1] (val=record)
######

######
our %h66_conf_ipsets_FIN_hash_g=();
#INVENTORY_HOST         #IPSET_NAME_TMPLT_LIST
#all                    ipset1--TMPLT,ipset4all_public--TMPLT (example)
#10.3.2.2               ipset4public--TMPLT (example)
###
#$h66_conf_ipsets_FIN_hash_g{'temporary/permanent'}{inventory_host}->
    #{ipset_name_tmplt-0}=1;
    #{ipset_name_tmplt-1}=1;
    #etc
######

######
our %h77_conf_zones_FIN_hash_g=();
#INVENTORY_HOST         #FIREWALL_ZONE_NAME_TMPLT       #INTERFACE_LIST   #SOURCE_LIST      	#IPSET_TMPLT_LIST			#FORWARD_PORTS_SET      #RICH_RULES_SET
#all                    public--TMPLT                   ens1,ens2,ens3    10.10.16.0/24		ipset:ipset4all_public--TMPLT   	empty                   empty (example)
#10.3.2.2               public--TMPLT                   empty             10.10.15.0/24		ipset:ipset4public--TMPLT       	fw_ports_set4public     rich_rules_set4public (example)
#10.1.2.3,10.1.2.4      zone1--TMPLT                    eth0,eth1,ens01   empty                 empty                        		fw_ports_set4zone1      rich_rules_set4zone1 (example)
###
#$h77_conf_zones_FIN_hash_g{'custom/standard'}{inventory_host}{firewall_zone_name_tmplt}->
#{'interface_list'}->;
    #{'empty'}=1
    #{'list'}->
	#{'interface-0'}=1
	#{'interface-1'}=1
	#etc
    #{'seq'}=[val-0,val-1] (val=interface)
#{'source_list'}->
    #{'empty'}=1
    #{'list'}->
	#{'source-0'}=1
	#{'source-1'}=1
	#etc
    #{'seq'}=[val-0,val-1] (val=source)
#{'ipset_tmplt_list'}->
    #{'epmty'}=1
    #{'list'}->
	#{'ipset_tmplt-0'}=1
	#{'ipset_tmplt-1'}=1
	#etc
    #{'seq'}=[val-0,val-1] (val=ipset_tmplt)
#{'forward_ports_set'}=empty|fw_ports_set (FROM '04_conf_forward_ports_sets')
#{'rich_rules_set'}=empty|rich_rules_set (FROM '05_conf_rich_rules_sets')

# ADDING not directly via '77_conf_zones_FIN' (see 'read_77_conf_fwrules.pl')
#{'allowed_services_set'}=[serv1,serv2,etc] (from '02_1_conf_allowed_services_sets')
#{'allowed_ports_set'}=[port1,port2,etc] (from '02_2_conf_allowed_ports_sets')
#{'allowed_source_ports_set'}=[port1,port2,etc] (from '02_2_conf_allowed_ports_sets')
#{'allowed_protocols_set'}=[proto1,proto2,etc] (from '02_3_conf_allowed_protocols_sets')
            
#{'icmp_blocks_set'}=[icmp-block1,icmp-block2,etc] (from '02_4_conf_icmp_blocks_sets')
#{'icmp_blocks_inversion'}=yes/no (from '02_4_conf_icmp_blocks_sets')
######

######
our %h88_conf_policies_FIN_hash_g=();
#INVENTORY_HOST         #POLICY_NAME_TMPLT           	#INGRESS-FIREWALL_ZONE_NAME_TMPLT    	#EGRESS-FIREWALL_ZONE_NAME_TMPLT     	#FORWARD_PORTS_SET      #RICH_RULES_SET
#all                    policy_public2home--TMPLT       public--TMPLT                           home--TMPLT                             fw_ports_set1           rich_rules_set1 (example)
#10.3.2.2               policy_zoneone2zonetwo--TMPLT   zoneone--TMPLT                          zonetwo--TMPLT                          fw_ports_set2           rich_rules_set2 (example)
###
#$h88_conf_policies_FIN_hash_g{inventory_host}{policy_name_tmplt}->
#{'ingress-firewall_zone_name_tmplt'}=value
#{'egress-firewall_zone_name_tmplt'}=value
#{'forward_ports_set'}=empty|fw_ports_set (FROM '04_conf_forward_ports_sets')
#{'rich_rules_set'}=empty|rich_rules_set (FROM '05_conf_rich_rules_sets')

# ADDING not directly via '88_conf_policies_FIN' (see 'read_88_conf_fwrules.pl')
#{'allowed_services_set'}=[serv1,serv2,etc] (from '02_1_conf_allowed_services_sets')
#{'allowed_ports_set'}=[port1,port2,etc] (from '02_2_conf_allowed_ports_sets')
#{'allowed_source_ports_set'}=[port1,port2,etc] (from '02_2_conf_allowed_ports_sets')
#{'allowed_protocols_set'}=[proto1,proto2,etc] (from '02_3_conf_allowed_protocols_sets')        
#{'icmp_blocks_set'}=[icmp-block1,icmp-block2,etc] (from '02_4_conf_icmp_blocks_sets')
######

our ($exec_res_g,$exec_status_g)=(undef,'OK');

our %input_hash4proc_g=();
#hash with hash refs for input
############VARS

############MAIN SEQ
while ( 1 ) { # ONE RUN CYCLE begin
    ######
    
    &init_files_ops_with_local_dyn_fwrules_files_dir($dyn_fwrules_files_dir_g);
    #$dyn_fwrules_files_dir_l
    
    ######

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
    
    $exec_res_g=&read_00_conf_firewalld($f00_conf_firewalld_path_g,\%inventory_hosts_g,\%h00_conf_divisions_for_inv_hosts_hash_g,\%h00_conf_firewalld_hash_g);
    #$file_l,$inv_hosts_href_l,$divisions_for_inv_hosts_href_l,$res_href_l
    if ( $exec_res_g=~/^fail/ ) {
	$exec_status_g='FAIL';
	print "$exec_res_g\n";
	last;
    }
    $exec_res_g=undef;
    #print Dumper(\%h00_conf_firewalld_hash_g);
    
    ######
    
    $exec_res_g=&read_01_conf_ipset_templates($f01_conf_ipset_templates_path_g,\%h01_conf_ipset_templates_hash_g);
    #$file_l,$res_href_l
    if ( $exec_res_g=~/^fail/ ) {
	$exec_status_g='FAIL';
	print "$exec_res_g\n";
	last;
    }
    $exec_res_g=undef;
    #print Dumper(\%h01_conf_ipset_templates_hash_g);
    
    ######
    
    $exec_res_g=&read_02_1_conf_allowed_services_sets($f02_1_conf_allowed_services_sets_path_g,\%inventory_hosts_g,\%h00_conf_divisions_for_inv_hosts_hash_g,\%h02_1_conf_allowed_services_sets_hash_g);
    #$file_l,$inv_hosts_href_l,$divisions_for_inv_hosts_href_l,$res_href_l
    if ( $exec_res_g=~/^fail/ ) {
    	$exec_status_g='FAIL';
    	print "$exec_res_g\n";
    	last;
    }
    $exec_res_g=undef;
    #print Dumper(\%h02_1_conf_allowed_services_sets_hash_g);
    
    ######
    
    $exec_res_g=&read_02_2_conf_allowed_ports_sets($f02_2_conf_allowed_ports_sets_path_g,\%inventory_hosts_g,\%h00_conf_divisions_for_inv_hosts_hash_g,\%h02_2_conf_allowed_ports_sets_hash_g);
    #$file_l,$inv_hosts_href_l,$divisions_for_inv_hosts_href_l,$res_href_l
    if ( $exec_res_g=~/^fail/ ) {
    	$exec_status_g='FAIL';
    	print "$exec_res_g\n";
    	last;
    }
    $exec_res_g=undef;
    #print Dumper(\%h02_2_conf_allowed_ports_sets_hash_g);
    
    ######
    
    $exec_res_g=&read_02_3_conf_allowed_protocols_sets($f02_3_conf_allowed_protocols_sets_path_g,\%inventory_hosts_g,\%h00_conf_divisions_for_inv_hosts_hash_g,\%h02_3_conf_allowed_protocols_sets_hash_g);
    #$file_l,$inv_hosts_href_l,$divisions_for_inv_hosts_href_l,$res_href_l
    if ( $exec_res_g=~/^fail/ ) {
    	$exec_status_g='FAIL';
    	print "$exec_res_g\n";
    	last;
    }
    $exec_res_g=undef;
    #print Dumper(\%h02_3_conf_allowed_protocols_sets_hash_g);    
    
    ######
    
    $exec_res_g=&read_02_4_conf_icmp_blocks_sets($f02_4_conf_icmp_blocks_sets_path_g,\%inventory_hosts_g,\%h00_conf_divisions_for_inv_hosts_hash_g,\%h02_4_conf_icmp_blocks_sets_hash_g);
    #$file_l,$inv_hosts_href_l,$divisions_for_inv_hosts_href_l,$res_href_l
    if ( $exec_res_g=~/^fail/ ) {
    	$exec_status_g='FAIL';
    	print "$exec_res_g\n";
    	last;
    }
    $exec_res_g=undef;
    #print Dumper(\%h02_4_conf_icmp_blocks_sets_hash_g);
    
    ######
    
    %input_hash4proc_g=(
    	'h02_1_conf_allowed_services_sets_href'=>\%h02_1_conf_allowed_services_sets_hash_g,
    	'h02_2_conf_allowed_ports_sets_href'=>\%h02_2_conf_allowed_ports_sets_hash_g,
	'h02_3_conf_allowed_protocols_sets_href'=>\%h02_3_conf_allowed_protocols_sets_hash_g,
    	'h02_4_conf_icmp_blocks_sets_href'=>\%h02_4_conf_icmp_blocks_sets_hash_g,
    );
    $exec_res_g=&read_02_conf_custom_firewall_zones_templates($f02_conf_custom_firewall_zones_templates_path_g,\%input_hash4proc_g,\%h02_conf_custom_firewall_zones_templates_hash_g);
    #$file_l,$input_hash4proc_href_l,$res_href_l
    if ( $exec_res_g=~/^fail/ ) {
	$exec_status_g='FAIL';
	print "$exec_res_g\n";
	last;
    }
    $exec_res_g=undef;
    %input_hash4proc_g=();
    #print Dumper(\%h02_conf_custom_firewall_zones_templates_hash_g);
    
    ######
    
    %input_hash4proc_g=(
    	'h02_1_conf_allowed_services_sets_href'=>\%h02_1_conf_allowed_services_sets_hash_g,
    	'h02_2_conf_allowed_ports_sets_href'=>\%h02_2_conf_allowed_ports_sets_hash_g,
    	'h02_3_conf_allowed_protocols_sets_href'=>\%h02_3_conf_allowed_protocols_sets_hash_g,
    	'h02_4_conf_icmp_blocks_sets_href'=>\%h02_4_conf_icmp_blocks_sets_hash_g,
    );
    $exec_res_g=&read_02_conf_standard_firewall_zones_templates($f02_conf_standard_firewall_zones_templates_path_g,\%input_hash4proc_g,\%h02_conf_standard_firewall_zones_templates_hash_g);
    #$file_l,$input_hash4proc_href_l,$res_href_l
    if ( $exec_res_g=~/^fail/ ) {
	$exec_status_g='FAIL';
	print "$exec_res_g\n";
	last;
    }
    $exec_res_g=undef;
    %input_hash4proc_g=();
    #print Dumper(\%h02_conf_standard_firewall_zones_templates_hash_g);
    
    ######
    
    %input_hash4proc_g=(
    	'h02_1_conf_allowed_services_sets_href'=>\%h02_1_conf_allowed_services_sets_hash_g,
    	'h02_2_conf_allowed_ports_sets_href'=>\%h02_2_conf_allowed_ports_sets_hash_g,
    	'h02_3_conf_allowed_protocols_sets_href'=>\%h02_3_conf_allowed_protocols_sets_hash_g,
    	'h02_4_conf_icmp_blocks_sets_href'=>\%h02_4_conf_icmp_blocks_sets_hash_g,
    );
    $exec_res_g=&read_03_conf_policy_templates($f03_conf_policy_templates_path_g,\%input_hash4proc_g,\%h03_conf_policy_templates_hash_g);
    #$file_l,$input_hash4proc_href_l,$res_href_l
    if ( $exec_res_g=~/^fail/ ) {
	$exec_status_g='FAIL';
	print "$exec_res_g\n";
	last;
    }
    $exec_res_g=undef;
    %input_hash4proc_g=();
    #print Dumper(\%h03_conf_policy_templates_hash_g);
    
    ######
    
    $exec_res_g=&read_04_conf_forward_ports_sets_v2($f04_conf_forward_ports_sets_path_g,\%inventory_hosts_g,\%h00_conf_divisions_for_inv_hosts_hash_g,\%h04_conf_forward_ports_sets_hash_g);
    #$file_l,$inv_hosts_href_l,$divisions_for_inv_hosts_href_l,$res_href_l
    if ( $exec_res_g=~/^fail/ ) {
	$exec_status_g='FAIL';
	print "$exec_res_g\n";
	last;
    }
    $exec_res_g=undef;
    #print Dumper(\%h04_conf_forward_ports_sets_hash_g);
    
    ######
    
    $exec_res_g=&read_05_conf_rich_rules_sets_v2($f05_conf_rich_rules_sets_path_g,\%inventory_hosts_g,\%h00_conf_divisions_for_inv_hosts_hash_g,\%h01_conf_ipset_templates_hash_g,\%h05_conf_rich_rules_sets_hash_g);
    #$file_l,$inv_hosts_href_l,$divisions_for_inv_hosts_href_l,$ipset_templates_href_l,$res_href_l
    if ( $exec_res_g=~/^fail/ ) {
	$exec_status_g='FAIL';
	print "$exec_res_g\n";
	last;
    }
    $exec_res_g=undef;
    #print Dumper(\%h05_conf_rich_rules_sets_hash_g);
    
    ######

    $exec_res_g=&read_65_conf_initial_ipsets_content_FIN_v2($f65_conf_initial_ipsets_content_FIN_path_g,\%inventory_hosts_g,\%h00_conf_divisions_for_inv_hosts_hash_g,\%h01_conf_ipset_templates_hash_g,\%h65_conf_initial_ipsets_content_FIN_hash_g);
    #$file_l,$inv_hosts_href_l,$divisions_for_inv_hosts_href_l,$ipset_templates_href_l,$res_href_l
    if ( $exec_res_g=~/^fail/ ) {
	$exec_status_g='FAIL';
	print "$exec_res_g\n";
	last;
    }
    $exec_res_g=undef;
    #print Dumper(\%h65_conf_initial_ipsets_content_FIN_hash_g);
    
    ######
    
    $exec_res_g=&read_66_conf_ipsets_FIN_v2($f66_conf_ipsets_FIN_path_g,\%inventory_hosts_g,\%h00_conf_divisions_for_inv_hosts_hash_g,\%h01_conf_ipset_templates_hash_g,\%h66_conf_ipsets_FIN_hash_g);
    #$file_l,$inv_hosts_href_l,$divisions_for_inv_hosts_href_l,$ipset_templates_href_l,$res_href_l
    if ( $exec_res_g=~/^fail/ ) {
	$exec_status_g='FAIL';
	print "$exec_res_g\n";
	last;
    }
    $exec_res_g=undef;
    #print Dumper(\%h66_conf_ipsets_FIN_hash_g);
    
    ######
    
    %input_hash4proc_g=(
	'inventory_hosts_href'=>\%inventory_hosts_g,
	'inv_hosts_network_data_href'=>\%inv_hosts_network_data_g,
	'divisions_for_inv_hosts_href'=>\%h00_conf_divisions_for_inv_hosts_hash_g,
	'h01_conf_ipset_templates_href'=>\%h01_conf_ipset_templates_hash_g,
	###
    	'h02_1_conf_allowed_services_sets_href'=>\%h02_1_conf_allowed_services_sets_hash_g,
    	'h02_2_conf_allowed_ports_sets_href'=>\%h02_2_conf_allowed_ports_sets_hash_g,
	'h02_3_conf_allowed_protocols_sets_href'=>\%h02_3_conf_allowed_protocols_sets_hash_g,
    	'h02_4_conf_icmp_blocks_sets_href'=>\%h02_4_conf_icmp_blocks_sets_hash_g,
	###
	'h02_conf_custom_firewall_zones_templates_href'=>\%h02_conf_custom_firewall_zones_templates_hash_g,
	'h02_conf_standard_firewall_zones_templates_href'=>\%h02_conf_standard_firewall_zones_templates_hash_g,
	'h04_conf_forward_ports_sets_href'=>\%h04_conf_forward_ports_sets_hash_g,
	'h05_conf_rich_rules_sets_href'=>\%h05_conf_rich_rules_sets_hash_g,
	'h66_conf_ipsets_FIN_href'=>\%h66_conf_ipsets_FIN_hash_g,
    );
    $exec_res_g=&read_77_conf_zones_FIN_v2($f77_conf_zones_FIN_path_g,\%input_hash4proc_g,\%h77_conf_zones_FIN_hash_g);
    #$file_l,$input_hash4proc_href_l,$res_href_l
    if ( $exec_res_g=~/^fail/ ) {
	$exec_status_g='FAIL';
	print "$exec_res_g\n";
	last;
    }
    $exec_res_g=undef;
    %input_hash4proc_g=();
    #print Dumper(\%h77_conf_zones_FIN_hash_g);
    
    ######

    %input_hash4proc_g=(
	'inventory_hosts_href'=>\%inventory_hosts_g,
	'divisions_for_inv_hosts_href'=>\%h00_conf_divisions_for_inv_hosts_hash_g,
	###
    	'h02_1_conf_allowed_services_sets_href'=>\%h02_1_conf_allowed_services_sets_hash_g,
    	'h02_2_conf_allowed_ports_sets_href'=>\%h02_2_conf_allowed_ports_sets_hash_g,
	'h02_3_conf_allowed_protocols_sets_href'=>\%h02_3_conf_allowed_protocols_sets_hash_g,
    	'h02_4_conf_icmp_blocks_sets_href'=>\%h02_4_conf_icmp_blocks_sets_hash_g,
	###
	'h02_conf_custom_firewall_zones_templates_href'=>\%h02_conf_custom_firewall_zones_templates_hash_g,
	'h02_conf_standard_firewall_zones_templates_href'=>\%h02_conf_standard_firewall_zones_templates_hash_g,
	'h03_conf_policy_templates_href'=>\%h03_conf_policy_templates_hash_g,
	'h04_conf_forward_ports_sets_href'=>\%h04_conf_forward_ports_sets_hash_g,
	'h05_conf_rich_rules_sets_href'=>\%h05_conf_rich_rules_sets_hash_g,
	'h77_conf_zones_FIN_href'=>\%h77_conf_zones_FIN_hash_g,
    );
    $exec_res_g=&read_88_conf_policies_FIN_v2($f88_conf_policies_FIN_path_g,\%input_hash4proc_g,\%h88_conf_policies_FIN_hash_g);
    #$file_l,$input_hash4proc_href_l,$res_href_l
    if ( $exec_res_g=~/^fail/ ) {
        $exec_status_g='FAIL';
        print "$exec_res_g\n";
        last;
    }
    $exec_res_g=undef;
    %input_hash4proc_g=();
    #print Dumper(\%h88_conf_policies_FIN_hash_g);
    
    ######
    
    %input_hash4proc_g=(
        'inventory_hosts_href'=>\%inventory_hosts_g,
        'divisions_for_inv_hosts_href'=>\%h00_conf_divisions_for_inv_hosts_hash_g,
        'h01_conf_ipset_templates_href'=>\%h01_conf_ipset_templates_hash_g,
        'h65_conf_initial_ipsets_content_FIN_href'=>\%h65_conf_initial_ipsets_content_FIN_hash_g,
        'h66_conf_ipsets_FIN_href'=>\%h66_conf_ipsets_FIN_hash_g,
    );

    $exec_res_g=&apply_IPSET_files_operation_main($ipset_input_dir_g,$ipset_actual_data_dir_g,$dyn_fwrules_files_dir_g,\%input_hash4proc_g);
    #$ipset_input_dir_l,$ipset_actual_data_dir_l,$dyn_fwrules_files_dir_l,$input_hash4proc_href_l
    if ( $exec_res_g=~/^fail/ ) {
        $exec_status_g='FAIL';
        print "$exec_res_g\n";
        last;
    }
    $exec_res_g=undef;
    
    ######
    
    $exec_res_g=&generate_firewall_configs($dyn_fwrules_files_dir_g,\%h00_conf_firewalld_hash_g);
    #$conf_firewalld_href_l
    if ( $exec_res_g=~/^fail/ ) {
        $exec_status_g='FAIL';
        print "$exec_res_g\n";
        last;
    }
    $exec_res_g=undef;
    
    ######
    %input_hash4proc_g=(
    	'inventory_hosts_href'=>\%inventory_hosts_g,
    	'h00_conf_firewalld_href'=>\%h00_conf_firewalld_hash_g,
    	'h01_conf_ipset_templates_href'=>\%h01_conf_ipset_templates_hash_g,
    	'h66_conf_ipsets_FIN_href'=>\%h66_conf_ipsets_FIN_hash_g,
    );
    
    $exec_res_g=&generate_shell_script_for_recreate_ipsets($dyn_fwrules_files_dir_g,$remote_dir_for_absible_helper_g,\%input_hash4proc_g);
    #$dyn_fwrules_files_dir_l,$remote_dir_for_absible_helper_l,$input_hash4proc_href_l
    if ( $exec_res_g=~/^fail/ ) {
        $exec_status_g='FAIL';
        print "$exec_res_g\n";
        last;
    }
    $exec_res_g=undef;
    
    ######
    
    %input_hash4proc_g=(
	'inventory_hosts_href'=>\%inventory_hosts_g,
    	'h00_conf_firewalld_href'=>\%h00_conf_firewalld_hash_g,
    	'h01_conf_ipset_templates_href'=>\%h01_conf_ipset_templates_hash_g,
    	'h02_conf_standard_firewall_zones_templates_href'=>\%h02_conf_standard_firewall_zones_templates_hash_g,
    	'h02_conf_custom_firewall_zones_templates_href'=>\%h02_conf_custom_firewall_zones_templates_hash_g,
    	'h04_conf_forward_ports_sets_href'=>\%h04_conf_forward_ports_sets_hash_g,
    	'h05_conf_rich_rules_sets_href'=>\%h05_conf_rich_rules_sets_hash_g,
    	'h77_conf_zones_FIN_href'=>\%h77_conf_zones_FIN_hash_g,
    );
    $exec_res_g=&generate_shell_script_for_recreate_firewall_zones_v2($dyn_fwrules_files_dir_g,\%input_hash4proc_g);
    #$dyn_fwrules_files_dir_l,$input_hash4proc_href_l
    if ( $exec_res_g=~/^fail/ ) {
        $exec_status_g='FAIL';
        print "$exec_res_g\n";
        last;
    }
    $exec_res_g=undef;
    %input_hash4proc_g=();
    
    ######
    
    %input_hash4proc_g=(
	'inventory_hosts_href'=>\%inventory_hosts_g,
    	'h00_conf_firewalld_href'=>\%h00_conf_firewalld_hash_g,
    	'h01_conf_ipset_templates_href'=>\%h01_conf_ipset_templates_hash_g,
    	'h02_conf_standard_firewall_zones_templates_href'=>\%h02_conf_standard_firewall_zones_templates_hash_g,
    	'h02_conf_custom_firewall_zones_templates_href'=>\%h02_conf_custom_firewall_zones_templates_hash_g,
	'h03_conf_policy_templates_href'=>\%h03_conf_policy_templates_hash_g,
    	'h04_conf_forward_ports_sets_href'=>\%h04_conf_forward_ports_sets_hash_g,
    	'h05_conf_rich_rules_sets_href'=>\%h05_conf_rich_rules_sets_hash_g,
    	'h88_conf_policies_FIN_href'=>\%h88_conf_policies_FIN_hash_g,
    );
    $exec_res_g=&generate_shell_script_for_recreate_policies_v2($dyn_fwrules_files_dir_g,\%input_hash4proc_g);
    #$dyn_fwrules_files_dir_l,$input_hash4proc_href_l
    if ( $exec_res_g=~/^fail/ ) {
        $exec_status_g='FAIL';
        print "$exec_res_g\n";
        last;
    }
    $exec_res_g=undef;
    %input_hash4proc_g=();
    
    ######

    $exec_res_g=&generate_rollback_fwrules_changes_sh($with_rollback_g,$scripts_for_remote_dir_g,$dyn_fwrules_files_dir_g,\%inventory_hosts_g,\%h00_conf_firewalld_hash_g);
    #$with_rollback_l,$scripts_for_remote_dir_l,$dyn_fwrules_files_dir_l,$inv_hosts_href_l,$conf_firewalld_href_l
    if ( $exec_res_g=~/^fail/ ) {
        $exec_status_g='FAIL';
        print "$exec_res_g\n";
        last;
    }
    $exec_res_g=undef;
    
    ######
    
    last;
} # ONE RUN CYCLE end

system("echo $exec_status_g > $self_dir_g/GEN_DYN_FWRULES_STATUS");
if ( $exec_status_g!~/^OK$/ ) {
    print "EXEC_STATUS not OK. Exit!\n\n";
    exit;
}
############MAIN SEQ

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )