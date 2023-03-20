sub get_dt_yyyymmddhhmmss {
    my $dt_now_l=`date '+%Y%m%d%H%M%S'`;
    return $dt_now_l;
}