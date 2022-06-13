#1) CHECK and CHANGE (if needed): nfs_server.conf, nfsmount_server.conf, nfs_exports_config.

#2) UPDATE list (for install nfs-server) of ip addresses = nfs_server_hosts.

#3) Make sure that the pub-ssh-key is thrown to the hosts (nfs_server_hosts).

#4) Run 'install_nfs_server.sh'.

#5) Check for services (nfs, rpc-bind, mountd) is allowed at firewall configuration (with '--add-service=***' parameter).