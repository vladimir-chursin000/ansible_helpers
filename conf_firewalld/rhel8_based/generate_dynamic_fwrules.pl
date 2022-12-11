#!/usr/bin/perl

###SCRIPT for generate firewall rules for each inventory host

use strict;
use warnings;
use Cwd;
use Data::Dumper;

our ($self_dir_g,$script_name_g)=Cwd::abs_path($0)=~/(.*[\/\\])(\S+)$/;

############ARGV
our $gen_with_rollback_g=0;

if ( defined($ARGV[0]) && $ARGV[0]=~/^with_rollback$/ ) {
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
############STATIC VARS

############VARS
our %h00_conf_firewalld_hash_g=();
our %h01_conf_ipset_templates_hash_g=();
our %h02_conf_custom_firewall_zones_templates_hash_g=();
our %h02_conf_standard_firewall_zones_templates_hash_g=();
our %h03_conf_policy_templates_hash_g=();
our %h04_conf_zone_forward_ports_sets_hash_g=();
our %h05_conf_zone_rich_rules_sets_hash_g=();
our %h06_conf_ipsets_FIN_hash_g=();
our %h07_conf_zones_FIN_hash_g=();
our %h08_conf_policies_FIN_hash_g=();
############VARS

############MAIN SEQ
############MAIN SEQ

############SUBROUTINES
############SUBROUTINES

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )