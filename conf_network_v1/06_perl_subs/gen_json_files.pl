sub generate_json_conf_files {
    my ($tmp_prms_href_l,$generated_json_files_now_dir_l,$generated_json_files_prev_dir_l)=@_;
    
    my $proc_name_l=(caller(0))[3];
    
    my $h01a_conf_int_hwaddr_inf_href_l=${$tmp_prms_href_l}{'h01a_conf_int_hwaddr_inf_href'};
    #'h01a_conf_int_hwaddr_inf_href'=>\%h01a_conf_int_hwaddr_inf_hash_g,
    
    my $h01b_conf_main_href_l=${$tmp_prms_href_l}{'h01b_conf_main_href'};
    #'h01b_conf_main_href'=>\%h01b_conf_main_hash_g,
    
    my $h01c_conf_ip_addr_href_l=${$tmp_prms_href_l}{'h01c_conf_ip_addr_href'};
    #'h01c_conf_ip_addr_href'=>\%h01c_conf_ip_addr_hash_g,
    
    my $h01d_conf_bond_opts_href_l=${$tmp_prms_href_l}{'h01d_conf_bond_opts_href'};
    #'h01d_conf_bond_opts_href'=>\%h01d_conf_bond_opts_hash_g,
    
    my $h02_conf_dns_href_l=${$tmp_prms_href_l}{'h02_conf_dns_href'};
    #'h02_conf_dns_href'=>\%h02_conf_dns_hash_g,
    
    my $h03_conf_routes_href_l=${$tmp_prms_href_l}{'h03_conf_routes_href'};
    #'h03_conf_routes_href'=>\%h03_conf_routes_hash_g,
    
    my $h04_conf_remote_backend_href_l=${$tmp_prms_href_l}{'h04_conf_remote_backend_href'};
    #'h04_conf_remote_backend_href'=>\%h04_conf_remote_backend_hash_g,
    
    my $h01a_conf_int_hwaddr_inf_href_l=${$tmp_prms_href_l}{'h01a_conf_int_hwaddr_inf_href'};
    #'h01a_conf_int_hwaddr_inf_href'=>\%h05_not_configured_interfaces_hash_g,
    
    my $h06_conf_temp_apply_href_l=${$tmp_prms_href_l}{'h06_conf_temp_apply_href'};
    #'h06_conf_temp_apply_href'=>\%h06_conf_temp_apply_hash_g,
    
    my $return_str_l='OK';
    
    ###save prev (mv from 'now' to 'prev') gen results (begin)
    system("mv $generated_json_files_now_dir_l/* $generated_json_files_prev_dir_l/");
    ###save prev gen results (end)
    
    ###gen new json-files (begin)
    ###gen new json-files (end)
    
    return $return_str_l;
}

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
