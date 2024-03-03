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
        1) Run playbook 'ifcfg_backup_playbook.yml' ->
	    1) Run task 'tasks/ifcfg_backup_task_main.yml'.
	    2) Run task 'tasks/ifcfg_backup_collect_raw_network_data_task.yml'.
	2) Run script 'generate_dynamic_ifcfg.pl'. Steps:
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
	    7) Run procedure 'read_config_del_not_configured_ifcfg'.
	    8) Run procedure 'read_config_temporary_apply_ifcfg'.
	    9) Run procedure 'fill_inv_hosts_hash1_with_fin_n_now_dirs'.
	    10) Run procedure 'modify_inv_hosts_hash1'.
	    11) Run procedure 'generate_dynamic_playbooks'.

'00_just_install_network_scripts.sh' ->
    1) Run script 'main.sh' ->
	1) Run playbook 'just_install_network_scripts_playbook.yml' ->

'01_check_ifcfg_without_apply.sh' ->
    1) Run script 'main.sh' ->
        1) Run playbook 'ifcfg_backup_playbook.yml' ->
	    *** See description for '00_install_network_scripts_and_configure_network.sh'.
	2) Run script 'generate_dynamic_ifcfg.pl'. Steps:
	    *** See description for '00_install_network_scripts_and_configure_network.sh'.

'01_check_network_scripts_serv_is_started.sh' ->
    1) Run script 'main.sh' ->
	1) Run playbook 'check_network_scripts_serv_is_started_playbook.yml' ->

'02_just_run_ifcfg_backup.sh' ->
    1) Run script 'main.sh' ->
        1) Run playbook 'ifcfg_backup_playbook.yml' ->

'03_apply_immediately_ifcfg.sh' ->
    1) Run script 'main.sh' ->
        1) Run playbook 'ifcfg_backup_playbook.yml' ->

	2) Run script 'generate_dynamic_ifcfg.pl'. Steps:
	    *** See description for '00_install_network_scripts_and_configure_network.sh'.

'03_apply_temporary_ifcfg.sh' ->
    1) Run script 'main.sh' ->
        1) Run playbook 'ifcfg_backup_playbook_for_temp_apply.yml' ->

	2) Run script 'generate_dynamic_ifcfg.pl'. Steps:
	
##################

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )

#Habr: https://habr.com/ru/post/700460/
