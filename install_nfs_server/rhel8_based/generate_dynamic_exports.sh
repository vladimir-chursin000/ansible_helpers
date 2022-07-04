#!/usr/bin/bash

SELF_DIR="$(dirname $(readlink -f $0))";
DYNAMIC_EXPORTS="$SELF_DIR/playbooks/exports";
CONF_FILE="$SELF_DIR/dyn_exports_config";

###VARS
LINE='';
EXE_RES='';
PARAM_ARRAY=();
DYN_EXPORTS_FILE_NAME='';
###VARS

EXE_RES=`rm -rf "$DYNAMIC_EXPORTS"/*_dyn_exports`;
REGEX="^#.*";

while read LINE; do
    if [[ ! -z "$LINE" ]] && [[ ! "$LINE" =~ $REGEX ]]; then
	PARAM_ARRAY=($LINE);
	DYN_EXPORTS_FILE_NAME="$DYNAMIC_EXPORTS/${PARAM_ARRAY[0]}_dyn_exports";
	echo "${PARAM_ARRAY[1]}			${PARAM_ARRAY[2]}" >> $DYN_EXPORTS_FILE_NAME;
    fi;
done < "$CONF_FILE";
