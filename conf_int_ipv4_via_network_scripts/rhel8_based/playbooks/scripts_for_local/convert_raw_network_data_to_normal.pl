#!/usr/bin/perl

use strict;
use warnings;
use Cwd;
use Data::Dumper;

our ($self_dir_g,$script_name_g)=Cwd::abs_path($0)=~/(.*[\/\\])(\S+)$/;

############ARGV
our $raw_data_dir_g='empty';
if ( defined($ARGV[0]) ) {
    $raw_data_dir_g=$ARGV[0];
}

if ( $raw_data_dir_g eq 'empty' ) { exit; }
############ARGV

############VARS
our @ip_link_files_g=(`ls $raw_data_dir_g | grep ip_link_noqueue`);
our @ip_neighbour_files_g=(`ls $raw_data_dir_g | grep ip_neighbour`);
chomp(@ip_link_files_g);
chomp(@ip_neighbour_files_g);
#
our $arr_el0_g=undef;
our $line_g=undef;
our $inv_host_g=undef;
############VARS

############MAIN SEQ
open(F,'>',$raw_data_dir_g.'/inv_hosts_interfaces_info');
print F "#INV_HOST	#INT_NAME	#HWADDR\n";
foreach $arr_el0_g ( @ip_link_files_g ) {
    if ( $arr_el0_g=~/^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\_/ ) {
	$inv_host_g=$1;
	open(FF,'<',$raw_data_dir_g.'/'.$arr_el0_g);
	while ( <FF> ) {
	    #2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000\    link/ether **:**:**:**:2d:5c brd ff:ff:ff:ff:ff:ff
	    $line_g=$_;
	    $line_g=~s/\n$|\r$|\n\r$|\r\n$//g;
	    while ($line_g=~/\t/) { $line_g=~s/\t/ /g; }
	    $line_g=~s/\s+/ /g;
	    $line_g=~s/^ //g;
	    if ( $line_g=~/^\d: (\S+)\: \<.* link\/ether (\S{2}\:\S{2}\:\S{2}\:\S{2}\:\S{2}\:\S{2}) brd/ ) {
		print F "$inv_host_g	$1		$2\n";
	    }
	}
	close(FF);
	print F "###################################################\n";
    }
}
close(F);
############MAIN SEQ