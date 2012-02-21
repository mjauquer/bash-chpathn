#!/bin/bash
#
# File: renamer.sh
# Author: Marcelo Auquer
#
# ======================================================================

find_all () {
	find "$operand" $find_opts -print0 |
	while IFS="" read -r -d "" file; do
		new_name="$file"
		slashes="${file//[^\/]}"
		depth=${#slashes}	
		pattern_separator="[^/]*/"
		while [ $depth -ne 0 ]; do
			pattern="$pattern$pattern_separator"
			depth=$(($depth-1))
		done
		trim
		rm_ctrl
		echo $new_name
		pattern=
	done
}

rm_ctrl () {
	local suffix="${new_name#$pattern}"
	local new_suffix="${suffix//[[:cntrl:]]}"
	new_name="$(echo $new_name |
	sed "s;\($pattern\).*;\1;")"
	new_name="$new_name$new_suffix"
}

trim () {
	new_name="$(echo $new_name |
	sed "s;\($pattern\)\([-[:space:]]*\)\(.*\);\1\3;")"
	shopt -s extglob
	new_name="${new_name%%+([[:space:]])}"
}

new_name=
find_opts="-maxdepth 1"
while getopts 'r' option; do
	case "$option" in
		r) find_opts="$(echo "$find_opts" |
		   sed 's/-maxdepth 1/-depth/')"
		   ;;
	esac
done
shift $(($OPTIND-1))
operand="$1"
find_all
