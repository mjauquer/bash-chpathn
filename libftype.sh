#! /bin/bash

#===  FUNCTION =========================================================
#
#        NAME: is_image
#
#       USAGE: is_image PATHNAME
#
# DESCRIPTION: Test if file is an image. Return 0 if it is or 1 if it is
#              not.
#
#  PARAMETERS: PATHNAME (A pathname).
#
#=======================================================================
is_image () {
	OLD_IFS=$IFS
	IFS="$(printf '\n\t')"
	{
		[[ "$#" -ne 1 ]] && cat <<- EOF
		Error: function is_image requires one argument.
		EOF
	} && exit 1
	[[ $(file -b --mime-type "$1") =~ image/.* ]] && IFS=$OLD_IFS &&
		return 0
	IFS=$OLD_IFS && return 1
}

#===  FUNCTION =========================================================
#
#        NAME: is_flac
#
#       USAGE: is_flac PATHNAME
#
# DESCRIPTION: Test if file is a flac file. Return 0 if it is or 1 if it
#              is not.
#
#  PARAMETERS: PATHNAME (A pathname).
#
#=======================================================================
is_flac () {
	OLD_IFS=$IFS
	IFS="$(printf '\n\t')"
	{
		[[ "$#" -ne 1 ]] && cat <<- EOF
		Error: function is_flac requires one argument.
		EOF
	} && exit 1
	[[ $(file -b --mime-type "$1") == audio/x-flac ]] && IFS=$OLD_IFS &&
	return 0
	IFS=$OLD_IFS && return 1
}

#===  FUNCTION =========================================================
#
#        NAME: is_iso
#
#       USAGE: is_iso PATHNAME
#
# DESCRIPTION: Test if file is an iso file. Return 0 if it is or 1 if it
#              is not.
#
#  PARAMETERS: PATHNAME (A pathname).
#
#=======================================================================
is_iso () {
	OLD_IFS=$IFS
	IFS="$(printf '\n\t')"
	{
		[[ "$#" -ne 1 ]] && cat <<- EOF
		Error: function is_iso requires one argument.
		EOF
	} && exit 1
	[[ $(file -b --mime-type "$1") == application/x-iso9660-image ]] && IFS=$OLD_IFS &&
		return 0
	IFS=$OLD_IFS && return 1
}

#===  FUNCTION =========================================================
#
#        NAME: is_text
#
#       USAGE: is_text PATHNAME
#
# DESCRIPTION: Test if file is a text file. Return 0 if it is or 1 if it
#              is not.
#
#  PARAMETERS: PATHNAME (A pathname).
#
#=======================================================================
is_text () {
	OLD_IFS=$IFS
	IFS="$(printf '\n\t')"
	{
		[[ "$#" -ne 1 ]] && cat <<- EOF
		Error: function is_text requires one argument.
		EOF
	} && exit 1
	[[ $(file -b --mime-type "$1") == text/plain ]] && IFS=$OLD_IFS &&
		return 0
	IFS=$OLD_IFS && return 1
}
