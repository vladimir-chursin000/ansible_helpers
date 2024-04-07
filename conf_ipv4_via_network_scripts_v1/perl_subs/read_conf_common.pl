sub read_uniq_lines_with_params_from_config {
    my ($file_l,$res_href_l)=@_;
    #file_l=simple config where one line=string with params
    #res_href_l=hash-ref for result-hash
    my $proc_name_l=(caller(0))[3];
        
    my ($line_l)=(undef);
    my ($hkey0_l,$hval0_l)=(undef,undef);
    my ($hkey1_l,$hval1_l)=(undef,undef);
    my $return_str_l='OK';

    my %res_tmp_lv0_l=();
        #key=string with params, value=1

    if ( length($file_l)<1 or ! -e($file_l) ) { return "fail [$proc_name_l]. File='$file_l' is not exists"; }
    
    # read file
    open(CONF_LINES,'<',$file_l);
    while ( <CONF_LINES> ) {
        $line_l=$_;
        $line_l=~s/\n$|\r$|\n\r$|\r\n$//g;
        $line_l=~s/\#.*$//g;
        while ( $line_l=~/\t/ ) { $line_l=~s/\t/ /g; }
        $line_l=~s/\s+/ /g;
        $line_l=~s/^ //g;
        $line_l=~s/ $//g;

        $line_l=~s/ \./\./g;
        $line_l=~s/\. /\./g;

        $line_l=~s/ \,/\,/g;
        $line_l=~s/\, /\,/g;

        $line_l=~s/ \:/\:/g;
        $line_l=~s/\: /\:/g;

        $line_l=~s/ \=/\=/g;
        $line_l=~s/\= /\=/g;

        $line_l=~s/ \//\//g;
        $line_l=~s/\/ /\//g;

        if ( length($line_l)>0 && $line_l!~/^\#/ ) {
            if ( !exists($res_tmp_lv0_l{$line_l}) ) {
                push(@{$res_tmp_lv0_l{'seq'}},$line_l);
                $res_tmp_lv0_l{$line_l}=1;
            }
            else { # duplicated value
                $return_str_l="fail [$proc_name_l]. Duplicated value ('$line_l') at file='$file_l'. Fix it!";
                last;
            }
        }
    }
    close(CONF_LINES);

    $line_l=undef;

    if ( $return_str_l!~/^OK$/ ) { return $return_str_l; } # check for return_str err after lv1-read
    ###

    # fill result hash
    %{$res_href_l}=%res_tmp_lv0_l;
    ###

    %res_tmp_lv0_l=();

    return $return_str_l;
}

#With best regards
#Chursin Vladimir ( https://github.com/vladimir-chursin000 )
