#!/usr/bin/bash

###GENERATED BY ansible_helpers/conf_firewalld (https://github.com/vladimir-chursin000/ansible_helpers)

######INIT DIRS and FILES
SELF_DIR_str="$(dirname $(readlink -f $0))";
EXEC_RESULT_DIR_str="$SELF_DIR_str/../exec_results";
NOW_YYYYMMDDHHMISS_AT_START_str=`date '+%Y%m%d%H%M%S'`;
EXEC_RESULT_FILE_str="$EXEC_RESULT_DIR_str/$NOW_YYYYMMDDHHMISS_AT_START_str-restore_tmp_ipsets_cont.log";
###INIT DIRS and FILES

######CFG
CONTENT_DIR_str="$SELF_DIR_str/../temporary_ipsets";
LIST_FILE_str="$CONTENT_DIR_str/LIST";
######CFG

######VARS
LINE0_str='';
LINE1_str='';

declare -a TMP_arr;

EPOCH_TIME_NOW_num=0;
EPOCH_TIME_CFG_num=0;
TIMEOUT_num=0;
######VARS

######FUNCTIONS
function write_log_func() {
    local local_log_str=$1;
    local local_log_file_str=$2;
    local local_now_yyyymmddhhmiss_str=`date '+%Y%m%d%H%M%S'`;

    echo "$local_now_yyyymmddhhmiss_str;+$local_log_str" &>> "$local_log_file_str";
}
######FUNCTIONS

######MAIN
write_log_func "Start script!" "$EXEC_RESULT_FILE_str";

if [[ -s "$LIST_FILE_str" ]]; then
    while read -r LINE0_str; # LINE0_str = ipset_name
    do
        if [[ -s "$CONTENT_DIR_str/$LINE0_str" && -s "/etc/firewalld/ipsets/$LINE0_str.xml" ]]; then # if file exists and not empty
            write_log_func "Add ipsets entries from file='$CONTENT_DIR_str/$LINE0_str' to ipset='$LINE0_str'" "$EXEC_RESULT_FILE_str";
    	    
            while read -r LINE1_str; # LINE1_str = one line with ipset entry
            do
                TMP_arr=($(echo "$LINE1_str" | sed 's/;+/\n/g')); # 0=ip, 1=expire_dt_at_format_YYYYMMDDHHMISS (num)
    	    	
                EPOCH_TIME_CFG_num=`date -d "$(echo ${TMP_arr[1]} | awk '{print substr($1,1,8), substr($1,9,2) ":" substr($1,11,2)":" substr($1,13,2)}')" '+%s'`;
                EPOCH_TIME_NOW_num=`date '+%s'`;
                TIMEOUT_num=$(($EPOCH_TIME_CFG_num - $EPOCH_TIME_NOW_num));
    	    	
                if [[ "$TIMEOUT_num" -gt "0" ]]; then
                    if [[ "$TIMEOUT_num" -gt "2147483" ]]; then
                        TIMEOUT_num='2147483';
    	    	    	
                        write_log_func "Add ipset entry '${TMP_arr[0]}' from file='$CONTENT_DIR_str/$LINE0_str' to ipset='$LINE0_str' = DONE, but timeout is set to '2147483' because calculated value > maximum_timeout_value ('2147483')" "$EXEC_RESULT_FILE_str";
                    fi;
    	    	    
                    ipset add $LINE0_str ${TMP_arr[0]} timeout $TIMEOUT_num;
                else
                    write_log_func "Add ipset entry '${TMP_arr[0]}' from file='$CONTENT_DIR_str/$LINE0_str' to ipset='$LINE0_str' is CANCELLED. Entry is expired" "$EXEC_RESULT_FILE_str";
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

write_log_func "Stop script!" "$EXEC_RESULT_FILE_str";
######MAIN
