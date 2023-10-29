###DEPENDENCIES: file_operations.pl

sub generate_shell_script_for_recreate_ipsets {
    my ($dyn_fwrules_files_dir_l,$remote_dir_for_absible_helper_l,$input_hash4proc_href_l)=@_;
    #$dyn_fwrules_files_dir_l=$dyn_fwrules_files_dir_g
    #$remote_dir_for_absible_helper_l=$remote_dir_for_absible_helper_g
    #$input_hash4proc_href_l=hash-ref for %input_hash4proc_g (hash with hash refs for input)
    my $proc_name_l=(caller(0))[3];

    my $inv_hosts_href_l=${$input_hash4proc_href_l}{'inventory_hosts_href'};
    #$inv_hosts_href_l=hash-ref for %invetory_hosts_g

    my $conf_firewalld_href_l=${$input_hash4proc_href_l}{'h00_conf_firewalld_href'};
    #$conf_firewalld_href_l=hash-ref for %h00_conf_firewalld_hash_g
        #$h00_conf_firewalld_hash_g{inventory_host}->

    my $ipset_templates_href_l=${$input_hash4proc_href_l}{'h01_conf_ipset_templates_href'};
    #$ipset_templates_href_l=hash-ref for %h01_conf_ipset_templates_hash_g
        #$h01_conf_ipset_templates_hash_g{'temporary/permanent'}{ipset_template_name--TMPLT}->

    my $h66_conf_ipsets_FIN_href_l=${$input_hash4proc_href_l}{'h66_conf_ipsets_FIN_href'};
    #$h66_conf_ipsets_FIN_href_l=hash-ref for \%h66_conf_ipsets_FIN_hash_g
        #$h66_conf_ipsets_FIN_hash_g{'temporary/permanent'}{inventory_host}->

    #$h01_conf_ipset_templates_hash_g{'temporary/permanent'}{ipset_template_name--TMPLT}->
    #{'ipset_name'}=value
    #{'ipset_description'}=empty|value
    #{'ipset_short_description'}=empty|value
    #{'ipset_create_option_timeout'}=num
    #{'ipset_create_option_hashsize'}=num
    #{'ipset_create_option_maxelem'}=num
    #{'ipset_create_option_family'}=inet|inet6
    #{'ipset_type'}=hash:ip|hash:ip,port|hash:ip,mark|hash:net|hash:net,port|hash:net,iface|hash:mac|hash:ip,port,ip|hash:ip,port,net|hash:net,net|hash:net,port,net
    ###
    #$h66_conf_ipsets_FIN_hash_g{'temporary/permanent'}{inventory_host}->
        #{ipset_name_tmplt-0}=1;
        #{ipset_name_tmplt-1}=1;
        #etc
    ###

    my $exec_res_l=undef;
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my $arr_el0_l=undef;
    my $wr_str_l=undef;
    my $wr_file_l=undef;
    my $ipset_list_l=undef;
    my @wr_arr_l=();
    my @tmp_arr_l=();
    my %wr_hash_permanent_l=();
        #key=inv-host, value=array of strings
    my %wr_hash_temporary_l=();
        #key=inv-host, value=array of strings
    my %permanet_ipset_names_l=(); # permanent ipset names (not tmplt names) at each inv-host
        #key=inv-host, value=array of permanent ipset names at current inv-host
    my %temporary_ipset_names_l=(); # temporary ipset names (not tmplt names) at each inv-host
        #key=inv-host, value=array of temporary ipset names at current inv-host
    my $return_str_l='OK';
    
    # fill array (for each host) with commands for recreate temporary ipsets
    #"firewall-cmd --permanent --new-ipset=some_ipset_name --type=hash:net --set-description=some_description --set-short=some_short_description --option=timeout=0
        # --option=family=inet --option=hashsize=4096 --option=maxelem=200000"
    while ( ($hkey0_l,$hval0_l)=each %{${$h66_conf_ipsets_FIN_href_l}{'temporary'}} ) {
        #$hkey0_l=inv-host

        @tmp_arr_l=sort(keys %{$hval0_l});
        foreach $arr_el0_l ( @tmp_arr_l ) {
            #$arr_el0_l=ipset_tmplt_name
            if ( !exists(${$ipset_templates_href_l}{'temporary'}{$arr_el0_l}) ) {
                $return_str_l="fail [$proc_name_l]. Ipset-template is not exists at '01_conf_ipset_templates'";
                last;
            }
            
	    push(@{$temporary_ipset_names_l{$hkey0_l}},${$ipset_templates_href_l}{'temporary'}{$arr_el0_l}{'ipset_name'});
	    
            $wr_str_l="firewall-cmd --permanent";
            $wr_str_l.=" --new-ipset=".${$ipset_templates_href_l}{'temporary'}{$arr_el0_l}{'ipset_name'};
            $wr_str_l.=" --type=".${$ipset_templates_href_l}{'temporary'}{$arr_el0_l}{'ipset_type'};
            if ( ${$ipset_templates_href_l}{'temporary'}{$arr_el0_l}{'ipset_description'}!~/^empty$/ ) {
                $wr_str_l.=" --set-description='".${$ipset_templates_href_l}{'temporary'}{$arr_el0_l}{'ipset_description'}."'";
            }
            if ( ${$ipset_templates_href_l}{'temporary'}{$arr_el0_l}{'ipset_short_description'}!~/^empty$/ && ${$ipset_templates_href_l}{'temporary'}{$arr_el0_l}{'ipset_description'}=~/^empty$/ ) {
                $wr_str_l.=" --set-short='".${$ipset_templates_href_l}{'temporary'}{$arr_el0_l}{'ipset_short_description'}."'";
            }
            $wr_str_l.=" --option=timeout=".${$ipset_templates_href_l}{'temporary'}{$arr_el0_l}{'ipset_create_option_timeout'};
            $wr_str_l.=" --option=family=".${$ipset_templates_href_l}{'temporary'}{$arr_el0_l}{'ipset_create_option_family'};
            $wr_str_l.=" --option=hashsize=".${$ipset_templates_href_l}{'temporary'}{$arr_el0_l}{'ipset_create_option_hashsize'};
            $wr_str_l.=" --option=maxelem=".${$ipset_templates_href_l}{'temporary'}{$arr_el0_l}{'ipset_create_option_maxelem'}.";";

            push(@wr_arr_l,$wr_str_l);

            $wr_str_l=undef;
        }
        
        if ( $#wr_arr_l!=-1 ) {
            push(@wr_arr_l,' ');
            @{$wr_hash_temporary_l{$hkey0_l}}=@wr_arr_l;
            @wr_arr_l=();
        }
        else { @{$wr_hash_temporary_l{$hkey0_l}}=(); }

        $arr_el0_l=undef;

        if ( $return_str_l!~/^OK$/ ) { last; }
    }
    
    ($hkey0_l,$hval0_l)=(undef,undef);
    
    if ( $return_str_l!~/^OK$/ ) { return $return_str_l; }
    ###

    # fill array (for each host) with commands for recreate permanent ipsets
    while ( ($hkey0_l,$hval0_l)=each %{${$h66_conf_ipsets_FIN_href_l}{'permanent'}} ) {
        #$hkey0_l=inv-host

        @tmp_arr_l=sort(keys %{$hval0_l});
        foreach $arr_el0_l ( @tmp_arr_l ) {
            #$arr_el0_l=ipset_tmplt_name
            if ( !exists(${$ipset_templates_href_l}{'permanent'}{$arr_el0_l}) ) {
                $return_str_l="fail [$proc_name_l]. Ipset-template is not exists at '01_conf_ipset_templates'";
                last;
            }
            
            push(@{$permanet_ipset_names_l{$hkey0_l}},${$ipset_templates_href_l}{'permanent'}{$arr_el0_l}{'ipset_name'});

            $wr_str_l="firewall-cmd --permanent";
            $wr_str_l.=" --new-ipset=".${$ipset_templates_href_l}{'permanent'}{$arr_el0_l}{'ipset_name'};
            $wr_str_l.=" --type=".${$ipset_templates_href_l}{'permanent'}{$arr_el0_l}{'ipset_type'};
            if ( ${$ipset_templates_href_l}{'permanent'}{$arr_el0_l}{'ipset_description'}!~/^empty$/ ) {
                $wr_str_l.=" --set-description='".${$ipset_templates_href_l}{'permanent'}{$arr_el0_l}{'ipset_description'}."'";
            }
            if ( ${$ipset_templates_href_l}{'permanent'}{$arr_el0_l}{'ipset_short_description'}!~/^empty$/ && ${$ipset_templates_href_l}{'permanent'}{$arr_el0_l}{'ipset_description'}=~/^empty$/ ) {
                $wr_str_l.=" --set-short='".${$ipset_templates_href_l}{'permanent'}{$arr_el0_l}{'ipset_short_description'}."'";
            }
            $wr_str_l.=" --option=timeout=".${$ipset_templates_href_l}{'permanent'}{$arr_el0_l}{'ipset_create_option_timeout'};
            $wr_str_l.=" --option=family=".${$ipset_templates_href_l}{'permanent'}{$arr_el0_l}{'ipset_create_option_family'};
            $wr_str_l.=" --option=hashsize=".${$ipset_templates_href_l}{'permanent'}{$arr_el0_l}{'ipset_create_option_hashsize'};
            $wr_str_l.=" --option=maxelem=".${$ipset_templates_href_l}{'permanent'}{$arr_el0_l}{'ipset_create_option_maxelem'}.";";
	    
            push(@wr_arr_l,$wr_str_l);

            $wr_str_l=undef;
        }

        if ( $#wr_arr_l!=-1 ) {
            push(@wr_arr_l,' ');
            #@{$wr_hash_permanent_l{$hkey0_l}}=(@{$wr_hash_permanent_l{$hkey0_l}},@wr_arr_l);
	    @{$wr_hash_permanent_l{$hkey0_l}}=@wr_arr_l;
            @wr_arr_l=();
        }
        else { @{$wr_hash_permanent_l{$hkey0_l}}=(); }

        $arr_el0_l=undef;

        if ( $return_str_l!~/^OK$/ ) { last; }
    }
    
    ($hkey0_l,$hval0_l)=(undef,undef);

    if ( $return_str_l!~/^OK$/ ) { return $return_str_l; }
    ###

    # create script "recreate_permanent_ipsets" (and ipset_names_list + content) for copy to remote hosts (BEGIN)
    while ( ($hkey0_l,$hval0_l)=each %{$inv_hosts_href_l} ) {
        #hkey0_l=inv-host
	if ( ! -d "$dyn_fwrules_files_dir_l/$hkey0_l" ) { system("mkdir -p $dyn_fwrules_files_dir_l/$hkey0_l"); }
        $wr_file_l=$dyn_fwrules_files_dir_l.'/'.$hkey0_l.'/recreate_permanent_ipsets.sh';
        
        if ( exists($wr_hash_permanent_l{$hkey0_l}) ) { # if exists content for 'recreate_permanent_ipsets.sh' (begin)
	    # 1) add lines with with commands for recreate permanent ipsets
            @wr_arr_l=@{$wr_hash_permanent_l{$hkey0_l}}; 
	    ###
	
            # 2) insert compiler path and remove commands at the begin of the script
            @wr_arr_l=(
                '#!/usr/bin/bash',
                ' ',
                '###GENERATED BY ansible_helpers/conf_firewalld (https://github.com/vladimir-chursin000/ansible_helpers)',
                '###DO NOT CHANGE!',
                ' ',
		'#FORCE_REMOVE_PERMANENT_IPSETS',
		' ',
                @wr_arr_l
            );
	    ###
        } # if exists content for 'recreate_permanent_ipsets.sh' (end)
        elsif ( !exists($wr_hash_permanent_l{$hkey0_l}) && ${$conf_firewalld_href_l}{$hkey0_l}{'if_no_ipsets_conf_action'}=~/^remove$/ ) {
            @wr_arr_l=(
                '#!/usr/bin/bash',
                ' ',
                '###GENERATED BY ansible_helpers/conf_firewalld (https://github.com/vladimir-chursin000/ansible_helpers)',
                '###DO NOT CHANGE!',
                ' ',
                '#FORCE_REMOVE_PERMANENT_IPSETS',
		' ',
            );
        }
        else { # if not exists content for 'recreate_permanent_ipsets.sh'
            @wr_arr_l=(
                '#!/usr/bin/bash',
                ' ',
                '###GENERATED BY ansible_helpers/conf_firewalld (https://github.com/vladimir-chursin000/ansible_helpers)',
                '###DO NOT CHANGE!',
                ' ',
                '#NO NEED TO RECREATE IPSETS',
		' ',
            );
        }
	
        $exec_res_l=&rewrite_file_from_array_ref($wr_file_l,\@wr_arr_l);
        #$file_l,$aref_l
        if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }

        $wr_file_l=undef;
        @wr_arr_l=();
    }

    ($hkey0_l,$hval0_l)=(undef,undef);
    # create script "recreate_permanent_ipsets" (and ipset_names_list + content) for copy to remote hosts (END)
    
    # create script for recreate temporary ipsets (and ipset_names_list + content) for copy to remote hosts (BEGIN)
    while ( ($hkey0_l,$hval0_l)=each %{$inv_hosts_href_l} ) {
        #hkey0_l=inv-host
	if ( ! -d "$dyn_fwrules_files_dir_l/$hkey0_l" ) { system("mkdir -p $dyn_fwrules_files_dir_l/$hkey0_l"); }
        $wr_file_l=$dyn_fwrules_files_dir_l.'/'.$hkey0_l.'/recreate_temporary_ipsets.sh';
	
	if ( exists($wr_hash_permanent_l{$hkey0_l}) ) { # if exists content for 'recreate_temporary_ipsets.sh'
	    # 1) add lines with with commands for recreate temporary ipsets
            @wr_arr_l=@{$wr_hash_temporary_l{$hkey0_l}}; 
	    ###
	
            # 2) insert compiler path and remove commands at the begin of the script
            @wr_arr_l=(
                '#!/usr/bin/bash',
                ' ',
                '###GENERATED BY ansible_helpers/conf_firewalld (https://github.com/vladimir-chursin000/ansible_helpers)',
                '###DO NOT CHANGE!',
                ' ',
                '#FORCE_REMOVE_TEMPORARY_IPSETS',
                ' ',
                @wr_arr_l
            );
	    ###
	} # if exists content for 'recreate_temporary_ipsets.sh' (end)
        elsif ( !exists($wr_hash_temporary_l{$hkey0_l}) && ${$conf_firewalld_href_l}{$hkey0_l}{'if_no_ipsets_conf_action'}=~/^remove$/ ) {
            @wr_arr_l=(
                '#!/usr/bin/bash',
                ' ',
                '###GENERATED BY ansible_helpers/conf_firewalld (https://github.com/vladimir-chursin000/ansible_helpers)',
                '###DO NOT CHANGE!',
                ' ',
                '#FORCE_REMOVE_TEMPORARY_IPSETS',
                ' ',
            );
        }
        else { # if not exists content for 'recreate_permanent_ipsets.sh'
            @wr_arr_l=(
                '#!/usr/bin/bash',
                ' ',
                '###GENERATED BY ansible_helpers/conf_firewalld (https://github.com/vladimir-chursin000/ansible_helpers)',
                '###DO NOT CHANGE!',
                ' ',
                '#NO NEED TO RECREATE IPSETS',
		' ',
            );
        }

        $exec_res_l=&rewrite_file_from_array_ref($wr_file_l,\@wr_arr_l);
        #$file_l,$aref_l
        if ( $exec_res_l=~/^fail/ ) { return "fail [$proc_name_l] -> ".$exec_res_l; }

        $wr_file_l=undef;
        @wr_arr_l=();
    }
    # create script for recreate temporary ipsets (and ipset_names_list + content) for copy to remote hosts (END)

    return $return_str_l;
}

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
