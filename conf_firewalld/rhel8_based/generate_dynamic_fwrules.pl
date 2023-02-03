#!/usr/bin/perl

###SCRIPT for generate firewall rules for each inventory host

use strict;
use warnings;
use Cwd;
use Data::Dumper;

our ($self_dir_g,$script_name_g)=Cwd::abs_path($0)=~/(.*[\/\\])(\S+)$/;
$self_dir_g=~s/\/$//g;

############ARGV
our $inventory_conf_path_g='no';
our $gen_with_rollback_g=0;

if ( defined($ARGV[0]) && length($ARGV[0])>0 ) {
    $inventory_conf_path_g=$ARGV[0];
}

if ( defined($ARGV[1]) && $ARGV[1]=~/^with_rollback$/ ) {
    $gen_with_rollback_g=1;
}
############ARGV

############CFG file
#00_conf_firewalld
#01_conf_ipset_templates
#02_conf_custom_firewall_zones_templates
#02_conf_standard_firewall_zones_templates
#03_conf_policy_templates
#04_conf_zone_forward_ports_sets
#05_conf_zone_rich_rules_sets
#66_conf_ipsets_FIN
#77_conf_zones_FIN
#88_conf_policies_FIN
###
our $f00_conf_firewalld_path_g=$self_dir_g.'/fwrules_configs/00_conf_firewalld';
our $f01_conf_ipset_templates_path_g=$self_dir_g.'/fwrules_configs/01_conf_ipset_templates';
our $f02_conf_custom_firewall_zones_templates_path_g=$self_dir_g.'/fwrules_configs/02_conf_custom_firewall_zones_templates';
our $f02_conf_standard_firewall_zones_templates_path_g=$self_dir_g.'/fwrules_configs/02_conf_standard_firewall_zones_templates';
our $f03_conf_policy_templates_path_g=$self_dir_g.'/fwrules_configs/03_conf_policy_templates';
our $f04_conf_zone_forward_ports_sets_path_g=$self_dir_g.'/fwrules_configs/04_conf_zone_forward_ports_sets';
our $f05_conf_zone_rich_rules_sets_path_g=$self_dir_g.'/fwrules_configs/05_conf_zone_rich_rules_sets';
our $f66_conf_ipsets_FIN_path_g=$self_dir_g.'/fwrules_configs/66_conf_ipsets_FIN';
our $f77_conf_zones_FIN_path_g=$self_dir_g.'/fwrules_configs/77_conf_zones_FIN';
our $f88_conf_policies_FIN_path_g=$self_dir_g.'/fwrules_configs/88_conf_policies_FIN';
###
our $ifcfg_backup_from_remote_nd_file_g=$self_dir_g.'/playbooks/fwrules_backup_from_remote/network_data/inv_hosts_interfaces_info.txt'; # dir contains actual network_data (eth) downloaded from remote hosts with help of playbook 'fwrules_backup_playbook.yml' before run this script
############CFG file

############STATIC VARS
our $remote_dir_for_absible_helper_g='~/ansible_helpers/conf_firewalld'; # dir for creating/manipulate files at remote side
our $dyn_fwrules_playbooks_dir_g=$self_dir_g.'/playbooks/dyn_fwrules_playbooks'; # dir for recreate shell-scripts for executing it at remote side (if need)
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
#$inv_hosts_network_data_g{inv_host}{int_name}=ipaddr
######

######
our %h00_conf_firewalld_hash_g=();
#[firewall_conf_for_all--TMPLT:BEGIN]
#host_list_for_apply=all
#unconfigured_custom_firewall_zones_action=no_action
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
our %h04_conf_zone_forward_ports_sets_hash_g=();
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
######

######
our %h05_conf_zone_rich_rules_sets_hash_g=();
#[some_rich_rules_set_name:BEGIN]
#rule family=ipv4 forward-port to-port=8080 protocol=tcp port=80 (example)
#rule family=ipv4 source address=192.168.55.4/32 destination address=10.10.7.0/24 masquerade (example)
#[some_rich_rules_set_name:END]
###
#$h05_conf_zone_rich_rules_sets_hash_g{set_name}->
    #{'rule-0'}=1
    #{'rule-1'}=1
    #etc
    #{'seq'}=[val-0,val-1] (val=rule)
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
#{'forward_ports_set'}=empty|fw_ports_set (FROM '04_conf_zone_forward_ports_sets')
#{'rich_rules_set'}=empty|rich_rules_set (FROM '05_conf_zone_rich_rules_sets')
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
#{'forward_ports_set'}=empty|fw_ports_set (FROM '04_conf_zone_forward_ports_sets')
#{'rich_rules_set'}=empty|rich_rules_set (FROM '05_conf_zone_rich_rules_sets')
######

our ($exec_res_g,$exec_status_g)=(undef,'OK');

our %input_hash4proc_g=();
#hash with hash refs for input
############VARS

############MAIN SEQ
while ( 1 ) { # ONE RUN CYCLE begin
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
    
    $exec_res_g=&read_00_conf_firewalld($f00_conf_firewalld_path_g,\%inventory_hosts_g,\%h00_conf_firewalld_hash_g);
    #$file_l,$inv_hosts_href_l,$res_href_l
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
    
    $exec_res_g=&read_02_conf_custom_firewall_zones_templates($f02_conf_custom_firewall_zones_templates_path_g,\%h02_conf_custom_firewall_zones_templates_hash_g);
    #$file_l,$res_href_l
    if ( $exec_res_g=~/^fail/ ) {
	$exec_status_g='FAIL';
	print "$exec_res_g\n";
	last;
    }
    $exec_res_g=undef;
    #print Dumper(\%h02_conf_custom_firewall_zones_templates_hash_g);
    
    ######
    
    $exec_res_g=&read_02_conf_standard_firewall_zones_templates($f02_conf_standard_firewall_zones_templates_path_g,\%h02_conf_standard_firewall_zones_templates_hash_g);
    #$file_l,$res_href_l
    if ( $exec_res_g=~/^fail/ ) {
	$exec_status_g='FAIL';
	print "$exec_res_g\n";
	last;
    }
    $exec_res_g=undef;
    #print Dumper(\%h02_conf_standard_firewall_zones_templates_hash_g);
    
    ######
    
    $exec_res_g=&read_03_conf_policy_templates($f03_conf_policy_templates_path_g,\%h03_conf_policy_templates_hash_g);
    #$file_l,$res_href_l
    if ( $exec_res_g=~/^fail/ ) {
	$exec_status_g='FAIL';
	print "$exec_res_g\n";
	last;
    }
    $exec_res_g=undef;
    #print Dumper(\%h03_conf_policy_templates_hash_g);
    
    ######
    
    $exec_res_g=&read_04_conf_zone_forward_ports_sets($f04_conf_zone_forward_ports_sets_path_g,\%h04_conf_zone_forward_ports_sets_hash_g);
    #$file_l,$res_href_l
    if ( $exec_res_g=~/^fail/ ) {
	$exec_status_g='FAIL';
	print "$exec_res_g\n";
	last;
    }
    $exec_res_g=undef;
    #print Dumper(\%h04_conf_zone_forward_ports_sets_hash_g);
    
    ######
    
    $exec_res_g=&read_05_conf_zone_rich_rules_sets($f05_conf_zone_rich_rules_sets_path_g,\%h05_conf_zone_rich_rules_sets_hash_g);
    #$file_l,$res_href_l
    if ( $exec_res_g=~/^fail/ ) {
	$exec_status_g='FAIL';
	print "$exec_res_g\n";
	last;
    }
    $exec_res_g=undef;
    #print Dumper(\%h05_conf_zone_rich_rules_sets_hash_g);
    
    ######
    
    $exec_res_g=&read_66_conf_ipsets_FIN($f66_conf_ipsets_FIN_path_g,\%inventory_hosts_g,\%h01_conf_ipset_templates_hash_g,\%h66_conf_ipsets_FIN_hash_g);
    #$file_l,$inv_hosts_href_l,$ipset_templates_href_l,$res_href_l
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
	'h01_conf_ipset_templates_href'=>\%h01_conf_ipset_templates_hash_g,
	'h02_conf_custom_firewall_zones_templates_href'=>\%h02_conf_custom_firewall_zones_templates_hash_g,
	'h02_conf_standard_firewall_zones_templates_href'=>\%h02_conf_standard_firewall_zones_templates_hash_g,
	'h04_conf_zone_forward_ports_sets_href'=>\%h04_conf_zone_forward_ports_sets_hash_g,
	'h05_conf_zone_rich_rules_sets_href'=>\%h05_conf_zone_rich_rules_sets_hash_g,
	'h66_conf_ipsets_FIN_href'=>\%h66_conf_ipsets_FIN_hash_g,
    );
    $exec_res_g=&read_77_conf_zones_FIN($f77_conf_zones_FIN_path_g,\%input_hash4proc_g,\%h77_conf_zones_FIN_hash_g);
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
	'h02_conf_custom_firewall_zones_templates_href'=>\%h02_conf_custom_firewall_zones_templates_hash_g,
	'h02_conf_standard_firewall_zones_templates_href'=>\%h02_conf_standard_firewall_zones_templates_hash_g,
	'h03_conf_policy_templates_href'=>\%h03_conf_policy_templates_hash_g,
	'h04_conf_zone_forward_ports_sets_href'=>\%h04_conf_zone_forward_ports_sets_hash_g,
	'h05_conf_zone_rich_rules_sets_href'=>\%h05_conf_zone_rich_rules_sets_hash_g,
	'h77_conf_zones_FIN_href'=>\%h77_conf_zones_FIN_hash_g,
    );
    $exec_res_g=&read_88_conf_policies_FIN($f88_conf_policies_FIN_path_g,\%input_hash4proc_g,\%h88_conf_policies_FIN_hash_g);
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
    
    $exec_res_g=&generate_shell_script_for_recreate_ipsets($dyn_fwrules_playbooks_dir_g,$remote_dir_for_absible_helper_g,\%h01_conf_ipset_templates_hash_g,\%h66_conf_ipsets_FIN_hash_g);
    #$dyn_fwrules_playbooks_dir_l,$ipset_templates_href_l,$h66_conf_ipsets_FIN_href_l
    if ( $exec_res_g=~/^fail/ ) {
        $exec_status_g='FAIL';
        print "$exec_res_g\n";
        last;
    }
    $exec_res_g=undef;

    ######
    
    %input_hash4proc_g=(
    	'h00_conf_firewalld_href'=>\%h00_conf_firewalld_hash_g,
    	'h01_conf_ipset_templates_href'=>\%h01_conf_ipset_templates_hash_g,
    	'h02_conf_standard_firewall_zones_templates_href'=>\%h02_conf_standard_firewall_zones_templates_hash_g,
    	'h02_conf_custom_firewall_zones_templates_href'=>\%h02_conf_custom_firewall_zones_templates_hash_g,
    	'h04_conf_zone_forward_ports_sets_href'=>\%h04_conf_zone_forward_ports_sets_hash_g,
    	'h05_conf_zone_rich_rules_sets_href'=>\%h05_conf_zone_rich_rules_sets_hash_g,
    	'h77_conf_zones_FIN_href'=>\%h77_conf_zones_FIN_hash_g,
    );
    $exec_res_g=&generate_shell_script_for_recreate_firewall_zones($dyn_fwrules_playbooks_dir_g,\%input_hash4proc_g);
    #$dyn_fwrules_playbooks_dir_l,$input_hash4proc_href_l
    if ( $exec_res_g=~/^fail/ ) {
        $exec_status_g='FAIL';
        print "$exec_res_g\n";
        last;
    }
    $exec_res_g=undef;
    %input_hash4proc_g=();
    
    ######
    
    %input_hash4proc_g=(
    	'h01_conf_ipset_templates_href'=>\%h01_conf_ipset_templates_hash_g,
    	'h02_conf_standard_firewall_zones_templates_href'=>\%h02_conf_standard_firewall_zones_templates_hash_g,
    	'h02_conf_custom_firewall_zones_templates_href'=>\%h02_conf_custom_firewall_zones_templates_hash_g,
    	'h04_conf_zone_forward_ports_sets_href'=>\%h04_conf_zone_forward_ports_sets_hash_g,
    	'h05_conf_zone_rich_rules_sets_href'=>\%h05_conf_zone_rich_rules_sets_hash_g,
    	'h88_conf_policies_FIN_href'=>\%h88_conf_policies_FIN_hash_g,
    );
    $exec_res_g=&generate_shell_script_for_recreate_policies($dyn_fwrules_playbooks_dir_g,\%input_hash4proc_g);
    #$dyn_fwrules_playbooks_dir_l,$input_hash4proc_href_l
    if ( $exec_res_g=~/^fail/ ) {
        $exec_status_g='FAIL';
        print "$exec_res_g\n";
        last;
    }
    $exec_res_g=undef;
    %input_hash4proc_g=();
    
    ######
        
    last;
} # ONE RUN CYCLE end

system("echo $exec_status_g > GEN_DYN_FWRULES_STATUS");
if ( $exec_status_g!~/^OK$/ ) {
    print "EXEC_STATUS not OK. Exit!\n\n";
    exit;
}
############MAIN SEQ

############SUBROUTINES
######general subs
sub read_inventory_file {
    my ($file_l,$res_href_l)=@_;
    #file_l=$inventory_conf_path_g, res_href_l=hash-ref for %inventory_hosts_g
    my $proc_name_l=(caller(0))[3];
            
    my ($line_l,$start_read_hosts_flag_l,$value_cnt_l)=(undef,0,0);
    
    if ( length($file_l)<1 or ! -e($file_l) ) { return "fail [$proc_name_l]. File='$file_l' is not exists"; }
    
    open(INVDATA,'<',$file_l);
    while ( <INVDATA> ) {
    	$line_l=$_;
    	$line_l=~s/\n$|\r$|\n\r$|\r\n$//g;
    	while ($line_l=~/\t/) { $line_l=~s/\t/ /g; }
    	$line_l=~s/\s+/ /g;
    	$line_l=~s/^ //g;
	$line_l=~s/ $//g;
    	if ( length($line_l)>0 && $line_l!~/^\#/ ) {
	    if ( $line_l=~/^\[rhel8_firewall_hosts\]/ && $start_read_hosts_flag_l==0 ) { $start_read_hosts_flag_l=1; }
	    elsif ( $start_read_hosts_flag_l==1 && $line_l=~/^\[rhel8_firewall_hosts\:vars\]/ ) {
		$start_read_hosts_flag_l=0;
		last;
	    }
	    elsif ( $start_read_hosts_flag_l==1 ) {
		${$res_href_l}{$line_l}=1;
		$value_cnt_l++;
	    }
    	}
    }
    close(INVDATA);
    
    ($line_l,$start_read_hosts_flag_l)=(undef,undef);
    
    if ( $value_cnt_l<1 ) { return "fail [$proc_name_l]. No needed data at file='$file_l'"; }
    
    return 'OK';
}

sub read_network_data_for_checks {
    my ($file_l,$res_href_l)=@_;
    #file_l=$ifcfg_backup_from_remote_nd_file_g
    #res_href_l=hash-ref for %inv_hosts_network_data_g
    my $proc_name_l=(caller(0))[3];
        
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
            #INV_HOST-0       #INT_NAME-1       #IPADDR-2
	    #$inv_hosts_network_data_g{inv_host}{int_name}=ipaddr
	    ###
            @arr0_l=split(' ',$line_l);
            ${$res_href_l}{$arr0_l[0]}{$arr0_l[1]}=$arr0_l[2];
	    $value_cnt_l++;
        }
    }
    close(NDATA);
    
    $line_l=undef;

    if ( $value_cnt_l<1 ) { return "fail [$proc_name_l]. No needed data at file='$file_l'"; }

    return 'OK';
}

sub read_00_conf_firewalld {
    my ($file_l,$inv_hosts_href_l,$res_href_l)=@_;
    #file_l=$f00_conf_firewalld_path_g
    #inv_hosts_href_l=hash-ref for %inventory_hosts_g
    #res_href_l=hash-ref for %h00_conf_firewalld_hash_g
    my $proc_name_l=(caller(0))[3];
    
    #[firewall_conf_for_all--TMPLT:BEGIN]
    #host_list_for_apply=all
    #unconfigured_custom_firewall_zones_action=no_action
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

    my $arr_el0_l=undef;
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my ($hkey1_l,$hval1_l)=(undef,undef);
    my $exec_res_l=undef;
    my $return_str_l='OK';
    
    my @inv_hosts_arr_l=();
    
    my %res_tmp_lv0_l=();
	#key0=tmplt_name, key1=param, value=value filtered by regex
    my %res_tmp_lv1_l=();
	#key0=inv-host, key1=param (except = host_list_for_apply), value=hash ref for %res_tmp_lv0_l
    my %cfg_params_and_regex_l=(
	'host_list_for_apply'=>'^all$|\S+',
	'unconfigured_custom_firewall_zones_action'=>'^no_action$|^remove$',
	'DefaultZone'=>'^\S+$',
	'CleanupOnExit'=>'^yes$|^no$',
	'CleanupModulesOnExit'=>'^yes$|^no$',
	'Lockdown'=>'^yes$|^no$',
	'IPv6_rpfilter'=>'^yes$|^no$',
	'IndividualCalls'=>'^yes$|^no$',
	'LogDenied'=>'^all$|^unicast$|^broadcast$|^multicast$|^off$',
	'enable_logging_of_dropped_packets'=>'^yes$|^no$',
	'FirewallBackend'=>'^nftables$|^iptables$',
	'FlushAllOnReload'=>'^yes$|^no$',
	'RFC3964_IPv4'=>'^yes$|^no$',
	'AllowZoneDrifting'=>'^yes$|^no$'
    );

    $exec_res_l=&read_param_value_templates_from_config($file_l,\%cfg_params_and_regex_l,\%res_tmp_lv0_l);
    #$file_l,$regex_href_l,$res_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }
    
    # fill res_tmp_lv1_l
    while ( ($hkey0_l,$hval0_l)=each %res_tmp_lv0_l ) {
	#hkey0_l=tmplt_name, hval0_l=hash of params
	if ( ${$hval0_l}{'host_list_for_apply'} eq 'all' ) {
	    while ( ($hkey1_l,$hval1_l)=each %{$inv_hosts_href_l} ) {
		#$hkey1_l=inv-host from inv-host-hash
		push(@inv_hosts_arr_l,$hkey1_l);
	    }
	    
	    ($hkey1_l,$hval1_l)=(undef,undef);
	}
	else {
	    @inv_hosts_arr_l=split(/\,/,${$hval0_l}{'host_list_for_apply'});
	}
	delete(${$hval0_l}{'host_list_for_apply'});
	
	foreach $arr_el0_l ( @inv_hosts_arr_l ) {
	    #arr_el0_l=inv-host
	    %{$res_tmp_lv1_l{$arr_el0_l}}=%{$hval0_l};
	}
	
	$arr_el0_l=undef;
	@inv_hosts_arr_l=();
    }
    
    ($hkey0_l,$hval0_l)=(undef,undef);
    @inv_hosts_arr_l=();
    %res_tmp_lv0_l=();
    ###

    # check for not existing configs for inv-hosts
    while ( ($hkey0_l,$hval0_l)=each %{$inv_hosts_href_l} ) {
	# hkey0_l = inv-host-name
	if ( !exists($res_tmp_lv1_l{$hkey0_l}) ) {
	    $return_str_l="fail [$proc_name_l]. Host='$hkey0_l' have not configuration";
	    last;
	}
    }
    
    ($hkey0_l,$hval0_l)=(undef,undef);
    
    if ( $return_str_l!~/OK$/ ) { return $return_str_l; }
    
    ###
    
    # fill result hash
    %{$res_href_l}=%res_tmp_lv1_l;
    ###

    %res_tmp_lv1_l=();
    
    return $return_str_l;
}

sub read_01_conf_ipset_templates {
    my ($file_l,$res_href_l)=@_;
    #file_l=$f01_conf_ipset_templates_path_g
    #res_href_l=hash-ref for %h01_conf_ipset_templates_hash_g
    my $proc_name_l=(caller(0))[3];

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
    
    my $exec_res_l=undef;
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my $return_str_l='OK';

    my %res_tmp_lv0_l=();
	#key0=ipset_tmplt_name, key1=param, value=value filtered by regex
    my %res_tmp_lv1_l=();

    my %cfg_params_and_regex_l=(
	'ipset_name'=>'^\S+$',
	'ipset_description'=>'^empty$|^.{1,100}',
	'ipset_short_description'=>'^empty$|^.{1,20}',
	'ipset_create_option_timeout'=>'^\d+$',
	'ipset_create_option_hashsize'=>'^\d+$',
	'ipset_create_option_maxelem'=>'^\d+$',
	'ipset_create_option_family'=>'^inet$|^inet6$',
	'ipset_type'=>'^hash\:ip$|^hash\:ip\,port$|^hash\:ip\,mark$|^hash\:net$|^hash\:net\,port$|^hash\:net\,iface$|^hash\:mac$|^hash\:ip\,port\,ip$|^hash\:ip\,port\,net$|^hash\:net\,net$|^hash\:net\,port\,net$',
    );

    $exec_res_l=&read_param_value_templates_from_config($file_l,\%cfg_params_and_regex_l,\%res_tmp_lv0_l);
    #$file_l,$regex_href_l,$res_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }
    
    # fill %res_tmp_lv1_l
    while ( ($hkey0_l,$hval0_l)=each %res_tmp_lv0_l ) {
	#$hkey0_l=tmplt_name, $hval0_l=href for hash slice with params and values
	if ( ${$hval0_l}{'ipset_create_option_timeout'}>0 ) { %{$res_tmp_lv1_l{'temporary'}{$hkey0_l}}=%{$hval0_l}; }
	else { %{$res_tmp_lv1_l{'permanent'}{$hkey0_l}}=%{$hval0_l}; }
    }
    
    ($hkey0_l,$hval0_l)=(undef,undef);
    %res_tmp_lv0_l=();
    ###
    
    # fill result hash
    %{$res_href_l}=%res_tmp_lv1_l;
    ###

    %res_tmp_lv1_l=();
    
    return $return_str_l;    
}

sub read_02_conf_custom_firewall_zones_templates {
    my ($file_l,$res_href_l)=@_;
    #file_l=$f02_conf_custom_firewall_zones_templates_path_g
    #res_href_l=hash-ref for %h02_conf_custom_firewall_zones_templates_hash_g
    my $proc_name_l=(caller(0))[3];

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

    my $exec_res_l=undef;
    my $arr_el0_l=undef;
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my ($hkey1_l,$hval1_l)=(undef,undef);
    my @split_arr0_l=();
    my $return_str_l='OK';
    my $param_list_regex_l='^zone_allowed_services$|^zone_allowed_protocols$|^zone_icmp_block$|^zone_allowed_ports$|^zone_allowed_source_ports$';

    my %res_tmp_lv0_l=();
	#key0=tmplt_name,key1=param, value=value filtered by regex
    my %res_tmp_lv1_l=();

    my %cfg_params_and_regex_l=(
	'zone_name'=>'^\S+\-\-custom$',
	'zone_description'=>'^empty$|^.{1,100}',
	'zone_short_description'=>'^empty$|^.{1,20}',
	'zone_target'=>'^ACCEPT$|^REJECT$|^DROP$|^default$',
	'zone_allowed_services'=>'^empty$|^.*$',
	'zone_allowed_ports'=>'^empty$|^.*$',
	'zone_allowed_protocols'=>'^empty$|^.*$',
	'zone_forward'=>'$yes$|^no$',
	'zone_masquerade_general'=>'$yes$|^no$',
	'zone_allowed_source_ports'=>'^empty$|^.*$',
	'zone_icmp_block_inversion'=>'$yes$|^no$',
	'zone_icmp_block'=>'^empty$|^.*$',
    );

    $exec_res_l=&read_param_value_templates_from_config($file_l,\%cfg_params_and_regex_l,\%res_tmp_lv0_l);
    #$file_l,$regex_href_l,$res_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }
    
    # fill %res_tmp_lv1_l (postprocessing_v1_after_read_param_value_templates_from_config)
    $exec_res_l=&postprocessing_v1_after_read_param_value_templates_from_config($file_l,$param_list_regex_l,\%res_tmp_lv0_l,\%res_tmp_lv1_l);
    #$file_l,$param_list_regex_for_postproc_l,$src_href_l,$res_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }
    ###
    
    # fill result hash
    %{$res_href_l}=%res_tmp_lv1_l;
    ###

    %res_tmp_lv1_l=();
    
    return $return_str_l;    
}

sub read_02_conf_standard_firewall_zones_templates {
    my ($file_l,$res_href_l)=@_;
    #file_l=$f02_conf_standard_firewall_zones_templates_path_g
    #res_href_l=hash-ref for %h02_conf_standard_firewall_zones_templates_hash_g
    my $proc_name_l=(caller(0))[3];

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
    
    my $exec_res_l=undef;
    my $arr_el0_l=undef;
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my ($hkey1_l,$hval1_l)=(undef,undef);
    my @split_arr0_l=();
    my $return_str_l='OK';
    my $param_list_regex_l='^zone_allowed_services$|^zone_allowed_protocols$|^zone_icmp_block$|^zone_allowed_ports$|^zone_allowed_source_ports$';

    my %res_tmp_lv0_l=();
	#key0=tmplt_name,key1=param, value=value filtered by regex
    my %res_tmp_lv1_l=();

    my %cfg_params_and_regex_l=(
	'zone_name'=>'^block$|^dmz$|^drop$|^external$|^internal$|^public$|^trusted$|^work$|^home$',
	'zone_target'=>'^ACCEPT$|^REJECT$|^DROP$|^default$',
	'zone_allowed_services'=>'^empty$|^.*$',
	'zone_allowed_ports'=>'^empty$|^.*$',
	'zone_allowed_protocols'=>'^empty$|^.*$',
	'zone_forward'=>'$yes$|^no$',
	'zone_masquerade_general'=>'$yes$|^no$',
	'zone_allowed_source_ports'=>'^empty$|^.*$',
	'zone_icmp_block_inversion'=>'$yes$|^no$',
	'zone_icmp_block'=>'^empty$|^.*$',
    );

    $exec_res_l=&read_param_value_templates_from_config($file_l,\%cfg_params_and_regex_l,\%res_tmp_lv0_l);
    #$file_l,$regex_href_l,$res_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }
    
    # fill %res_tmp_lv1_l (postprocessing_v1_after_read_param_value_templates_from_config)
    $exec_res_l=&postprocessing_v1_after_read_param_value_templates_from_config($file_l,$param_list_regex_l,\%res_tmp_lv0_l,\%res_tmp_lv1_l);
    #$file_l,$param_list_regex_for_postproc_l,$src_href_l,$res_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }
    ###
    
    # fill result hash
    %{$res_href_l}=%res_tmp_lv1_l;
    ###
    
    %res_tmp_lv1_l=();

    return $return_str_l;    
}

sub read_03_conf_policy_templates {
    my ($file_l,$res_href_l)=@_;
    #file_l=$f03_conf_policy_templates_path_g
    #res_href_l=hash-ref for %h03_conf_policy_templates_hash_g
    my $proc_name_l=(caller(0))[3];

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

    my $exec_res_l=undef;
    my $arr_el0_l=undef;
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my ($hkey1_l,$hval1_l)=(undef,undef);
    my @split_arr0_l=();
    my $return_str_l='OK';
    my $param_list_regex_l='^policy_allowed_services$|^policy_allowed_protocols$|^policy_icmp_block$|^policy_allowed_ports$|^policy_allowed_source_ports$';

    my %res_tmp_lv0_l=();
	#key0=tmplt_name,key1=param, value=value filtered by regex
    my %res_tmp_lv1_l=();

    my %cfg_params_and_regex_l=(
	'policy_name'=>'^\S+$',
	'policy_description'=>'^empty$|^.{1,100}',
	'policy_short_description'=>'^empty$|^.{1,20}',
	'policy_target'=>'^ACCEPT$|^REJECT$|^DROP$|^CONTINUE$',
	'policy_priority'=>'^\d+$|^\-\d+$',
	'policy_allowed_services'=>'^empty$|^.*$',
	'policy_allowed_ports'=>'^empty$|^.*$',
	'policy_allowed_protocols'=>'^empty$|^.*$',
	'policy_masquerade_general'=>'$yes$|^no$',
	'policy_allowed_source_ports'=>'^empty$|^.*$',
	'policy_icmp_block'=>'^empty$|^.*$',
    );

    $exec_res_l=&read_param_value_templates_from_config($file_l,\%cfg_params_and_regex_l,\%res_tmp_lv0_l);
    #$file_l,$regex_href_l,$res_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }
    
    # fill %res_tmp_lv1_l (postprocessing_v1_after_read_param_value_templates_from_config)
    $exec_res_l=&postprocessing_v1_after_read_param_value_templates_from_config($file_l,$param_list_regex_l,\%res_tmp_lv0_l,\%res_tmp_lv1_l);
    #$file_l,$param_list_regex_for_postproc_l,$src_href_l,$res_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }
    ###
    
    # fill result hash
    %{$res_href_l}=%res_tmp_lv1_l;
    ###

    %res_tmp_lv1_l=();
    
    return $return_str_l;    
}

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
		
		if ( $to_addr_l!~/^localhost$/ && $to_addr_l=~/^\d{1,3}\./ && $to_addr_l!~/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/ ) { # check ipv4
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

sub read_05_conf_zone_rich_rules_sets {
    my ($file_l,$res_href_l)=@_;
    #file_l=$f05_conf_zone_rich_rules_sets_path_g
    #res_href_l=hash-ref for %h05_conf_zone_rich_rules_sets_hash_g
    my $proc_name_l=(caller(0))[3];
    
    #[some_rich_rules_set_name:BEGIN]
    #rule family=ipv4 forward-port to-port=8080 protocol=tcp port=80 (example)
    #rule family=ipv4 source address=192.168.55.4/32 destination address=10.10.7.0/24 masquerade (example)
    #[some_rich_rules_set_name:END]
    ###
    #$h05_conf_zone_rich_rules_sets_hash_g{set_name}->
	#{'rule-0'}=1
	#{'rule-1'}=1
	#etc
	#{'seq'}=[val-0,val-1] (val=rule)

    my $exec_res_l=undef;
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my ($hkey1_l,$hval1_l)=(undef,undef);
    my $return_str_l='OK';
    
    my %res_tmp_lv0_l=();
	#key=rule, value=value filtered by regex

    $exec_res_l=&read_param_only_templates_from_config($file_l,\%res_tmp_lv0_l);
    #$file_l,$res_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }
    
    # check rules with regex (for future functional)
    #while ( ($hkey0_l,$hval0_l)=each %res_tmp_lv0_l ) { # cycle 0
    #	#hkey0_l=tmplt_name, hval0_l=hash ref where key=rule
    #	###
    #	while ( ($hkey1_l,$hval1_l)=each %{$hval0_l} ) { # cycle 1
    #	    #hkey1_l=rule
    #	    #rule family=ipv4 forward-port to-port=8080 protocol=tcp port=80 (example)
    #	    #rule family=ipv4 source address=192.168.55.4/32 destination address=10.10.7.0/24 masquerade (example)
    #	    if ( $hkey1_l!~/^seq$/ ) {
    #	    }
    #	} # cycle 1
    #	
    #	if ( $return_str_l!~/^OK$/ ) { last; }
    #} # cycle 0
    #
    #if ( $return_str_l!~/^OK$/ ) { return $return_str_l; }
    ###

    # fill result hash
    %{$res_href_l}=%res_tmp_lv0_l;
    ###

    %res_tmp_lv0_l=();

    return $return_str_l;
}

sub read_66_conf_ipsets_FIN {
    my ($file_l,$inv_hosts_href_l,$ipset_templates_href_l,$res_href_l)=@_;
    #$file_l=$f66_conf_ipsets_FIN_path_g
    #inv_hosts_href_l=hash-ref for %inventory_hosts_g
    #$ipset_templates_href_l=hash-ref for %h01_conf_ipset_templates_hash_g
    #$res_href_l=hash ref for %h66_conf_ipsets_FIN_hash_g
    my $proc_name_l=(caller(0))[3];

    #INVENTORY_HOST         #IPSET_NAME_TMPLT_LIST
    #all                    ipset1--TMPLT,ipset4all_public--TMPLT (example)
    #10.3.2.2               ipset4public--TMPLT (example)
    ###
    #$h66_conf_ipsets_FIN_hash_g{'temporary/permanent'}{inventory_host}->
    	#{ipset_name_tmplt-0}=1;
    	#{ipset_name_tmplt-1}=1;
    	#etc
    ###

    my $exec_res_l=undef;
    my $arr_el0_l=undef;
    my $ipset_type_l=undef; # temporary / permanent
    my $ipset_name_l=undef;
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my @arr0_l=();
    my $return_str_l='OK';
    
    my %ipset_uniq_check_l=();
	#key0=inv-host, key1=ipset_name (not tmplt-name), value=1
    
    my %res_tmp_lv0_l=();
	#key=inv-host, value=[array of values]. IPSET_NAME_TMPLT_LIST-0
    my %res_tmp_lv1_l=();
	#final hash
    
    $exec_res_l=&read_config_FIN_level0($file_l,$inv_hosts_href_l,2,0,\%res_tmp_lv0_l);
    #$file_l,$inv_hosts_href_l,$needed_elements_at_line_arr_l,$add_ind4key_l,$res_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }
    
    # fill %res_tmp_lv1_l
    while ( ($hkey0_l,$hval0_l)=each %res_tmp_lv0_l ) {
	#hkey0_l=inv-host
	@arr0_l=split(/\,/,${$hval0_l}[0]);
	foreach $arr_el0_l ( @arr0_l ) {
	    #$arr_el0_l=ipset_template_name
	    #$h01_conf_ipset_templates_hash_g{'temporary/permanent'}{ipset_template_name--TMPLT}->
		#{'ipset_name'}=value
		#{'ipset_description'}=empty|value
		#{'ipset_short_description'}=empty|value
		#{'ipset_create_option_timeout'}=num
		#{'ipset_create_option_hashsize'}=num
		#{'ipset_create_option_maxelem'}=num
		#{'ipset_create_option_family'}=inet|inet6
		#{'ipset_type'}=hash:ip|hash:ip,port|hash:ip,mark|hash:net|hash:net,port|hash:net,iface|hash:mac|hash:ip,port,ip|hash:ip,port,net|hash:net,net|hash:net,port,net
	    
	    # check ipset-tmpl for exists at 'h01_conf_ipset_templates_hash_g'
	    if ( exists(${$ipset_templates_href_l}{'temporary'}{$arr_el0_l}) ) {
		$ipset_type_l='temporary';
		$ipset_name_l=${$ipset_templates_href_l}{'temporary'}{$arr_el0_l}{'ipset_name'};
	    }
	    elsif ( exists(${$ipset_templates_href_l}{'permanent'}{$arr_el0_l}) ) {
		$ipset_type_l='permanent';
		$ipset_name_l=${$ipset_templates_href_l}{'permanent'}{$arr_el0_l}{'ipset_name'};
	    }
	    else {
		$return_str_l="fail [$proc_name_l]. Template '$arr_el0_l' (used at '$file_l') is not exists at '01_conf_ipset_templates'";
		last;
	    }
	    ###
	    
	    # check for uniq inv-host+ipset_name
	    if ( exists($ipset_uniq_check_l{$hkey0_l}{$ipset_name_l}) ) {
		$return_str_l="fail [$proc_name_l]. Duplicate ipset_name='$ipset_name_l' (tmplt_name='$arr_el0_l') for inv-host='$hkey0_l' at conf '66_conf_ipsets_FIN'. Check '01_conf_ipset_templates' and '66_conf_ipsets_FIN'";
		last;
	    }
	    $ipset_uniq_check_l{$hkey0_l}{$ipset_name_l}=1;
	    ###
	    
	    if ( !exists($res_tmp_lv1_l{$ipset_type_l}{$hkey0_l}{$arr_el0_l}) ) {
		$res_tmp_lv1_l{$ipset_type_l}{$hkey0_l}{$arr_el0_l}=1;
	    }
	    else { # duplicated value
		$return_str_l="fail [$proc_name_l]. Duplicated template name value ('$arr_el0_l') at file='$file_l' at substring='${$hval0_l}[0]'. Fix it!";
                last;
	    }
	}
	
	$arr_el0_l=undef;
	$ipset_type_l=undef;
	@arr0_l=();

	if ( $return_str_l!~/^OK$/ ) { last; }
    }
    
    ($hkey0_l,$hval0_l)=(undef,undef);
    $arr_el0_l=undef;
    @arr0_l=();
    
    if ( $return_str_l!~/^OK$/ ) { return $return_str_l; }
    ###
    
    # fill result hash
    %{$res_href_l}=%res_tmp_lv1_l;
    ###

    %res_tmp_lv1_l=();

    return $return_str_l;
}

sub read_77_conf_zones_FIN {
    my ($file_l,$input_hash4proc_href_l,$res_href_l)=@_;
    #$file_l=$f77_conf_zones_FIN_path_g
    #$input_hash4proc_href_l=hash-ref for %input_hash4proc_g (hash with hash refs for input)
    #$res_href_l=hash ref for %h77_conf_zones_FIN_hash_g
    
    my $inv_hosts_href_l=${$input_hash4proc_href_l}{'inventory_hosts_href'};
    #inv_hosts_href_l=hash-ref for %inventory_hosts_g
    
    my $inv_hosts_nd_href_l=${$input_hash4proc_href_l}{'inv_hosts_network_data_href'};
    #$inv_hosts_nd_href_l=hash-ref for %inv_hosts_network_data_g
    	#INV_HOST-0       #INT_NAME-1       #IPADDR-2
    	#$inv_hosts_network_data_g{inv_host}{int_name}=ipaddr
    
    my $ipset_templates_href_l=${$input_hash4proc_href_l}{'h01_conf_ipset_templates_href'};
    #$ipset_templates_href_l=hash-ref for %h01_conf_ipset_templates_hash_g
    	#$h01_conf_ipset_templates_hash_g{'temporary/permanent'}{ipset_template_name--TMPLT}->

    my $custom_zone_templates_href_l=${$input_hash4proc_href_l}{'h02_conf_custom_firewall_zones_templates_href'};
    #$custom_zone_templates_href_l=hash-ref for %h02_conf_custom_firewall_zones_templates_hash_g
    
    my $std_zone_templates_href_l=${$input_hash4proc_href_l}{'h02_conf_standard_firewall_zones_templates_href'};
    #$std_zone_templates_href_l=hash-ref for %h02_conf_standard_firewall_zones_templates_hash_g
        
    my $fw_ports_set_href_l=${$input_hash4proc_href_l}{'h04_conf_zone_forward_ports_sets_href'};
    #$fw_ports_set_href_l=hash-ref for %h04_conf_zone_forward_ports_sets_hash_g
    	#$h04_conf_zone_forward_ports_sets_hash_g{set_name}->
    
    my $rich_rules_set_href_l=${$input_hash4proc_href_l}{'h05_conf_zone_rich_rules_sets_href'};
    #$rich_rules_set_href_l=hash-ref for %h05_conf_zone_rich_rules_sets_hash_g
    	#$h05_conf_zone_rich_rules_sets_hash_g{set_name}->
    
    my $h66_conf_ipsets_FIN_href_l=${$input_hash4proc_href_l}{'h66_conf_ipsets_FIN_href'};
    #$h66_conf_ipsets_FIN_href_l=hash-ref for \%h66_conf_ipsets_FIN_hash_g
	#$h66_conf_ipsets_FIN_hash_g{'temporary/permanent'}{inventory_host}->
    	    #{ipset_name_tmplt-0}=1;
    	    #{ipset_name_tmplt-1}=1;
    	    #etc
    
    my $proc_name_l=(caller(0))[3];

    #INVENTORY_HOST         #FIREWALL_ZONE_NAME_TMPLT       #INTERFACE_LIST   #SOURCE_LIST          #IPSET_TMPLT_LIST                       #FORWARD_PORTS_SET      #RICH_RULES_SET
    #all                    public--TMPLT                   ens1,ens2,ens3    10.10.16.0/24         ipset4all_public--TMPLT           	    empty                   empty (example)
    #10.3.2.2               public--TMPLT                   empty             10.10.15.0/24         ipset4public--TMPLT                     fw_ports_set4public     rich_rules_set4public (example)
    #10.1.2.3,10.1.2.4      zone1--TMPLT                    eth0,eth1,ens01   empty                 empty                                   fw_ports_set4zone1      rich_rules_set4zone1 (example)
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
    #{'forward_ports_set'}=empty|fw_ports_set (FROM '04_conf_zone_forward_ports_sets')
    #{'rich_rules_set'}=empty|rich_rules_set (FROM '05_conf_zone_rich_rules_sets')
    ###

    my ($exec_res_l,$inv_host_l)=(undef,undef);
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my $arr_el0_l=undef;
    my @arr0_l=();
    my $zone_type_l=undef; # possible_values: custom, standard 
    my $fwzone_name_l=undef; # for fwzone_uniq_check
    my $return_str_l='OK';

    my %fwzone_uniq_check_l=(); # uniq for 'inv-host + firewall_zone_name(not tmplt)'
	#key=inv-host, key1=firewall_zone_name(not tmplt), value=firewall_zone_tmplt_name
    my %int_uniq_check_l=(); # uniq for 'inv-host + interface'
	#key0=inv-host, key1=interface, value=firewall_zone_tmplt_name
    my %src_uniq_check_l=(); # uniq for 'inv-host + source'
	#key0=inv-host, key1=source, value=firewall_zone_tmplt_name
    my %ipset_tmplt_uniq_check_l=(); # uniq for 'inv-host + impset-tmplt'
	#key0=inv-host, key1=ipset_tmplt_name, value=firewall_zone_tmplt_name
    my %res_tmp_lv0_l=();
	#key=inv-host, value=[array of values]. FIREWALL_ZONE_NAME_TMPLT-0, INTERFACE_LIST-1, etc
    my %res_tmp_lv1_l=();
	#final hash
    
    $exec_res_l=&read_config_FIN_level0($file_l,$inv_hosts_href_l,7,1,\%res_tmp_lv0_l); # protects from not uniq 'inv-host+fwzone-tmplt'
    #$file_l,$inv_hosts_href_l,$needed_elements_at_line_arr_l,$add_ind4key_l,$res_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }
    
    # fill %res_tmp_lv1_l (begin)
    while ( ($hkey0_l,$hval0_l)=each %res_tmp_lv0_l ) {
	#hval0_l=arr-ref for [FIREWALL_ZONE_NAME_TMPLT-0, INTERFACE_LIST-1, SOURCE_LIST-2, IPSET_TMPLT_LIST-3, FORWARD_PORTS_SET-4, RICH_RULES_SET-5]
	$inv_host_l=$hkey0_l;
	$inv_host_l=~s/\+\S+$//g;
	
	# FIREWALL_ZONE_NAME_TMPLT ops [0] (begin)
	#$h02_conf_custom_firewall_zones_templates_hash_g{zone_teplate_name--TMPLT}-> ... #{'zone_name'}
	    #$custom_zone_templates_href_l
	#$h02_conf_standard_firewall_zones_templates_hash_g{zone_teplate_name--TMPLT}-> ... #{'zone_name'}
	    #$std_zone_templates_href_l
	if ( exists(${$custom_zone_templates_href_l}{${$hval0_l}[0]}) ) {
	    $zone_type_l='custom';
	    $fwzone_name_l=${$custom_zone_templates_href_l}{${$hval0_l}[0]}{'zone_name'};
	}
	elsif ( exists(${$std_zone_templates_href_l}{${$hval0_l}[0]}) ) {
	    $zone_type_l='standard';
	    $fwzone_name_l=${$std_zone_templates_href_l}{${$hval0_l}[0]}{'zone_name'};
	}
	else {
	    $return_str_l="fail [$proc_name_l]. Fw-zone-tmplt='${$hval0_l}[0]' (conf='$file_l') is not exists at '02_conf_custom_firewall_zones_templates/02_conf_standard_firewall_zones_templates'";
	    last;
	}
	### (end)
	
	# fwzone_name uniq check
	if ( exists($fwzone_uniq_check_l{$inv_host_l}{$fwzone_name_l}) ) {
	    $return_str_l="fail [$proc_name_l]. Fwzone_name='$fwzone_name_l' (inv-host='$inv_host_l', fwzone-tmplt='${$hval0_l}[0]') is already assign to fwzone-tmplt='$fwzone_uniq_check_l{$inv_host_l}{$fwzone_name_l}' at conf='77_conf_zones_FIN'";
	    last;
	}
	$fwzone_uniq_check_l{$inv_host_l}{$fwzone_name_l}=${$hval0_l}[0];
	###
	
	# INTERFACE_LIST ops [1] (begin)
	if ( ${$hval0_l}[1]=~/^empty$/ ) { $res_tmp_lv1_l{$zone_type_l}{$inv_host_l}{${$hval0_l}[0]}{'interface_list'}{'empty'}=1; }
	else {
	    @arr0_l=split(/\,/,${$hval0_l}[1]);
	    foreach $arr_el0_l ( @arr0_l ) {
		#$arr_el0_l=interface name
		if ( !exists(${$inv_hosts_nd_href_l}{$inv_host_l}{$arr_el0_l}) ) {
		    $return_str_l="fail [$proc_name_l]. Interface='$arr_el0_l' is not exists at host='$inv_host_l' (conf='$file_l') at conf='77_conf_zones_FIN'";
		    last;
		}
		
		# check for 'interface is already belongs to fw-zone-tmplt'
		if ( !exists($int_uniq_check_l{$inv_host_l}{$arr_el0_l}) ) { $int_uniq_check_l{$inv_host_l}{$arr_el0_l}=${$hval0_l}[0]; }
		else {
		    $return_str_l="fail [$proc_name_l]. Interface='$arr_el0_l' is already used for fw-zone-tmplt='$int_uniq_check_l{$inv_host_l}{$arr_el0_l}' for inv-host='$inv_host_l' at conf='77_conf_zones_FIN'";
		    last;
		}
		###
		
		if ( !exists($res_tmp_lv1_l{$zone_type_l}{$inv_host_l}{${$hval0_l}[0]}{'interface_list'}{'list'}{$arr_el0_l}) ) {
		    $res_tmp_lv1_l{$zone_type_l}{$inv_host_l}{${$hval0_l}[0]}{'interface_list'}{'list'}{$arr_el0_l}=1;
		    push(@{$res_tmp_lv1_l{$zone_type_l}{$inv_host_l}{${$hval0_l}[0]}{'interface_list'}{'seq'}},$arr_el0_l);
		}
		else { # duplicate interface name
		    $return_str_l="fail [$proc_name_l]. Duplicated interface_name='$arr_el0_l' (conf='$file_l') for inv-host='$inv_host_l' and fw-zone-tmplt-name='${$hval0_l}[0] at conf='77_conf_zones_FIN'";
		    last;
		}
	    }
	    
	    @arr0_l=();
	    $arr_el0_l=undef;
	    
	    if ( $return_str_l!~/^OK$/ ) { last; }
	}
	### (end)
	
	# SOURCE_LIST ops [2] (begin)
	if ( ${$hval0_l}[2]=~/^empty$/ ) { $res_tmp_lv1_l{$zone_type_l}{$inv_host_l}{${$hval0_l}[0]}{'source_list'}{'empty'}=1; }
	else {
	    @arr0_l=split(/\,/,${$hval0_l}[2]);
	    foreach $arr_el0_l ( @arr0_l ) {
		#$arr_el0_l=source
		#if ( $arr_el0_l!~/some_regex/ ) {
		    #maybe need to add regex for check sources
		#}
		
		# check for 'source is already belongs to fw-zone-tmplt'
		if ( !exists($src_uniq_check_l{$inv_host_l}{$arr_el0_l}) ) { $src_uniq_check_l{$inv_host_l}{$arr_el0_l}=${$hval0_l}[0]; }
		else {
		    $return_str_l="fail [$proc_name_l]. Source='$arr_el0_l' is already used for fw-zone-tmplt='$src_uniq_check_l{$inv_host_l}{$arr_el0_l}' for inv-host='$inv_host_l' at conf='77_conf_zones_FIN'";
		    last;
		}
		###

		if ( !exists($res_tmp_lv1_l{$zone_type_l}{$inv_host_l}{${$hval0_l}[0]}{'source_list'}{'list'}{$arr_el0_l}) ) {
		    $res_tmp_lv1_l{$zone_type_l}{$inv_host_l}{${$hval0_l}[0]}{'source_list'}{'list'}{$arr_el0_l}=1;
		    push(@{$res_tmp_lv1_l{$zone_type_l}{$inv_host_l}{${$hval0_l}[0]}{'source_list'}{'seq'}},$arr_el0_l);
		}
		else { # duplicate source
		    $return_str_l="fail [$proc_name_l]. Duplicated source='$arr_el0_l' (conf='$file_l') for inv-host='$inv_host_l' and fw-zone-tmplt-name='${$hval0_l}[0] at conf='77_conf_zones_FIN'";
		    last;
		}
	    }
	    
	    @arr0_l=();
	    $arr_el0_l=undef;
	    
	    if ( $return_str_l!~/^OK$/ ) { last; }
	}
	### (end)
	
	# IPSET_TMPLT_LIST ops [3] (begin)
	if ( ${$hval0_l}[3]=~/^empty$/ ) { $res_tmp_lv1_l{$zone_type_l}{$inv_host_l}{${$hval0_l}[0]}{'ipset_tmplt_list'}{'empty'}=1; }
	else {
	    @arr0_l=split(/\,/,${$hval0_l}[3]);
	    foreach $arr_el0_l ( @arr0_l ) {
		#$arr_el0_l=ipset_tmplt_name
		#$ipset_templates_href_l=hash-ref for %h01_conf_ipset_templates_hash_g
		    #$h01_conf_ipset_templates_hash_g{'temporary/permanent'}{ipset_template_name--TMPLT}-> ... #{'ipset_name'}
		if ( !exists(${$ipset_templates_href_l}{'temporary'}{$arr_el0_l}) && !exists(${$ipset_templates_href_l}{'permanent'}{$arr_el0_l}) ) {
		    $return_str_l="fail [$proc_name_l]. IPSET_TMPLT_NAME='$arr_el0_l' (conf='$file_l') is not exists at '01_conf_ipset_templates'";
		    last;
		}
		
		#$h66_conf_ipsets_FIN_hash_g{'temporary/permanent'}{inventory_host}->
        	    #{ipset_name_tmplt-0}=1;
		if ( !exists(${$h66_conf_ipsets_FIN_href_l}{'temporary'}{$inv_host_l}{$arr_el0_l}) && !exists(${$h66_conf_ipsets_FIN_href_l}{'permanent'}{$inv_host_l}{$arr_el0_l}) ) {
		    $return_str_l="fail [$proc_name_l]. IPSET_TMPLT_NAME='$arr_el0_l' (conf='$file_l') is not exists at '66_conf_ipsets_FIN' for inv-host='$inv_host_l'";
		    last;
		}
		
		# check for 'ipset-tmplt is already belongs to fw-zone-tmplt'
		if ( exists($ipset_tmplt_uniq_check_l{$inv_host_l}{$arr_el0_l}) ) {
		    $return_str_l="fail [$proc_name_l]. IPSET-tmplt='$arr_el0_l' is already used for fwzone-tmplt='$ipset_tmplt_uniq_check_l{$inv_host_l}{$arr_el0_l}' for inv-host='$inv_host_l' at conf='77_conf_zones_FIN'";
		    last;    
		}
		$ipset_tmplt_uniq_check_l{$inv_host_l}{$arr_el0_l}=${$hval0_l}[0];
		###
		
		if ( !exists($res_tmp_lv1_l{$zone_type_l}{$inv_host_l}{${$hval0_l}[0]}{'ipset_tmplt_list'}{'list'}{$arr_el0_l}) ) {
		    $res_tmp_lv1_l{$zone_type_l}{$inv_host_l}{${$hval0_l}[0]}{'ipset_tmplt_list'}{'list'}{$arr_el0_l}=1;
		    push(@{$res_tmp_lv1_l{$zone_type_l}{$inv_host_l}{${$hval0_l}[0]}{'ipset_tmplt_list'}{'seq'}},$arr_el0_l);
		}
		else { # duplicate ipset_template_name
		    $return_str_l="fail [$proc_name_l]. Duplicated ipset_tmplt_name='$arr_el0_l' (conf='$file_l') for inv-host='$inv_host_l' and fw-zone-tmplt-name='${$hval0_l}[0] at conf='77_conf_zones_FIN'";
		    last;
		}
	    }
	    
	    @arr0_l=();
	    $arr_el0_l=undef;
	    
	    if ( $return_str_l!~/^OK$/ ) { last; }
	}
	### (end)
	
	# FORWARD_PORTS_SET ops [4] (begin)
	if ( ${$hval0_l}[4]=~/^empty$/ ) { $res_tmp_lv1_l{$zone_type_l}{$inv_host_l}{${$hval0_l}[0]}{'forward_ports_set'}='empty'; }
	else {
	    #$fw_ports_set_href_l=hash-ref for %h04_conf_zone_forward_ports_sets_hash_g
    		#$h04_conf_zone_forward_ports_sets_hash_g{set_name}-> ...
	    if ( !exists(${$fw_ports_set_href_l}{${$hval0_l}[4]}) ) {
		$return_str_l="fail [$proc_name_l]. FORWARD_PORTS_SET='${$hval0_l}[4]' (conf='$file_l) is not exists at '04_conf_zone_forward_ports_sets' (conf='77_conf_zones_FIN')";
		last;
	    }
	    else { $res_tmp_lv1_l{$zone_type_l}{$inv_host_l}{${$hval0_l}[0]}{'forward_ports_set'}=${$hval0_l}[4]; }
	}
	### (end)

	# RICH_RULES_SET ops [5] (begin)
	if ( ${$hval0_l}[5]=~/^empty$/ ) { $res_tmp_lv1_l{$zone_type_l}{$inv_host_l}{${$hval0_l}[0]}{'rich_rules_set'}='empty'; }
	else {
	    #$rich_rules_set_href_l=hash-ref for %h05_conf_zone_rich_rules_sets_hash_g
    		#$h05_conf_zone_rich_rules_sets_hash_g{set_name}-> ...
	    if ( !exists(${$rich_rules_set_href_l}{${$hval0_l}[5]}) ) {
		$return_str_l="fail [$proc_name_l]. RICH_RULES_SET='${$hval0_l}[5]' (conf='$file_l) is not exists at '05_conf_zone_rich_rules_sets' (conf='77_conf_zones_FIN')";
		last;
	    }
	    else { $res_tmp_lv1_l{$zone_type_l}{$inv_host_l}{${$hval0_l}[0]}{'rich_rules_set'}=${$hval0_l}[5]; }
	}
	### (end)
    }
    
    ($hkey0_l,$hval0_l)=(undef,undef);
    $inv_host_l=undef;
    $fwzone_name_l=undef;
    
    if ( $return_str_l!~/^OK$/ ) { return $return_str_l; }
    ### fill %res_tmp_lv1_l (end)
    
    # fill result hash
    %{$res_href_l}=%res_tmp_lv1_l;
    ###

    %res_tmp_lv1_l=();

    return $return_str_l;
}

sub read_88_conf_policies_FIN {
    my ($file_l,$input_hash4proc_href_l,$res_href_l)=@_;
    #$file_l=$f88_conf_policies_FIN_path_g
    #$input_hash4proc_href_l=hash-ref for %input_hash4proc_g (hash with hash refs for input)
    #$res_href_l=hash ref for %h88_conf_policies_FIN_hash_g
    
    my $inv_hosts_href_l=${$input_hash4proc_href_l}{'inventory_hosts_href'};
    #inv_hosts_href_l=hash-ref for %inventory_hosts_g
    
    my $policy_templates_href_l=${$input_hash4proc_href_l}{'h03_conf_policy_templates_href'};
    #$policy_templates_href_l=hash-ref for %h03_conf_policy_templates_hash_g
	#$h03_conf_policy_templates_hash_g{policy_tmplt_name--TMPLT}-> ... #{'policy_name'}
    
    my $custom_zone_templates_href_l=${$input_hash4proc_href_l}{'h02_conf_custom_firewall_zones_templates_href'};    
    #$custom_zone_templates_href_l=hash-ref for %h02_conf_custom_firewall_zones_templates_hash_g

    my $std_zone_templates_href_l=${$input_hash4proc_href_l}{'h02_conf_standard_firewall_zones_templates_href'};
    #$std_zone_templates_href_l=hash-ref for %h02_conf_standard_firewall_zones_templates_hash_g
    
    my $fw_ports_set_href_l=${$input_hash4proc_href_l}{'h04_conf_zone_forward_ports_sets_href'};
    #$fw_ports_set_href_l=hash-ref for %h04_conf_zone_forward_ports_sets_hash_g
    
    my $rich_rules_set_href_l=${$input_hash4proc_href_l}{'h05_conf_zone_rich_rules_sets_href'};
    #$rich_rules_set_href_l=hash-ref for %h05_conf_zone_rich_rules_sets_hash_g
    
    my $h77_conf_zones_FIN_href_l=${$input_hash4proc_href_l}{'h77_conf_zones_FIN_href'};
    #$h77_conf_zones_FIN_href_l=hash-ref for %h77_conf_zones_FIN_hash_g
	#$h77_conf_zones_FIN_hash_g{'custom/standard'}{inventory_host}{firewall_zone_name_tmplt}->
    
    my $proc_name_l=(caller(0))[3];

    #INVENTORY_HOST         #POLICY_NAME_TMPLT              #INGRESS-FIREWALL_ZONE_NAME_TMPLT       #EGRESS-FIREWALL_ZONE_NAME_TMPLT        #FORWARD_PORTS_SET      #RICH_RULES_SET
    #all                    policy_public2home--TMPLT       public--TMPLT                           home--TMPLT                             fw_ports_set1           rich_rules_set1 (example)
    #10.3.2.2               policy_zoneone2zonetwo--TMPLT   zoneone--TMPLT                          zonetwo--TMPLT                          fw_ports_set2           rich_rules_set2 (example)
    ###
    #$h88_conf_policies_FIN_hash_g{inventory_host}{policy_name_tmplt}->
    #{'ingress-firewall_zone_name_tmplt'}=value
    #{'egress-firewall_zone_name_tmplt'}=value
    #{'forward_ports_set'}=empty|fw_ports_set (FROM '04_conf_zone_forward_ports_sets')
    #{'rich_rules_set'}=empty|rich_rules_set (FROM '05_conf_zone_rich_rules_sets')
    ###

    my ($exec_res_l,$inv_host_l)=(undef,undef);
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my $policy_name_l=undef;
    my ($ingress_zone_name_l,$egress_zone_name_l)=(undef,undef); # for ingress_egress_uniq_check_l
    my $return_str_l='OK';
    
    my %policy_name_uniq_check_l=(); # uniq check for 'inv-host + policy_name (not tmplt)'
    	#key0=inv-host, key1=policy_name (not_tmplt), value=policy-tmplt-name
    
    my %ingress_egress_tmplt_uniq_check_l=(); # uniq for 'inv_host + ingress_zone_tmplt + egress_zone_tmplt'
    	#key0=inv_host, key1=ingress_zone_tmplt, key2=egress_zone_tmplt, value=policy_tmplt

    my %policy_ingress_egress_uniq_check_l=(); # uniq for 'inv_host + policy_name + ingress_zone_name + egress_zone_name'
    	#key0=inv_host, key1=policy_name (not tmplt), key2=ingress_zone_name (not tmplt), key3=egress_zone_name (not tmplt), value=policy_tmplt -> policy_name
    
    my %res_tmp_lv0_l=();
    	#key=inv-host, value=[array of values]. POLICY_NAME_TMPLT-0, INGRESS-FIREWALL_ZONE_NAME_TMPLT-1, etc
    my %res_tmp_lv1_l=();
    	#final hash
        
    $exec_res_l=&read_config_FIN_level0($file_l,$inv_hosts_href_l,6,1,\%res_tmp_lv0_l); #protects from not uniq 'inv-host+policy-tmplt'
    #$file_l,$inv_hosts_href_l,$needed_elements_at_line_arr_l,$add_ind4key_l,$res_href_l
    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }
    
    # fill %res_tmp_lv1_l
    while ( ($hkey0_l,$hval0_l)=each %res_tmp_lv0_l ) {
	#hval0_l=arr-ref for [#POLICY_NAME_TMPLT-0 #INGRESS-FIREWALL_ZONE_NAME_TMPLT-1 #EGRESS-FIREWALL_ZONE_NAME_TMPLT-2 #FORWARD_PORTS_SET-3 #RICH_RULES_SET-4]
	$inv_host_l=$hkey0_l;
        $inv_host_l=~s/\+\S+$//g;
	
	# POLICY_NAME_TMPLT ops [0]
	    #$policy_templates_href_l=hash-ref for %h03_conf_policy_templates_hash_g
    		#$h03_conf_policy_templates_hash_g{policy_tmplt_name--TMPLT}->
	if ( !exists(${$policy_templates_href_l}{${$hval0_l}[0]}) ) {
	    $return_str_l="fail [$proc_name_l]. POLICY_NAME_TMPLT='${$hval0_l}[0]' (conf='$file_l') is not exists at '03_conf_policy_templates'";
            last;
	}
	$policy_name_l=${$policy_templates_href_l}{${$hval0_l}[0]}{'policy_name'};
	###
	
	# check for uniq policy_name
	    #%policy_name_uniq_check_l=(); # uniq check for 'inv-host + policy_name (not tmplt)'
    		#key0=inv-host, key1=policy_name (not_tmplt), value=policy-tmplt-name

	if ( exists($policy_name_uniq_check_l{$inv_host_l}{$policy_name_l}) ) {
	    $return_str_l="fail [$proc_name_l]. Policy_name='$policy_name_l' (inv-host='$inv_host_l', policy-tmplt='${$hval0_l}[0]') is already assign to policy-tmplt='$policy_name_uniq_check_l{$inv_host_l}{$policy_name_l}' at conf='88_conf_policies_FIN'";
	    last;
	}
	$policy_name_uniq_check_l{$inv_host_l}{$policy_name_l}=${$hval0_l}[0];
	###
	
	# INGRESS-FIREWALL_ZONE_NAME_TMPLT ops [1]
	if ( exists(${$custom_zone_templates_href_l}{${$hval0_l}[1]}) ) { $ingress_zone_name_l=${$custom_zone_templates_href_l}{${$hval0_l}[1]}{'zone_name'}; }
	elsif ( exists(${$std_zone_templates_href_l}{${$hval0_l}[1]}) ) { $ingress_zone_name_l=${$std_zone_templates_href_l}{${$hval0_l}[1]}{'zone_name'}; }
	else {
	    $return_str_l="fail [$proc_name_l]. Ingress-fw-zone-tmplt='${$hval0_l}[1]' (conf='$file_l') is not exists at '02_conf_custom_firewall_zones_templates/02_conf_standard_firewall_zones_templates'";
	    last;
	}
	
	#$h77_conf_zones_FIN_href_l=hash-ref for %h77_conf_zones_FIN_hash_g
	    #$h77_conf_zones_FIN_hash_g{'custom/standard'}{inventory_host}{firewall_zone_name_tmplt}->
	if ( !exists(${$h77_conf_zones_FIN_href_l}{'custom'}{$inv_host_l}{${$hval0_l}[1]}) && !exists(${$h77_conf_zones_FIN_href_l}{'standard'}{$inv_host_l}{${$hval0_l}[1]}) ) {
	    $return_str_l="fail [$proc_name_l]. Ingress-fw-zone-tmplt='${$hval0_l}[1]' (conf='$file_l') is not exists at '77_conf_zones_FIN' for inv-host='$inv_host_l'";
	    last;
	}
	
	$res_tmp_lv1_l{$inv_host_l}{${$hval0_l}[0]}{'ingress-firewall_zone_name_tmplt'}=${$hval0_l}[1];
	###
	
	# EGRESS-FIREWALL_ZONE_NAME_TMPLT ops [2]
	if ( exists(${$custom_zone_templates_href_l}{${$hval0_l}[2]}) ) { $egress_zone_name_l=${$custom_zone_templates_href_l}{${$hval0_l}[1]}{'zone_name'}; }
	elsif ( exists(${$std_zone_templates_href_l}{${$hval0_l}[2]}) ) { $egress_zone_name_l=${$std_zone_templates_href_l}{${$hval0_l}[1]}{'zone_name'}; }
	else {
	    $return_str_l="fail [$proc_name_l]. Egress-fw-zone-tmplt='${$hval0_l}[2]' (conf='$file_l') is not exists at '02_conf_custom_firewall_zones_templates/02_conf_standard_firewall_zones_templates'";
	    last;
	}
	
	#$h77_conf_zones_FIN_href_l=hash-ref for %h77_conf_zones_FIN_hash_g
	    #$h77_conf_zones_FIN_hash_g{'custom/standard'}{inventory_host}{firewall_zone_name_tmplt}->
	if ( !exists(${$h77_conf_zones_FIN_href_l}{'custom'}{$inv_host_l}{${$hval0_l}[2]}) && !exists(${$h77_conf_zones_FIN_href_l}{'standard'}{$inv_host_l}{${$hval0_l}[2]}) ) {
	    $return_str_l="fail [$proc_name_l]. Ingress-fw-zone-tmplt='${$hval0_l}[2]' (conf='$file_l') is not exists at '77_conf_zones_FIN' for inv-host='$inv_host_l'";
	    last;
	}

	$res_tmp_lv1_l{$inv_host_l}{${$hval0_l}[0]}{'egress-firewall_zone_name_tmplt'}=${$hval0_l}[2];
	###
	
	# CHECK for uniq 'inv-host + ingress-zone-tmplt + egress-zone-tmplt'
	    #%ingress_egress_tmplt_uniq_check_l=(); # uniq for 'inv_host + ingress_zone_tmplt + egress_zone_tmplt'
    	        #key0=inv_host, key1=ingress_zone_tmplt, key2=egress_zone_tmplt, value=policy_tmplt
	if ( exists($ingress_egress_tmplt_uniq_check_l{$inv_host_l}{${$hval0_l}[1]}{${$hval0_l}[2]}) ) {
	    $return_str_l="fail [$proc_name_l]. Incorrect policy-tmplt='${$hval0_l}[0]' for inv-host='$inv_host_l'. Pair = '${$hval0_l}[1]' (ingress-zone-tmplt) + '${$hval0_l}[2]' (egress-zone-tmplt) is already used for policy-tmplt='$ingress_egress_tmplt_uniq_check_l{$inv_host_l}{${$hval0_l}[1]}{${$hval0_l}[2]}'";
	    last;
	}
	$ingress_egress_tmplt_uniq_check_l{$inv_host_l}{${$hval0_l}[1]}{${$hval0_l}[2]}=${$hval0_l}[0];
	###

	# CHECK for uniq 'inv-host + policy-name + ingress-zone-name + egress-zone-name'
	    #%policy_ingress_egress_uniq_check_l=(); # uniq for 'inv_host + policy_name + ingress_zone_name + egress_zone_name'
    		#key0=inv_host, key1=policy_name (not tmplt), key2=ingress_zone_name (not tmplt), key3=egress_zone_name (not tmplt), value=policy_tmplt -> policy_name
	if ( exists($policy_ingress_egress_uniq_check_l{$inv_host_l}{$policy_name_l}{$ingress_zone_name_l}{$egress_zone_name_l}) ) {
	    $return_str_l="fail [$proc_name_l]. Incorrect policy-tmplt='${$hval0_l}[0]' for inv-host='$inv_host_l'. Complex-key = '$policy_name_l' (policy-name) + '${$hval0_l}[1]' (ingress-zone-name) + '${$hval0_l}[2]' (egress-zone-name) is already used for policy-tmplt='$policy_ingress_egress_uniq_check_l{$inv_host_l}{$policy_name_l}{$ingress_zone_name_l}{$egress_zone_name_l}'";
	    last;
	}
	$policy_ingress_egress_uniq_check_l{$inv_host_l}{$policy_name_l}{$ingress_zone_name_l}{$egress_zone_name_l}=${$hval0_l}[0];
	###

	# FORWARD_PORTS_SET ops [3]
	if ( ${$hval0_l}[3]=~/^empty$/ ) { $res_tmp_lv1_l{$inv_host_l}{'forward_ports_set'}='empty'; }
        else {
            #$fw_ports_set_href_l=hash-ref for %h04_conf_zone_forward_ports_sets_hash_g
                #$h04_conf_zone_forward_ports_sets_hash_g{set_name}-> ...
            if ( !exists(${$fw_ports_set_href_l}{${$hval0_l}[3]}) ) {
                $return_str_l="fail [$proc_name_l]. FORWARD_PORTS_SET='${$hval0_l}[3]' (conf='$file_l) is not exists at '04_conf_zone_forward_ports_sets'";
                last;
            }
            else { $res_tmp_lv1_l{$inv_host_l}{${$hval0_l}[0]}{'forward_ports_set'}=${$hval0_l}[3]; }
        }
	###
	
	# RICH_RULES_SET ops [4]
	if ( ${$hval0_l}[4]=~/^empty$/ ) { $res_tmp_lv1_l{$inv_host_l}{'rich_rules_set'}='empty'; }
	else {
	    #$rich_rules_set_href_l=hash-ref for %h05_conf_zone_rich_rules_sets_hash_g
    		#$h05_conf_zone_rich_rules_sets_hash_g{set_name}-> ...
	    if ( !exists(${$rich_rules_set_href_l}{${$hval0_l}[4]}) ) {
		$return_str_l="fail [$proc_name_l]. RICH_RULES_SET='${$hval0_l}[4]' (conf='$file_l) is not exists at '05_conf_zone_rich_rules_sets'";
		last;
	    }
	    else { $res_tmp_lv1_l{$inv_host_l}{${$hval0_l}[0]}{'rich_rules_set'}=${$hval0_l}[4]; }
	}
	###
    }
    
    ($hkey0_l,$hval0_l)=(undef,undef);
    $inv_host_l=undef;
    $policy_name_l=undef;
    
    if ( $return_str_l!~/^OK$/ ) { return $return_str_l; }
    ###
    
    # fill result hash
    %{$res_href_l}=%res_tmp_lv1_l;
    ###

    %res_tmp_lv1_l=();

    return $return_str_l;
}

sub generate_shell_script_for_recreate_ipsets {
    my ($dyn_fwrules_playbooks_dir_l,$remote_dir_for_absible_helper_l,$ipset_templates_href_l,$h66_conf_ipsets_FIN_href_l)=@_;
    #$dyn_fwrules_playbooks_dir_l=$dyn_fwrules_playbooks_dir_g
    #$remote_dir_for_absible_helper_l=$remote_dir_for_absible_helper_g
    #$ipset_templates_href_l=hash-ref for %h01_conf_ipset_templates_hash_g
    #$conf_ipsets_href_l=hash ref for %h66_conf_ipsets_FIN_hash_g
    my $proc_name_l=(caller(0))[3];

    #$h01_conf_ipset_templates_hash_g{'temporary/permanent'}{ipset_template_name--TMPLT}->
    #{'ipset_name'}=value
    #{'ipset_description'}=empty|value
    #{'ipset_short_description'}=empty|value
    #{'ipset_create_option_timeout'}=num
    #{'ipset_create_option_hashsize'}=num
    #{'ipset_create_option_maxelem'}=num
    #{'ipset_create_option_family'}=inet|inet6
    #{'ipset_type'}=hash:ip|hash:ip,port|hash:ip,mark|hash:net|hash:net,port|hash:net,iface|hash:mac|hash:ip,port,ip|hash:ip,port,net|hash:net,net|hash:net,port,net
    ###
    #$h66_conf_ipsets_FIN_hash_g{'temporary/permanent'}{inventory_host}->
    	#{ipset_name_tmplt-0}=1;
    	#{ipset_name_tmplt-1}=1;
    	#etc
    ###

    my $exec_res_l=undef;
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my $arr_el0_l=undef;
    my $wr_str_l=undef;
    my $wr_file_l=undef;
    my @wr_arr_l=();
    my @tmp_arr_l=();
    my %wr_hash_l=();
	#key=inv-host, value=array of strings
    my %permanet_ipset_names_l=(); # permanent ipset names (not tmplt names) at each inv-host
	#key=inv-host, value=array of permanent ipset names at current inv-host
    my $return_str_l='OK';
    
    # fill array (for each host) with commands for recreate temporary ipsets
    #"firewall-cmd --permanent --new-ipset=some_ipset_name --type=hash:net --set-description=some_description --set-short=some_short_description --option=timeout=0
	# --option=family=inet --option=hashsize=4096 --option=maxelem=200000"
    while ( ($hkey0_l,$hval0_l)=each %{${$h66_conf_ipsets_FIN_href_l}{'temporary'}} ) {
    	#$hkey0_l=inv-host
	
	@tmp_arr_l=sort(keys %{$hval0_l});
    	foreach $arr_el0_l ( @tmp_arr_l ) {
	    #$arr_el0_l=ipset_tmplt_name
	    if ( !exists(${$ipset_templates_href_l}{'temporary'}{$arr_el0_l}) ) {
		$return_str_l="fail [$proc_name_l]. Ipset-template is not exists at '01_conf_ipset_templates'";
		last;
	    }
	    
	    $wr_str_l="firewall-cmd --permanent";
	    $wr_str_l.=" --new-ipset=".${$ipset_templates_href_l}{'temporary'}{$arr_el0_l}{'ipset_name'};
	    $wr_str_l.=" --type=".${$ipset_templates_href_l}{'temporary'}{$arr_el0_l}{'ipset_type'};
	    if ( ${$ipset_templates_href_l}{'temporary'}{$arr_el0_l}{'ipset_description'}!~/^empty$/ ) {
		$wr_str_l.=" --set-description=".${$ipset_templates_href_l}{'temporary'}{$arr_el0_l}{'ipset_description'};
	    }
	    if ( ${$ipset_templates_href_l}{'temporary'}{$arr_el0_l}{'ipset_description'}!~/^empty$/ ) {
		$wr_str_l.=" --set-short=".${$ipset_templates_href_l}{'temporary'}{$arr_el0_l}{'ipset_short_description'};
	    }
	    $wr_str_l.=" --option=timeout=".${$ipset_templates_href_l}{'temporary'}{$arr_el0_l}{'ipset_create_option_timeout'};
	    $wr_str_l.=" --option=family=".${$ipset_templates_href_l}{'temporary'}{$arr_el0_l}{'ipset_create_option_family'};
	    $wr_str_l.=" --option=hashsize=".${$ipset_templates_href_l}{'temporary'}{$arr_el0_l}{'ipset_create_option_hashsize'};
	    $wr_str_l.=" --option=maxelem=".${$ipset_templates_href_l}{'temporary'}{$arr_el0_l}{'ipset_create_option_maxelem'}.";";
	    
	    push(@wr_arr_l,$wr_str_l);
	    
	    $wr_str_l=undef;
	}
	
	if ( $#wr_arr_l!=-1 ) {
	    push(@wr_arr_l,' ');
	    @{$wr_hash_l{$hkey0_l}}=@wr_arr_l;
	    @wr_arr_l=();
	}
	else { @{$wr_hash_l{$hkey0_l}}=(); }
	
	$arr_el0_l=undef;
	
	if ( $return_str_l!~/^OK$/ ) { last; }
    }
    
    ($hkey0_l,$hval0_l)=(undef,undef);
    
    if ( $return_str_l!~/^OK$/ ) { return $return_str_l; }
    ###
    
    # fill array (for each host) with commands for recreate permanent ipsets
    while ( ($hkey0_l,$hval0_l)=each %{${$h66_conf_ipsets_FIN_href_l}{'permanent'}} ) {
    	#$hkey0_l=inv-host
    
	@tmp_arr_l=sort(keys %{$hval0_l});
    	foreach $arr_el0_l ( @tmp_arr_l ) {
    	    #$arr_el0_l=ipset_tmplt_name
    	    if ( !exists(${$ipset_templates_href_l}{'permanent'}{$arr_el0_l}) ) {
    		$return_str_l="fail [$proc_name_l]. Ipset-template is not exists at '01_conf_ipset_templates'";
    		last;
    	    }
	    
	    push(@{$permanet_ipset_names_l{$hkey0_l}},${$ipset_templates_href_l}{'permanent'}{$arr_el0_l}{'ipset_name'});
	    
	    $wr_str_l="firewall-cmd --permanent";
	    $wr_str_l.=" --new-ipset=".${$ipset_templates_href_l}{'permanent'}{$arr_el0_l}{'ipset_name'};
	    $wr_str_l.=" --type=".${$ipset_templates_href_l}{'permanent'}{$arr_el0_l}{'ipset_type'};
	    if ( ${$ipset_templates_href_l}{'permanent'}{$arr_el0_l}{'ipset_description'}!~/^empty$/ ) {
		$wr_str_l.=" --set-description=".${$ipset_templates_href_l}{'permanent'}{$arr_el0_l}{'ipset_description'};
	    }
	    if ( ${$ipset_templates_href_l}{'permanent'}{$arr_el0_l}{'ipset_description'}!~/^empty$/ ) {
		$wr_str_l.=" --set-short=".${$ipset_templates_href_l}{'permanent'}{$arr_el0_l}{'ipset_short_description'};
	    }
	    $wr_str_l.=" --option=timeout=".${$ipset_templates_href_l}{'permanent'}{$arr_el0_l}{'ipset_create_option_timeout'};
	    $wr_str_l.=" --option=family=".${$ipset_templates_href_l}{'permanent'}{$arr_el0_l}{'ipset_create_option_family'};
	    $wr_str_l.=" --option=hashsize=".${$ipset_templates_href_l}{'permanent'}{$arr_el0_l}{'ipset_create_option_hashsize'};
	    $wr_str_l.=" --option=maxelem=".${$ipset_templates_href_l}{'permanent'}{$arr_el0_l}{'ipset_create_option_maxelem'}.";";
	    
	    push(@wr_arr_l,$wr_str_l);
	    
	    $wr_str_l=undef;
    	}
    	
	if ( $#wr_arr_l!=-1 ) {
	    push(@wr_arr_l,' ');
	    @{$wr_hash_l{$hkey0_l}}=(@{$wr_hash_l{$hkey0_l}},@wr_arr_l);
	    @wr_arr_l=();
	}
	else { @{$wr_hash_l{$hkey0_l}}=(); }

    	$arr_el0_l=undef;
    	
    	if ( $return_str_l!~/^OK$/ ) { last; }
    }
    
    ($hkey0_l,$hval0_l)=(undef,undef);
    
    if ( $return_str_l!~/^OK$/ ) { return $return_str_l; }
    ###
    
    # create scripts for copy to remote hosts
    while ( ($hkey0_l,$hval0_l)=each %wr_hash_l ) {
	#hkey0_l=inv-host
	
	@wr_arr_l=@{$hval0_l};
	
	if ( $#wr_arr_l!=-1 ) {
	    $wr_file_l=$dyn_fwrules_playbooks_dir_g.'/'.$hkey0_l.'_recreate_ipsets.sh';
	    
	    # 1) form array of commands for remove ipset xml-s
		#rm -rf  /etc/firewalld/ipsets/* +
		#or "firewall-cmd --permanent --delete-ipset=some_ipset_name"
	    @wr_arr_l=(' ','rm -rf  /etc/firewalld/ipsets/*;',' ',@wr_arr_l);
	    ###

	    # 2) form array of commands for get and save ipset entries (for permanent ipsets) and save it to the '$remote_dir_for_absible_helper_l'
		#"firewall-cmd --permanent --ipset=some_ipset_name --get-entries"
		###
		#%permanet_ipset_names_l=(); # permanent ipset names (not tmplt names) at each inv-host
    		    #key=inv-host, value=array of permanent ipset names at current inv-host
	    if ( exists($permanet_ipset_names_l{$hkey0_l}) ) {
		foreach $arr_el0_l ( @{$permanet_ipset_names_l{$hkey0_l}} ) {
		    #arr_el0_l=permanent ipset name
		    $wr_str_l="firewall-cmd --permanent --ipset=$arr_el0_l --get-entries > $remote_dir_for_absible_helper_l/$arr_el0_l".'-list.txt;';
		    @wr_arr_l=($wr_str_l,@wr_arr_l);
		}
	    }
	    ###
	    
	    # insert compiler path at the begin of the script
	    @wr_arr_l=('#!/usr/bin/bash',' ','###GENERATED BY ansible_helpers/conf_firewalld (https://github.com/vladimir-chursin000/ansible_helpers)','###DO NOT CHANGE!',' ',@wr_arr_l);
	    ###

	    # 3) form array of commands for add saved entries to permanent ipsets (for add to end of the wr_array_l)
		#"firewall-cmd --permanent --ipset=some_ipset_name --add-entries-from-file=some_ipset_list.txt"
	    if ( exists($permanet_ipset_names_l{$hkey0_l}) ) {
		foreach $arr_el0_l ( @{$permanet_ipset_names_l{$hkey0_l}} ) {
		    #arr_el0_l=permanent ipset name
		    $wr_str_l="firewall-cmd --permanent --ipset=$arr_el0_l --add-entries-from-file=\"$remote_dir_for_absible_helper_l/$arr_el0_l".'-list.txt";';
		    push(@wr_arr_l,$wr_str_l);
		}
	    }	    
	    ###
	    
	    $exec_res_l=&rewrite_file_from_array_ref($wr_file_l,\@wr_arr_l);
	    #$file_l,$aref_l
	    if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }
	    
	    $wr_file_l=undef;
	    @wr_arr_l=();
	}
	
	@wr_arr_l=();	
    }
    ###

    return $return_str_l;
}

sub generate_shell_script_for_recreate_firewall_zones {
    my ($dyn_fwrules_playbooks_dir_l,$input_hash4proc_href_l)=@_;
    #$dyn_fwrules_playbooks_dir_l=$dyn_fwrules_playbooks_dir_g
    #$input_hash4proc_href_l=hash-ref for %input_hash4proc_g (hash with hash refs for input)
    
    my $conf_firewalld_href_l=${$input_hash4proc_href_l}{'h00_conf_firewalld_href'};
    #$conf_firewalld_href_l=hash-ref for %h00_conf_firewalld_hash_g
	#$h00_conf_firewalld_hash_g{inventory_host}->
    
    my $ipset_templates_href_l=${$input_hash4proc_href_l}{'h01_conf_ipset_templates_href'};
    #$ipset_templates_href_l=hash-ref for %h01_conf_ipset_templates_hash_g
    	#$h01_conf_ipset_templates_hash_g{'temporary/permanent'}{ipset_template_name--TMPLT}->

    my $std_zone_templates_href_l=${$input_hash4proc_href_l}{'h02_conf_standard_firewall_zones_templates_href'};
    #$std_zone_templates_href_l=hash-ref for %h02_conf_standard_firewall_zones_templates_hash_g

    my $custom_zone_templates_href_l=${$input_hash4proc_href_l}{'h02_conf_custom_firewall_zones_templates_href'};
    #$custom_zone_templates_href_l=hash-ref for %h02_conf_custom_firewall_zones_templates_hash_g
    
    my $fw_ports_set_href_l=${$input_hash4proc_href_l}{'h04_conf_zone_forward_ports_sets_href'};
    #$fw_ports_set_href_l=hash-ref for %h04_conf_zone_forward_ports_sets_hash_g
    	#$h04_conf_zone_forward_ports_sets_hash_g{set_name}->
    
    my $rich_rules_set_href_l=${$input_hash4proc_href_l}{'h05_conf_zone_rich_rules_sets_href'};
    #$rich_rules_set_href_l=hash-ref for %h05_conf_zone_rich_rules_sets_hash_g
    	#$h05_conf_zone_rich_rules_sets_hash_g{set_name}->
    
    my $h77_conf_zones_FIN_href_l=${$input_hash4proc_href_l}{'h77_conf_zones_FIN_href'};
    #$h77_conf_zones_FIN_href_l=hash-ref for %h77_conf_zones_FIN_hash_g
	#$h77_conf_zones_FIN_hash_g{'custom/standard'}{inventory_host}{firewall_zone_name_tmplt}->
    
    my $proc_name_l=(caller(0))[3];

    #$h00_conf_firewalld_hash_g{inventory_host}->
    #{'unconfigured_custom_firewall_zones_action'}=no_action|remove
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
    #$h04_conf_zone_forward_ports_sets_hash_g{set_name}->
        #{'rule-0'}=1
        #{'rule-1'}=1
        #etc
        #{'seq'}=[val-0,val-1] (val=rule)
    ######
    #$h05_conf_zone_rich_rules_sets_hash_g{set_name}->
        #{'rule-0'}=1
        #{'rule-1'}=1
        #etc
        #{'seq'}=[val-0,val-1] (val=rule)
    ######
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
    #{'forward_ports_set'}=empty|fw_ports_set (FROM '04_conf_zone_forward_ports_sets')
    #{'rich_rules_set'}=empty|rich_rules_set (FROM '05_conf_zone_rich_rules_sets')
    ######

    my $exec_res_l=undef;
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my ($hkey1_l,$hval1_l)=(undef,undef);
    my $arr_el0_l=undef;
    my $wr_str_l=undef;
    my $wr_file_l=undef;
    my $unconf_custom_fw_zones_act_l=undef;
    my @wr_arr_l=();
    my @tmp_arr_l=();
    my %wr_hash_l=();
	#key0=inv-host, key1=wr_type (standard, custom, etc), value=array of strings
    my $return_str_l='OK';
    
    my @begin_script_arr_l=('#!/usr/bin/bash',' ','###GENERATED BY ansible_helpers/conf_firewalld (https://github.com/vladimir-chursin000/ansible_helpers)','###DO NOT CHANGE!',' ');
    
    # fill array (for each host) with commands for recreate standard fw-zones
    while ( ($hkey0_l,$hval0_l)=each %{${$h77_conf_zones_FIN_href_l}{'standard'}} ) {
    	#$hkey0_l=inv-host
    	
    	#%wr_hash_l=();
    	    #key0=inv-host, key1=wr_type (standard, custom, etc), value=array of strings
    	@tmp_arr_l=sort(keys %{$hval0_l});
    	foreach $arr_el0_l ( @tmp_arr_l ) {
    	    #$arr_el0_l=fw-zone-tmplt-name
    	    
    	}
    }
    
    ($hkey0_l,$hval0_l)=(undef,undef);
    
    if ( $return_str_l!~/^OK$/ ) { return $return_str_l; }
    ###
    
    # fill array (for each host) with commands for recreate custom fw-zones
    while ( ($hkey0_l,$hval0_l)=each %{${$h77_conf_zones_FIN_href_l}{'custom'}} ) {
    	#$hkey0_l=inv-host
    	
    	#%wr_hash_l=();
    	    #key0=inv-host, key1=wr_type (standard, custom, etc), value=array of strings
    	@tmp_arr_l=sort(keys %{$hval0_l});
    	foreach $arr_el0_l ( @tmp_arr_l ) {
    	    #$arr_el0_l=fw-zone-tmplt-name
    	    
    	}
    }
    
    ($hkey0_l,$hval0_l)=(undef,undef);
    
    if ( $return_str_l!~/^OK$/ ) { return $return_str_l; }
    ###
    
    return $return_str_l;
}

sub generate_shell_script_for_recreate_policies {
    my ($dyn_fwrules_playbooks_dir_l,$input_hash4proc_href_l)=@_;
    #$dyn_fwrules_playbooks_dir_l=$dyn_fwrules_playbooks_dir_g
    #$input_hash4proc_href_l=hash-ref for %input_hash4proc_g (hash with hash refs for input)
    
    my $ipset_templates_href_l=${$input_hash4proc_href_l}{'h01_conf_ipset_templates_href'};
    #$ipset_templates_href_l=hash-ref for %h01_conf_ipset_templates_hash_g
    	#$h01_conf_ipset_templates_hash_g{'temporary/permanent'}{ipset_template_name--TMPLT}->

    my $custom_zone_templates_href_l=${$input_hash4proc_href_l}{'h02_conf_custom_firewall_zones_templates_href'};
    #$custom_zone_templates_href_l=hash-ref for %h02_conf_custom_firewall_zones_templates_hash_g
    
    my $std_zone_templates_href_l=${$input_hash4proc_href_l}{'h02_conf_standard_firewall_zones_templates_href'};
    #$std_zone_templates_href_l=hash-ref for %h02_conf_standard_firewall_zones_templates_hash_g
        
    my $fw_ports_set_href_l=${$input_hash4proc_href_l}{'h04_conf_zone_forward_ports_sets_href'};
    #$fw_ports_set_href_l=hash-ref for %h04_conf_zone_forward_ports_sets_hash_g
    	#$h04_conf_zone_forward_ports_sets_hash_g{set_name}->
    
    my $rich_rules_set_href_l=${$input_hash4proc_href_l}{'h05_conf_zone_rich_rules_sets_href'};
    #$rich_rules_set_href_l=hash-ref for %h05_conf_zone_rich_rules_sets_hash_g
    	#$h05_conf_zone_rich_rules_sets_hash_g{set_name}->
    
    my $h88_conf_zones_FIN_href_l=${$input_hash4proc_href_l}{'h88_conf_policies_FIN_href'};
    #$h88_conf_policies_FIN_href_l=hash-ref for %h88_conf_policies_FIN_hash_g
	#$h77_conf_zones_FIN_hash_g{'custom/standard'}{inventory_host}{firewall_zone_name_tmplt}->
    
    my $proc_name_l=(caller(0))[3];

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
    #$h04_conf_zone_forward_ports_sets_hash_g{set_name}->
        #{'rule-0'}=1
        #{'rule-1'}=1
        #etc
        #{'seq'}=[val-0,val-1] (val=rule)
    ######
    #$h05_conf_zone_rich_rules_sets_hash_g{set_name}->
        #{'rule-0'}=1
        #{'rule-1'}=1
        #etc
        #{'seq'}=[val-0,val-1] (val=rule)
    ######
    #$h88_conf_policies_FIN_hash_g{inventory_host}{policy_name_tmplt}->
    #{'ingress-firewall_zone_name_tmplt'}=value
    #{'egress-firewall_zone_name_tmplt'}=value
    #{'forward_ports_set'}=empty|fw_ports_set (FROM '04_conf_zone_forward_ports_sets')
    #{'rich_rules_set'}=empty|rich_rules_set (FROM '05_conf_zone_rich_rules_sets')
    ######

    my ($exec_res_l)=(undef);
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my $return_str_l='OK';
}
######general subs

######other subs
sub read_param_value_templates_from_config {
    my ($file_l,$regex_href_l,$res_href_l)=@_;
    #file_l=config with templates
    #regex_href_l=hash-ref for %cfg_params_and_regex_l
    #res_href_l=hash-ref for result-hash
    my $proc_name_l=(caller(0))[3];

    my ($line_l)=(undef);
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my ($hkey1_l,$hval1_l)=(undef,undef);
    my ($read_tmplt_flag_l)=(0);
    my ($tmplt_name_begin_l,$tmplt_name_end_l)=(undef,undef);
    my $return_str_l='OK';

    my @split_arr0_l=();

    my %res_tmp_lv0_l=();
	#key0=tmplt_name, key1=param, value=value filtered by regex
    my %uniq_tmplt_name_check_l=();
	#key=tmplt_name, value=1
    
    if ( length($file_l)<1 or ! -e($file_l) ) { return "fail [$proc_name_l]. File='$file_l' is not exists"; }

    # read file
    open(CONF_TMPLT,'<',$file_l);
    while ( <CONF_TMPLT> ) {
        $line_l=$_;
        $line_l=~s/\n$|\r$|\n\r$|\r\n$//g;
        while ($line_l=~/\t/) { $line_l=~s/\t/ /g; }
        $line_l=~s/\s+/ /g;
        $line_l=~s/^ //g;
	$line_l=~s/ $//g;
	
	$line_l=~s/ \,/\,/g;
	$line_l=~s/\, /\,/g;

	$line_l=~s/ \=/\=/g;
	$line_l=~s/\= /\=/g;

        if ( length($line_l)>0 && $line_l!~/^\#/ ) {
	    if ( $line_l=~/^\[(\S+\-\-TMPLT)\:BEGIN\]$/ ) { # if cfg block begin
		$tmplt_name_begin_l=$1;
		$read_tmplt_flag_l=1;
		if ( exists($uniq_tmplt_name_check_l{$tmplt_name_begin_l}) ) {
		    $return_str_l="fail [$proc_name_l]. Duplicated template='$tmplt_name_begin_l'. Check and correct config='$file_l'";
		    last;
		}
		$uniq_tmplt_name_check_l{$tmplt_name_begin_l}=1;
	    }
	    elsif ( $read_tmplt_flag_l==1 && $line_l=~/^\[(\S+\-\-TMPLT)\:END\]$/ ) { # if cfg block ends
		$tmplt_name_end_l=$1;
		if ( $tmplt_name_begin_l eq $tmplt_name_end_l ) { # if correct begin and end of template
		    $read_tmplt_flag_l=0;
		    $tmplt_name_begin_l='notmplt';
		}
		else { # if incorrect begin and end of template
		    $return_str_l="fail [$proc_name_l]. Tmplt_name_begin ('$tmplt_name_begin_l') != tmplt_name_end ('$tmplt_name_end_l'). Check and correct config='$file_l'";
		    last;
		}
	    }
	    elsif ( $read_tmplt_flag_l==1 && $tmplt_name_begin_l ne 'notmplt' ) { # if cfg param + value
		@split_arr0_l=split(/\=/,$line_l);
		
		if ( exists(${$regex_href_l}{$split_arr0_l[0]}) && $split_arr0_l[1]=~/${$regex_href_l}{$split_arr0_l[0]}/ ) {
		    ($res_tmp_lv0_l{$tmplt_name_begin_l}{$split_arr0_l[0]})=$split_arr0_l[1]=~/(${$regex_href_l}{$split_arr0_l[0]})/;
		}
		elsif ( exists(${$regex_href_l}{$split_arr0_l[0]}) && $split_arr0_l[1]!~/${$regex_href_l}{$split_arr0_l[0]}/ ) {
		    $return_str_l="fail [$proc_name_l]. For param='$split_arr0_l[0]' value ('$split_arr0_l[1]') is incorrect (tmplt_name='$tmplt_name_begin_l')";
		    last;
		}
		elsif ( !exists(${$regex_href_l}{$split_arr0_l[0]}) ) {
		    $return_str_l="fail [$proc_name_l]. Param='$split_arr0_l[0]' is not allowed (tmplt_name='$tmplt_name_begin_l')";
		    last;
		}
		@split_arr0_l=();
	    }
	}
    }
    close(CONF_TMPLT);
        
    $line_l=undef;
    ($tmplt_name_begin_l,$tmplt_name_end_l)=(undef,undef);
    @split_arr0_l=();

    if ( $return_str_l!~/^OK$/ ) { return $return_str_l; } # check for return_str err after lv1-read
    ###

    # check for not existsing params
    while ( ($hkey0_l,$hval0_l)=each %res_tmp_lv0_l ) {
	# hkey0_l = tmplt_name
	# hval0_l = hash with params
	while ( ($hkey1_l,$hval1_l)=each %{$regex_href_l} ) {
	    #hkey1_l = param
	    if ( !exists(${$hval0_l}{$hkey1_l}) ) {
		$return_str_l="fail [$proc_name_l]. Param '$hkey1_l' is not exists at cfg for tmplt_name='$hkey0_l'";
		last;
	    }
	}
	if ( $return_str_l!~/^OK$/ ) { last; }
    }
    
    ($hkey0_l,$hval0_l)=(undef,undef);
    ($hkey1_l,$hval1_l)=(undef,undef);
    
    if ( $return_str_l!~/^OK$/ ) { return $return_str_l; } # check for return_str err after 'check for not existsing params'
    ###

    # fill result hash
    %{$res_href_l}=%res_tmp_lv0_l;
    ###
    
    %res_tmp_lv0_l=();
    
    return $return_str_l;    
}

sub read_param_only_templates_from_config {
    my ($file_l,$res_href_l)=@_;
    #file_l=config with templates
    #res_href_l=hash-ref for result-hash
    my $proc_name_l=(caller(0))[3];

    my ($line_l)=(undef);
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my ($hkey1_l,$hval1_l)=(undef,undef);
    my ($read_tmplt_flag_l)=(0);
    my ($tmplt_name_begin_l,$tmplt_name_end_l)=(undef,undef);
    my $return_str_l='OK';

    my @split_arr0_l=();

    my %res_tmp_lv0_l=();
	#key=param, value=1
    my %uniq_tmplt_name_check_l=();
	#key=tmplt_name, value=1
    
    if ( length($file_l)<1 or ! -e($file_l) ) { return "fail [$proc_name_l]. File='$file_l' is not exists"; }

    # read file
    open(CONF_TMPLT,'<',$file_l);
    while ( <CONF_TMPLT> ) {
        $line_l=$_;
        $line_l=~s/\n$|\r$|\n\r$|\r\n$//g;
        while ($line_l=~/\t/) { $line_l=~s/\t/ /g; }
        $line_l=~s/\s+/ /g;
        $line_l=~s/^ //g;
	$line_l=~s/ $//g;
	
	$line_l=~s/ \./\./g;
	$line_l=~s/\. /\./g;

	$line_l=~s/ \:/\:/g;
	$line_l=~s/\: /\:/g;

	$line_l=~s/ \=/\=/g;
	$line_l=~s/\= /\=/g;

        if ( length($line_l)>0 && $line_l!~/^\#/ ) {
	    if ( $line_l=~/^\[(\S+)\:BEGIN\]$/ ) { # if cfg block begin
		$tmplt_name_begin_l=$1;
		$read_tmplt_flag_l=1;
		if ( exists($uniq_tmplt_name_check_l{$tmplt_name_begin_l}) ) {
		    $return_str_l="fail [$proc_name_l]. Duplicated template='$tmplt_name_begin_l'. Check and correct config='$file_l'";
		    last;
		}
		$uniq_tmplt_name_check_l{$tmplt_name_begin_l}=1;
	    }
	    elsif ( $read_tmplt_flag_l==1 && $line_l=~/^\[(\S+)\:END\]$/ ) { # if cfg block ends
		$tmplt_name_end_l=$1;
		if ( $tmplt_name_begin_l eq $tmplt_name_end_l ) { # if correct begin and end of template
		    $read_tmplt_flag_l=0;
		    $tmplt_name_begin_l='notmplt';
		}
		else { # if incorrect begin and end of template
		    $return_str_l="fail [$proc_name_l]. Tmplt_name_begin ('$tmplt_name_begin_l') != tmplt_name_end ('$tmplt_name_end_l'). Check and correct config='$file_l'";
		    last;
		}
	    }
	    elsif ( $read_tmplt_flag_l==1 && $tmplt_name_begin_l ne 'notmplt' ) { # if param str
		if ( !exists($res_tmp_lv0_l{$line_l}) ) {
		    push(@{$res_tmp_lv0_l{$tmplt_name_begin_l}{'seq'}},$line_l);
		    $res_tmp_lv0_l{$tmplt_name_begin_l}{$line_l}=1;
		}
		else { # duplicated value
		    $return_str_l="fail [$proc_name_l]. Duplicated value ('$line_l') at file='$file_l' for tmplt='$tmplt_name_begin_l'. Fix it!";
		    last;
		}
	    }
	}
    }
    close(CONF_TMPLT);
        
    $line_l=undef;
    ($tmplt_name_begin_l,$tmplt_name_end_l)=(undef,undef);

    if ( $return_str_l!~/^OK$/ ) { return $return_str_l; } # check for return_str err after lv1-read
    ###

    # fill result hash
    %{$res_href_l}=%res_tmp_lv0_l;
    ###
    
    %res_tmp_lv0_l=();
    
    return $return_str_l;    
}

sub postprocessing_v1_after_read_param_value_templates_from_config {
    my ($file_l,$param_list_regex_for_postproc_l,$src_href_l,$res_href_l)=@_;
    #$param_list_regex_for_postproc_l = string like '^zone_allowed_services$|^zone_allowed_protocols$|^zone_icmp_block$|^zone_allowed_ports$|^zone_allowed_source_ports$'
    #$src_href_l=hash ref for result hash of '&read_templates_from_config'
    #$res_href_lhash ref for result hash
    my $proc_name_l=(caller(0))[3];
    
    my $arr_el0_l=undef;
    my $exec_res_l=undef;
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my ($hkey1_l,$hval1_l)=(undef,undef);
    my @split_arr0_l=();
    my $return_str_l='OK';
    
    while ( ($hkey0_l,$hval0_l)=each %{$src_href_l} ) { # cycle 0
	#hkey0_l=zone_tmpltname, hval0_l=hash ref with params and values
	while ( ($hkey1_l,$hval1_l)=each %{$hval0_l} ) { # cycle 1
	    #hkey1_l=param_name, hval1_l=param_value
	    if ( $hkey1_l=~/$param_list_regex_for_postproc_l/ ) { #if regex list params
		if ( $hval1_l!~/^empty$/ ) { # if regex list params and value is not empty
		    @split_arr0_l=split(/\,/,$hval1_l);
		    foreach $arr_el0_l ( @split_arr0_l ) { # cycle 2
			#$arr_el0_l=port/port_type or port_begin-port_end/port_type
			if ( $hkey1_l=~/_ports$/ ) { # if need to check values with ports (udp/tcp)
			    $arr_el0_l=~s/\/ /\//g;
			    $arr_el0_l=~s/ \//\//g;
			    $exec_res_l=&check_port_for_apply_to_fw_conf($arr_el0_l);
			    #$port_str_l
			    if ( $exec_res_l=~/^fail/ ) { # exit from cycle 2 if error
				$return_str_l="fail [$proc_name_l] -> ".$exec_res_l;
				last;
			    }
			}
			
			if ( !exists(${$res_href_l}{$hkey0_l}{$hkey1_l}{'list'}{$arr_el0_l}) ) {
			    push(@{${$res_href_l}{$hkey0_l}{$hkey1_l}{'seq'}},$arr_el0_l);
			    ${$res_href_l}{$hkey0_l}{$hkey1_l}{'list'}{$arr_el0_l}=1;
			}
			else { # duplicate list-value
			    $return_str_l="fail [$proc_name_l]. Duplicated list-value ('$arr_el0_l') at file='$file_l' for tmlt='$hkey0_l'. Fix it!";
			    last;
			}
		    } # cycle 2
		    
		    $arr_el0_l=undef;
		    @split_arr0_l=();
		    
		    if ( $return_str_l!~/^OK$/ ) { last; } # exit from cycle 1 if at cycle 2 catched error
		}
		else { ${$res_href_l}{$hkey0_l}{$hkey1_l}{'empty'}=1; } # regex params and value = empty
	    }
	    else { ${$res_href_l}{$hkey0_l}{$hkey1_l}=$hval1_l; } # just param=value
	} # cycle 1
	
	($hkey1_l,$hval1_l)=(undef,undef);
	
	if ( $return_str_l!~/^OK$/ ) { last; } # exit from cycle 0 if at cycle 1/2 catched error
    } # cycle 0
    
    ($hkey0_l,$hval0_l)=(undef,undef);
    ($hkey1_l,$hval1_l)=(undef,undef);
    %{$src_href_l}=();
    
    return $return_str_l;
}

sub check_port_for_apply_to_fw_conf {
    my ($port_str_l)=@_;
    #port=NUM/udp, NUM/tcp, NUM_begin-NUM_end/tcp, NUM_begin-NUM_end/udp (sctp and dccp)
    my $proc_name_l=(caller(0))[3];
    
    my ($port_num0_l,$port_num1_l)=(undef,undef);
    my $return_str_l='OK';
    
    if ( $port_str_l=~/^(\d+)\/tcp$|^(\d+)\/udp$|^(\d+)\/sctp$|^(\d+)\/dccp$/ ) {
	($port_num0_l)=$port_str_l=~/^(\d+)\//;
	$port_num0_l=int($port_num0_l);
	if ( $port_num0_l<1 or $port_num0_l>65535 ) {
	    return "fail [$proc_name_l]. Port number must be >= 1 and <= 65535";
	}
    }
    elsif ( $port_str_l=~/^\d+\-\d+\/tcp$|^\d+\-\d+\/udp$|^\d+\-\d+\/sctp$|^\d+\-\d+\/dccp$/ ) {
	($port_num0_l,$port_num1_l)=$port_str_l=~/^(\d+)\-(\d+)\//;
	$port_num0_l=int($port_num0_l);
	$port_num1_l=int($port_num1_l);
	if ( $port_num0_l<1 or $port_num0_l>65535 ) { return "fail [$proc_name_l]. Port number must be >= 1 and <= 65535"; }
	if ( $port_num1_l<1 or $port_num1_l>65535 ) { return "fail [$proc_name_l]. Port number must be >= 1 and <= 65535"; }
	if ( $port_num0_l>=$port_num1_l ) { return "fail [$proc_name_l]. Begin_port can not be >= end_port"; }
    }
    else {
	return "fail [$proc_name_l]. Port (or port range)='$port_str_l' is not correct. It must be like 'NUM/port_type' or 'NUMbegin-NUMend/port_type' where port_type='udp/tcp/sctp/dccp'";
    }
    
    return $return_str_l;
}

sub read_config_FIN_level0 {
    my ($file_l,$inv_hosts_href_l,$needed_elements_at_line_arr_l,$add_ind4key_l,$res_href_l)=@_;
    #$file_l=fin conf file '66_conf_ipsets_FIN/77_conf_zones_FIN/88_conf_policies_FIN'
    #inv_hosts_href_l=hash-ref for %inventory_hosts_g
    #$needed_elements_at_line_arr_l=needed count of elements at array formed from line
    #$add_ind4key_l (addditional index of array for hash-key)=by default at result hash key=first element of array (with 0 index), but if set add_ind_l -> key="0+add_ind_l"
    #res_href_l=hash ref for result-hash
	#key=inventory-host (arr-0), value=[arr-1,arr-2,etc]
    ###
    
    my $proc_name_l=(caller(0))[3];
    
    my ($line_l)=(undef);
    my ($arr_el0_l)=(undef);
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my ($arr_cnt_l,$key_ind_l)=(undef,undef);
    my %key_ind_cnt_l=();
	#key=$key_ind_l, value=1
    my @arr0_l=();
    my @arr1_l=();
    my %res_tmp_lv0_l=();
	#key=inventory-host (arr-0), value=[arr-1,arr-2,etc]
    my $return_str_l='OK';
    
    if ( length($file_l)<1 or ! -e($file_l) ) { return "fail [$proc_name_l]. File='$file_l' is not exists"; }

    # read file
    open(CONF_FIN,'<',$file_l);
    while ( <CONF_FIN> ) {
        $line_l=$_;
        $line_l=~s/\n$|\r$|\n\r$|\r\n$//g;
        while ($line_l=~/\t/) { $line_l=~s/\t/ /g; }
        $line_l=~s/\s+/ /g;
        $line_l=~s/^ //g;
	$line_l=~s/ $//g;
	
	if ( length($line_l)>0 && $line_l!~/^\#/ ) {
	    $line_l=~s/ \,/\,/g;
	    $line_l=~s/\, /\,/g;

	    @arr0_l=$line_l=~/(\S+)/g;
	    
	    $arr_cnt_l=$#arr0_l+1;
	    if ( $arr_cnt_l!=$needed_elements_at_line_arr_l ) {
		$return_str_l="fail [$proc_name_l]. Count of params at string of cfg-file='$file_l' must be = $needed_elements_at_line_arr_l";
		last;
	    }
	    
	    #$arr0_l[0]=inv-host
	    if ( $arr0_l[0]=~/^all$/ ) {
		# Fist time check uniq with key_ind
		$key_ind_l=$arr0_l[0];
		if ( $add_ind4key_l>0 ) { $key_ind_l.='+'.$arr0_l[$add_ind4key_l]; }
		if ( !exists($key_ind_cnt_l{$key_ind_l}) ) { $key_ind_cnt_l{$key_ind_l}=1; }
		else {
		    $return_str_l="fail [$proc_name_l]. At conf='$file_l' can be only one param 'inventory-host' with value like '$key_ind_l' (0). Check config and run again";
		    last;
		}
		$key_ind_l=undef;
		###

		while ( ($hkey0_l,$hval0_l)=each %{$inv_hosts_href_l} ) {
            	    #$hkey0_l=inv-host from inv-host-hash
            	    #push(@inv_hosts_arr_l,$hkey0_l);
		    $key_ind_l=$hkey0_l;
		    if ( $add_ind4key_l>0 ) { $key_ind_l.='+'.$arr0_l[$add_ind4key_l]; }
		    
		    #if exists -> not replace $key_ind_l (inv-host+add_ind)
		    if ( !exists($res_tmp_lv0_l{$key_ind_l}) ) { $res_tmp_lv0_l{$key_ind_l}=[@arr0_l[1..$#arr0_l]]; }
        	}
		
        	($hkey0_l,$hval0_l)=(undef,undef);
	    }
	    else { # list, separated by ",", or single inv-host
		@arr1_l=split(/\,/,$arr0_l[0]);
		foreach $arr_el0_l ( @arr1_l ) {
		    #$arr_el0_l=inv-host
		    if ( exists(${$inv_hosts_href_l}{$arr_el0_l}) ) {
			$key_ind_l=$arr_el0_l;
                	if ( $add_ind4key_l>0 ) { $key_ind_l.='+'.$arr0_l[$add_ind4key_l]; }
			
			# Second time check uniq with key_ind (for target inv-host)
			if ( !exists($key_ind_cnt_l{$key_ind_l}) ) { $key_ind_cnt_l{$key_ind_l}=1; }
			else {
			    $return_str_l="fail [$proc_name_l]. At conf='$file_l' can be only one param 'inventory-host' with value like '$key_ind_l' (1). Check config and run again";
			    last;
			}
			###

			$res_tmp_lv0_l{$key_ind_l}=[@arr0_l[1..$#arr0_l]];
		    }
		    else {
			$return_str_l="fail [$proc_name_l]. Host='$arr_el0_l' (config='$file_l') is not exists at inventory file";
			last;
		    }
		}
		
		$arr_el0_l=undef;
		@arr1_l=();
	    }
	    
	    if ( $return_str_l!~/^OK$/ ) { last; }
	    
	    @arr0_l=();
	}
    }
    close(CONF_FIN);
    
    $line_l=undef;
    ###

    if ( $return_str_l!~/^OK$/ ) { return $return_str_l; }
    
    # fill result hash
    %{$res_href_l}=%res_tmp_lv0_l;
    ###
    
    %res_tmp_lv0_l=();
    
    return $return_str_l;
}

sub rewrite_file_from_array_ref {
    my ($file_l,$aref_l)=@_;
    my $proc_name_l=(caller(0))[3];
    
    my $arr_el0_l=undef;
    my $return_str_l='OK';
    
    open(FILE,'>',$file_l);
    while ( $arr_el0_l=splice(@{$aref_l},0,1) ) {
    	print FILE $arr_el0_l."\n";
    	
    	$arr_el0_l=undef;
    }
    close(FILE);
    
    return $return_str_l;
}   
######other subs
############SUBROUTINES

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )