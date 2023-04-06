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
