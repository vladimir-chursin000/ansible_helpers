# ANSIBLE-APP NOT FINISHED YET!!!
################
# 1) CHECK and CHANGE (if needed): "playbooks/conf/lxc_default.conf", "playbooks/conf/lxc-usernet", "playbooks/conf/lxc_subuid", "playbooks/conf/lxc_subgid".

# 2) UPDATE list (for install lxc-server) of ip addresses = lxc_server_hosts.

# 3) Make sure that the pub-ssh-key is thrown to the hosts (lxc_server_hosts).

# 4) Run 'install_lxc_server.sh'.
##################

# 'install_lxc_server.sh' = full install.

# 'check_all_lxc_serv_is_started.sh' = check for lxc-daemons is started (and start if not).

# 'check_lxc_serv_conf_is_changed.sh' = check for changes at conf-files ("playbooks/conf") and run reload/restart if changes available.

# 'uninstall_lxc_server.sh' = uninstall lxc-packages and stop lxc-services.

# 'update_lxc_server.sh' = update lxc-packages.

# 'create_template_almalinux8_amd64.sh' = create template container (for cloning): almalinux8, amd64.


#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
