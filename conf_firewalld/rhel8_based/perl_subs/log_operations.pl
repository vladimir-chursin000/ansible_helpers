###DEPENDENCIES: datetime.pl

sub read_local_ipset_input_log_ops {
    my ($history_log_dir_l,$ipset_type_by_time_l,$inv_host_l,$ipset_template_name_l,$ipset_name_l,$op_l,$ipset_type_l,$ipset_rec_l,$status_l)=@_;
    # File name format - "DATE-history.log"
	# Record format - "datetime;+IPSET_TYPE_BY_TIME;+INV_HOST;+IPSET_TEMPLATE_NAME;+IPSET_NAME;+add/del;+IPSET_TYPE;+RECORD;+status"
    	    # Datetime format - YYYYMMDDHHMISS.
	    # IPSET_TYPE_BY_TIME = temporary/permanent/no.
	    # INV_HOST = inventory-host/no.
	    # IPSET_TEMPLATE_NAME = ipset_template_name/no.
	    # IPSET_NAME = ipset_name/no.
	    # IPSET_TYPE = ipset_type/no.
    	    # RECORD = ipset-record or incorrect file name (if file name not match with VER1/VER2/VER3).
    	    # Status = OK / error (incorrect ip-address, etc).
    
    my $date_l=&get_dt_yyyymmdd();
    my $dt_now_l=&get_dt_yyyymmddhhmmss();
    
    if ( $status_l!~/^ok$/i ) { $status_l='error='.$status_l; }
    
    my $history_file_l=$history_log_dir_l.'/'.$date_l.'-history.log';
    my $log_line_l="$dt_now_l;+$ipset_type_by_time_l;+$inv_host_l;+$ipset_template_name_l;+$ipset_name_l;+$op_l;+$ipset_type_l;+$ipset_rec_l;+$status_l";
    
    system("echo '$log_line_l' >> $history_file_l");
}

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
