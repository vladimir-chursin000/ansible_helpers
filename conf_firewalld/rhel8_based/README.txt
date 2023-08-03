NOT READY! Some refactoring!
####
# 1) UPDATE list (for install and configure firewall) of ip addresses = conf_firewall_hosts (inventory).

# 2) Fill conf files at dir 'fwrules_configs'.

# 3) Make sure that the pub-ssh-key is thrown to the hosts (conf_firewall_hosts).

# 4) Run '00_install_firewall_and_configure_fwrules.sh' (or '03_apply_immediately_fwrules.sh').
##################

# '00_just_install_firewall.sh' = just install firewalld.

# '01_check_firewall_serv_is_started.sh' = check for firewalld.service is started (and start if not).

# '01_check_fwrules_without_apply.sh' = just check configuration without apply new settings.

# '02_just_run_fwrules_backup.sh' = copy fwrules-files (content of '/etc/firewalld' and output of 'firewall-cmd --list-all-zones') from remote hosts. 
# Also collect network data (at 'playbooks/fwrules_backup_from_remote/network_data') for get interface names.
# INFO about existing interface names (and ip addr) at inv_hosts -> 'inv_hosts_interfaces_info.txt'.

# '03_apply_immediately_fwrules.sh' = run for immediately apply changes (without run installation of 'firewalld') if generated firewall rules differ from actual rules on remote host.
# Actual rules = content of scrips 'recreate_ipsets.sh', 'recreate_fw_zones.sh' and 'recreate_policies.sh' at remote side.
# That is, idempotency is provided at the level of the files listed below.
# Also cancel execution of firewall rules rollback operation (rollback_fwrules_changes.sh) on remote host if need.

# '03_apply_temporary_fwrules.sh' = run for temporary apply changes (without run installation of 'firewalld') if generated firewall rules differs from actual rules.
# Before apply changes starts script 'rollback_fwrules_changes.sh' on remote host for
# rollback changes after N minutes (rollback_timeout configuration = 'fwrules_configs/config_temporary_apply_fwrules').

# '03_force_apply_fwrules.sh' = force apply changes (without run installation of 'firewalld') without comparing generated and actual rules.

# 'generate_dynamic_fwrules.pl' = SCRIPT for generate firewall rules for each inventory host.
# Used with '00_install_firewall_and_configure_fwrules.sh', '03_apply_immediately_fwrules.sh', '03_apply_temporary_fwrules.sh' .

# 'IPSET_files_operation.pl' = SCRIPT for create subfolders and manipulate ipset-files for each inventory host.
##################
SCRIPTS LOGIC DESCRIPTION
'00_install_firewall_and_configure_fwrules.sh' ->
    1) Run script 'main.sh' ->
        1) Run playbook '02_fwrules_backup_pb.yml' ->
    	    1) Run task 'tasks/fwrules_backup_task_main.yml'.
    	    2) Run task 'tasks/fwrules_backup_collect_raw_network_data_task.yml'.
	    3) Run script 'scripts_for_local/convert_raw_network_data_to_normal.pl'
		(info) Converts raw network data from 'fwrules_backup_from_remote/network_data'
		    to file 'inv_hosts_interfaces_info.txt' at the same dir.
	2) Run script 'generate_dynamic_fwrules.pl'. Steps:
	    1) Run procedure 'init_files_ops_with_local_dyn_fwrules_files_dir'.
		1) Recreate dir 'scripts_for_remote/fwrules_files' if need.
    		2) Remove sh/conf-files from 'scripts_for_remote/fwrules_files'.
	    2) Run procedure 'read_inventory_file'.
		(info) REad file 'conf_firewall_hosts' to hash '%inventory_hosts_g'.
	    3) Run procedure 'read_network_data_for_checks'.
		(info) Read file 'fwrules_backup_from_remote/network_data/inv_hosts_interfaces_info.txt' to hash '%inv_hosts_network_data_g'.
	    4) Read configuration files from dir 'fwrules_configs' to several hashes.
	    5) Run procedure 'apply_IPSET_files_operation_main'.
		(info) Handles the contents of directories 'ipset_input' and 'ipset_actual_data'.
    	    *) generate new sh/conf-files at 'scripts_for_remote/fwrules_files'
	3) Run playbook '00_IMPORT_install_firewall_n_conf_fwrules_pb.yml' ->
	    1) Run blaybook '00_just_install_firewall_pb.yml'.
	    2) Run playbook 'check_firewall_serv_is_started_pb.yml'.
	    3) Run playbook 'fwrules_apply_immediately_pb.yml' ->
		1) Fill vars: apply_fwrules_is_run_at_remote_now_exist, rollback_fwrules_changes_is_run_at_remote_now_exists.
		2) Kill rollback process and remove 'rollback_fwrules_changes_is_run_now' if need.
		    (info) If rollback_fwrules_changes_is_run_at_remote_now_exists=true + apply_fwrules_is_run_at_remote_now_exist=false.
		3) Run task 'tasks/fwrules_apply_fwconfig_task.yml'.
		    (info) If apply_fwrules_is_run_at_remote_now_exists=false.
		4) Run task 'tasks/fwrules_apply_droppd_conf_task.yml'.
		    (info) If apply_fwrules_is_run_at_remote_now_exists=false.
		5) Run task 'tasks/fwrules_apply_task.yml'.
		    (info) If apply_fwrules_is_run_at_remote_now_exists=false.
	    4) Run playbook 'FIN_RUN_apply_fwrules_pb.yml' (run 'apply_fwrules.sh' as process at remote).

'00_just_install_firewall.sh' ->
    1) Run script 'main.sh' ->
	1) Run playbook '00_just_install_firewall_pb.yml'.

'01_check_firewall_serv_is_started.sh' ->
    1) Run script 'main.sh' ->
	1) Run playbook '01_check_firewall_serv_is_started_pb.yml'.

'01_check_fwrules_without_apply.sh' ->
    1) Run script 'main.sh' ->
	1) Run playbook '02_fwrules_backup_pb.yml' ->
	    *** See description for '00_install_firewall_and_configure_fwrules.sh'.
	2) Run script 'generate_dynamic_fwrules.pl'. Steps:
	    *** See description for '00_install_firewall_and_configure_fwrules.sh'.

'02_just_run_fwrules_backup.sh' ->
    1) Run script 'main.sh' ->
	1) Run playbook '02_fwrules_backup_pb.yml' ->
	    *** See description for '00_install_firewall_and_configure_fwrules.sh'.

'03_apply_immediately_fwrules.sh' ->
    1) Run script 'main.sh' ->
	1) Run playbook '02_fwrules_backup_pb.yml' ->
	    *** See description for '00_install_firewall_and_configure_fwrules.sh'.
	2) Run script 'generate_dynamic_fwrules.pl'. Steps:
	    *** See description for '00_install_firewall_and_configure_fwrules.sh'.
	3) Run playbook '03_IMPORT_fwrules_apply_immediately_pb.yml' ->
	    1) Run playbook 'fwrules_apply_immediately_pb.yml' ->
		*** See description for '00_install_firewall_and_configure_fwrules.sh'.
	    2) Run playbook 'FIN_RUN_apply_fwrules_pb.yml' (run 'apply_fwrules.sh' as process at remote).

'03_apply_temporary_fwrules.sh' ->
    1) Run script 'main.sh' ->
	1) Run playbook '02_fwrules_backup_pb.yml' ->
	    *** See description for '00_install_firewall_and_configure_fwrules.sh'.
	2) Run script 'generate_dynamic_fwrules.pl'. Steps:
	    *** See description for '00_install_firewall_and_configure_fwrules.sh'.
	3) Run playbook '03_IMPORT_fwrules_apply_temporary_pb.yml' ->
	    1) Run playbook 'fwrules_apply_temporary_pb.yml' ->
		1) Fill vars: apply_fwrules_is_run_at_remote_now_exist, rollback_fwrules_changes_is_run_at_remote_now_exists.
		2) Run task 'tasks/fwrules_apply_fwconfig_task.yml'.
		    (info) If apply_fwrules_is_run_at_remote_now_exist=false + rollback_fwrules_changes_is_run_at_remote_now_exists=false.
		3) Run task 'tasks/fwrules_apply_droppd_conf_task.yml'.
		    (info) If apply_fwrules_is_run_at_remote_now_exist=false + rollback_fwrules_changes_is_run_at_remote_now_exists=false.
		4) Run task 'tasks/fwrules_apply_task.yml'.
		    (info) If apply_fwrules_is_run_at_remote_now_exist=false + rollback_fwrules_changes_is_run_at_remote_now_exists=false.
	    2) Run playbook 'FIN_RUN_apply_fwrules_pb.yml' (run 'apply_fwrules.sh' as process at remote).

'03_force_apply_fwrules.sh' ->
    1) Run script 'main.sh' ->
	1) Run playbook '02_fwrules_backup_pb.yml' ->
	    *** See description for '00_install_firewall_and_configure_fwrules.sh'.
	2) Run script 'generate_dynamic_fwrules.pl'. Steps:
	    *** See description for '00_install_firewall_and_configure_fwrules.sh'.
	3) Run playbook '03_IMPORT_fwrules_force_apply_pb.yml' ->
	    1) Run playbook 'fwrules_force_apply_pb.yml'.
		1) Fill vars: apply_fwrules_is_run_at_remote_now_exist, rollback_fwrules_changes_is_run_at_remote_now_exists.
		2) Kill rollback/apply_fwrules processes if need and remove content of '~/ansible_helpers/conf_firewalld'.
		    (info) If apply_fwrules_is_run_at_remote_now_exist=true -> kill apply_fwrules process.
		    (info) if rollback_fwrules_changes_is_run_at_remote_now_exists=true -> kill Kill rollback process.
		3) Run task 'tasks/fwrules_apply_fwconfig_task.yml'.
		    (info) Run without conditions.
		4) Run task 'tasks/fwrules_apply_task.yml'.
		    (info) Run without conditions.
		5) Run task 'tasks/fwrules_apply_droppd_conf_task.yml'.
		    (info) Run without conditions.
	    2) Run playbook 'FIN_RUN_apply_fwrules_pb.yml' (run 'apply_fwrules.sh' as process at remote).
    
##################
#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
