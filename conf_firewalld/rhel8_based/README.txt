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
	1) fwrules_backup_playbook.yml ->
	    1) tasks/fwrules_backup_task_main.yml
	    2) tasks/fwrules_backup_collect_raw_network_data_task.yml
	2) generate_dynamic_fwrules.pl. Important ops:
	    1) remove sh/conf-files from "playbooks/scripts_for_remote/fwrules_files".
	    2) generate new sh/conf-files at "playbooks/scripts_for_remote/fwrules_files".
	2) full_install_firewall_and_configure_fwrules_playbook.yml ->
	    1) just_install_firewall_playbook.yml
	    2) check_firewall_serv_is_started_playbook.yml
	    3) fwrules_apply_immediately_playbook.yml ->
		1) tasks for check for 'apply_fwrules_is_run_now' and 'rollback_fwrules_changes_is_run_now' at remote side.
		2) tasks for kill rollback process and remove 'rollback_fwrules_changes_is_run_now' if need.
		If not exists 'apply_fwrules_is_run_now' at remote side (!!!) ->
		    3) tasks/fwrules_apply_fwconfig_task.yml (for apply firewalld.conf).
		    4) tasks/fwrules_apply_droppd_conf_task.yml (for apply '/etc/rsyslog.d/firewalld-droppd.conf').
		    5) tasks/fwrules_apply_task.yml (for apply firewall rules: recreate ipsets/zones/policies).
			1) Check for locally generated fwrules files is exist.
			    Fwrules files (at "scripts_for_remote/fwrules_files"): INV_HOSTNAME_recreate_ipsets.sh,
				INV_HOSTNAME_recreate_fw_zones.sh, INV_HOSTNAME_recreate_policies.sh,
				INV_HOSTNAME_rollback_fwrules_changes.sh
			2) Create_dir "~/ansible_helpers/conf_firewalld" (if not exists) and 
			    remove file "~/ansible_helpers/conf_firewalld/rollback_fwrules_changes.sh" 
			    at remote side before run 'apply_fwrules.sh'
			3) Copy recreated fwrules-files and rollback-script to remote if need.
			    "scripts_for_remote/fwrules_files/INV_HOSTNAME_recreate_ipsets.sh" -> "~/ansible_helpers/conf_firewalld/recreate_ipsets.sh".
			    "scripts_for_remote/fwrules_files/INV_HOSTNAME_recreate_fw_zones.sh" -> "~/ansible_helpers/conf_firewalld/recreate_fw_zones.sh".
			    "scripts_for_remote/fwrules_files/INV_HOSTNAME_recreate_policies.sh" -> "~/ansible_helpers/conf_firewalld/recreate_policies.sh".
			    "scripts_for_remote/fwrules_files/INV_HOSTNAME_rollback_fwrules_changes.sh" -> "~/ansible_helpers/conf_firewalld/rollback_fwrules_changes.sh".
			    "scripts_for_remote/apply_fwrules.sh" -> "~/ansible_helpers/conf_firewalld/apply_fwrules.sh".
			4) Run 'apply_fwrules.sh' as process at remote side if one of the files is updated: recreate_ipsets.sh,
			    recreate_fw_zones.sh, recreate_policies.sh

'00_just_install_firewall.sh' ->
    1) main.sh ->
	1) just_install_firewall_playbook.yml

'01_check_firewall_serv_is_started.sh' ->
    1) main.sh ->
	1) check_firewall_serv_is_started_playbook.yml

'01_check_fwrules_without_apply.sh' ->
    1) main.sh ->
	1) fwrules_backup_playbook.yml ->
	    1) tasks/fwrules_backup_task_main.yml
	    2) tasks/fwrules_backup_collect_raw_network_data_task.yml
	2) generate_dynamic_fwrules.pl. Important ops:
	    1) remove sh/conf-files from "playbooks/scripts_for_remote/fwrules_files".
	    2) generate new sh/conf-files at "playbooks/scripts_for_remote/fwrules_files".

'02_just_run_fwrules_backup.sh' ->
    1) main.sh ->
	1) fwrules_backup_playbook.yml ->
	    1) tasks/fwrules_backup_task_main.yml
	    2) tasks/fwrules_backup_collect_raw_network_data_task.yml

'03_apply_immediately_fwrules.sh' ->
    1) main.sh ->
	1) fwrules_backup_playbook.yml ->
	    1) tasks/fwrules_backup_task_main.yml
	    2) tasks/fwrules_backup_collect_raw_network_data_task.yml
	2) generate_dynamic_fwrules.pl. Important ops:
	    1) remove sh/conf-files from "playbooks/scripts_for_remote/fwrules_files".
	    2) generate new sh/conf-files at "playbooks/scripts_for_remote/fwrules_files".
	3) fwrules_apply_immediately_playbook.yml ->
	    1) tasks for check for 'apply_fwrules_is_run_now' and 'rollback_fwrules_changes_is_run_now' at remote side.
	    2) tasks for kill rollback process and remove 'rollback_fwrules_changes_is_run_now' if need.
	    If not exists 'apply_fwrules_is_run_now' at remote side (!!!) ->
		3) tasks/fwrules_apply_fwconfig_task.yml (for apply firewalld.conf).
		4) tasks/fwrules_apply_droppd_conf_task.yml (for apply '/etc/rsyslog.d/firewalld-droppd.conf').
		5) tasks/fwrules_apply_task.yml (for apply firewall rules: recreate ipsets/zones/policies).

'03_apply_temporary_fwrules.sh' ->
    1) main.sh ->
	1) fwrules_backup_playbook_for_temp_apply.yml ->
	    1) tasks/fwrules_backup_task_main.yml
	    2) tasks/fwrules_local_backup_for_temp_apply_task.yml
	    3) tasks/fwrules_backup_collect_raw_network_data_task.yml
	2) generate_dynamic_fwrules.pl. Important ops:
	    1) remove sh/conf-files from "playbooks/scripts_for_remote/fwrules_files".
	    2) generate new sh/conf-files (!!! with 'rollback_fwrules_changes.sh') at "playbooks/scripts_for_remote/fwrules_files".
	3) fwrules_apply_temporary_playbook.yml ->
	    1) tasks for check for 'apply_fwrules_is_run_now' and 'rollback_fwrules_changes_is_run_now' at remote side.
	    If not exists 'apply_fwrules_is_run_now' and 'rollback_fwrules_changes_is_run_now' at remote side (!!!) ->
		3) tasks/fwrules_apply_fwconfig_task.yml (for apply firewalld.conf).
		4) tasks/fwrules_apply_droppd_conf_task.yml (for apply '/etc/rsyslog.d/firewalld-droppd.conf').
		5) tasks/fwrules_apply_task.yml (for apply firewall rules: recreate ipsets/zones/policies).

'03_force_apply_fwrules.sh' ->
    1) main.sh ->
	1) fwrules_backup_playbook.yml ->
	    1) tasks/fwrules_backup_task_main.yml
	    2) tasks/fwrules_backup_collect_raw_network_data_task.yml
	2) generate_dynamic_fwrules.pl. Important ops:
	    1) remove sh/conf-files from "playbooks/scripts_for_remote/fwrules_files".
	    2) generate new sh/conf-files at "playbooks/scripts_for_remote/fwrules_files".
	3) fwrules_force_apply_playbook.yml ->
	    1) Kill rollback/apply_fwrules processes if need and remove content of '~/ansible_helpers/conf_firewalld'.
		For run like first time.
	    2) tasks/fwrules_apply_fwconfig_task.yml (for apply firewalld.conf).
	    3) tasks/fwrules_apply_droppd_conf_task.yml (for apply '/etc/rsyslog.d/firewalld-droppd.conf').
	    4) tasks/fwrules_apply_task.yml (for apply firewall rules: recreate ipsets/zones/policies).
##################
#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
