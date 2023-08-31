###DEPENDENCIES: datetime.pl

sub write_local_ipset_input_log_ops {
    my ($history_log_dir_l,$input_params_href_l)=@_;
    # File name format - "DATE-history.log"
        # Record format - "WRITE_LOG_DATETIME;+INPUT_OP_TYPE;+INPUT_FILE_NAME;+INPUT_FILE_CREATE_DATETIME;+INV_HOST;+IPSET_TEMPLATE_NAME;+IPSET_NAME;+IPSET_TYPE_BY_TIME;+IPSET_TYPE;+RECORD;+STATUS"
            # WRITE_LOG_DATETIME - format "YYYYMMDDHHMISS".
            # INPUT_OP_TYPE - add/del.
            # INPUT_FILE_NAME.
            # INPUT_FILE_CREATE_DATETIME - format "YYYYMMDDHHMISS".
            # INV_HOST = inventory-host/no.
            # IPSET_TEMPLATE_NAME = ipset_template_name/no.
            # IPSET_NAME = ipset_name/no.
            # IPSET_TYPE_BY_TIME = temporary/permanent/no.
            # IPSET_TYPE = ipset_type/no.
            # RECORD = ipset-record.
            # STATUS = OK / error (incorrect ip-address, etc).
    my $op_l=${$input_params_href_l}{'INPUT_OP_TYPE'};
    my $in_fn_l=${$input_params_href_l}{'INPUT_FILE_NAME'};
    my $in_fn_cr_epoch_l=${$input_params_href_l}{'INPUT_FILE_CREATE_DATETIME_epoch'};
    my $inv_host_l=${$input_params_href_l}{'INV_HOST'};
    my $ipset_tmplt_name_l=${$input_params_href_l}{'IPSET_TEMPLATE_NAME'};
    my $ipset_name_l=${$input_params_href_l}{'IPSET_NAME'};
    my $ipset_type_by_time_l=${$input_params_href_l}{'IPSET_TYPE_BY_TIME'};
    my $ipset_type_l=${$input_params_href_l}{'IPSET_TYPE'};
    my $rec_l=${$input_params_href_l}{'RECORD'};
    my $status_l=${$input_params_href_l}{'STATUS'};
    
    my $date_l=&get_dt_yyyymmdd();
    my $dt_now_l=&get_dt_yyyymmddhhmmss();

    my $in_fn_cr_dt_l=&conv_epoch_sec_to_yyyymmddhhmiss($in_fn_cr_epoch_l);
    #$for_conv_sec_l
    
    if ( $status_l!~/^ok/i ) { $status_l='error='.$status_l; }
    
    my $history_file_l=$history_log_dir_l.'/'.$date_l.'-history.log';
    my $log_line_l="$dt_now_l;+$op_l;+$in_fn_l;+$in_fn_cr_dt_l;+$inv_host_l;+$ipset_tmplt_name_l;+$ipset_name_l;+$ipset_type_by_time_l;+$ipset_type_l;+$rec_l;+$status_l";
    
    system("echo '$log_line_l' >> $history_file_l");
}

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
