sub read_03_conf_routes {
    my ($file_l,$inv_hosts_href_l,$divisions_for_inv_hosts_href_l,$res_href_l)=@_;
    #$file_l=$f03_conf_routes_path_g
    #inv_hosts_href_l=hash-ref for %inventory_hosts_g
    #$divisions_for_inv_hosts_href_l=hash-ref for %h00_conf_divisions_for_inv_hosts_hash_g
        #$h00_conf_divisions_for_inv_hosts_hash_g{group-name}{inv-host}=1;
    #$res_href_l=hash ref for %h03_conf_routes_hash_g
	#key=inv-host, value=[array of routes]
    ###############
    # INVENTORY_HOST = all / list of inventory hosts separated by "," / group name from conf '00_conf_divisions_for_inv_hosts'.
	# If "all" -> the configuration will be applied to all inventory hosts.
        # Priority (from lower to higher): all (0), group name from conf '00_conf_divisions_for_inv_hosts' (1),
        # list of inventory hosts separated by "," or individual hosts (2).
    ###
    # LIST_OF_ROUTES - list of routes separated by ";". Format for one route = "IP/SUBNET-addr,PREFIX,GW,METRIC".
    ###
    #INVENTORY_HOST                 #LIST_OF_ROUTES
    ###############

    my $proc_name_l=(caller(0))[3];
        
    my ($exec_res_l)=(undef);
    my ($hkey0_l,$hval0_l)=(undef,undef);

}

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
