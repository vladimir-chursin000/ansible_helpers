###DEPENDENCIES: datetime.pl

sub read_local_ipset_input_log_ops {
    my ($history_log_dir_l)=@_;
    # File name format - "DATE-history.log"
    # Record format - "datetime;+temporary/permanent/unknown;+inventory-host;+ipset_template_name;+ipset_name;+add/del;+ipset_type-record;+status"
    # Datetime format - YYYYMMDDHHMISS.
    # Status = OK / error (incorrect ip-address, etc).
    
    my $date_l=&get_dt_yyyymmdd();
    my $dt_now_l=&get_dt_yyyymmddhhmmss();
}

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
