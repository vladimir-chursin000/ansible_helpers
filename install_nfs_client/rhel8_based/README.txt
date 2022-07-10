#1) UPDATE list (for install nfs-clients) of ip addresses = nfs_client_hosts.

#2) Fill conf_file='dyn_mount_config' (where clients must connect to various nfs-servers).

#3) Make sure that the pub-ssh-key is thrown to the hosts (nfs_server_hosts).

#4) Run 'install_nfs_client.sh'.
##################

#'generate_dynamic_mount_playbooks.sh' using for generate dynamic tasks (based on 'dyn_exports_config') for configure nfs-mounts. Included to scripts: install_nfs_client.sh, just_apply_new_mounts.sh

#'install_nfs_client.sh' = full install nfs and apply configured (at 'dyn_mount_config') mounts to remote hosts.

#'just_apply_new_mounts.sh' = apply new mounts configurations to remote hosts.

#'uninstall_nfs_client.sh' = uninstall nfs-packages and unmount nfs-shares.

#'update_nfs_client.sh' = update nfs-packages.
