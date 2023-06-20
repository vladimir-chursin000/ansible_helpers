#!/usr/bin/bash

###GENERATED BY ansible_helpers/conf_firewalld (https://github.com/vladimir-chursin000/ansible_helpers)

SELF_DIR_str="$(dirname $(readlink -f $0))";

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
###VARS

while :
do
    touch "$SELF_DIR_str/rollback_fwrules_changes_is_run_now";
    sleep 60;

    let "TIMEOUT_num-=1";
    if [[ "$TIMEOUT_num" -le "0" ]]; then
	###DO ROLLBACK of firewall rules changes
	if [ -d "$BACKUP_FOR_ROLLBACK_DIR_str" ]; then
	    rm -rf $SELF_DIR_str/recreate_permanent_ipsets.sh;
	    if [[ -f "$SELF_DIR_str/prev_recreate_permanent_ipsets.sh" ]]; then
		mv "$SELF_DIR_str/prev_recreate_permanent_ipsets.sh" "$SELF_DIR_str/recreate_permanent_ipsets.sh";
	    fi;
	    
	    rm -rf $SELF_DIR_str/recreate_temporary_ipsets.sh;
	    if [[ -f "$SELF_DIR_str/prev_recreate_temporary_ipsets.sh" ]]; then
		mv "$SELF_DIR_str/prev_recreate_temporary_ipsets.sh" "$SELF_DIR_str/recreate_temporary_ipsets.sh";
	    fi;
	    
	    rm -rf $SELF_DIR_str/recreate_fw_zones.sh;
	    if [[ -f "$SELF_DIR_str/prev_recreate_fw_zones.sh" ]]; then
		mv "$SELF_DIR_str/prev_recreate_fw_zones.sh" "$SELF_DIR_str/recreate_fw_zones.sh";
	    fi;

	    rm -rf $SELF_DIR_str/recreate_policies.sh;
	    if [[ -f "$SELF_DIR_str/prev_recreate_policies.sh" ]]; then
		mv "$SELF_DIR_str/prev_recreate_policies.sh" "$SELF_DIR_str/recreate_policies.sh";
	    fi;
	    
	    rm -rf /etc/firewalld/*;
	    
	    cp -r $BACKUP_FOR_ROLLBACK_DIR_str/* /etc/firewalld;
	    
	    systemctl restart firewalld;
	    
	    # restore temporary ipsets content
	    if [[ -s "$BACKUP_FOR_ROLLBACK_DIR_str/temporary_ipsets_list.txt" ]]; then
		while read -r LINE0_str;
		do
		    # read ipset content from file LINE0_str
		    while read -r LINE1_str; # LINE1_str = one line with ipset entry
		    do
			echo "$LINE1_str";
		    done < "$TEMP_IPSET_CONT_BACKUP_FOR_ROLLBACK_DIR_str/$LINE0_str.txt";
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
