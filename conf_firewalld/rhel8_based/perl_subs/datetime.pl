sub get_dt_yyyymmddhhmmss {
    my $dt_now_l=`date '+%Y%m%d%H%M%S'`;
    $dt_now_l=~s/\n|\r//g;
    return $dt_now_l;
}

sub get_dt_yyyymmdd {
    my $date_now_l=`date '+%Y%m%d'`;
    $date_now_l=~s/\n|\r//g;
    return $date_now_l;
}

sub conv_epoch_sec_to_yyyymmddhhmiss {
    my ($for_conv_sec_l)=@_;
    my ($sec_l,$min_l,$hour_l,$mday_l,$mon_l,$year_l)=(undef,undef,undef,undef,undef,undef);
    ($year_l,$mon_l,$mday_l,$hour_l,$min_l,$sec_l)=(localtime($for_conv_sec_l))[5,4,3,2,1,0];
    $year_l=$year_l+1900;
    $mon_l=$mon_l+1;
    my $ret_value_l=sprintf("%.4d%.2d%.2d%.2d%.2d%.2d",$year_l,$mon_l,$mday_l,$hour_l,$min_l,$sec_l);
    return $ret_value_l;
}

sub conv_yyyymmddhhmiss_to_epoch_sec {
    my ($for_conv_dt)=@_;
    my ($yy_l,$mm_l,$dd_l,$hh_l,$mi_l,$ss_l)=$for_conv_dt=~/^(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})$/;
    $yy_l=$yy_l-1900; $mm_l=$mm_l-1;
    my $ret_value_l=undef;
    $ret_value_l=Time::Local::timelocal($ss_l,$mi_l,$hh_l,$dd_l,$mm_l,$yy_l);# need use Time::Local;
    return $ret_value_l;
}
