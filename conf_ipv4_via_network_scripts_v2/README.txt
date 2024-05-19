# Not READY yet!
#####
# For OS based on RHEL8 (AlmaLinux8, RockyLinux8, etc).
# I think it will work on RHEL6/RHEL7 based systems.
####
# 1) UPDATE list (for install and configure network-scripts) of ip addresses = conf_network_scripts_hosts (inventory).

# 2) Fill conf_file='01_configs/00_config'. Example config='01_configs/00_config_examples'.

# 3) Update config file '01_configs/01_dns_settings' for configure resolv.conf at remote hosts.

# 4) If need to remove interfaces (shutdown and remove ifcfg-files) not included to '00_config' update config file '01_configs/02_config_del_not_configured_ifcfg'.

# 5) Make sure that the pub-ssh-key is thrown to the hosts (conf_network_scripts_hosts).

# 6) Run '00_install_network_scripts_and_configure_network.sh' (or '03_apply_immediately_ifcfg.sh').
##################

# '00_install_network_scripts_and_configure_network.sh' = install network-scripts and configure network after.

# '00_just_install_network_scripts.sh' = just install network-scripts.

# '01_check_ifcfg_without_apply.sh' = just check configuration without apply new settings.

# '01_check_network_scripts_serv_is_started.sh' = check for network.service is started (and start if not).

# '02_just_run_ifcfg_backup.sh' = copy ifcfg-files from remote hosts. Also collect network data (at 'playbooks/ifcfg_backup_from_remote/network_data') and analyze it
# for find duplicates of mac-addresses. 
# Detected mac duplicates -> 'WARNINGS.txt'
# INFO about existing mac-addresses at inv_hosts -> 'inv_hosts_interfaces_info.txt'.
# INFO about network neighbours of inv_hosts -> 'inv_hosts_neighbour_info.txt'.

# '03_apply_immediately_ifcfg.sh' = run for immediately apply changes (without run installation of 'network-scripts') if generated ifcfg differ from actual ifcfg on remote host.
# Also cancel execution of ifcfg rollback operation (rollback_ifcfg_changes.sh) on remote host if need.

# '03_apply_temporary_ifcfg.sh' = run for temporary apply changes (without run installation of 'network-scripts') if generated ifcfg differs from actual ifcfg.
# Before apply changes starts script 'rollback_ifcfg_changes.sh' on remote host for
# rollback changes after N minutes (rollback_timeout configuration = '01_configs/03_config_temporary_apply_ifcfg').

# All scripts above can be run with a parameter "limit=limit_hosts" that limits the application of changes to inventory hosts.
# Possible limit values: 1) single inventory host; 2) list of inventory hosts separated by ",";
# 3) group name configured at cfg-file '00_conf_divisions_for_inv_hosts'.
# Examples (on the example of the script '03_apply_immediately_ifcfg.sh'):
# 1) ./03_apply_immediately_ifcfg.sh "limit=192.168.168.1";
# 2) ./03_apply_immediately_ifcfg.sh "limit=192.168.168.1,192.168.168.2";
# 3) ./03_apply_immediately_ifcfg.sh "limit=gr_some_group1".

# 'generate_dynamic_ifcfg.pl' = SCRIPT for generate ifcfg-files, resolv.conf for each inventory host and dynamic playbooks for ifcfg and resolv.conf. Used with
# '03_apply_immediately_ifcfg.sh', '03_apply_temporary_ifcfg.sh' and '00_install_network_scripts_and_configure_network.sh'.

##################
SCRIPTS LOGIC DESCRIPTION
'00_install_network_scripts_and_configure_network.sh' ->
    1) Run script 'main.sh' ->
	1) Remove all content from dirs '../playbooks/ifcfg_backup_from_remote/now' (remove prev downloaded backup of ifcfg from now-dir)
	    and '../playbooks/ifcfg_backup_from_remote/network_data' (remove prev downloaded data from network_data).
        2) Run playbook 'ifcfg_backup_playbook.yml' ->
	    1) Run task 'tasks/ifcfg_backup_task_main.yml'.
	    2) Run task 'tasks/ifcfg_backup_collect_raw_network_data_task.yml'.
		(info) Operations:
		1) "ip -o link | grep -v noqueue > ~/ansible_helpers/conf_int_ipv4_via_network_scripts/ip_link_noqueue".
		2) "ip neighbour > ~/ansible_helpers/conf_int_ipv4_via_network_scripts/ip_neighbour".
		3) Copy files "ip_link_noqueue" and "ip_neighbour" to "../playbooks/ifcfg_backup_from_remote/network_data".
	3) Run perl-script '/playbooks/scripts_for_local/convert_raw_network_data_to_normal.pl'
	    for convert raw network data to normal format.
	4) Run script 'generate_dynamic_ifcfg.pl'. Steps:
            1) Run procedure 'read_inventory_file'.
                (info) Read file 'conf_network_scripts_hosts' to hash '%inventory_hosts_g'.
	    2) Run procedure 'read_00_conf_divisions_for_inv_hosts'.
		(info) Read file '01_configs/00_conf_divisions_for_inv_hosts' to hash '%h00_conf_divisions_for_inv_hosts_hash_g'.
	    3) Run procedure 'read_network_data_for_checks'.
		(info) Read file 'playbooks/ifcfg_backup_from_remote/network_data/inv_hosts_interfaces_info.txt'
		    to hash '%inv_hosts_network_data_g'.
	    4) Run procedure 'read_main_config'.
		(info) Read file '01_configs/00_config' to hash '%cfg0_hash_g'.
	    5) Run procedure 'recreate_ifcfg_tmplt_based_on_cfg0_hash'.
		(info) Create/recreate ifcfg-files (based on ifcfg-tmplt-files='playbooks/ifcfg_tmplt')
		    at dir='playbooks/dyn_ifcfg_playbooks/dyn_ifcfg' for hosts configured at '00_config'.

	    6) Run procedure 'generate_resolv_conf_files'.
		(info) Create/recreate resolv-conf-files for each inventory host
		    at dir='playbooks/dyn_ifcfg_playbooks/dyn_resolv_conf'.
	    7) Run procedure 'read_config_del_not_configured_ifcfg'.
		(info) Read file '01_configs/02_config_del_not_configured_ifcfg' to hash '%inv_hosts_ifcfg_del_not_configured_g'.
	    8) Run procedure 'read_config_temporary_apply_ifcfg'.
		(info) Read file '01_configs/03_config_temporary_apply_ifcfg' to hash '%inv_hosts_tmp_apply_cfg_g'.
	    9) Run procedure 'fill_inv_hosts_hash1_with_fin_n_now_dirs'.
		(info) Read file names from dirs 'playbooks/ifcfg_backup_from_remote/now/*INV_HOST*',
		'playbooks/dyn_ifcfg_playbooks/dyn_ifcfg/*INV_HOST*/fin' and save info into the hash '%inv_hosts_hash1_g'.
		    For 'now' (ifcfg-files downloaded from hosts) -> $inv_hosts_hash1_g{inv_host}{'now'}{interface_name}.
			Exception: wifi-interfaces.
		    For 'fin' (ifcfg-files finally gen by 'generate*' script) -> $inv_hosts_hash1_g{inv_host}{'fin'}{interface_name}.
	    10) Run procedure 'modify_inv_hosts_hash1'.
		(info) Modify hash '%inv_hosts_hash1_g':
		    1) If content of now-ifcfg-file (file name from '$inv_hosts_hash1_g{inv_host}{'now'}{interface_name}')
			differ from content of fin-ifcfg-file (file name from '$inv_hosts_hash1_g{inv_host}{'fin'}{interface_name}')
			or fin-ifcfg-file is new ->
			-> create hash-record '$inv_hosts_hash1_g{inv_host}{'for_upd'}{ifcfg-name}'
			    (for create interface at remote side).
		    2) For inv-hosts configured at '02_config_del_not_configured_ifcfg'.
			2.1) If env-host exists at 'now' and not exits at 'fin' -> 
			    -> create hash-record '$inv_hosts_hash1_g{inv_host}{'for_del'}{ifcfg-name}'
				(for shutdown interface and delete ifcfg-file at remote side).
			2.2) If env-host exists at 'now' + not exits at 'fin' + interface-name not exists at remote host ->
			    -> create hash-record '$inv_hosts_hash1_g{inv_host}{'for_del_ip_link'}{interface_name}'
				(for operation 'ip link delete <interface_name>' at remote side).
	    11) Run procedure 'generate_dynamic_playbooks'.
		Generates playbook 'aa.bb.cc.dd_ifcfg_change.yml' at 'playbooks/dyn_ifcfg_playbooks' for each inventory host.
		    1) If exists '$inv_hosts_hash1_g{inv_host}{'for_del'}{ifcfg-name}' ->
			add tasks for shutdown and delete interfaces at remote.
		    2) If exists '$inv_hosts_hash1_g{inv_host}{'for_del_ip_link'}{interface_name}' ->
			add task with 'ip link delete <interface_name>' for exec at remote.
		    3) If exists '$inv_hosts_hash1_g{inv_host}{'for_upd'}{ifcfg-name}' ->
			add task for 'upd/add' interfaces at remote.
		    4) If rollback needed -> add tasks for rollback changes at remote.
		    5) If items 1-4 is actual -> add task for restart network.service at remote.
		    6) Add task for update resolv.conf at remote.
		    7) If operation without rollback -> add task for cancel rollback.
	    
	5) Run playbook 'full_install_network_scripts_and_configure_network_playbook.yml' ->
	    1) Run playbook 'just_install_network_scripts_playbook.yml' (install network-scripts, procps-ng).
	    2) Run playbook 'check_network_scripts_serv_is_started_playbook.yml'.
	    3) Run playbook 'dyn_ifcfg_playbooks/dynamic_ifcfg_loader.yml'.
		1) Run dynamically generated playbook 'playbooks/dyn_ifcfg_playbooks/aa.bb.cc.dd_ifcfg_change.yml'.

'00_just_install_network_scripts.sh' ->
    1) Run script 'main.sh' ->
	1) Run playbook 'just_install_network_scripts_playbook.yml'.
	    *** See description for '00_install_network_scripts_and_configure_network.sh'.

'01_check_ifcfg_without_apply.sh' ->
    1) Run script 'main.sh' ->
	1) Remove all content from dirs '../playbooks/ifcfg_backup_from_remote/now' (remove prev downloaded backup of ifcfg from now-dir)
	    and '../playbooks/ifcfg_backup_from_remote/network_data' (remove prev downloaded data from network_data).
        2) Run playbook 'ifcfg_backup_playbook.yml' ->
	    *** See description for '00_install_network_scripts_and_configure_network.sh'.
	3) Run perl-script '/playbooks/scripts_for_local/convert_raw_network_data_to_normal.pl'
	    for convert raw network data to normal format.
	4) Run script 'generate_dynamic_ifcfg.pl'. Steps:
	    *** See description for '00_install_network_scripts_and_configure_network.sh'.

'01_check_network_scripts_serv_is_started.sh' ->
    1) Run script 'main.sh' ->
	1) Run playbook 'check_network_scripts_serv_is_started_playbook.yml'.

'02_just_run_ifcfg_backup.sh' ->
    1) Run script 'main.sh' ->
	1) Remove all content from dirs '../playbooks/ifcfg_backup_from_remote/now' (remove prev downloaded backup of ifcfg from now-dir)
	    and '../playbooks/ifcfg_backup_from_remote/network_data' (remove prev downloaded data from network_data).
	2) Run playbook 'ifcfg_backup_playbook.yml' ->
	    *** See description for '00_install_network_scripts_and_configure_network.sh'.
	3) Run perl-script '/playbooks/scripts_for_local/convert_raw_network_data_to_normal.pl'
	    for convert raw network data to normal format.

'03_apply_immediately_ifcfg.sh' ->
    1) Run script 'main.sh' ->
	1) Remove all content from dirs '../playbooks/ifcfg_backup_from_remote/now' (remove prev downloaded backup of ifcfg from now-dir)
	    and '../playbooks/ifcfg_backup_from_remote/network_data' (remove prev downloaded data from network_data).
        2) Run playbook 'ifcfg_backup_playbook.yml' ->
	    *** See description for '00_install_network_scripts_and_configure_network.sh'.
	3) Run perl-script '/playbooks/scripts_for_local/convert_raw_network_data_to_normal.pl'
	    for convert raw network data to normal format.
	4) Run script 'generate_dynamic_ifcfg.pl'. Steps:
	    *** See description for '00_install_network_scripts_and_configure_network.sh'.
	5) Run playbook 'dyn_ifcfg_playbooks/dynamic_ifcfg_loader.yml'.
	    *** See description for '00_install_network_scripts_and_configure_network.sh'.

'03_apply_temporary_ifcfg.sh' ->
    1) Run script 'main.sh' ->
	1) Remove all content from dirs '../playbooks/ifcfg_backup_from_remote/now' (remove prev downloaded backup of ifcfg from now-dir)
	    and '../playbooks/ifcfg_backup_from_remote/network_data' (remove prev downloaded data from network_data).
        2) Run playbook 'ifcfg_backup_playbook_for_temp_apply.yml' ->
	    1) Run task 'tasks/ifcfg_backup_task_main.yml'.
		*** See description for '00_install_network_scripts_and_configure_network.sh'.
	    2) Run task 'tasks/ifcfg_local_backup_for_temp_apply_task.yml' ->
		1) Run task 'tasks/ifcfg_backup_task_main.yml'.
		2) Run task 'tasks/ifcfg_local_backup_for_temp_apply_task.yml'.
		3) Run task 'tasks/ifcfg_backup_collect_raw_network_data_task.yml'.
		    *** See description for '00_install_network_scripts_and_configure_network.sh'.
	    3) Run task 'tasks/ifcfg_backup_collect_raw_network_data_task.yml'.
		*** See description for '00_install_network_scripts_and_configure_network.sh'.
	3) Run perl-script '/playbooks/scripts_for_local/convert_raw_network_data_to_normal.pl'
	    for convert raw network data to normal format.
	4) Run script 'generate_dynamic_ifcfg.pl'. Steps:
	    *** See description for '00_install_network_scripts_and_configure_network.sh'.
	5) Run playbook 'dyn_ifcfg_playbooks/dynamic_ifcfg_loader.yml'.
	    *** See description for '00_install_network_scripts_and_configure_network.sh'.
	
##################

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )

#Habr: https://habr.com/ru/post/700460/
