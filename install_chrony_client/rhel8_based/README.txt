# 1) CHECK and CHANGE (if needed): "playbooks/conf/chrony_client.conf".

# 2) UPDATE list (for install chrony-client) of ip addresses = chrony_client_hosts.

# 3) Make sure that the pub-ssh-key is thrown to the hosts (chrony_client_hosts).

# 4) Run 'install_chrony_client.sh'.
##################

# 'install_chrony_client.sh' = full install and apply conf-file to remote hosts.

# 'check_chrony_serv_is_started.sh' = check for chrony-daemon is started (and start if not).

# 'check_chrony_serv_conf_is_changed.sh' = check for changes at conf-file and restart service if changes available.

# 'uninstall_chrony_client.sh' = uninstall chrony-packages and stop chrony-service.

# 'update_chrony_client.sh' = update chrony-packages.
