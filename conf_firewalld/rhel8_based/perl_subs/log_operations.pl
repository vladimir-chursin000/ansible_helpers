###DEPENDENCIES: datetime.pl

sub read_local_ipset_input_log_ops {
    my ($history_log_dir_l,$ipset_type_by_time_l,$inv_host_l,$ipset_template_name_l,$ipset_name_l,$op_l,$ipset_type_l,$ipset_rec_l,$status_l)=@_;
    # File name format - "DATE-history.log"
	# Record format - "datetime;+IPSET_TYPE_BY_TIME;+inventory-host;+ipset_template_name;+ipset_name;+add/del;+ipset_type;+RECORD;+status"
        # Datetime format - YYYYMMDDHHMISS.
	# IPSET_TYPE_BY_TIME = temporary/permanent/unknown.
        # RECORD = ipset-record or incorrect file name (if file name not match with VER1/VER2/VER3).
        # Status = OK / error (incorrect ip-address, etc).
    
    my $date_l=&get_dt_yyyymmdd();
    my $dt_now_l=&get_dt_yyyymmddhhmmss();
    
    my $history_file_l=$history_log_dir_l.'/'.$date_l.'-history.log';
    my $log_line_l="$dt_now_l;+$ipset_type_by_time_l;+$inv_host_l;+";
}

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
