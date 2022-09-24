#1) UPDATE list (for install and configure network-scripts) of ip addresses = conf_network_scripts_hosts (inventory).

#2) Fill conf_file='config'. Example config='config_examples'.

#3) Update config file 'additional_configs/dns_settings' for configure resolv.conf at remote hosts.

#4) If need to remove interfaces (shutdown and remove ifcfg-files) not included to 'config' update config file 'additional_configs/config_del_not_configured_ifcfg'.

#5) Make sure that the pub-ssh-key is thrown to the hosts (conf_network_scripts_hosts).

#6) Run 'install_network_scripts_and_configure_network.sh' (or 'apply_immediately_ifcfg.sh').
##################

#'generate_dynamic_ifcfg.pl' = SCRIPT for generate ifcfg-files, resolv.conf for each inventory host and dynamic playbooks for ifcfg and resolv.conf. Used with
#'apply_immediately_ifcfg.sh' and 'install_network_scripts_and_configure_network.sh'.

#'apply_immediately_ifcfg.sh' = run for immediately apply changes (without run installation of 'network-scripts') if generated ifcfg differ from actual ifcfg on remote host.
#Also cancel execution of ifcfg rollback operation (rollback_ifcfg_changes.sh) on remote host if need.

#'apply_temporary_ifcfg.sh' = run for temporary apply changes (without run installation of 'network-scripts') if generated ifcfg differs from actual ifcfg.
#Before apply changes starts script 'rollback_ifcfg_changes.sh' on remote host for
#rollback changes after N minutes (rollback_timeout configuration = 'additional_configs/config_temporary_apply_ifcfg').

#'check_network_scripts_serv_is_started.sh' = check for network.service is started (and start if not).

#'just_install_network_scripts.sh' = just install network-scripts.

#'just_run_ifcfg_backup.sh' = copy ifcfg-files from remote hosts. Also collect network data (at 'playbooks/ifcfg_backup_from_remote/network_data') and analyze it
#for find duplicates of mac-addresses. 
#Detected mac duplicates -> 'WARNINGS.txt'
#INFO about existing mac-addresses at inv_hosts -> 'inv_hosts_interfaces_info.txt'.
#INFO about network neighbours of inv_hosts -> 'inv_hosts_neighbour_info.txt'.

#'check_ifcfg_without_apply.sh' = just check configuration without apply new settings.
