#!/bin/bash
# file: $HOME/bin/correct_pathname.sh

# This script renames pathnames if they include weird symbols.

rename_match () {
	local tempfile
	tempfile=$HOME/tmp/correct_pathname.sh.tmp
	mv -v $f $file &> $tempfile
	sed -i s/^/\[$(date)\]\ \ / $tempfile
	cat $tempfile | tee | tee -a $HOME/log/correct_pathname.sh.log			# Script's actions are saved to this log file.
	rm $tempfile
	return
}

process () {
	file=$(echo $f | tr \!\"\#\$\%\&\'\(\)\*\+\<\>\=\?¿@\[\]\^\`\{\|\}\~ '-' | tr ,\;\: '.' | tr [:blank:] '_' | sed 's=/-=/_=')
	if [ -e $f ]; then
		if [ ! -e $file ]; then
			rename_match
		else
			if [ $f != $file ]; then
				error=$(echo \[$(date)\]\ \ "ERROR: failed to rename" ${f} \($file already exist.\))
				echo $error | tee -a $HOME/log/correct_pathname.sh.log >&2
			fi
		fi
	fi
	return
}

[ -d $1 ] && directory=$1
IFS=$'\n'
[[ -d $HOME/tmp ]] || mkdir $HOME/tmp ; [[ -d $HOME/log ]] || mkdir $HOME/log
for f in $(find $directory -type d); do
	process
done
for f in $(find $directory -type f); do
	process
done
unset IFS
