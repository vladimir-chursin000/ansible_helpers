#!/usr/bin/perl

###SCRIPT for create subfolders and manipulate ipset-files for each inventory host

use strict;
use warnings;
use Cwd;
use Data::Dumper;

our ($self_dir_g,$script_name_g)=Cwd::abs_path($0)=~/(.*[\/\\])(\S+)$/;
$self_dir_g=~s/\/$//g;

###LOAD SUBROUTINES
our @do_arr_g=(
    'log_operations.pl',
    'file_operations.pl',
    'datetime.pl',
    'read_conf_other.pl',
    'read_00_conf_fwrules.pl',
    'read_01_conf_fwrules.pl',
    'read_66_conf_fwrules.pl',
    'read_conf_fwrules_common.pl',
    'apply_IPSET_files_operation.pl'
);

foreach my $do_g ( @do_arr_g ) {
    do ($self_dir_g.'/perl_subs/'.$do_g);
    if ( $@ ) { die "'$do_g' error:$@"; }
}
###LOAD SUBROUTINES

############ARGV
our $inventory_conf_path_g='no';

if ( defined($ARGV[0]) && length($ARGV[0])>0 ) {
    $inventory_conf_path_g=$ARGV[0];
}
############ARGV

############CFG file
our $f00_conf_divisions_for_inv_hosts_path_g=$self_dir_g.'/fwrules_configs/00_conf_divisions_for_inv_hosts';
our $f01_conf_ipset_templates_path_g=$self_dir_g.'/fwrules_configs/01_conf_ipset_templates';
our $f65_conf_initial_ipsets_content_FIN_path_g=$self_dir_g.'/fwrules_configs/65_conf_initial_ipsets_content_FIN';
our $f66_conf_ipsets_FIN_path_g=$self_dir_g.'/fwrules_configs/66_conf_ipsets_FIN';
############CFG file

############STATIC VARS
our $remote_ipset_dir_for_absible_helper_g='$HOME/ansible_helpers/conf_firewalld/ipset_files'; # dir for creating/manipulate files (for add/remove ipsets) at remote side
our $scripts_for_remote_dir_g=$self_dir_g.'/playbooks/scripts_for_remote';

our $dyn_ipsets_files_dir_g=$scripts_for_remote_dir_g.'/fwrules_files/ipset_files'; # dir for recreate shell-scripts (for add/remove ipsets) for executing it at remote side (if need)
our $ipset_input_dir_g=$self_dir_g.'/ipset_input';
our $ipset_actual_data_dir_g=$self_dir_g.'/ipset_actual_data';
############STATIC VARS

############VARS
######
our %inventory_hosts_g=(); # for checks of h00_conf_firewalld_hash_g/h66_conf_ipsets_FIN_hash_g/h77_conf_zones_FIN_hash_g/h88_conf_policies_FIN_hash_g
# and operate with 'all' (apply for all inv hosts) options
###
#Key=inventory_host, value=1
######

######
our %h00_conf_divisions_for_inv_hosts_hash_g=();
#DIVISION_NAME/GROUP_NAME       #LIST_OF_HOSTS
###
#$h00_conf_divisions_for_inv_hosts_hash_g{group_name}{inv-host}=1;
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
our %h65_conf_initial_ipsets_content_FIN_hash_g=();
# This CFG only for permanent ipset templates (if "#ipset_create_option_timeout=0").
#[IPSET_TEMPLATE_NAME:BEGIN]
#one row = one record with ipset accoring to "#ipset_type" of conf file "01_conf_ipset_templates"
#[IPSET_TEMPLATE_NAME:END]
###
#$h65_conf_initial_ipsets_content_FIN_hash_g{ipset_template_name}->
    #{'record-0'}=1
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

our ($exec_res_g,$exec_status_g)=(undef,'OK');

our %input_hash4proc_g=();
#hash with hash refs for input
############VARS

############MAIN SEQ
while ( 1 ) { # ONE RUN CYCLE begin
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

    $exec_res_g=&read_66_conf_ipsets_FIN($f66_conf_ipsets_FIN_path_g,\%inventory_hosts_g,\%h00_conf_divisions_for_inv_hosts_hash_g,\%h01_conf_ipset_templates_hash_g,\%h66_conf_ipsets_FIN_hash_g);
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
        'divisions_for_inv_hosts_href'=>\%h00_conf_divisions_for_inv_hosts_hash_g,
        'h01_conf_ipset_templates_href'=>\%h01_conf_ipset_templates_hash_g,
        'h66_conf_ipsets_FIN_href'=>\%h66_conf_ipsets_FIN_hash_g,
    );

    $exec_res_g=&apply_IPSET_files_operation_main($remote_ipset_dir_for_absible_helper_g,$dyn_ipsets_files_dir_g,$ipset_input_dir_g,$ipset_actual_data_dir_g,\%input_hash4proc_g);
    #$remote_ipset_dir_for_absible_helper_l,$dyn_ipsets_files_dir_l,$ipset_input_dir_l,$ipset_actual_data_dir_l
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
