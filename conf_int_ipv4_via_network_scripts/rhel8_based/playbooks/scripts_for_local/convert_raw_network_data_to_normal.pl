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
our ($arr_el0_g,$line_g,$inv_host_g,$hwaddr_g)=(undef,undef,undef,undef);
our %ip_link_uniq_hwaddr_g=(); #key=hwaddr, value=inv_host
our %ip_neighbour_uniq_hwaddr_g=(); #key=hwaddr, value=neighbour_ip
our @mac_warnings_g=();
############VARS

############MAIN SEQ

###READ ip_link
open(F,'>',$raw_data_dir_g.'/inv_hosts_interfaces_info.txt');
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
		$hwaddr_g=lc($2);
		if ( !exists($ip_link_uniq_hwaddr_g{$hwaddr_g}) ) {
		    print F "$inv_host_g	$1		$hwaddr_g\n";
		    $ip_link_uniq_hwaddr_g{$hwaddr_g}=$inv_host_g;
		}
		else {
		    push(@mac_warnings_g,"HWADDR='$hwaddr_g' (interface_name='$1') for inv_host='$inv_host_g' is already used at host='$ip_link_uniq_hwaddr_g{$hwaddr_g}'!");
		}
	    }
	}
	close(FF);
	print F "###################################################\n";
    }
}
close(F);
###READ ip_link

###READ ip_neighbour
open(F,'>',$raw_data_dir_g.'/inv_hosts_neighbour_info.txt');
print F "#UNIQ_NEIGHBOUR_IP	#HWADDR\n";
foreach $arr_el0_g ( @ip_neighbour_files_g ) {
    if ( $arr_el0_g=~/^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\_/ ) {
	$inv_host_g=$1;
	print F "#INV_HOST=$inv_host_g\n";
	open(FF,'<',$raw_data_dir_g.'/'.$arr_el0_g);
	while ( <FF> ) {
	    #10.*.*.* dev eth0 lladdr **:**:**:**:49:3b REACHABLE
	    $line_g=$_;
	    $line_g=~s/\n$|\r$|\n\r$|\r\n$//g;
	    while ($line_g=~/\t/) { $line_g=~s/\t/ /g; }
	    $line_g=~s/\s+/ /g;
	    $line_g=~s/^ //g;
	    if ( $line_g=~/^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}) .* (\S{2}\:\S{2}\:\S{2}\:\S{2}\:\S{2}\:\S{2}) \S+/ ) {
		$hwaddr_g=lc($2);
		if ( !exists($ip_link_uniq_hwaddr_g{$hwaddr_g}) ) {
		    if ( !exists($ip_neighbour_uniq_hwaddr_g{$hwaddr_g}) ) {
			print F "$1		$hwaddr_g\n";
			$ip_neighbour_uniq_hwaddr_g{$hwaddr_g}=$1;
		    }
		    else {
			print F "#$1		$hwaddr_g (not UNIQ, already exists at ip_neighbour_uniq_hwaddr -> '$ip_neighbour_uniq_hwaddr_g{$hwaddr_g}')\n";
		    }
		}
		else {
		    print F "#$1		$hwaddr_g (not UNIQ, already exists at ip_link_uniq_hwaddr -> '$ip_link_uniq_hwaddr_g{$hwaddr_g}')\n";
		}
	    }
	}
	close(FF);
	print F "###################################################\n";
    }
}
close(F);
###READ ip_neighbour

############MAIN SEQ