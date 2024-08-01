sub generate_dynamic_playbooks {
    my ($dyn_ifcfg_playbooks_dir_l,$remote_dir_for_absible_helper_l,$gen_playbooks_next_with_rollback_l,$inv_hosts_tmp_apply_cfg_href_l,$inv_hosts_dns_href_l,$inv_hosts_hash1_href_l)=@_;
    #$dyn_ifcfg_playbooks_dir_l=$dyn_ifcfg_playbooks_dir_g
    #$remote_dir_for_absible_helper_l=$remote_dir_for_absible_helper_g
    #$gen_playbooks_next_with_rollback_l=$gen_playbooks_next_with_rollback_g
    #inv_hosts_tmp_apply_cfg_href_l=hash ref for %inv_hosts_tmp_apply_cfg_g
    #inv_hosts_dns_href_l=hash ref for %inv_hosts_dns_g
    #inv_hosts_hash1_href_l=hash ref for inv_hosts_hash1_g
    my $proc_name_l=(caller(0))[3];
    
    my ($tmp_file0_l,$tmp_var_l)=(undef,undef);
    my ($hkey0_l,$hval0_l)=(undef,undef);    
    my ($hkey1_l,$hval1_l)=(undef,undef);
    my $return_str_l='OK';

    system("rm -rf ".$dyn_ifcfg_playbooks_dir_l."/*_ifcfg_change.yml");

    while ( ($hkey0_l,$hval0_l)=each %{$inv_hosts_hash1_href_l} ) {
	#hkey0_l=inv_host, hval0_l=hash
	
	$tmp_file0_l=$dyn_ifcfg_playbooks_dir_l.'/'.$hkey0_l.'_ifcfg_change.yml';
	    
	open(DYN_YML,'>',$tmp_file0_l);
	if ( exists(${$hval0_l}{'for_del'}) ) { #if need to remove ifcfg
	    print DYN_YML "- name: shutdown interfaces before delete\n";
	    print DYN_YML "  ansible.builtin.command: \"ifdown {{item}}\"\n";
	    print DYN_YML "  with_items:\n";
	    while ( ($hkey1_l,$hval1_l)=each %{${$hval0_l}{'for_del'}} ) {
		#hkey1_l=ifcfg_name
		print DYN_YML "    - $hkey1_l\n";
	    }
	    ($hkey1_l,$hval1_l)=(undef,undef);
	    print DYN_YML "\n";
	    print DYN_YML "######################################################\n";
	    print DYN_YML "\n";
	    
	    print DYN_YML "- name: delete unconfigured ifcfg-files\n";
	    print DYN_YML "  ansible.builtin.file:\n";
	    print DYN_YML "    path: \"/etc/sysconfig/network-scripts/{{item}}\"\n";
	    print DYN_YML "    state: absent\n";
	    print DYN_YML "  with_items:\n";
	    while ( ($hkey1_l,$hval1_l)=each %{${$hval0_l}{'for_del'}} ) {
		#hkey1_l=ifcfg_name
		print DYN_YML "    - $hkey1_l\n";
	    }
	    ($hkey1_l,$hval1_l)=(undef,undef);
	    print DYN_YML "\n";
	    print DYN_YML "######################################################\n";
	    print DYN_YML "\n";
	}
	
	if ( exists(${$hval0_l}{'for_del_ip_link'}) ) { # if need to 'ip link delete' (for bridges/bond ifcfg)
	    print DYN_YML "- name: ip link delete for unconfigured bridge/bonds/vlan-interfaces\n";
	    print DYN_YML "  ansible.builtin.command: \"ip link delete {{item}}\"\n";
	    print DYN_YML "  with_items:\n";
	    while ( ($hkey1_l,$hval1_l)=each %{${$hval0_l}{'for_del_ip_link'}} ) {
		#hkey1_l=link-name
		print DYN_YML "    - $hkey1_l\n";
	    }
	    ($hkey1_l,$hval1_l)=(undef,undef);
	    print DYN_YML "\n";
	    print DYN_YML "######################################################\n";
	    print DYN_YML "\n";
	}

	if ( exists(${$hval0_l}{'for_upd'}) ) { #if need to upd ifcfg
	    print DYN_YML "- name: copy/upd ifcfg-files\n";
	    print DYN_YML "  ansible.builtin.copy:\n";
	    print DYN_YML "    src: \"{{playbook_dir}}/dyn_ifcfg/{{inventory_hostname}}/fin/{{item}}\"\n";
	    print DYN_YML "    dest: \"/etc/sysconfig/network-scripts/{{item}}\"\n";
    	    print DYN_YML "    owner: root\n";
    	    print DYN_YML "    group: root\n";
    	    print DYN_YML "    mode: '0644'\n";
    	    print DYN_YML "    seuser: system_u\n";
    	    print DYN_YML "    setype: net_conf_t\n";
    	    print DYN_YML "    serole: object_r\n";
    	    print DYN_YML "    selevel: s0\n";
	    print DYN_YML "  with_items:\n";
	    if ( exists(${$hval0_l}{'for_upd'}) ) { #if need to add/upd ifcfg
		while ( ($hkey1_l,$hval1_l)=each %{${$hval0_l}{'for_upd'}} ) {
		    #hkey1_l=ifcfg_name
		    print DYN_YML "    - $hkey1_l\n";
		}
		($hkey1_l,$hval1_l)=(undef,undef);
	    }
	    print DYN_YML "\n";
	    print DYN_YML "######################################################\n";
	    print DYN_YML "\n";
	    
	    ###task for '03_config_temporary_apply_ifcfg' (FOR start RUN BEFORE network restart) (begin)
		#%inv_hosts_tmp_apply_cfg_g=(); #key=inv_host/common, value=rollback_ifcfg_timeout
	    if ( $gen_playbooks_next_with_rollback_l==1 && (exists(${$inv_hosts_tmp_apply_cfg_href_l}{$hkey0_l}) or exists(${$inv_hosts_tmp_apply_cfg_href_l}{'common'})) ) {
		#tmp_var_l=rollback_ifcfg_timeout
		if ( exists(${$inv_hosts_tmp_apply_cfg_href_l}{$hkey0_l}) ) { $tmp_var_l=${$inv_hosts_tmp_apply_cfg_href_l}{$hkey0_l}; }
		elsif ( exists(${$inv_hosts_tmp_apply_cfg_href_l}{'common'}) ) { $tmp_var_l=${$inv_hosts_tmp_apply_cfg_href_l}{'common'}; }
		
		print DYN_YML "- name: copy script 'rollback_ifcfg_changes.sh' to remote\n";
		print DYN_YML "  ansible.builtin.copy:\n";
		print DYN_YML "    src: \"{{playbook_dir}}/../scripts_for_remote/rollback_ifcfg_changes.sh\"\n";
		print DYN_YML "    dest: \"$remote_dir_for_absible_helper_l/rollback_ifcfg_changes.sh\"\n";
    		print DYN_YML "    mode: '0700'\n";
		print DYN_YML "\n";
		print DYN_YML "######################################################\n";
		print DYN_YML "\n";
		
		print DYN_YML "- name: run script 'rollback_ifcfg_changes.sh' as process\n";
		print DYN_YML "  ansible.builtin.raw: \"nohup sh -c '$remote_dir_for_absible_helper_l/rollback_ifcfg_changes.sh $tmp_var_l >/dev/null 2>&1' & sleep 3\"\n";
		print DYN_YML "\n";
		print DYN_YML "######################################################\n";
		print DYN_YML "\n";

	    }
	    ###task for '03_config_temporary_apply_ifcfg' (end)

	    print DYN_YML "- name: restart network.service\n";
	    print DYN_YML "  ansible.builtin.systemd:\n";
	    print DYN_YML "    name: network.service\n";
	    print DYN_YML "    state: restarted\n";
	    print DYN_YML "\n";
	    print DYN_YML "######################################################\n";
	    print DYN_YML "\n";
	}
	
	###task for copy resolv.conf (begin)
	if ( exists(${$inv_hosts_dns_href_l}{$hkey0_l}) ) { #use special resolv.conf for inv_host
	    print DYN_YML "- name: copy/upd resolv.conf\n";
	    print DYN_YML "  ansible.builtin.copy:\n";
	    print DYN_YML "    src: \"{{playbook_dir}}/dyn_resolv_conf/{{inventory_hostname}}_resolv\"\n";
	    print DYN_YML "    dest: \"/etc/resolv.conf\"\n";
    	    print DYN_YML "    owner: root\n";
    	    print DYN_YML "    group: root\n";
    	    print DYN_YML "    mode: '0644'\n";
    	    print DYN_YML "    seuser: system_u\n";
    	    print DYN_YML "    setype: net_conf_t\n";
    	    print DYN_YML "    serole: object_r\n";
    	    print DYN_YML "    selevel: s0\n";
    	    print DYN_YML "    backup: yes\n";
	}
	elsif ( ${$inv_hosts_dns_href_l}{'common'} ) { #use common resolv.conf
	    print DYN_YML "- name: copy/upd ifcfg-files\n";
	    print DYN_YML "  ansible.builtin.copy:\n";
	    print DYN_YML "    src: \"{{playbook_dir}}/dyn_resolv_conf/common_resolv\"\n";
	    print DYN_YML "    dest: \"/etc/resolv.conf\"\n";
    	    print DYN_YML "    owner: root\n";
    	    print DYN_YML "    group: root\n";
    	    print DYN_YML "    mode: '0644'\n";
    	    print DYN_YML "    seuser: system_u\n";
    	    print DYN_YML "    setype: net_conf_t\n";
    	    print DYN_YML "    serole: object_r\n";
    	    print DYN_YML "    selevel: s0\n";
    	    print DYN_YML "    backup: yes\n";
	}
	print DYN_YML "\n";
	print DYN_YML "######################################################\n";
	print DYN_YML "\n";
	###task for copy resolv.conf (end)
	
	###for cancel operation of rollback ifcfg changes if run 'apply_immediately_ifcfg.sh' with GEN_DYN_IFCFG_RUN='yes' (begin)
	if ( $gen_playbooks_next_with_rollback_l==0 ) {
	    print DYN_YML "- name: cancel rollback operation (rollback_ifcfg_changes.sh) if need\n";
	    print DYN_YML "  ansible.builtin.command: \"pkill -9 -f rollback_ifcfg_changes\"\n";
	    print DYN_YML "  ignore_errors: yes\n";
	    print DYN_YML "\n";
	    print DYN_YML "######################################################\n";
	    print DYN_YML "\n";
	}
	###for cancel operation of rollback ifcfg changes if run 'apply_immediately_ifcfg.sh' with GEN_DYN_IFCFG_RUN='yes' (end)
	
	close(DYN_YML);
	$tmp_file0_l=undef;
    }
    ($hkey0_l,$hval0_l)=(undef,undef);
    ($hkey1_l,$hval1_l)=(undef,undef);
    $tmp_file0_l=undef;
    
    return $return_str_l;
}

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
