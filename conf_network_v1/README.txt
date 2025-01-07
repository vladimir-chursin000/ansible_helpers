# Not READY yet!
#####
# For OS based on RHEL8 (AlmaLinux8, RockyLinux8, etc).
# I think it will work on RHEL6/RHEL7 based systems.
####
# 1) UPDATE list (for install and configure network) of ip addresses = conf_network_hosts (inventory).

# *) Make sure that the pub-ssh-key is thrown to the hosts (conf_network_scripts_hosts).

# *) Run '00_install_network_backend_n_conf_network.sh' (or '03_apply_immediately_ifcfg.sh').
##################

# '00_install_network_backend_n_conf_network.sh' = install network backend and configure network after.

# '00_just_install_network_backend.sh' = just install network backend.

# '01_check_conf_without_apply.sh' = just check configuration without apply new settings.

# '01_check_network_serv_is_started.sh' = check for network.service is started (and start if not).

# '02_just_run_conf_backup.sh' = copy conf-files from remote hosts. Also collect network data (to '02_files/conf_backup_from_remote/network_data') and analyze it
# for find duplicates of mac-addresses. 
# Detected mac duplicates -> 'WARNINGS.txt'
# INFO about existing mac-addresses at inv_hosts -> 'inv_hosts_interfaces_info.txt'.
# INFO about network neighbours of inv_hosts -> 'inv_hosts_neighbour_info.txt'.

# '03_apply_conf_immediately.sh' = run for immediately apply changes (without run installation of 'network-scripts') if generated ifcfg differ from actual ifcfg on remote host.
# Also cancel execution of ifcfg rollback operation (rollback_ifcfg_changes.sh) on remote host if need.

# '03_apply_conf_temporary.sh' = run for temporary apply changes (without run installation of 'network-scripts') if generated ifcfg differs from actual ifcfg.
# Before apply changes starts script 'rollback_ifcfg_changes.sh' on remote host for
# rollback changes after N minutes (rollback_timeout configuration = '01_configs/03_config_temporary_apply_ifcfg').

# All scripts above can be run with a parameter "limit=limit_hosts" that limits the application of changes to inventory hosts.
# Possible limit values: 1) single inventory host; 2) list of inventory hosts separated by ",";
# 3) group name configured at cfg-file '00_conf_divisions_for_inv_hosts'.
# Examples (on the example of the script '03_apply_immediately_ifcfg.sh'):
# 1) ./03_apply_immediately_ifcfg.sh "limit=192.168.168.1";
# 2) ./03_apply_immediately_ifcfg.sh "limit=192.168.168.1,192.168.168.2";
# 3) ./03_apply_immediately_ifcfg.sh "limit=gr_some_group1".

# 'generate_json_files.pl' = SCRIPT for generate json-files for playbooks. Used with
# '03_apply_immediately_ifcfg.sh', '03_apply_temporary_ifcfg.sh' and '00_install_network_scripts_and_configure_network.sh'.

##################
SCRIPTS LOGIC DESCRIPTION
	
##################

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
