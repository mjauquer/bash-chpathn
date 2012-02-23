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
portable () {
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
recursive=false
#-----------------------------------------------------------------------
# Parse command line options.
#-----------------------------------------------------------------------
optindex=0
while getopts 'bcprst' option; do
	case "$option" in
		b) editopts[$optindex]=b
		   ;;
		c) editopts[$optindex]=c
		   ;;
		p) editopts[$optindex]=p
		   ;;
		r) recursive=true
		   ;;
		s) editopts[$optindex]=s
		   ;;
		t) editopts[$optindex]=t
		   ;;
	esac
	optindex=$((${optindex}+1))
done
#-----------------------------------------------------------------------
# Build the find command.
#-----------------------------------------------------------------------
shift $(($OPTIND-1))
if [ $recursive == "true" ]; then
	find_opts="-depth"
else
	find_opts="-maxdepth 1"
fi
root_dir="$1"
find "$root_dir" $find_opts -print0 |
#-----------------------------------------------------------------------
# Execute edit actions on every founded file and directory.
#-----------------------------------------------------------------------
while IFS="" read -r -d "" file; do
	new_name="$file"
	#--------------------------------------------------------------
	# Build the pattern which will match the absolute pathname of
	# the current file's parent directory.
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
	#--------------------------------------------------------------
	# Call editing functions on the current file.
	#--------------------------------------------------------------
	for editopt in "${editopts[@]}"; do
		if [ $editopt == b ]; then
			tr_blank
		fi
		if [ $editopt == c ]; then
			rm_cntrl
		fi
		if [ $editopt == p ]; then
			portable	
		fi
		if [ $editopt == s ]; then
			rm_seq
		fi
		if [ $editopt == t ]; then
			trim		
		fi
	done
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
