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

# 'generate_dynamic_ifcfg.pl' = SCRIPT for generate ifcfg-files, resolv.conf for each inventory host and dynamic playbooks for ifcfg and resolv.conf. Used with
# '03_apply_immediately_ifcfg.sh', '03_apply_temporary_ifcfg.sh' and '00_install_network_scripts_and_configure_network.sh'.

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )

#Habr: https://habr.com/ru/post/700460/
