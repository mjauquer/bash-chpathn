#!/bin/bash
#=======================================================================
#
#         FILE: renamer.sh
#
#        USAGE: renamer.sh [OPTIONS] OPERAND_DIR
#
#  DESCRIPTION: Change filenames in the operand directory.
#
#      OPTIONS:
# REQUIREMENTS:
#         BUGS:
#        NOTES:
#       AUTHOR: Marcelo Auquer, auquer@gmail.com
#      CREATED:
#     REVISION:
#
#======================================================================= 

#===  FUNCTION =========================================================
#        NAME:
# DESCRIPTION:
#  PARAMETERS:
#=======================================================================
rm_punct () {
	local prefix="$(echo $new_name |
	sed "s;\($parent_matcher\).*;\1;")"
	local suffix="${new_name#$parent_matcher}"
	local new_suffix="${suffix//[^[:word:].]/-}"
	new_name="$prefix$new_suffix"
}

#===  FUNCTION =========================================================
#        NAME:
# DESCRIPTION:
#  PARAMETERS:
#=======================================================================
tr_blank () {
	local prefix="$(echo $new_name |
	sed "s;\($parent_matcher\).*;\1;")"
	local suffix="${new_name#$parent_matcher}"
	local new_suffix="${suffix//[[:blank:]]/_}"
	new_name="$prefix$new_suffix"
}

#===  FUNCTION =========================================================
#        NAME:
# DESCRIPTION:
#  PARAMETERS:
#=======================================================================
rm_cntrl () {
	local prefix="$(echo $new_name |
	sed "s;\($parent_matcher\).*;\1;")"
	local suffix="${new_name#$parent_matcher}"
	local new_suffix="${suffix//[[:cntrl:]]}"
	new_name="$prefix$new_suffix"
}

#===  FUNCTION =========================================================
#        NAME:
# DESCRIPTION:
#  PARAMETERS:
#=======================================================================
rm_seq () {
	local prefix="$(echo $new_name |
	sed "s;\($parent_matcher\).*;\1;")"
	local suffix="${new_name#$parent_matcher}"
	local new_suffix="$(echo $suffix | tr -s [-_])"
	new_name="$prefix$new_suffix"
	trim
}

#===  FUNCTION =========================================================
#        NAME:
# DESCRIPTION:
#  PARAMETERS:
#=======================================================================
trim () {
	new_name="$(echo $new_name |
	sed "s;\($parent_matcher\)\([-[:space:]]*\)\(.*\);\1\3;")"
	shopt -s extglob
	new_name="${new_name%%+([[:space:]])}"
}

#-----------------------------------------------------------------------
# BEGINING OF MAIN CODE
#-----------------------------------------------------------------------
new_name=
find_opts="-maxdepth 1"
basic_opts="trim; rm_cntrl;"
ext_opts=""
#-----------------------------------------------------------------------
# Handle command line options.
#-----------------------------------------------------------------------
while getopts 'bdprs' option; do
	case "$option" in
		b) ext_opts="$ext_opts tr_blank;"
		   ;;
		d) ext_opts="tr_blank; rm_punct; rm_seq;"
		   find_opts="-depth"
		   ;;
		p) ext_opts="$ext_opts rm_punct;"
		   ;;
		r) find_opts="$(echo "$find_opts" |
		   sed 's/-maxdepth 1/-depth/')"
		   ;;
		s) ext_opts="$ext_opts rm_seq;"
	esac
done
shift $(($OPTIND-1))
operand="$1"
find "$operand" $find_opts -print0 |
while IFS="" read -r -d "" file; do
	new_name="$file"
	#--------------------------------------------------------------
	# Build the parent directory matching pattern for the 
	# current file. Call filename editing functions.
	#--------------------------------------------------------------
	slashes="${file//[^\/]}"
	depth=${#slashes}	
	if [ ${#file} -eq ${#slashes} ]; then
		echo "Error: file $file skipped." 2>&1
		parent_matcher=
		continue
	fi
	subdir_matcher="[^/]*/"
	while [ $depth -ne 0 ]; do
		parent_matcher="$parent_matcher$subdir_matcher"
		depth=$(($depth-1))
	done
	eval $basic_opts
	eval $ext_opts
	echo $file
	echo $new_name
	#--------------------------------------------------------------
	# Rename file. Handle name conflicts.
	#--------------------------------------------------------------
	if [ "$file" == "$new_name" ]; then
		parent_matcher=
		continue
	elif [ -e "$new_name" ]; then
		echo "Error: file $new_name already exists." 2>&1
	else
		mv "$file" "$new_name"
	fi
	parent_matcher=
done
