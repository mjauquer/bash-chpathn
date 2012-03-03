#!/bin/bash

source ~/code/bash/upvars/upvars.sh
source ~/code/bash/getoptx/getoptx.bash
source ~/code/bash/pathnlib/pathnlib.sh

#=======================================================================
#
#         FILE: chpathn.sh
#
#        USAGE: chpathn.sh [OPTIONS] PATH...
#
#  DESCRIPTION: Change filenames in the operand directories.
#
#      OPTIONS: See function 'usage' below.
# REQUIREMENTS: upvars.sh
#         BUGS: --
#        NOTES: --
#       AUTHOR: Marcelo Auquer, auquer@gmail.com
#      CREATED: 02/19/2012
#     REVISION: 03/02/2012
#
#======================================================================= 

#===  FUNCTION =========================================================
#
#        NAME: asciivowels
#
#       USAGE: asciivowels PATHNAME PATTERN VARNAME
#
# DESCRIPTION: Use the expanded value of PATTERN (the parent_matcher) to
#              match a beggining substring (a prefix) of the expanded
#              value of PATHNAME (pathname) to be preserved of further
#              editing of this function. Replace in the trailing
#              substring not matched by the parent_matcher (the suffix)
#              every non-ascii vowel character with his matching ascii
#              vowel character. Store the resulting string in the
#              caller's variable VARNAME.
#
#  PARAMETERS: PATHNAME (A string).
#              PATTERN  (A word subject of tilde expansion, parameter
#                        expansion, command substitution and arithmetic
#                        substitution). 
#              VARNAME  (A variable name).
#=======================================================================
usage () {
	cat <<- EOF
	Usage: chpathn.sh [-b] [-c] [-h] [-p] [-r] [-R] [-s] [-t] [-v]\
	DIR
	
	Change the name of files and subdirectories in DIR.

	--ascii-vowels Replace non-ascii vowels with ascii ones.
	 -h
	--help         Display this help.
	--noblank      Replace blank characters with underscores.
	--nocontrol    Remove control characters.
	--norep        Replace every sequence of more than one dash (or 
	               underscore) with only one character.
	--nospecial    Replace every character with a dash, unless it is 
	               an alphanumeric character, a dot or an underscore.
	 -p
	--portable     Equivalent to --nocontrol --trim --noblank
	               --ascii-vowels --nospecial --norep --trim
	 -r
	 -R
	--recursive    Do all actions recursively.
	--trim         Remove leading dashes or blank characters and 
	               trailing blank characters.
	EOF
}

#===  FUNCTION =========================================================
#
#        NAME: asciivowels
#
#       USAGE: asciivowels PATHNAME PATTERN VARNAME
#
# DESCRIPTION: Use the expanded value of PATTERN (the parent_matcher) to
#              match a beggining substring (a prefix) of the expanded
#              value of PATHNAME (pathname) to be preserved of further
#              editing of this function. Replace in the trailing
#              substring not matched by the parent_matcher (the suffix)
#              every character of a non-ascii vowel with his matching
#              ascii vowel character. Store the resulting string in the
#              caller's variable VARNAME.
#
#  PARAMETERS: PATHNAME (A string).
#              PATTERN  (A word subject of tilde expansion, parameter
#                        expansion, command substitution and arithmetic
#                        substitution). 
#              VARNAME  (A variable name).
#=======================================================================
asciivowels () {
	local suffix="${1#$2}"
	local prefix="${1%$suffix}"
	suffix=${suffix//â/a}
	suffix=${suffix//à/a}
	suffix=${suffix//á/a}
	suffix=${suffix//ä/a}
	suffix=${suffix//ê/e}
	suffix=${suffix//è/e}
	suffix=${suffix//é/e}
	suffix=${suffix//ë/e}
	suffix=${suffix//î/i}
	suffix=${suffix//ì/i}
	suffix=${suffix//í/i}
	suffix=${suffix//ï/i}
	suffix=${suffix//ô/o}
	suffix=${suffix//ò/o}
	suffix=${suffix//ó/o}
	suffix=${suffix//ö/o}
	suffix=${suffix//û/u}
	suffix=${suffix//ù/u}
	suffix=${suffix//ú/u}
	suffix=${suffix//ü/u}
	local $3 && upvar $3 "$prefix$suffix"
}

#===  FUNCTION =========================================================
#
#        NAME: noblank #
#       USAGE: noblank PATHNAME PATTERN VARNAME
#
# DESCRIPTION: Use the expanded value of PATTERN (the parent_matcher) to
#              match a beggining substring (a prefix) of the expanded
#              value of PATHNAME (pathname) to be preserved of further
#              editing of this function. Replace in the trailing
#              substring not matched by the parent_matcher (the suffix)
#              every blank character with an undescore. Store the
#              resulting string in the caller's variable VARNAME.
#
#  PARAMETERS: PATHNAME (A string).
#              PATTERN  (A word subject of tilde expansion, parameter
#                        expansion, command substitution and arithmetic
#                        substitution). 
#              VARNAME  (A variable name).
#=======================================================================
noblank () {
	local suffix="${1#$2}"
	local prefix="${1%$suffix}"
	suffix="${suffix//[[:blank:]]/_}"
	local $3 && upvar $3 "$prefix$suffix"
}

#===  FUNCTION =========================================================
#
#        NAME: nospecial
#
#       USAGE: nospecial PATHNAME PATTERN VARNAME
#
# DESCRIPTION: Use the expanded value of PATTERN (the parent_matcher) to
#              match a beggining substring (a prefix) of the expanded
#              value of PATHNAME (pathname) to be preserved of further
#              editing of this function. Replace in the trailing
#              substring not matched by the parent_matcher (the suffix)
#              every character with a dash, unless it is a dot, an
#              underscore or an alphanumeric character. Store the
#              resulting string in the caller's variable VARNAME.
#
#  PARAMETERS: PATHNAME (A string).
#              PATTERN  (A word subject of tilde expansion, parameter
#                        expansion, command substitution and arithmetic
#                        substitution). 
#              VARNAME  (A variable name).
#=======================================================================
nospecial () {
	local suffix="${1#$2}"
	local prefix="${1%$suffix}"
	suffix="${suffix//[^[:word:].]/-}"
	local $3 && upvar $3 "$prefix$suffix"
	trim "$new_name" "$2" "new_name"
}

#===  FUNCTION =========================================================
#
#        NAME: nocntrl
#
#       USAGE: nocntrl PATHNAME PATTERN VARNAME
#
# DESCRIPTION: Use the expanded value of PATTERN (the parent_matcher) to
#              match a beggining substring (a prefix) of the expanded
#              value of PATHNAME (pathname) to be preserved of further
#              editing of this function. Remove of the trailing
#              substring not matched by the parent_matcher (the suffix)
#              every control character. Store the resulting string in
#              the caller's variable VARNAME.
#
#  PARAMETERS: PATHNAME (A string).
#              PATTERN  (A word subject of tilde expansion, parameter
#                        expansion, command substitution and arithmetic
#                        substitution). 
#              VARNAME  (A variable name).
#=======================================================================
nocntrl () {
	local suffix="${1#$2}"
	local prefix="${1%$suffix}"
	suffix="${suffix//[[:cntrl:]]}"
	local $3 && upvar $3 "$prefix$suffix"
}

#===  FUNCTION =========================================================
#
#        NAME: norep
#
#       USAGE: norep PATHNAME PATTERN VARNAME
#
# DESCRIPTION: Use the expanded value of PATTERN (the parent_matcher) to
#              match a beggining substring (a prefix) of the expanded
#              value of PATHNAME (pathname) to be preserved of further
#              editing of this function. Remove of the trailing
#              substring not matched by the parent_matcher (the suffix)
#              every sequence of dashes (or underscores). Leave only one
#              character in that place. Store the resulting string in
#              the caller's variable VARNAME.
#
#  PARAMETERS: PATHNAME (A string).
#              PATTERN  (A word subject of tilde expansion, parameter
#                        expansion, command substitution and arithmetic
#                        substitution). 
#              VARNAME  (A variable name).
#=======================================================================
norep () {
	local suffix="${1#$2}"
	local prefix="${1%$suffix}"
	suffix="$(echo $suffix | tr -s [-_])"
	local $3 && upvar $3 "$prefix$suffix"
	trim "$new_name" "$2" "new_name"

}

#===  FUNCTION =========================================================
#
#        NAME: portable
#
#       USAGE: portable PATHNAME PATTERN VARNAME
#
# DESCRIPTION: Equivalent to:
#              {
#              nocntrl PATHNAME PATTERN VARNAME
#              trim PATHNAME PATTERN VARNAME
#              noblank PATHNAME PATTERN VARNAME
#              asciivowels PATHNAME PATTERN VARNAME
#              nospecial PATHNAME PATTERN VARNAME
#              norep PATHNAME PATTERN VARNAME
#              trim PATHNAME PATTERN VARNAME
#              }
#
#  PARAMETERS: PATHNAME (A string).
#              PATTERN  (A word subject of tilde expansion, parameter
#                        expansion, command substitution and arithmetic
#                        substitution). 
#              VARNAME  (A variable name).
#=======================================================================
portable () {
	local suffix="${1#$2}"
	local prefix="${1%$suffix}"
	suffix="${suffix//[[:cntrl:]]}"
	suffix="${suffix##+([-[[:space:]])}"
	suffix="${suffix%%+([[:space:]])}"
	suffix="${suffix//[[:blank:]]/_}"
	suffix=${suffix//â/a}
	suffix=${suffix//à/a}
	suffix=${suffix//á/a}
	suffix=${suffix//ä/a}
	suffix=${suffix//ê/e}
	suffix=${suffix//è/e}
	suffix=${suffix//é/e}
	suffix=${suffix//ë/e}
	suffix=${suffix//î/i}
	suffix=${suffix//ì/i}
	suffix=${suffix//í/i}
	suffix=${suffix//ï/i}
	suffix=${suffix//ô/o}
	suffix=${suffix//ò/o}
	suffix=${suffix//ó/o}
	suffix=${suffix//ö/o}
	suffix=${suffix//û/u}
	suffix=${suffix//ù/u}
	suffix=${suffix//ú/u}
	suffix=${suffix//ü/u}
	suffix="${suffix//[^[:word:].]/-}"
	suffix="$(echo $suffix | tr -s [-_])"
	suffix="${suffix##+([-[[:space:]])}"
	suffix="${suffix%%+([[:space:]])}"
	local $3 && upvar $3 "$prefix$suffix"
}

#===  FUNCTION =========================================================
#
#        NAME: trim
#
#       USAGE: trim PATHNAME PATTERN VARNAME
#
# DESCRIPTION: Use the expanded value of PATTERN (the parent_matcher) to
#              match a beggining substring (a prefix) of the expanded
#              value of PATHNAME (pathname) to be preserved of further
#              editing of this function. Remove of the trailing
#              substring not matched by the parent_matcher (the suffix)
#              every sequence of dashes (or underscores). Remove spaces
#              and dashes at the beggining of the suffix and spaces at
#              the end of it. Store the resulting string in the caller's
#              variable VARNAME.
#
#  PARAMETERS: PATHNAME (A string).
#              PATTERN  (A word subject of tilde expansion, parameter
#                        expansion, command substitution and arithmetic
#                        substitution). 
#              VARNAME  (A variable name).
#=======================================================================
trim () {
	local suffix="${1#$2}"
	local prefix="${1%$suffix}"
	suffix="${suffix##+([-[[:space:]])}"
	suffix="${suffix%%+([[:space:]])}"
	local $3 && upvar $3 "$prefix$suffix"
}

#-----------------------------------------------------------------------
# BEGINNING OF MAIN CODE
#-----------------------------------------------------------------------
OLD_LC_ALL=$LC_ALL
LC_ALL=C
shopt -s extglob
recursive=false
#-----------------------------------------------------------------------
# Parse command line options.
#-----------------------------------------------------------------------
optindex=0
while getoptex "ascii-vowels noblank nocontrol norep h help p portable r
	recursive R nospecial trim" "$@"; do
	case "$OPTOPT" in
		ascii-vowels) editopts[$optindex]=ascii-vowels
		              ;;
		noblank)      editopts[$optindex]=noblank
		              ;;
		nocontrol)    editopts[$optindex]=nocontrol
		              ;;
		norep)        editopts[$optindex]=norep
		              ;;
		h)            editopts[$optindex]=h
		              ;;
		help)         editopts[$optindex]=help
		              ;;
		p)            editopts[$optindex]=portable
		              ;;
		portable)     editopts[$optindex]=portable
		              ;;
		r)            recursive=true
		              ;;
		recursive)    recursive=true
		              ;;
		R)            recursive=true
		              ;;
		nospecial)    editopts[$optindex]=s
		              ;;
		trim)         editopts[$optindex]=trim
		              ;;
	esac
	optindex=$((${optindex}+1))
done
shift $(($OPTIND-1))
#-----------------------------------------------------------------------
# Check for command line correctness.
#-----------------------------------------------------------------------
[[ $# -eq 0 ]] && usage && exit
#-----------------------------------------------------------------------
# Build the find command.
#-----------------------------------------------------------------------
if [ $recursive == "true" ]; then
	find_opts="-depth"
else
	find_opts="-maxdepth 1"
fi
find "$@" $find_opts -print0 |
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
		if [ $editopt == ascii-vowels ]; then
			asciivowels "$new_name" "$parent_matcher" \
				"new_name"
		fi
		if [ $editopt == noblank ]; then
			noblank "$new_name" "$parent_matcher" \
				"new_name"
		fi
		if [ $editopt == nocontrol ]; then
			nocntrl "$new_name" "$parent_matcher" \
				"new_name"
		fi
		if [ $editopt == nospecial ]; then
			nospecial "$new_name" "$parent_matcher" \
				"new_name"
		fi
		if [ $editopt == help ]; then
			usage
		fi
		if [ $editopt == portable ]; then
			portable "$new_name" "$parent_matcher" \
				"new_name"
		fi
		if [ $editopt == norep ]; then
			norep "$new_name" "$parent_matcher" \
				"new_name"
		fi
		if [ $editopt == trim ]; then
			trim "$new_name" "$parent_matcher" \
				"new_name"
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
