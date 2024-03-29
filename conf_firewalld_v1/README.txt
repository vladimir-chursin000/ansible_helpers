NOT READY! Testing!
####
# For OS based on RHEL8 (AlmaLinux8, RockyLinux8, etc).
# I think it will work on RHEL7 based systems.
####
# 1) UPDATE list (for install and configure firewall) of ip addresses = conf_firewall_hosts (inventory).

# 2) Fill conf files at dir '01_fwrules_configs'.

# 3) Make sure that the pub-ssh-key is thrown to the hosts (conf_firewall_hosts).

# 4) Run '00_install_firewall_and_configure_fwrules.sh' (or '03_apply_immediately_fwrules.sh').
##################

# '00_just_install_firewall.sh' = just install firewalld and some ther packages.
# For install packages: firewall, procps-ng, rsyslog, conntrack-tools.

# '00_update_firewall.sh' = update firewalld and some other packages.
# For uodate packages: firewall, procps-ng, rsyslog, conntrack-tools.

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
# rollback changes after N minutes (param 'temporary_apply_fwrules_timeout' at conf '01_fwrules_configs/00_conf_firewalld').

# '03_force_apply_fwrules.sh' = force apply changes (without run installation of 'firewalld') without comparing generated and actual rules.

# '04_add_ipset_entry.sh' = adding IP-addresses and/or subnets to a specific ipset on remote hosts.
# Possible input ARGV-parameters:
# 1) ipset_list (required parameter). List of IP-addresses and/or subnets separated by ";".
# 2) ipset_tmplt_name (required parameter). Name of the ipset template configured in files '01_conf_ipset_templates' and '66_conf_ipsets_FIN'.
# 3) limit (optional parameter). Limits the application of changes to inventory hosts.
# 4) expire_dt (optional parameter). Sets the expiration date (format "YYYYMMDDHHMISS") for ipset entries listed at paramater 'ipset_list'.
# 5) rollback (optional parameter). If "yes", then after N (param 'temporary_apply_fwrules_timeout' from conf '00_conf_firewalld')
# minutes the changes to the ipset (corresponding to the ipset_tmplt_name) will be rolled back.
# ###
# Examples:
# 1) ./04_add_ipset_entry.sh "ipset_list=10.11.12.13;192.168.9.0/24" "ipset_tmplt_name=some_tmplt--TMPLT";
# 2) ./04_add_ipset_entry.sh "limit=192.168.8.7" "ipset_list=10.11.12.13;192.168.9.0/24" "ipset_tmplt_name=some_tmplt--TMPLT";
# 3) ./04_add_ipset_entry.sh "limit=gr_some_group1" "ipset_list=10.11.12.13;192.168.9.0/24" "ipset_tmplt_name=some_tmplt--TMPLT" "expire_dt=20241010150010";
# 4) ./04_add_ipset_entry.sh "limit=192.168.8.7,10.1.2.3" "ipset_list=10.11.12.13;192.168.9.0/24" "ipset_tmplt_name=some_tmplt--TMPLT" "expire_dt=20241010150010" "rollback=yes".

# '04_del_ipset_entry.sh' = deleting IP-addresses and/or subnets from a specific ipset on remote hosts.
# *** See possible input params and examples for '04_add_ipset_entry.sh'.

# '05_get_exec_logs_from_remote.sh' = download execution logs (apply_fwrules.sh and rollback_fwrules_changes.sh) from remote dir
# '~/ansible_helpers/conf_firewalld/exec_results' to local dir '../run_history/from_remote'.
# If 'apply_fwrules.sh' or 'rollback_fwrules_changes.sh' is run at remote -> skip downloading.

# '05_remove_exec_logs_at_remote.sh' = remove logs at remote dir '~/ansible_helpers/conf_firewalld/exec_results'.
# If 'apply_fwrules.sh' or 'rollback_fwrules_changes.sh' is run at remote -> skip removing.

# '06_activate_crontab_ops_at_remote.sh' = add scripts for remote execution (from dir '../playbooks/scripts_for_remote/for_cron')
# to crontab at remote side.
# For cron scripts:
# 1) 'check_external_timeouts_for_permanent_ipsets.sh'. Checks external obsolescence dates for elements of permanent ipsets.
# If an element with an outdated date is found, such an element will be deleted from the ipset.
# 2) 'restore_tmp_ipsets_content_after_reboot.sh'.

# '06_deactivate_crontab_ops_at_remote.sh' = remove scripts for remote execution from crontab at remote side.

# '07_temporary_enable_panic_mode.sh' = for temporary enable panic mode (block all input/output network trafic).
# Also kill all ssh sessions and flush conntrack table.

# For the script '07_temporary_enable_panic_mode.sh' the parameter 'timeout' is available.
# This parameter limits the duration of the 'panic' mode (in minutes).
# The default value (one minute) of the parameter can be edited in the script.
# Examples:
# 1) ./07_temporary_enable_panic_mode.sh "timeout=3";
# 2) ./07_temporary_enable_panic_mode.sh "limit=192.168.168.1" "timeout=3";
# 3) ./07_temporary_enable_panic_mode.sh "timeout=3" "limit=192.168.168.1";

# '99_stop_and_disable_firewall.sh' = stop and disable service 'firewalld.service' at remote.

# '99_uninstall_firewall.sh' = uninstall firewalld at remote.
# For uninstall packages: firewall.

# All scripts above can be run with a parameter "limit=limit_hosts" that limits the application of changes to inventory hosts.
# Possible limit values: 1) single inventory host; 2) list of inventory hosts separated by ",";
# 3) group name configured at cfg-file '00_conf_divisions_for_inv_hosts'.
# Examples (on the example of the script '03_force_apply_fwrules.sh'):
# 1) ./03_force_apply_fwrules.sh "limit=192.168.168.1";
# 2) ./03_force_apply_fwrules.sh "limit=192.168.168.1,192.168.168.2";
# 3) ./03_force_apply_fwrules.sh "limit=gr_some_group1".

# 'generate_dynamic_fwrules.pl' = SCRIPT for generate firewall rules for each inventory host.
# Used with '00_install_firewall_and_configure_fwrules.sh', '03_apply_immediately_fwrules.sh', '03_apply_temporary_fwrules.sh' .

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
		(info) Read file 'conf_firewall_hosts' to hash '%inventory_hosts_g'.
	    3) Run procedure 'read_network_data_for_checks'.
		(info) Read file 'fwrules_backup_from_remote/network_data/inv_hosts_interfaces_info.txt' to hash '%inv_hosts_network_data_g'.
	    4) Read configuration files from dir '01_fwrules_configs' to several hashes.
	    5) Run procedure 'apply_IPSET_files_operation_main'.
		(info) Handles the contents of directories '02_ipset_input' and '03_ipset_actual_data'.
    	    6) Generate new sh/conf-files (and other files) at 'scripts_for_remote/fwrules_files'.
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

'04_add_ipset_entry.sh' ->
    1) Run script 'main.sh' ->
	1) Run playbook '02_fwrules_backup_pb.yml' ->
	    *** See description for '00_install_firewall_and_configure_fwrules.sh'.
	2) Run script 'generate_dynamic_fwrules.pl'. Steps:
	    *** See description for '00_install_firewall_and_configure_fwrules.sh'.
	3a) Run playbook '03_IMPORT_fwrules_apply_immediately_pb.yml' (default. If no input ARGV-param "rollback") ->
	    1) Run playbook 'fwrules_apply_immediately_pb.yml' ->
                *** See description for '00_install_firewall_and_configure_fwrules.sh'.
            2) Run playbook 'FIN_RUN_apply_fwrules_pb.yml' (run 'apply_fwrules.sh' as process at remote).
	3b) Run playbook '03_IMPORT_fwrules_apply_temporary_pb.yml' (if input ARGV-param "rollback=yes").
	    1) Run playbook 'fwrules_apply_temporary_pb.yml' ->
                *** See description for '03_apply_temporary_fwrules.sh'.
            2) Run playbook 'FIN_RUN_apply_fwrules_pb.yml' (run 'apply_fwrules.sh' as process at remote).

'04_del_ipset_entry.sh' ->
    *** See description for '04_add_ipset_entry.sh'.

'05_get_exec_logs_from_remote.sh' ->
    1) Run script 'main.sh' ->
	1) Run playbook '06_get_exec_logs_from_remote_pb.yml'.

'05_remove_exec_logs_at_remote.sh' ->
    1) Run script 'main.sh' ->
	1) Run playbook '07_remove_exec_logs_at_remote_pb.yml'.

'06_activate_crontab_ops_at_remote.sh' ->
    1) Run script 'main.sh' ->
	1) Run playbook '06_activate_crontab_ops_at_remote_pb.yml'.

'06_deactivate_crontab_ops_at_remote.sh' ->
    1) Run script 'main.sh' ->
	1) Run playbook '06_deactivate_crontab_ops_at_remote_pb.yml'.

'07_temporary_enable_panic_mode.sh' ->
    1) Run script 'main.sh' ->
	1) Run playbook '07_temporary_enable_panic_mode_pb.yml'.

'99_stop_and_disable_firewall.sh' ->
    1) Run script 'main.sh' ->
	1) Run playbook '99_stop_and_disable_firewall_pb.yml'.

'99_uninstall_firewall.sh' ->
    1) Run script 'main.sh' ->
	1) Run playbook '99_uninstall_firewall_pb.yml'.

##################
#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
