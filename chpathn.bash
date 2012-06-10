#! /bin/bash

#=======================================================================
#
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
#

source ~/code/bash/chpathn/chpathn.flib
source ~/code/bash/chpathn/getoptx/getoptx.bash
source ~/code/bash/chpathn/filetype/filetype.flib

#===  FUNCTION =========================================================
#
#        NAME: usage
#
#       USAGE: usage
#
# DESCRIPTION: Print a help message to stdout.
#
usage () {
	cat <<- EOF
	Usage: chpathn.sh [OPTIONS] PATH...
	
	Change the name of files and subdirectories of the directories
	listed in PATH...

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
#        NAME: error_exit
#
#       USAGE: error_exit [MESSAGE]
#
# DESCRIPTION: Function for exit due to fatal program error.
#
#   PARAMETER: MESSAGE An optional description of the error.
#
error_exit () {
	echo "${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
	exit 1
}

#-----------------------------------------------------------------------
# BEGINNING OF MAIN CODE
#-----------------------------------------------------------------------

shopt -s extglob
LC_ALL=C
PROGNAME=$(basename $0)

# Parse command line options.
declare -a FIND_OPTS; FIND_OPTS=("-maxdepth 1")
declare -a EDIT_OPTS
declare -i EDIT_IND=0
declare -a FIND_TESTS
declare -i FTESTS_IND=0
while getoptex "ascii-vowels ftype: h help noblank nocontrol norep p portable output-to: r recursive R nospecial trim type:" "$@"
do
	case "$OPTOPT" in
		ascii-vowels) EDIT_OPTS[((EDIT_IND++))]=ascii-vowels
		              ;;
		ftype)        if [ "$OPTARG" == image ]
		              then
			              FTYPE="image"
			      fi
		              if [ "$OPTARG" == text ]
			      then
			              FTYPE="text"
			      fi
		              ;;
		noblank)      EDIT_OPTS[((EDIT_IND++))]=noblank
		              ;;
		nocontrol)    EDIT_OPTS[((EDIT_IND++))]=nocontrol
		              ;;
		norep)        EDIT_OPTS[((EDIT_IND++))]=norep
		              ;;
		output-to)    OUTPUT="$OPTARG"
			      ;;
		h)            EDIT_OPTS[((EDIT_IND++))]=h
		              ;;
		help)         EDIT_OPTS[((EDIT_IND++))]=help
		              ;;
		p)            EDIT_OPTS[((EDIT_IND++))]=portable
		              ;;
		portable)     EDIT_OPTS[((EDIT_IND++))]=portable
		              ;;
		r)            FIND_OPTS[0]="-depth"
			      ;;
		recursive)    FIND_OPTS[0]="-depth"
		              ;;
		R)            FIND_OPTS[0]="-depth"
		              ;;
		nospecial)    EDIT_OPTS[((EDIT_IND++))]=s
		              ;;
		trim)         EDIT_OPTS[((EDIT_IND++))]=trim
		              ;;
		type)         TYPE="$OPTARG"
			      if [[ ! $TYPE =~ [bcdpflsD] ]]
			      then
				     error_exit "$LINENO: Wrong argument in option --type." 
			      fi
		              FIND_TESTS[((FTESTS_IND++))]="-type $TYPE"
			      ;;
	esac
done
shift $(($OPTIND-1))

# Check command line's sintax
[[ $# -eq 0 ]] && usage && exit
[[ ! $TYPE ]] && [[ ! $FTYPE ]] && [[ $OUTPUT ]] &&
	error_exit "$LINENO: Either --type or --ftype option must be given with option --output-to."

# Build find command.
for arg
do
	cd "$arg"
	if [ $? -ne 0 ]
	then
		exit 1
	fi
	find . $FIND_OPTS $FIND_TESTS -print0 |
	while IFS="" read -r -d "" file
	do
		IFS="$(printf '\n\t')"

		# Files to be skipped.
		[[ "$file" == . ]] && continue
		[[ ! -a "$file" ]] && continue
		if [ "$FTYPE" == "image" ]
		then
			is_image image "$file"
			[[ $image == true ]] || continue
		fi
		if [ "$FTYPE" == "text" ]
		then
			is_text text "$file"
			[[ $text == true ]] || continue
		fi

		new_name=$file
		get_parentmatcher parent_matcher "$file"
		
		# Call editing functions on the current filename.
		for editopt in "${EDIT_OPTS[@]}"
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

		# If --output-to option was given, build output
		# directory's pathname.
		[ "$OUTPUT" ] && get_outputdir output_dir "$OUTPUT" \
			"$file" "$@"
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
	cd "$OLDPWD"
done
