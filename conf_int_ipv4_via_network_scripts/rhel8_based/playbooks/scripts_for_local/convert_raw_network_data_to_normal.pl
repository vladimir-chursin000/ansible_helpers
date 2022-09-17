#!/usr/bin/perl

use strict;
use warnings;
use Cwd;
use Data::Dumper;

our ($self_dir_g,$script_name_g)=Cwd::abs_path($0)=~/(.*[\/\\])(\S+)$/;

###ARGV
our $raw_data_dir='empty';
if ( defined($ARGV[0]) ) {
    $raw_data_dir=$ARGV[0];
}
###ARGV
