#1) CHECK and CHANGE (if needed): "playbooks/conf/nfs_server.conf", "playbooks/conf/nfsmount_server.conf", "playbooks/exports/common_exports"
(or "playbooks/exports/IP_from_inventory" for special exports).

#2) UPDATE list (for install nfs-server) of ip addresses = nfs_server_hosts.

#3) Make sure that the pub-ssh-key is thrown to the hosts (nfs_server_hosts).

#4) Run 'install_nfs_server.sh'.

#5) Check for services (nfs, rpc-bind, mountd) is allowed at firewall configuration (with '--add-service=***' parameter).

#6) Create group "nfs_share_group" with id=40000 on client side, add client side users (who need to connect nfs-share) to this group
and connect to configured nfs-share.