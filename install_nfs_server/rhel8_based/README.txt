# 1) CHECK and CHANGE (if needed): "playbooks/conf/nfs_server.conf", "playbooks/conf/nfsmount_server.conf", "dyn_exports_config" (for configure exports).

# 2) UPDATE list (for install nfs-server) of ip addresses = nfs_server_hosts.

# 3) Make sure that the pub-ssh-key is thrown to the hosts (nfs_server_hosts).

# 4) Run '00_install_nfs_server.sh'.

# 5) Check for services (nfs, rpc-bind, mountd) is allowed at firewall configuration (with '--add-service=***' parameter).
##################

# '00_install_nfs_server.sh' = full install and apply exports files to remote hosts.

# '00_uninstall_nfs_server.sh' = uninstall nfs-packages and stop nfs-services.

# '00_update_nfs_server.sh' = update nfs-packages.

# '01_check_all_nfs_serv_is_started.sh' = check for nfs-daemons is started (and start if not).

# '01_check_nfs_serv_conf_is_changed.sh' = check for changes at conf-files ("playbooks/conf") and run reload if changes available.

# '02_check_nfs_serv_exports_is_changed.sh' = apply 'dyn_exports_config' changes to remote hosts.

# 'generate_dynamic_exports.sh' using for generate exports files based on 'dyn_exports_config'. Included to scripts: install_nfs_server.sh, check_nfs_serv_exports_is_changed.sh

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
