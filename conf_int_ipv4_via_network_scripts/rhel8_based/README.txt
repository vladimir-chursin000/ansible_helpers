###Partially READY ansible-helper. You can use it!

#1) UPDATE list (for install and configure network-scripts) of ip addresses = conf_network_scripts_hosts (inventory).

#2) Fill conf_file='config'. Example config='config_examples'.

#3) Update config file 'additional_configs/dns_settings' for configure resolv.conf at remote hosts.

#4) If need to remove interfaces (shutdown and remove ifcfg-files) not included to 'config' update config file 'additional_configs/config_del_not_configured_ifcfg'.

#5) Make sure that the pub-ssh-key is thrown to the hosts (conf_network_scripts_hosts).

#6) Run 'install_network_scripts_and_configure_network.sh' (or 'apply_immediately_ifcfg.sh').
##################

#'generate_dynamic_ifcfg.pl' = SCRIPT for generate ifcfg-files, resolv.conf for each inventory host and dynamic playbooks for ifcfg and resolv.conf. Used with
#'apply_immediately_ifcfg.sh' and 'install_network_scripts_and_configure_network.sh'.

#'apply_immediately_ifcfg.sh' = run for immediately apply changes (without run installation of 'network-scripts').

#'check_network_scripts_serv_is_started.sh' = check for network.service is started (and start if not).

#'just_install_network_scripts.sh' = just install network-scripts.

#'just_run_ifcfg_backup.sh' = copy ifcfg-files form remote hosts.

#'apply_temporary_ifcfg.sh' = NOT READY YET