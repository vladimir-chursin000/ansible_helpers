###NO DEPENDENCIES

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

sub check_ipset_input_by_type {
    my ($ipset_val_l,$ipset_type_l,$check_type_l)=@_;
    #$check_type_l: simple, complex
    
    my %ipset_types_simple_regex_l=(
	'simple' => {
	    'hash:ip' => '^\S+$|^\S+\/\d{1,2}$',
            # Examples:
                # 192.168.10.67
                # 192.168.11.0/24
	    'hash:ip,port' => '',
            # Examples:
                # 192.168.12.12,udp:53
                # 192.168.1.0/24,80-82
                # 192.168.1.1,vrrp:0
                # 192.168.1.1,80
	    'hash:ip,mark' => '',
            # Examples:
                # 192.168.1.0/24,555
                # 192.168.1.1,0x63
                # 192.168.1.1,111236
	    'hash:net' => '',
            # Examples:
                # 192.168.0.0/24
                # 10.1.0.0/16
                # 192.168.0/24
	    'hash:net,port' => '',
            # Examples:
                # 192.168.0/24,25
                # 10.1.0.0/16,80
                # 192.168.0/24,25
                # 192.168.1.0/24,tcp:8081
	    'hash:net,iface' => '',
            # Examples:
                # 192.168.0/24,eth0
                # 10.1.0.0/16,eth1
                # 192.168.0/24,eth0
	    'hash:mac' => '',
            # Examples:
                # 01:02:03:04:05:06
	},
	'complex' => { }
    );
    
    if ( $ipset_val_l!~/$ipset_types_simple_regex_l{$check_type_l}{$ipset_type_l}/ ) { return "fail"; }
    
    my $return_str_l='OK';
    
    return $return_str_l;    
}
#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
