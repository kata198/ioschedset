#!/bin/bash

###########################################################################
#
#  Copyright (c) 2018 Timothy Savannah All Rights Reserved
#
#    Licensed under terms of the GNU General Public License Version 3
#     which should have been supplied with this distribution as LICENSE
#
#    If not, you can access the latest LICENSE at:
#      https://raw.githubusercontent.com/kata198/ioschedset/master/LICENSE
#
#
#  install.sh - Installs the applications
#
###########################################################################

# Default DESTDIR and PREFIX if not specified
if [ -z "${DESTDIR}" ];
then
    DESTDIR="/"
fi
if [ -z "${PREFIX}" ];
then
    PREFIX="/usr"
fi

# PROG_NAME / PROG_PATH / PROG_BASENAME - Names involving this script
PROG_NAME="${BASH_SOURCE[0]}"
PROG_PATH="$(realpath "$0")"
PROG_BASENAME="$(basename "${PROG_PATH}")"

# VERSION - We overwrite the "VERSION" variable in the
#  io-get-sched and io-set-sched executables with this value
VERSION='1.1.1'

usage() {
    cat >&2 <<EOT
Usage: ${PROG_BASENAME}
  Installs the ioschedest executables

The following environment variables are meaningful, and
  can also be specified as arguments, e.x.. ${PROG_BASENAME} PREFIX=/usr/local

DESTDIR - Defines the "root" of the destination.
          Defaults to / (current filesystem).
          If building a package, this would be your \${pkgdir} or \${RPM_BUILD_ROOT}


PREFIX - Defines the leading path prefix.
         Defaults to /usr (so executables will be installed to "\${DESTDIR}/usr/bin"
         An alternate might be \$HOME for a user-local install into \${DESTDIR}/\$HOME/bin

EOT

}

########################
# 
# die - Print a message to stderr and exit
#
#    1st arg - exit code <int> - Will exit with this code
#
#    2nd arg - Format string <str> - Format string to printf
#
#    3rd..Nth arg - Format string args - Any va_args to resolve
#                     within your format string
#
#  NOTE: If you forget to specify the exit code 
#    and just start up with the format string, it will
#    assume exit code = 1
#
############################################
die() {
    
    EXIT_CODE=$1
    shift;
    if ( echo "${EXIT_CODE}" | grep -Eq '^[0-9][0-9]*$' );
    then
        # First arg was a number, so keep going
        FORMAT_STR="$1"
        shift
    else
        # Oops! Mising exit code, assume one.
        FORMAT_STR="${EXIT_CODE}"
        EXIT_CODE=1
    fi

    printf "${FORMAT_STR}\n" "$@" >&2
    
    exit ${EXIT_CODE}
}


########################
# 
# ensure_dir - Ensure a directory exists at the given location
#
#    1st arg - Path to ensure
#
#  If directory does not exist and fails to be created,
#    a warning message will be output on stderr
#    and non-zero return.
#
#  Otherwise, 0 return if directory already present
#   or we sucessfully created it
#
############################################
ensure_dir() {
    _ENSURE_DIR="$1"

    [[ -d "${_ENSURE_DIR}" ]] && return 0;

    printf "\tmkdir -p \"%s\"\n" "${_ENSURE_DIR}"
    mkdir -p "${_ENSURE_DIR}"
    RET=$?
    if [[ $RET -ne 0 ]];
    then
        printf "  WARNING: Could not create directory \"%s\", install may fail. Check permissions?\n\n" "${_ENSURE_DIR}" >&2
    fi

    return $RET
}

install_file() {

    FROM_PATH="$1"
    # Exit code 22 = EINVAL = Invalid argument
    [[ -z "${FROM_PATH}" ]] && die 22 'Missing 1st argument, "from path" to install_file'
    shift

    # Exit code 2 = ENOENT = No such file or directory
    [[ ! -e "${FROM_PATH}" ]] && die 2 "Tried to install \"${FROM_PATH}\" but file does not exist."

    TO_PATH="$1"
    [[ -z "${TO_PATH}" ]] && die 22 'Missing 2nd argument, "to path" to install_file'
    shift

    MODE="$1"
    [[ -z "${MODE}" ]] && die 22 'Missing 3rd argument, "mode" to install_file'


    printf "\t"'install -m "%s" "%s" "%s"'"\n" "${MODE}" "${FROM_PATH}" "${TO_PATH}"
    install -m "${MODE}" "${FROM_PATH}" "${TO_PATH}"
    RET=$?
    [ ${RET} -ne 0 ] && die ${RET} "  Failed to install \"%s\" to \"%s\".  Exit code=%d\n\nAborting...\n" "${FROM_PATH}" "${TO_PATH}" ${RET}


    # This will never be non-zero because we will "die" above
    return ${RET}
}


for arg in "$@";
do
    if [[ "${arg}" = "--help" ]];
    then
        usage;
        exit 1;
    elif [[ "${arg}" = "--version" ]];
    then
        printf "ioschedset version ${VERSION} by Timothy Savannah\n" >&2
        exit 0;
    elif [[ "${arg:0:7}" = "PREFIX=" ]];
    then
        PREFIX="${arg:7}"
    elif [[ "${arg:0:8}" = "DESTDIR=" ]];
    then
        DESTDIR="${arg:8}"
    else
        printf "Unknown/Invalid arg: '${arg}'\n\n" >&2
        usage;
        exit 7;
    fi
done

INSTALLDIR="${DESTDIR}/${PREFIX}"
INSTALLDIR="$(echo "${INSTALLDIR}" | sed -e 's|//|/|g' | sed -e 's|//|/|g')"

printf "Version: ${VERSION}\n\n"

printf "DESTDIR=%s\nPREFIX=%s\n\nInstalling into: %s\n\n" "${DESTDIR}" "${PREFIX}" "${INSTALLDIR}"

#########################################
##         INSTALL EXECUTABLES         ##
#########################################

printf "** INSTALLING EXECUTABLES **\n-----------------------------\n\n"

ensure_dir "${INSTALLDIR}/bin"

# Install io-get-sched
install_file 'io-get-sched' "${INSTALLDIR}/bin" 755
cat <<EOT
	sed -e 's/^VERSION=.*$/VERSION=${VERSION}/g' -i "${INSTALLDIR}/bin/io-get-sched"
EOT
sed -e 's/^VERSION=.*$/VERSION='"${VERSION}"'/g' -i "${INSTALLDIR}/bin/io-get-sched"

echo;

# Install io-set-sched
install_file 'io-set-sched' "${INSTALLDIR}/bin" 755
cat << EOT
	sed -e 's/^VERSION=.*$/VERSION=${VERSION}/g' -i "${INSTALLDIR}/bin/io-set-sched"
EOT
sed -e 's/^VERSION=.*$/VERSION='"${VERSION}"'/g' -i "${INSTALLDIR}/bin/io-set-sched"

#########################################
##         INSTALL MAN PAGES           ##
#########################################

printf "\n\n** INSTALLING MAN PAGES **\n-------------------------\n"

ensure_dir "${INSTALLDIR}/share/man/man8"

# Install man pages
for manpageName in "io-get-sched.8" "io-set-sched.8";
do
    echo;
    printf "\t"'cat "man/'"${manpageName}"'" | gzip -c > "man/'"${manpageName}"'.gz"'"\n"
    (cat "man/${manpageName}" | gzip -c > "man/${manpageName}.gz") || die $? "  Failed to compress man page at \"man/${manpageName}\". Exit code=%d\n\nAborting...\n" $?

    install_file "man/${manpageName}.gz" "${INSTALLDIR}/share/man/man8" 644
done

#########################################
##         INSTALL MISC SHARE          ##
#########################################

printf "\n\n** INSTALLING SHARE MISC **\n--------------------------\n"
echo;
# Install README and LICENSE
ensure_dir "${INSTALLDIR}/share/ioschedset"

install_file "README.md" "${INSTALLDIR}/share/ioschedset" 644
install_file "LICENSE" "${INSTALLDIR}/share/ioschedset" 644

echo;

ensure_dir "${INSTALLDIR}/share/licenses/ioschedset"

install_file "LICENSE" "${INSTALLDIR}/share/licenses/ioschedset" 644

echo


printf "\n** ALL DONE! Perfect A+ 11/10 Success on the install!\n\n"

true

# vim: set ts=4 sw=4 st=4 expandtab :
