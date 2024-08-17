sub ifcfg_diff_with_zone_param_save {
    #FOR REPLACE THIS=`diff $dyn_ifcfg_common_dir_g/$hkey0_g/fin/$hkey1_g $ifcfg_backup_from_remote_dir_g/$hkey0_g/$hkey1_g | wc -l`.
    #Compare file and add "firewall ZONE=*" (from_remote) to generated ifcfg.
    my ($ifcfg_generated_file_l,$ifcfg_from_remote_file_l)=@_;
    my ($zone_substr_l,$exec_res_l)=(undef,undef);
    
    $zone_substr_l=`grep -i zone $ifcfg_from_remote_file_l`;
    
    if ( defined($zone_substr_l) && length($zone_substr_l)>0 ) {
        $zone_substr_l=~s/\n|\r|\n\r|\r\n//g;
        $exec_res_l=`echo $zone_substr_l >> $ifcfg_generated_file_l`;
        $exec_res_l=undef;
    }
    
    $exec_res_l=`diff $ifcfg_generated_file_l $ifcfg_from_remote_file_l | wc -l`;
    $exec_res_l=~s/\n|\r|\n\r|\r\n//g;
    $exec_res_l=int($exec_res_l);
    
    return $exec_res_l;
}
