#!/usr/bin/perl

###SCRIPT for create subfolders and manipulate ipset-files for each inventory host

use strict;
use warnings;
use Cwd;
use Data::Dumper;

our ($self_dir_g,$script_name_g)=Cwd::abs_path($0)=~/(.*[\/\\])(\S+)$/;

############ARGV
our $inventory_conf_path_g='no';

if ( defined($ARGV[0]) && length($ARGV[0])>0 ) {
    $inventory_conf_path_g=$ARGV[0];
}
############ARGV

############CFG file
our $f01_conf_ipset_templates_path_g=$self_dir_g.'/fwrules_configs/01_conf_ipset_templates';
our $f66_conf_ipsets_FIN_path_g=$self_dir_g.'/fwrules_configs/66_conf_ipsets_FIN';
############CFG file

############STATIC VARS
our $remote_dir_for_absible_helper_g='$HOME/ansible_helpers/conf_firewalld'; # dir for creating/manipulate files at remote side
our $scripts_for_remote_dir_g=$self_dir_g.'/playbooks/scripts_for_remote';
our $dyn_fwrules_files_dir_g=$scripts_for_remote_dir_g.'/fwrules_files'; # dir for recreate shell-scripts for executing it at remote side (if need)
############STATIC VARS

############VARS
############VARS

############MAIN SEQ
############MAIN SEQ


#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
