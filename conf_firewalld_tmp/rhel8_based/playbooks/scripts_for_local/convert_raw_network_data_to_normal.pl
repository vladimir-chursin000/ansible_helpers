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
our @ip_addr_files_g=(`ls $raw_data_dir_g | grep ip_addr`);
chomp(@ip_addr_files_g);
#
our ($arr_el0_g,$line_g,$inv_host_g)=(undef,undef,undef);
############VARS

############MAIN SEQ

###READ ip_addr
open(F,'>',$raw_data_dir_g.'/inv_hosts_interfaces_info.txt');
print F "#INV_HOST	#INT_NAME	#IPADDR\n";
foreach $arr_el0_g ( @ip_addr_files_g ) {
    if ( $arr_el0_g=~/^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\_/ ) {
	$inv_host_g=$1;
	open(FF,'<',$raw_data_dir_g.'/'.$arr_el0_g);
	while ( <FF> ) {
	    #2: eth0    inet 10.1.2.10/24 brd 10.1.2.255 scope global eth0\       valid_lft forever preferred_lft forever
	    $line_g=$_;
	    $line_g=~s/\n$|\r$|\n\r$|\r\n$//g;
	    while ($line_g=~/\t/) { $line_g=~s/\t/ /g; }
	    $line_g=~s/\s+/ /g;
	    $line_g=~s/^ //g;
	    if ( $line_g=~/^\d: (\S+) inet (\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\/\d+ brd/ ) {
		print F "$inv_host_g	$1		$2\n";
	    }
	}
	close(FF);
	print F "###################################################\n";
	
	unlink($raw_data_dir_g.'/'.$arr_el0_g);
    }
}
close(F);

($arr_el0_g,$inv_host_g,$line_g)=(undef,undef,undef);
###READ ip_addr

############MAIN SEQ