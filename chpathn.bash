#! /bin/bash

# chpathn.bash (See description below).
# Copyright (C) 2012  Marcelo Javier Auquer
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#        USAGE: See function 'usage' below.
#
#  DESCRIPTION: Change filenames in the operand directories.
#
# REQUIREMENTS: chpathn.bash, getoptx.bash, upvars.bash
#
#        NOTES: Any suggestion is welcomed at auq..r@gmail.com (fill in
#               the dots).

source ~/code/bash/chpathn/chpathn.flib
source ~/code/bash/chpathn/getoptx/getoptx.bash
source ~/code/bash/chpathn/filetype/filetype.flib

#===  FUNCTION =========================================================
#
#       USAGE: usage
#
# DESCRIPTION: Print a help message to stdout.
#
usage () {
	cat <<- EOF
	Usage: chpathn.sh [OPTIONS] PATH...
	
	Change the pathnames of files and directories listed in PATH...

	--ascii-vowels Replace non-ascii vowels with ascii ones.
	--ftype        Argument required and may be:
	                 image
	                 text
	--find-tests   Argument required and may be any number of tests
	               of the find command.
	 -h
	--help         Display this help.
	--noblank      Replace blank characters with underscores.
	--nocontrol    Remove control characters.
	--norep        Replace every sequence of more than one dash (or 
	               underscore) with only one character.
	--nospecial    Replace every character with a dash, unless it is 
	               an alphanumeric character, a dot or an underscore.
	--output-to    Argument required. Move the target file or
	               directory to the directory specified by argument.
	               If argument has a relative form (do not lead with
	               a slash), consider it relative to the target's
	               ancestor directory specified in PATH...
	 -p
	--portable     Equivalent to --nocontrol --trim --noblank
	               --ascii-vowels --nospecial --norep --trim
	 -r
	 -R
	--recursive    Do all actions recursively.
	--trim         Remove leading dashes or blank characters and 
	               trailing blank characters.
	--verbose      Print information about what is beeing done.
	EOF
}

#===  FUNCTION =========================================================
#
#       USAGE: error_exit [MESSAGE]
#
# DESCRIPTION: Function for exit due to fatal program error.
#
#   PARAMETER: MESSAGE An optional description of the error.
#
error_exit () {
	echo "${progname}: ${1:-"Unknown Error"}" 1>&2
	exit 1
}

#===  FUNCTION =========================================================
#
#       USAGE: must_be_skipped VARNAME PATHNAME
#
# DESCRIPTION: Check if PATHNAME must be skipped acording to the options
#              passed to this script. Store "true" or "false" in the
#              caller's variable VARNAME.
#
#   PARAMETER: VARNAME  A variable in caller's scope.
#              PATHNAME A pathname pointing to a file or directory
#                       passed as an argument to this script.
#
must_be_skipped () {
	local old_ifs=$IFS
	IFS="$(printf '\n\t')"
	local answer # The answer to be returned.
	local image  # The answer returned by is_image().
	local text   # The answer returned by is_text().
	answer=false
	case "$ftype" in
		"")    ;;
		image) is_image image "$2"
		       [[ $image == true ]] || answer=true
		       ;;
		text)  is_text text "$2"
		       [[ $text == true ]] || answer=true
		       ;;
		*)     error_exit "$LINENO: Wrong argument passed to the --ftype option."
		       ;;
	esac
	local $1 && upvar $1 $answer
	IFS=$old_ifs
}

#===  FUNCTION =========================================================
#
#       USAGE: edit VARNAME PATHNAME
#
# DESCRIPTION: Call editing functions on PATHNAME. Store the resulting
#              pathname in the caller's variable VARNAME.
#
#   PARAMETER: VARNAME  A caller's variable.
#              PATHNAME A pathname pointing to a file or directory
#                       passed as an argument to this script.
#
edit () {
	local old_ifs=$IFS
	local name="$2"
	local pattern
	get_parentmatcher pattern "$name"
	IFS="$(printf '\n\t')"
	for editopt in "${edit_opts[@]}"
	do
		case $editopt in
			ascii-vowels) asciivowels "$name" "$pattern" name
			              ;;
			noblank)      noblank "$name" "$pattern" name
			              ;;
			nocontrol)    nocntrl "$name" "$pattern" name
			              ;;
			nospecial)    nospecial "$name" "$pattern" name
			              ;;
			help)         usage
			              ;;
			portable)     portable "$name" "$pattern" name
			              ;;
			norep)        norep "$name" "$pattern" name
			              ;;
			trim)         trim "$name" "$pattern" name
			              ;;
		esac	
	done

	# Insert output directory if the --output-to option was invoked.
	if [ \( -v dirs \) -a \( "$output" \) ]
	then
		insert_outdir name "$name" "$pattern"
	fi
	local $1 && upvar $1 "$name"
	IFS=$oldifs
}

#===  FUNCTION =========================================================
#
#       USAGE: insert_outdir VARNAME PATHNAME PATTERN
#
# DESCRIPTION: Get the pathname of PATHNAME's parent directory and
#              insert it at the beginning of PATHNAME and store the
#              resulting pathname in the caller's VARNAME variable.
#
#   PARAMETER: VARNAME  A variable in caller's scope.
#              PATHNAME A pathname pointing to a file or directory
#                       passed as an argument to this script.
#              PATTERN  A word subject of tilde expansion, parameter
#                       expansion, command substitution and arithmetic
#                       substitution. It is used as a pattern to match
#                       PATHNAME's parent directory.
#
insert_outdir () {
	local aux_name="$2"
	local pattern="$3"
	local output_dir
	if ! get_outputdir output_dir "$output" "$file" ${dirs[@]}
	then
		error_exit "$LINENO: error after call to get_outputdir()."
	fi
	if ! mkdir -p "$output_dir"
	then
		error_exit "$LINENO: error after call to mkdir."
	fi
	aux_name="$output_dir"/"${aux_name#$pattern}"
	local $1 && upvar $1 "$aux_name"
}

#===  FUNCTION =========================================================
#
#       USAGE: get_dirname PATHNAME
#
# DESCRIPTION: If pathname is a directory, add it to the 'top_dirs'
#              array. If it is not, then add its parent directory
#              instead.
#
#   PARAMETER: PATHNAME A pathname pointing to a file or directory
#                       passed as an argument to this script.
#
get_dirname () {
	local old_ifs=$IFS
	IFS="$(printf '\n\t')"
	if [ -d "$1" ]
	then
		top_dirs+=( "$1" )
	elif [ -f "$1" ]
	then
		top_dirs+=( $(dirname "$1" ) )
	fi
	continue
	IFS=$old_ifs
}

#-----------------------------------------------------------------------
# BEGINNING OF MAIN CODE
#-----------------------------------------------------------------------

# Variables declaration.
declare progname # The name of this script.

declare oldifs   # The original content of the environment
                 # variable IFS.

progname=$(basename $0)
oldifs=$IFS

# If no argument was passed, print usage message and exit.
[[ $# -eq 0 ]] && usage && exit

# Bash configuration.
shopt -s extglob
LC_ALL=C

# Parse command line options.
declare -a edit_opts  # A list of editing options parsed from the
                      # command line.

declare -a find_tests # This is a list of tests to be passed as
                      # arguments of the find command, if the recursive
		      # option of this script was set.

declare ftype         # The argument passed to the --ftype option of this
                      # script. 

declare output        # The argument passed to the --output-to option of
                      # this script.

declare recursive     # True if the --recursive option was given.

declare verbose       # True if the --verbose option was given.

while getoptex "ascii-vowels find-tests: ftype: h help noblank \
	nocontrol norep p portable output-to: r recursive R nospecial \
	trim verbose" "$@"
do
	case "$OPTOPT" in
		ascii-vowels) edit_opts+=( ascii-vowels )
		              ;;
		find-tests)   find_tests+=( $OPTARG )
			      ;;
		ftype)        ftype=$OPTARG
		              ;;
		noblank)      edit_opts+=( noblank )
		              ;;
		nocontrol)    edit_opts+=( nocontrol )
		              ;;
		norep)        edit_opts+=( norep )
		              ;;
		output-to)    output="$OPTARG"
			      ;;
		h)            edit_opts+=( h )
		              ;;
		help)         edit_opts+=( help )
		              ;;
		p)            edit_opts+=( portable )
		              ;;
		portable)     edit_opts+=( portable )
		              ;;
		r)            recursive=true
			      ;;
		recursive)    recursive=true
		              ;;
		R)            recursive=true
		              ;;
		nospecial)    edit_opts+=( s )
		              ;;
		trim)         edit_opts+=( trim )
		              ;;
		verbose)      verbose=true
	esac
done
shift $(($OPTIND-1))

# Store the inodes of the directories passed as arguments for subsequent
# use.
declare -a inodes 
declare -a type_file # "d" for directories, "f" for regular files.
for arg
do
	if [ -d "$arg" ]
	then
		type_file+=( d )
		inodes+=($(stat -c %i "$arg"))
	elif [ -f "$arg" ]
	then
		type_file+=( f )
		inodes+=($(stat -c %i "$arg"))
	fi
done
unset -v arg

# Process only the pathnames passed as arguments.

declare top_dirs # The list of directories where to find the files and
                 # directories whose pathnames where passed as arguments
		 # of this script, once these have been changed.

declare file     # The absolute version of a pathname passed as argument
                 # to this script.
for arg
do
	file="$(readlink -f "$arg")"
	IFS="$(printf '\n\t')"

	# Skip the file if it does not exist anymore.
	[[ ! -a "$file" ]] && continue

	# Apply filters.
	if ! must_be_skipped skip "$file"
	then
		error_exit "$LINENO: error after calling must_be_skipped()."
	fi
	[[ ! -d "$file" ]] && [[ $skip == true ]] && continue

	# Edit pathname.
	edit new_name "$file"	

	# Rename file. Handle name conflicts.
	if [ "$file" == "$new_name" ]
	then
		get_dirname "$file"
		continue
	elif [ -e "$new_name" ]
	then
		error_exit "$LINENO: File $new_name already exists"
	else
		mv "$file" "$new_name"
		get_dirname "$new_name"
	fi
done
unset -v arg
unset -v new_name
unset -v skip
unset -v file
IFS=$oldifs

# Remove redundant entries in the 'top_dirs' array.
if ! rm_subtrees top_dirs ${top_dirs[@]}
then
	error_exit "$LINENO: Error after calling rm_subtrees()."
fi

# If the --verbose option was given, print the content of the 'top_dirs'
# array.
if [[ $verbose == true ]]
then
	printf ' -----------\n Chpathn log:\n -----------\n'
        printf ' * Top directories:\n'
	for dir in ${top_dirs[@]}
	do
		echo "   $dir"
	done
	unset -v dir
fi

# If recursive is not set, exit succesfully
[[ ! $recursive ]] && exit 0 
unset -v recursive

# Find the new pathname of directories passed as arguments.
declare -a dirs # The list of processed pathnames corresponding to
                # directories passed as arguments.
for (( i=0; i<${#inodes[@]}; i++ )) 
do
	if [ ${type_file[i]} == d ]
	then
		dirs+=( "$(find ${top_dirs[@]} -depth -inum ${inodes[i]} -type d)" )
	fi
done
unset -v inodes
unset -v top_dirs
unset -v type_file

# If there is not directories, exit succesfully.
[[ ${#dirs[@]} == 0 ]] && exit 0

# Process recursively every directory passed as argument.
declare file     # The file beeing edited.
find ${dirs[@]} -depth ${find_tests[@]} -print0 |
while IFS="" read -r -d "" file
do
	IFS="$(printf '\n\t')"

	# Apply filters.
	if ! must_be_skipped skip "$file"
	then
		error_exit "$LINENO: error after calling must_be_skipped()."
	fi
	[[ $skip == true ]] && continue

	# Edit pathname.
	edit new_name "$file"	

	# Rename file. Handle name conflicts.
	if [ "$file" == "$new_name" ]
	then
		continue
	elif [ -e "$new_name" ]
	then
		error_exit "$LINENO: File $new_name already exists"
	else
		mv "$file" "$new_name"
	fi
done
IFS=$oldifs
unset -v dirs
unset -v edit_opts
unset -v file
unset -v find_tests
unset -v ftype
unset -v output
unset -v new_name
unset -v oldifs
unset -v progname
unset -v skip
