#!/usr/bin/bash

###GENERATED BY ansible_helpers/conf_firewalld (https://github.com/vladimir-chursin000/ansible_helpers)

###INIT DIRS and FILES
SELF_DIR_str="$(dirname $(readlink -f $0))";
EXEC_RESULT_DIR_str="$SELF_DIR_str/../exec_results";
###INIT DIRS and FILES

if [[ -s "$LIST_FILE_str" ]]; then
    #echo_log_func "re_add_ipsets_content.sh: Execute scenario='re_add_temporary'. Read ipset-names from file='$LIST_FILE_str'";
    
    while read -r LINE0_str; # LINE0_str = ipset_name
    do
        if [[ -s "$CONTENT_DIR_str/$LINE0_str" && -s "/etc/firewalld/ipsets/$LINE0_str.xml" ]]; then # if file exists and not empty
            #echo_log_func "re_add_ipsets_content.sh: Add ipsets entries from file='$CONTENT_DIR_str/$LINE0_str' to ipset='$LINE0_str'";
	    
            while read -r LINE1_str; # LINE1_str = one line with ipset entry
            do
                TMP_arr=($(echo "$LINE1_str" | sed 's/;+/\n/g')); # 0=ip, 1=expire_dt_at_format_YYYYMMDDHHMISS (num)
		
                EPOCH_TIME_CFG_num=`date -d "$(echo ${TMP_arr[1]} | awk '{print substr($1,1,8), substr($1,9,2) ":" substr($1,11,2)":" substr($1,13,2)}')" '+%s'`;
                EPOCH_TIME_NOW_num=`date '+%s'`;
                TIMEOUT_num=$(($EPOCH_TIME_CFG_num - $EPOCH_TIME_NOW_num));
		
                if [[ "$TIMEOUT_num" -gt "0" ]]; then
                    if [[ "$TIMEOUT_num" -gt "2147483" ]]; then
                        TIMEOUT_num='2147483';
			
                        #echo_log_func "re_add_ipsets_content.sh: Add ipset entry '${TMP_arr[0]}' from file='$CONTENT_DIR_str/$LINE0_str' to ipset='$LINE0_str' = DONE, but timeout is set to '2147483' because calculated value > maximum_timeout_value ('2147483')";
                    fi;
		    
                    ipset add $LINE0_str ${TMP_arr[0]} timeout $TIMEOUT_num;
                else
                    #echo_log_func "re_add_ipsets_content.sh: Add ipset entry '${TMP_arr[0]}' from file='$CONTENT_DIR_str/$LINE0_str' to ipset='$LINE0_str' is CANCELLED. Entry is expired";
                fi;
		
                # clear vars
                TMP_arr=();
                EPOCH_TIME_NOW_num=0;
                EPOCH_TIME_CFG_num=0;
                TIMEOUT_num=0;
                ###
    	    done < "$CONTENT_DIR_str/$LINE0_str";
        fi;
    done < $LIST_FILE_str;
fi;
