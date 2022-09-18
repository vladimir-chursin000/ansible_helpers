#!/usr/bin/perl

use strict;
use warnings;
use Cwd;
use Data::Dumper;

our ($self_dir_g,$script_name_g)=Cwd::abs_path($0)=~/(.*[\/\\])(\S+)$/;

###ARGV
our $raw_data_dir_g='empty';
if ( defined($ARGV[0]) ) {
    $raw_data_dir_g=$ARGV[0];
}

if ( $raw_data_dir_g eq 'empty' ) { exit; }
###ARGV

###VARS
our @ip_list_files_g=(`ls $raw_data_dir_g | grep ip_link_noqueue`);
our @ip_neighbour_files_g=(`ls $raw_data_dir_g | grep ip_neighbour`);
chomp(@ip_list_files_g);
chomp(@ip_neighbour_files_g);
###VARS
