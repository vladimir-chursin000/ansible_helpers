###DEPENDENCIES: datetime.pl

sub read_local_ipset_input_log_ops {
    my ($history_log_dir_l,$ipset_type_by_time_l,$inv_host_l,$ipset_template_name_l,$ipset_name_l,$op_l,$ipset_type_l,$ipset_rec_l,$status_l)=@_;
    # File name format - "DATE-history.log"
	# Record format - "datetime;+temporary/permanent/unknown;+inventory-host;+ipset_template_name;+ipset_name;+add/del;+ipset_type;+RECORD;+status"
        # Datetime format - YYYYMMDDHHMISS.
        # RECORD = ipset-record or incorrect file name (if file name not match with VER1/VER2/VER3).
        # Status = OK / error (incorrect ip-address, etc).
    
    my $date_l=&get_dt_yyyymmdd();
    my $dt_now_l=&get_dt_yyyymmddhhmmss();
}

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
