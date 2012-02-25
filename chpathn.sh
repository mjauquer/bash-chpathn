#"!/bin/bash
#=======================================================================
#
#         FILE: chpathn.sh
#
#        USAGE: chpathn.sh [OPTIONS] OPERAND_DIR
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
#
#        NAME: portable
#
#       USAGE: portable PATHNAME PATTERN VARNAME
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
#        NAME: portable
#
#       USAGE: portable PATHNAME PATTERN VARNAME
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
portable () {
	local suffix="${1#$2}"
	local prefix="${1%$suffix}"
	suffix="${suffix//[^[:word:].]/-}"
	local $3 && upvar $3 "$prefix$suffix"
	trim "$new_name" "$2" "new_name"
}

#===  FUNCTION =========================================================
#
#        NAME: noblanks
#
#       USAGE: noblanks PATHNAME PATTERN VARNAME
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
noblanks () {
	local suffix="${1#$2}"
	local prefix="${1%$suffix}"
	suffix="${suffix//[[:blank:]]/_}"
	local $3 && upvar $3 "$prefix$suffix"
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
	suffix="${suffix//[[:cntrl:]]}"
	suffix="$(echo $suffix | tr -s [-_])"
	local $3 && upvar $3 "$prefix$suffix"
	trim "$new_name" "$2" "new_name"

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
# BEGINING OF MAIN CODE
#-----------------------------------------------------------------------
source ~/bin/upvars
OLD_LC_ALL=$LC_ALL
LC_ALL=C
shopt -s extglob
recursive=false
#-----------------------------------------------------------------------
# Parse command line options.
#-----------------------------------------------------------------------
optindex=0
while getopts 'bcprstv' option; do
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
		v) editopts[$optindex]=v
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
			noblanks "$new_name" "$parent_matcher" \
				"new_name"
		fi
		if [ $editopt == c ]; then
			nocntrl "$new_name" "$parent_matcher" \
				"new_name"
		fi
		if [ $editopt == p ]; then
			portable "$new_name" "$parent_matcher" \
				"new_name"
		fi
		if [ $editopt == s ]; then
			norep "$new_name" "$parent_matcher" \
				"new_name"
		fi
		if [ $editopt == t ]; then
			trim "$new_name" "$parent_matcher" \
				"new_name"
		fi
		if [ $editopt == v ]; then
			asciivowels "$new_name" "$parent_matcher" \
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
