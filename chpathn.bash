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
#         BUGS: Pathnames with a leading dash can not be passed as an
#               argument.
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
	--type         Argument required and may be:
	                 b Target must be a block (buffered) special.
	                 c Target must be a character (unbuffered)
	                   special.
	                 d Target must be a directory.
	                 p Target must be a named pipe (FIFO).
	                 f Target must be a file.
	                 l Target must be a symbolic link.
	                 s Target must be a socket.
	                 D Target must be a door (Solaris)
	--ftype        Argument required and may be:
	                 image
	                 text
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

#-----------------------------------------------------------------------
# BEGINNING OF MAIN CODE
#-----------------------------------------------------------------------

shopt -s extglob
LC_ALL=C
progname=$(basename $0)

# Parse command line options.
declare -a edit_opts
declare -i edit_ind=0
declare -a find_tests
declare -i ftests_ind=0
while getoptex "ascii-vowels ftype: h help noblank nocontrol norep p portable output-to: r recursive R nospecial trim type:" "$@"
do
	case "$OPTOPT" in
		ascii-vowels) edit_opts[((edit_ind++))]=ascii-vowels
		              ;;
		ftype)        if [ "$OPTARG" == image ]
		              then
			              ftype="image"
			      fi
		              if [ "$OPTARG" == text ]
			      then
			              ftype="text"
			      fi
		              ;;
		noblank)      edit_opts[((edit_ind++))]=noblank
		              ;;
		nocontrol)    edit_opts[((edit_ind++))]=nocontrol
		              ;;
		norep)        edit_opts[((edit_ind++))]=norep
		              ;;
		output-to)    output="$OPTARG"
			      ;;
		h)            edit_opts[((edit_ind++))]=h
		              ;;
		help)         edit_opts[((edit_ind++))]=help
		              ;;
		p)            edit_opts[((edit_ind++))]=portable
		              ;;
		portable)     edit_opts[((edit_ind++))]=portable
		              ;;
		r)            recursive=true
			      ;;
		recursive)    recursive=true
		              ;;
		R)            recursive=true
		              ;;
		nospecial)    edit_opts[((edit_ind++))]=s
		              ;;
		trim)         edit_opts[((edit_ind++))]=trim
		              ;;
		type)         type="$OPTARG"
			      if [[ ! $type =~ [bcdpflsD] ]]
			      then
				     error_exit "$LINENO: Wrong argument in option --type." 
			      fi
		              find_tests[((ftests_ind++))]="-type $type"
			      ;;
	esac
done
shift $(($OPTIND-1))

# Check command line's sintax
[[ $# -eq 0 ]] && usage && exit
[[ ! $type ]] && [[ ! $ftype ]] && [[ $output ]] &&
	error_exit "$LINENO: Either --type or --ftype option must be given with option --output-to."

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

# First, change pathnames of the pathnames passed as arguments.
for arg
do
	file="$(readlink -f "$arg")"
	oldifs=$IFS
	IFS="$(printf '\n\t')"

	# Files to be skipped.
	[[ ! -a "$file" ]] && continue
	if [ "$ftype" == "image" ]
	then
		is_image image "$file"
		[[ $image == true ]] || continue
	fi
	if [ "$ftype" == "text" ]
	then
		is_text text "$file"
		[[ $text == true ]] || continue
	fi

	new_name=$file
	get_parentmatcher parent_matcher "$file"
	
	# Call editing functions on the current filename.
	for editopt in "${edit_opts[@]}"
	do
		if [ $editopt == ascii-vowels ]
		then
			asciivowels "$new_name" "$parent_matcher" \
				new_name
		fi
		if [ $editopt == noblank ]
		then
			noblank "$new_name" "$parent_matcher" \
				new_name
		fi
		if [ $editopt == nocontrol ]
		then 
			nocntrl "$new_name" "$parent_matcher" \ 
			new_name
		fi
		if [ $editopt == nospecial ]
		then
			nospecial "$new_name" "$parent_matcher" \
			new_name
		fi
		if [ $editopt == help ]
		then
			usage
		fi
		if [ $editopt == portable ]
		then
			portable "$new_name" "$parent_matcher" \
				new_name
		fi
		if [ $editopt == norep ]
		then
			norep "$new_name" "$parent_matcher" \
				new_name
		fi
		if [ $editopt == trim ]
		then
			trim "$new_name" "$parent_matcher" \
				new_name
		fi
	done

	# Rename file. Handle name conflicts.
	if [ "$file" == "$new_name" ]
	then
		parent_matcher=
		continue
	elif [ -e "$new_name" ]
	then
		error_exit "$LINENO: File $new_name already exists"
	else
		mv "$file" "$new_name"
	fi
	parent_matcher=
	IFS=$oldifs
done

# If recursive is not set, exit succesfully
[[ ! $recursive ]] && exit 0 

# Find the new pathname of directories passed as arguments.
declare -a dirs
for (( i=0; i<${#inodes[@]}; i++ )) 
do
	if [ ${type_file[i]} == d ]
	then
		dirs+=( "$(find /home/marce -depth -inum ${inodes[i]} -type d)" )
	fi
done

# If there is not directories, exit succesfully.
[[ ${#dirs[@]} == 0 ]] && exit 0

# Process recursively every directory passed as argument.
find ${dirs[@]} $find_tests -depth -print0 |
while IFS="" read -r -d "" file
do
	IFS="$(printf '\n\t')"

# Files to be skipped.
	[[ ! -a "$file" ]] && continue
	if [ "$ftype" == "image" ]
	then
		is_image image "$file"
		[[ $image == true ]] || continue
	fi
	if [ "$ftype" == "text" ]
	then
		is_text text "$file"
		[[ $text == true ]] || continue
	fi

	new_name=$file
	get_parentmatcher parent_matcher "$file"
	
	# Call editing functions on the current filename.
	for editopt in "${edit_opts[@]}"
	do
		if [ $editopt == ascii-vowels ]
		then
			asciivowels "$new_name" "$parent_matcher" \
				new_name
		fi
		if [ $editopt == noblank ]
		then
			noblank "$new_name" "$parent_matcher" \
				new_name
		fi
		if [ $editopt == nocontrol ]
		then
			nocntrl "$new_name" "$parent_matcher" \
				new_name
		fi
		if [ $editopt == nospecial ]
		then
			nospecial "$new_name" "$parent_matcher" \
				new_name
		fi
		if [ $editopt == help ]
		then
			usage
		fi
		if [ $editopt == portable ]
		then
			portable "$new_name" "$parent_matcher" \
				new_name
		fi
		if [ $editopt == norep ]
		then
			norep "$new_name" "$parent_matcher" \
				new_name
		fi
		if [ $editopt == trim ]
		then
			trim "$new_name" "$parent_matcher" \
				new_name
		fi
	done

	# If --output-to option was given, build output directory
	# pathname.
	[ "$output" ] && get_outputdir output_dir "$output" \
		"$file" ${dirs[@]}
	[ "$output_dir" ] && mkdir -p "$output_dir" && \
	new_name="$output_dir"/"${new_name#$parent_matcher}"

	# Rename file. Handle name conflicts.
	if [ "$file" == "$new_name" ]
	then
		parent_matcher=
		continue
	elif [ -e "$new_name" ]
	then
		error_exit "$LINENO: File $new_name already exists"
	else
		mv "$file" "$new_name"
	fi
	parent_matcher=
done
