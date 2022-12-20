#!/usr/bin/perl

###SCRIPT for generate firewall rules for each inventory host

use strict;
use warnings;
use Cwd;
use Data::Dumper;

our ($self_dir_g,$script_name_g)=Cwd::abs_path($0)=~/(.*[\/\\])(\S+)$/;

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
#06_conf_ipsets_FIN
#07_conf_zones_FIN
#08_conf_policies_FIN
###
our $f00_conf_firewalld_path_g=$self_dir_g.'/fwrules_configs/00_conf_firewalld';
our $f01_conf_ipset_templates_path_g=$self_dir_g.'/fwrules_configs/01_conf_ipset_templates';
our $f02_conf_custom_firewall_zones_templates_path_g=$self_dir_g.'/fwrules_configs/02_conf_custom_firewall_zones_templates';
our $f02_conf_standard_firewall_zones_templates_path_g=$self_dir_g.'/fwrules_configs/02_conf_standard_firewall_zones_templates';
our $f03_conf_policy_templates_path_g=$self_dir_g.'/fwrules_configs/03_conf_policy_templates';
our $f04_conf_zone_forward_ports_sets_path_g=$self_dir_g.'/fwrules_configs/04_conf_zone_forward_ports_sets';
our $f05_conf_zone_rich_rules_sets_path_g=$self_dir_g.'/fwrules_configs/05_conf_zone_rich_rules_sets';
our $f06_conf_ipsets_FIN_path_g=$self_dir_g.'/fwrules_configs/06_conf_ipsets_FIN';
our $f07_conf_zones_FIN_path_g=$self_dir_g.'/fwrules_configs/07_conf_zones_FIN';
our $f08_conf_policies_FIN_path_g=$self_dir_g.'/fwrules_configs/08_conf_policies_FIN';
############CFG file

############STATIC VARS
our $remote_dir_for_absible_helper_g='~/ansible_helpers/conf_firewalld'; # dir for creating/manipulate files at remote side
############STATIC VARS

############VARS
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
#$h00_conf_firewalld_hash_g{inventory_host}{fwconf_tmplt_name--TMPLT}->
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
#$h01_conf_ipset_templates_hash_g{ipset_template_name--TMPLT}->
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
	#{'service-0'}
	#{'service-1'}
	#etc
#{'zone_allowed_ports'}->
    #{'empty'}=1 or
    #{'list'}->
	#{'port-0'}
	#{'port-1'}
	#etc
#{'zone_allowed_protocols'}->
    #{'empty'}=1 or
    #{'list'}->
	#{'proto-0'}
	#{'proto-1'}
	#etc
#{'zone_forward'}=yes|no
#{'zone_masquerade_general'}=yes|no
#{'zone_allowed_source_ports'}->
    #{'empty'}=1 or
    #{'list'}->
	#{'port-0'}
	#{'port-1'}
	#etc
#{'zone_icmp_block_inversion'}=yes|no
#{'zone_icmp_block'}->
    #{'empty'}=1 or
    #{'list'}->
	#{'icmptype-0'}
	#{'icmptype-1'}
	#etc
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
	#{'service-0'}
	#{'service-1'}
	#etc
#{'zone_allowed_ports'}->
    #{'empty'}=1 or
    #{'list'}->
	#{'port-0'}
	#{'port-1'}
	#etc
#{'zone_allowed_protocols'}->
    #{'empty'}=1 or
    #{'list'}->
	#{'proto-0'}
	#{'proto-1'}
	#etc
#{'zone_forward'}=yes|no
#{'zone_masquerade_general'}=yes|no
#{'zone_allowed_source_ports'}->
    #{'empty'}=1 or
    #{'list'}->
	#{'port-0'}
	#{'port-1'}
	#etc
#{'zone_icmp_block_inversion'}=yes|no
#{'zone_icmp_block'}->
    #{'empty'}=1 or
    #{'list'}->
	#{'icmptype-0'}
	#{'icmptype-1'}
	#etc
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
	#{'service-0'}
	#{'service-1'}
	#etc
#{'policy_allowed_ports'}->
    #{'empty'}=1 or
    #{'list'}->
	#{'port-0'}
	#{'port-1'}
	#etc
#{'policy_allowed_protocols'}->
    #{'empty'}=1 or
    #{'list'}->
	#{'proto-0'}
	#{'proto-1'}
	#etc
#{'policy_masquerade_general'}=yes|no
#{'policy_allowed_source_ports'}->
    #{'empty'}=1 or
    #{'list'}->
	#{'port-0'}
	#{'port-1'}
	#etc
#{'policy_icmp_block_inversion'}=yes|no
#{'policy_icmp_block'}->
    #{'empty'}=1 or
    #{'list'}->
	#{'icmptype-0'}
	#{'icmptype-1'}
	#etc
######

######
our %h04_conf_zone_forward_ports_sets_hash_g=();
#[some_forward_ports_set_name:BEGIN]
#port=80:proto=tcp:toport=8080:toaddr=192.168.1.60 (example)
#port=80:proto=tcp:toport=8080 (example)
#[some_forward_ports_set_name:END]
###
#$h04_conf_zone_forward_ports_sets_hash_g{set_name}->
    #{'rule-0'}
    #{'rule-1'}
    #etc
######

######
our %h05_conf_zone_rich_rules_sets_hash_g=();
#[some_rich_rules_set_name:BEGIN]
#rule family=ipv4 forward-port to-port=8080 protocol=tcp port=80 (example)
#rule family=ipv4 source address=192.168.55.4/32 destination address=10.10.7.0/24 masquerade (example)
#[some_rich_rules_set_name:END]
###
#$h05_conf_zone_rich_rules_sets_hash_g{set_name}->
    #{'rule-0'}
    #{'rule-1'}
    #etc
######

######
our %h06_conf_ipsets_FIN_hash_g=();
#INVENTORY_HOST         #IPSET_NAME_TMPLT_LIST
#all                    ipset1--TMPLT,ipset4all_public--TMPLT (example)
#10.3.2.2               ipset4public--TMPLT (example)
###
#$h06_conf_ipsets_FIN_hash_g{inventory_host}->
#{ipset_name_tmplt}=1;
######

######
our %h07_conf_zones_FIN_hash_g=();
#INVENTORY_HOST         #FIREWALL_ZONE_NAME_TMPLT       #INTERFACE_LIST   #SOURCE_LIST                                  #FORWARD_PORTS_SET      #RICH_RULES_SET
#all                    public--TMPLT                   ens1,ens2,ens3    10.10.16.0/24,ipset:ipset4all_public--TMPLT   empty                   empty (example)
#10.3.2.2               public--TMPLT                   empty             10.10.15.0/24,ipset:ipset4public--TMPLT       fw_ports_set4public     rich_rules_set4public (example)
#10.1.2.3,10.1.2.4      zone1--TMPLT                    eth0,eth1,ens01   empty                                         fw_ports_set4zone1      rich_rules_set4zone1 (example)
###
#$h06_conf_ipsets_FIN_hash_g{inventory_host}{firewall_zone_name_tmplt}->
#{'interface_list'}->;
    #{'interface-0'}
    #{'interface-1'}
    #etc
#{'source_list'}->
    #{'source-0'}
    #{'source-1'}
    #etc
#{'forward_ports_set'}=empty|fw_ports_set (FROM '04_conf_zone_forward_ports_sets')
#{'rich_rules_set'}=empty|rich_rules_set (FROM '05_conf_zone_rich_rules_sets')
######

######
our %h08_conf_policies_FIN_hash_g=();
#INVENTORY_HOST         #POLICY_NAME_TMPLT           	#INGRESS-FIREWALL_ZONE_NAME_TMPLT    	#EGRESS-FIREWALL_ZONE_NAME_TMPLT     	#FORWARD_PORTS_SET      #RICH_RULES_SET
#all                    policy_public2home--TMPLT       public--TMPLT                           home--TMPLT                             fw_ports_set1           rich_rules_set1 (example)
#10.3.2.2               policy_zoneone2zonetwo--TMPLT   zoneone--TMPLT                          zonetwo--TMPLT                          fw_ports_set2           rich_rules_set2 (example)
###
#$h08_conf_policies_FIN_hash_g{inventory_host}{policy_name_tmplt}->
#{'ingress-firewall_zone_name_tmplt'}=value
#{'egress-firewall_zone_name_tmplt'}=value
#{'forward_ports_set'}=empty|fw_ports_set (FROM '04_conf_zone_forward_ports_sets')
#{'rich_rules_set'}=empty|rich_rules_set (FROM '05_conf_zone_rich_rules_sets')
######

######
our %inventory_hosts_g=(); # for checks of h00_conf_firewalld_hash_g/h06_conf_ipsets_FIN_hash_g/h07_conf_zones_FIN_hash_g/h08_conf_policies_FIN_hash_g 
# and operate with 'all' (apply for all inv hosts) options
###
#Key=inventory_host, value=1
######
############VARS

############MAIN SEQ
&read_inventory_file($inventory_conf_path_g,\%inventory_hosts_g);
#$file_l,$res_href_l
############MAIN SEQ

############SUBROUTINES
sub read_inventory_file {
    my ($file_l,$res_href_l)=@_;
    #file_l=$inventory_conf_path_g, res_href_l=hash-ref for %inventory_hosts_g
            
    my ($line_l,$start_read_hosts_flag_l)=(undef,0);
            
    open(INVDATA,'<',$file_l);
    while ( <INVDATA> ) {
        $line_l=$_;
        $line_l=~s/\n$|\r$|\n\r$|\r\n$//g;
        while ($line_l=~/\t/) { $line_l=~s/\t/ /g; }
        $line_l=~s/\s+/ /g;
        $line_l=~s/^ //g;
        if ( length($line_l)>0 && $line_l!~/^\#/ ) {
	    if ( $line_l=~/^\[rhel8_firewall_hosts\]/ && $start_read_hosts_flag_l==0 ) { $start_read_hosts_flag_l=1; }
	    elsif ( $start_read_hosts_flag_l==1 && $line_l=~/^\[rhel8_firewall_hosts\:vars\]/ ) {
		$start_read_hosts_flag_l=0;
		last;
	    }
	    elsif ( $start_read_hosts_flag_l==1 ) { ${$res_href_l}{$line_l}=1; }
        }
    }
    close(INVDATA);
}
############SUBROUTINES

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )