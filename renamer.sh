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
	local suffix="${new_name#$parent_matcher}"
	local prefix="${new_name%$suffix}"
	suffix="${suffix//[^[:word:].]/-}"
	new_name="$prefix$suffix"
	trim
}

#===  FUNCTION =========================================================
#        NAME:
# DESCRIPTION:
#  PARAMETERS:
#=======================================================================
tr_blank () {
	local suffix="${new_name#$parent_matcher}"
	local prefix="${new_name%$suffix}"
	suffix="${suffix//[[:blank:]]/_}"
	new_name="$prefix$suffix"
}

#===  FUNCTION =========================================================
#        NAME:
# DESCRIPTION:
#  PARAMETERS:
#=======================================================================
rm_cntrl () {
	local suffix="${new_name#$parent_matcher}"
	local prefix="${new_name%$suffix}"
	suffix="${suffix//[[:cntrl:]]}"
	new_name="$prefix$suffix"
}

#===  FUNCTION =========================================================
#        NAME:
# DESCRIPTION:
#  PARAMETERS:
#=======================================================================
rm_seq () {
	local suffix="${new_name#$parent_matcher}"
	local prefix="${new_name%$suffix}"
	suffix="${suffix//[[:cntrl:]]}"
	suffix="$(echo $suffix | tr -s [-_])"
	new_name="$prefix$suffix"
	trim
}

#===  FUNCTION =========================================================
#        NAME:
# DESCRIPTION:
#  PARAMETERS:
#=======================================================================
trim () {
	local suffix="${new_name#$parent_matcher}"
	local prefix="${new_name%$suffix}"
	suffix="${suffix##+([-[[:space:]])}"
	suffix="${suffix%%+([[:space:]])}"
	new_name="$prefix$suffix"
}

#-----------------------------------------------------------------------
# BEGINING OF MAIN CODE
#-----------------------------------------------------------------------
OLD_LC_ALL=$LC_ALL
LC_ALL=C
shopt -s extglob
find_opts="-maxdepth 1"
basic_opts="trim; rm_cntrl;"
ext_opts=""
#-----------------------------------------------------------------------
# Parse command line options.
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
LC_ALL=$OLDLC_ALL
