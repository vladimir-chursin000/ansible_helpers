NOT READY YET!
####
# 1) UPDATE list (for install and configure firewall) of ip addresses = conf_firewall_hosts (inventory).

# 2) Fill conf files at dir 'fwrules_configs'.

# 3) Make sure that the pub-ssh-key is thrown to the hosts (conf_firewall_hosts).

# 4) Run 'install_firewall_and_configure_fwrules.sh' (or 'apply_immediately_fwrules.sh').
##################

# 'generate_dynamic_fwrules.pl' = SCRIPT for generate firewall rules for each inventory host. Used with
# 'apply_immediately_fwrules.sh' and 'install_firewall_and_configure_fwrules.sh'.

# 'IPSET_files_operation.pl' = SCRIPT for create subfolders and manipulate ipset-files for each inventory host.

# 'apply_immediately_fwrules.sh' = run for immediately apply changes (without run installation of 'firewalld') if generated firewall rules differ from actual rules on remote host.
# Also cancel execution of firewall rules rollback operation (rollback_fwrules_changes.sh) on remote host if need.

# 'apply_temporary_fwrules.sh' = run for temporary apply changes (without run installation of 'firewalld') if generated firewall rules differs from actual rules.
# Before apply changes starts script 'rollback_fwrules_changes.sh' on remote host for
# rollback changes after N minutes (rollback_timeout configuration = 'fwrules_configs/config_temporary_apply_fwrules').

# 'check_firewall_serv_is_started.sh' = check for firewalld.service is started (and start if not).

# 'just_install_firewall.sh' = just install firewalld.

# 'just_run_fwrules_backup.sh' = copy fwrules-files (content of '/etc/firewalld' and output of 'firewall-cmd --list-all-zones') from remote hosts. 
# Also collect network data (at 'playbooks/fwrules_backup_from_remote/network_data') for get interface names.
# INFO about existing interface names (and ip addr) at inv_hosts -> 'inv_hosts_interfaces_info.txt'.

# 'check_fwrules_without_apply.sh' = just check configuration without apply new settings.
