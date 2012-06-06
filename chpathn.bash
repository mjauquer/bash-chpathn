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
# REQUIREMENTS: getoptx.bash, upvars.bash
#         BUGS: Pathnames with a leading dash can not be passed as an
#               argument.
#        NOTES: Any suggestion is welcomed at auq..r@gmail.com (fill in
#               the dots).
#

source ~/code/bash/chpathn/getoptx/getoptx.bash
source ~/code/bash/chpathn/chpathn.flib
source ~/code/bash/chpathn/libftype.sh

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

#-----------------------------------------------------------------------
# BEGINNING OF MAIN CODE
#-----------------------------------------------------------------------

OLD_LC_ALL=$LC_ALL
LC_ALL=C
shopt -s extglob

# Parse command line options.
find_opts[0]="-maxdepth 1"
editoptind=0
findtestind=0
while getoptex "ascii-vowels ftype: h help noblank nocontrol norep p portable output-to: r recursive R nospecial trim type:" "$@"; do
	case "$OPTOPT" in
		ascii-vowels) editopts[$editoptind]=ascii-vowels
		              editoptind=$((${editoptind}+1))
		              ;;
		ftype)        if [ "$OPTARG" == image ]; then
			              ftype="image"
			      fi
		              if [ "$OPTARG" == text ]; then
			              ftype="text"
			      fi
		              ;;
		noblank)      editopts[$editoptind]=noblank
		              editoptind=$((${editoptind}+1))
		              ;;
		nocontrol)    editopts[$editoptind]=nocontrol
		              editoptind=$((${editoptind}+1))
		              ;;
		norep)        editopts[$editoptind]=norep
		              editoptind=$((${editoptind}+1))
		              ;;
		output-to)    output_opt="$OPTARG"
			      ;;
		h)            editopts[$editoptind]=h
		              editoptind=$((${editoptind}+1))
		              ;;
		help)         editopts[$editoptind]=help
		              editoptind=$((${editoptind}+1))
		              ;;
		p)            editopts[$editoptind]=portable
		              editoptind=$((${editoptind}+1))
		              ;;
		portable)     editopts[$editoptind]=portable
		              editoptind=$((${editoptind}+1))
		              ;;
		r)            find_opts[0]="-depth"
			      ;;
		recursive)    find_opts[0]="-depth"
		              ;;
		R)            find_opts[0]="-depth"
		              ;;
		nospecial)    editopts[$editoptind]=s
		              editoptind=$((${editoptind}+1))
		              ;;
		trim)         editopts[$editoptind]=trim
		              editoptind=$((${editoptind}+1))
		              ;;
		type)         [[ ! $OPTARG =~ [bcdpflsD] ]] && continue
			      find_tests[$findtestind]="-type $OPTARG"
		              findtestind=$((${findtestind}+1))
			      ;;
	esac
done
shift $(($OPTIND-1))

# Check for command line correctness.
[[ $# -eq 0 ]] && usage && exit

# Build the find command.
for arg
do
	cd "$arg"
	if [ $? -ne 0 ]
	then
		exit 1
	fi
	find . $find_opts $find_tests -print0 |
	while IFS="" read -r -d "" file; do
		IFS="$(printf '\n\t')"
		[[ "$file" == . ]] && continue
		[[ ! -a "$file" ]] && continue
		[[ "$ftype" == "image" ]] &&
		if ! is_image "$file"; then
			continue
		fi
		[[ "$ftype" == "text" ]] &&
		if ! is_text "$file"; then
			continue
		fi
		new_name=$file
		get_parentmatcher parent_matcher "$file"
		
		# Call editing functions on the current filename.
		for editopt in "${editopts[@]}"; do
			if [ $editopt == ascii-vowels ]; then
				asciivowels "$new_name" "$parent_matcher" \
					new_name
			fi
			if [ $editopt == noblank ]; then
				noblank "$new_name" "$parent_matcher" \
					new_name
			fi
			if [ $editopt == nocontrol ]; then
				nocntrl "$new_name" "$parent_matcher" \
					new_name
			fi
			if [ $editopt == nospecial ]; then
				nospecial "$new_name" "$parent_matcher" \
					new_name
			fi
			if [ $editopt == help ]; then
				usage
			fi
			if [ $editopt == portable ]; then
				portable "$new_name" "$parent_matcher" \
					new_name
			fi
			if [ $editopt == norep ]; then
				norep "$new_name" "$parent_matcher" \
					new_name
			fi
			if [ $editopt == trim ]; then
				trim "$new_name" "$parent_matcher" \
					new_name
			fi
		done

		# If --output-to option was given, build output directory
		# pathname.
		[ "$output_opt" ] && get_outputdir output_dir "$output_opt" \
			"$file" ${pathnames[@]}
		[ "$output_dir" ] && mkdir -p "$output_dir" && \
		new_name="$output_dir"/"${new_name#$parent_matcher}"

		# Rename file. Handle name conflicts.
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
	cd "$OLDPWD"
done
LC_ALL=$OLDLC_ALL
IFS=$OLD_IFS
