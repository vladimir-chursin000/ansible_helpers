#!/usr/bin/bash

###GENERATED BY ansible_helpers/conf_firewalld (https://github.com/vladimir-chursin000/ansible_helpers)

SELF_DIR_str="$(dirname $(readlink -f $0))";
EXEC_RESULT_DIR_str="$SELF_DIR_str/exec_results";
NOW_YYYYMMDDHHMISS_AT_START_str=`date '+%Y%m%d%H%M%S'`;
EXEC_RESULT_FILE_str="$EXEC_RESULT_DIR_str/$NOW_YYYYMMDDHHMISS_AT_START_str-rollback_fwrules_changes.log";

if [[ ! -d $EXEC_RESULT_DIR_str ]]; then
    mkdir -p "$EXEC_RESULT_DIR_str";
fi;

###CFG
BACKUP_FOR_ROLLBACK_DIR_str="$SELF_DIR_str/fwrules_backup_now";
TEMP_IPSET_CONT_BACKUP_FOR_ROLLBACK_DIR_str="$BACKUP_FOR_ROLLBACK_DIR_str/temporary_ipsets_content";
###CFG

###STATIC_VARS
TIMEOUT_num=!_TIMEOUT_NUM_!;
###STATIC_VARS

###VARS
LINE0_str='';
LINE1_str='';
NOW_YYYYMMDDHHMISS_str='';
declare -a TMP_arr;
###VARS

touch "$SELF_DIR_str/rollback_fwrules_changes_is_run_now";

while :
do  
    NOW_YYYYMMDDHHMISS_str=`date '+%Y%m%d%H%M%S'`;
    echo "$NOW_YYYYMMDDHHMISS_str;+Wait iteration number $TIMEOUT_num" &>> $EXEC_RESULT_FILE_str;
      
    sleep 60;

    let "TIMEOUT_num-=1";
    if [[ "$TIMEOUT_num" -le "0" ]]; then
	NOW_YYYYMMDDHHMISS_str=`date '+%Y%m%d%H%M%S'`;

    	###DO ROLLBACK of firewall rules changes
    	if [ -d "$BACKUP_FOR_ROLLBACK_DIR_str" ]; then
    	    echo "$NOW_YYYYMMDDHHMISS_str;+Start rollback" &>> $EXEC_RESULT_FILE_str;
    	    
    	    # rollback for script 'recreate_permanent_ipsets.sh'
    	    if [[ -f "$SELF_DIR_str/recreate_permanent_ipsets.sh" ]]; then
    		echo "$NOW_YYYYMMDDHHMISS_str;+Remove script 'recreate_permanent_ipsets.sh'" &>> $EXEC_RESULT_FILE_str;
    		
    		rm -rf $SELF_DIR_str/recreate_permanent_ipsets.sh;
    	    fi;
    	    if [[ -f "$SELF_DIR_str/prev_recreate_permanent_ipsets.sh" ]]; then
    		echo "$NOW_YYYYMMDDHHMISS_str;+Rename script 'prev_recreate_permanent_ipsets.sh' to 'recreate_permanent_ipsets.sh'" &>> $EXEC_RESULT_FILE_str;
    		
    		mv "$SELF_DIR_str/prev_recreate_permanent_ipsets.sh" "$SELF_DIR_str/recreate_permanent_ipsets.sh";
    	    fi;
    	    ###
    	    
    	    # rollback for script 'recreate_temporary_ipsets.sh'
    	    if [[ -f "$SELF_DIR_str/recreate_temporary_ipsets.sh" ]]; then
    		rm -rf $SELF_DIR_str/recreate_temporary_ipsets.sh;
    	    fi;
    	    if [[ -f "$SELF_DIR_str/prev_recreate_temporary_ipsets.sh" ]]; then
    		mv "$SELF_DIR_str/prev_recreate_temporary_ipsets.sh" "$SELF_DIR_str/recreate_temporary_ipsets.sh";
    	    fi;
    	    ###
    	    
    	    # rollback for script 'recreate_fw_zones.sh'
    	    if [[ -f "$SELF_DIR_str/recreate_fw_zones.sh" ]]; then
    		rm -rf $SELF_DIR_str/recreate_fw_zones.sh;
    	    fi;
    	    if [[ -f "$SELF_DIR_str/prev_recreate_fw_zones.sh" ]]; then
    		mv "$SELF_DIR_str/prev_recreate_fw_zones.sh" "$SELF_DIR_str/recreate_fw_zones.sh";
    	    fi;
    	    ###
    	    
    	    # rollback for script 'recreate_policies.sh'
    	    if [[ -f "$SELF_DIR_str/recreate_policies.sh" ]]; then
    		rm -rf $SELF_DIR_str/recreate_policies.sh;
    	    fi;
    	    if [[ -f "$SELF_DIR_str/prev_recreate_policies.sh" ]]; then
    		mv "$SELF_DIR_str/prev_recreate_policies.sh" "$SELF_DIR_str/recreate_policies.sh";
    	    fi;
    	    ###
    	    
    	    # rollback for file 'permanent_ipsets_flag_file'
    	    if [[ -f "$SELF_DIR_str/permanent_ipsets_flag_file" ]]; then
    		rm -rf $SELF_DIR_str/permanent_ipsets_flag_file;
    	    fi;
    	    if [[ -f "$SELF_DIR_str/prev_permanent_ipsets_flag_file" ]]; then
    		mv "$SELF_DIR_str/prev_permanent_ipsets_flag_file"  "$SELF_DIR_str/permanent_ipsets_flag_file";
    	    fi;
    	    ###
    	    
    	    # rollback for file 'temporary_ipsets_flag_file'
    	    if [[ -f "$SELF_DIR_str/temporary_ipsets_flag_file" ]]; then
    		rm -rf $SELF_DIR_str/temporary_ipsets_flag_file;
    	    fi;
    	    if [[ -f "$SELF_DIR_str/prev_temporary_ipsets_flag_file" ]]; then
    		mv "$SELF_DIR_str/prev_temporary_ipsets_flag_file"  "$SELF_DIR_str/temporary_ipsets_flag_file";
    	    fi;
    	    ###
    	    
    	    # rollback for dir 'permanent_ipsets'
    	    if [[ -d "$SELF_DIR_str/permanent_ipsets" ]]; then
    		rm -rf $SELF_DIR_str/permanent_ipsets;
    	    fi;
    	    if [[ -f "$SELF_DIR_str/prev_permanent_ipsets" ]]; then
    		mv "$SELF_DIR_str/prev_permanent_ipsets"  "$SELF_DIR_str/permanent_ipsets";
    	    fi;
    	    ###
    	
    	    # rollback for dir 'temporary_ipsets'
    	    if [[ -d "$SELF_DIR_str/temporary_ipsets" ]]; then
    		rm -rf $SELF_DIR_str/temporary_ipsets;
    	    fi;
    	    if [[ -f "$SELF_DIR_str/prev_temporary_ipsets" ]]; then
    		mv "$SELF_DIR_str/prev_temporary_ipsets"  "$SELF_DIR_str/temporary_ipsets";
    	    fi;
    	    ###
    	    
    	    rm -rf /etc/firewalld/*;
    	    
    	    cp -r $BACKUP_FOR_ROLLBACK_DIR_str/* /etc/firewalld;
    	    
    	    systemctl restart firewalld;
    	    
    	    # restore temporary ipsets content
    	    if [[ -s "$BACKUP_FOR_ROLLBACK_DIR_str/temporary_ipsets_list.txt" ]]; then
    		while read -r LINE0_str; # LINE0_str = ipset_name
    		do
    		    # read ipset content from file LINE0_str
    		    if [[ -s "$TEMP_IPSET_CONT_BACKUP_FOR_ROLLBACK_DIR_str/$LINE0_str.txt" ]]; then
    			while read -r LINE1_str; # LINE1_str = one line with ipset entry
    			do
    			    TMP_arr=($LINE1_str); # 0=ip, 1=string "timeout", 2=timeout (num)
    			    ipset add $LINE0_str ${TMP_arr[0]} timeout ${TMP_arr[2]}; # restore ipset entry for ipset_name=LINE0_str
    			done < "$TEMP_IPSET_CONT_BACKUP_FOR_ROLLBACK_DIR_str/$LINE0_str.txt";
    		    fi;
    		    ###
    		done < "$BACKUP_FOR_ROLLBACK_DIR_str/temporary_ipsets_list.txt";
    	    fi;
    	    ###
    	    
    	    rm -rf $BACKUP_FOR_ROLLBACK_DIR_str/*; # remove backup files
    	fi;
    	###DO ROLLBACK of firewall rules changes
    	
    	rm -rf "$SELF_DIR_str/rollback_fwrules_changes_is_run_now";
    	exit;
    fi;
done;
