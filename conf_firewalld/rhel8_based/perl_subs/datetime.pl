sub get_dt_yyyymmddhhmmss {
    my $dt_now_l=`date '+%Y%m%d%H%M%S'`;
    $dt_now_l=~s/\n|\r//g;
    #output format 'YYYYMMDDHHMISS'
    return $dt_now_l;
}

sub get_dt_yyyymmdd {
    my $date_now_l=`date '+%Y%m%d'`;
    $date_now_l=~s/\n|\r//g;
    #output format 'YYYYMMDD'
    return $date_now_l;
}

sub conv_epoch_sec_to_yyyymmddhhmiss {
    my ($for_conv_sec_l)=@_;
    my ($sec_l,$min_l,$hour_l,$mday_l,$mon_l,$year_l)=(undef,undef,undef,undef,undef,undef);
    ($year_l,$mon_l,$mday_l,$hour_l,$min_l,$sec_l)=(localtime($for_conv_sec_l))[5,4,3,2,1,0];
    $year_l=$year_l+1900;
    $mon_l=$mon_l+1;
    my $ret_value_l=sprintf("%.4d%.2d%.2d%.2d%.2d%.2d",$year_l,$mon_l,$mday_l,$hour_l,$min_l,$sec_l);
    #putput format 'YYYYMMDDHHMISS'
    return $ret_value_l;
}

sub conv_yyyymmddhhmiss_to_epoch_sec {
    my ($for_conv_dt_l)=@_;
    my ($yy_l,$mm_l,$dd_l,$hh_l,$mi_l,$ss_l)=$for_conv_dt_l=~/^(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})$/;
    $yy_l=$yy_l-1900; $mm_l=$mm_l-1;
    my $ret_value_l=undef;
    $ret_value_l=Time::Local::timelocal($ss_l,$mi_l,$hh_l,$dd_l,$mm_l,$yy_l);# need use Time::Local;
    return $ret_value_l;
}

sub check_yyyymmddhhmiss_is_expire {
    my ($dt_l)=@_;
    
    my $epoch_sec_l=&conv_yyyymmddhhmiss_to_epoch_sec($dt_l);
    #$for_conv_dt_l
    
    my $ret_value_l=0;
    
    if ( $epoch_sec_l < time() ) { $ret_value_l=1; }
    
    return $ret_value_l;
}

sub check_yyyymmddhhmiss_is_more_than_max_ipset_timeout {
    my ($dt_l,$now_epoch_sec_l,$timeout_limit_l)=@_;
    
    my $epoch_sec_l=&conv_yyyymmddhhmiss_to_epoch_sec($dt_l);
    #$for_conv_dt
    
    my $timeout_limit_calc_l=$epoch_sec_l-$now_epoch_sec_l;
    my $ret_value_l=0;
    
    if ( $timeout_limit_calc_l > $timeout_limit_l ) { $ret_value_l=1; }
    
    return $ret_value_l;
}