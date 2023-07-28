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
    1) main.sh ->
        1) 02_fwrules_backup_pb.yml ->
    	    1) tasks/fwrules_backup_task_main.yml
    	    2) tasks/fwrules_backup_collect_raw_network_data_task.yml
	2) generate_dynamic_fwrules.pl. Important ops:
    	    1) remove sh/conf-files from "playbooks/scripts_for_remote/fwrules_files".
    	    2) generate new sh/conf-files at "playbooks/scripts_for_remote/fwrules_files".
	3) 00_IMPORT_install_firewall_n_conf_fwrules_pb.yml ->
	    1) 00_just_install_firewall_pb.yml
	    2) check_firewall_serv_is_started_pb.yml
	    3) fwrules_apply_immediately_pb.yml ->
		1) Kill rollback process and remove 'rollback_fwrules_changes_is_run_now' if need
		2) tasks/fwrules_apply_fwconfig_task.yml
		3) tasks/fwrules_apply_droppd_conf_task.yml
		4) tasks/fwrules_apply_task.yml
	    4) FIN_RUN_apply_fwrules_pb.yml (run 'apply_fwrules.sh' as process at remote)

'00_just_install_firewall.sh' ->
    1) main.sh ->
	1) 00_just_install_firewall_pb.yml

'01_check_firewall_serv_is_started.sh' ->
    1) main.sh ->
	1) 01_check_firewall_serv_is_started_pb.yml

'01_check_fwrules_without_apply.sh' ->
    1) main.sh ->
	1) 02_fwrules_backup_pb.yml ->
    	    1) tasks/fwrules_backup_task_main.yml
    	    2) tasks/fwrules_backup_collect_raw_network_data_task.yml
	2) generate_dynamic_fwrules.pl. Important ops:
    	    1) remove sh/conf-files from "playbooks/scripts_for_remote/fwrules_files".
    	    2) generate new sh/conf-files at "playbooks/scripts_for_remote/fwrules_files".

'02_just_run_fwrules_backup.sh' ->
    1) main.sh ->
	1) 02_fwrules_backup_pb.yml ->
    	    1) tasks/fwrules_backup_task_main.yml
    	    2) tasks/fwrules_backup_collect_raw_network_data_task.yml

'03_apply_immediately_fwrules.sh' ->
    1) main.sh ->
	1) 02_fwrules_backup_pb.yml ->
    	    1) tasks/fwrules_backup_task_main.yml
    	    2) tasks/fwrules_backup_collect_raw_network_data_task.yml
	2) generate_dynamic_fwrules.pl. Important ops:
    	    1) remove sh/conf-files from "playbooks/scripts_for_remote/fwrules_files".
    	    2) generate new sh/conf-files at "playbooks/scripts_for_remote/fwrules_files".
	3) 03_IMPORT_fwrules_apply_immediately_pb.yml ->
	    1) fwrules_apply_immediately_pb.yml
	    2) FIN_RUN_apply_fwrules_pb.yml (run 'apply_fwrules.sh' as process at remote)

'03_apply_temporary_fwrules.sh' ->
    1) main.sh ->
	1) 02_fwrules_backup_pb.yml ->
    	    1) tasks/fwrules_backup_task_main.yml
    	    2) tasks/fwrules_backup_collect_raw_network_data_task.yml
	2) generate_dynamic_fwrules.pl. Important ops:
    	    1) remove sh/conf-files from "playbooks/scripts_for_remote/fwrules_files".
    	    2) generate new sh/conf-files at "playbooks/scripts_for_remote/fwrules_files".
	3) 03_IMPORT_fwrules_apply_temporary_pb.yml ->
	    1) fwrules_apply_temporary_pb.yml
	    2) FIN_RUN_apply_fwrules_pb.yml (run 'apply_fwrules.sh' as process at remote)

'03_force_apply_fwrules.sh' ->
    1) main.sh ->
	1) 02_fwrules_backup_pb.yml ->
    	    1) tasks/fwrules_backup_task_main.yml ->
    	    2) tasks/fwrules_backup_collect_raw_network_data_task.yml
	2) generate_dynamic_fwrules.pl. Important ops:
    	    1) remove sh/conf-files from "playbooks/scripts_for_remote/fwrules_files".
    	    2) generate new sh/conf-files at "playbooks/scripts_for_remote/fwrules_files".
	3) 03_IMPORT_fwrules_force_apply_pb.yml ->
	    1) fwrules_force_apply_pb.yml
	    2) FIN_RUN_apply_fwrules_pb.yml (run 'apply_fwrules.sh' as process at remote)
    
##################
#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
