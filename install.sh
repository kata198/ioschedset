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
VERSION='1.1.0'

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
############################################
die() {

    EXIT_CODE=$1
    shift;

    FORMAT_STR="$1"
    shift

    printf "${FORMAT_STR}" "$@" >&2
    
    exit ${EXIT_CODE}
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

mkdir -p "${INSTALLDIR}/bin" || printf "  WARNING: Could not create directory '${INSTALLDIR}/bin', install may fail. Check permissions?\n\n" >&2

# Install io-get-sched
printf "\t"'install -m 755 io-get-sched "'"${INSTALLDIR}"'/bin"'"\n"
install -m 755 io-get-sched "${INSTALLDIR}/bin" || die $? "  Failed to install \"%s\" to \"%s\". Exit code=%d\n\nAborting...\n" 'io-get-sched' "${INSTALLDIR}/bin" "$?" 
cat <<EOT
	sed -e 's/^VERSION=.*$/VERSION=${VERSION}/g' -i "${INSTALLDIR}/bin/io-get-sched"
EOT
sed -e 's/^VERSION=.*$/VERSION='"${VERSION}"'/g' -i "${INSTALLDIR}/bin/io-get-sched"

echo;

# Install io-set-sched
printf "\t"'install -m 755 io-set-sched "'"${INSTALLDIR}"'/bin"'"\n"
install -m 755 io-set-sched "${INSTALLDIR}/bin" || die $? "  Failed to install \"%s\" to \"%s\". Exit code=%d\n\nAborting...\n" 'io-set-sched' "${INSTALLDIR}/bin" "$?" 
cat << EOT
	sed -e 's/^VERSION=.*$/VERSION=${VERSION}/g' -i "${INSTALLDIR}/bin/io-set-sched"
EOT
sed -e 's/^VERSION=.*$/VERSION='"${VERSION}"'/g' -i "${INSTALLDIR}/bin/io-set-sched"

#########################################
##         INSTALL MAN PAGES           ##
#########################################

mkdir -p "${INSTALLDIR}/share/man/man8" || printf "  WARNING: Could not create directory '${INSTALLDIR}/share/man/man3', install may fail. Check permissions?\n\n" >&2

# Install man pages
for manpageName in "io-get-sched.8" "io-set-sched.8";
do
    echo;
    printf "\t"'cat "man/'"${manpageName}"'" | gzip -c > "man/'"${manpageName}"'.gz"'"\n"
    (cat "man/${manpageName}" | gzip -c > "man/${manpageName}.gz") || die $? "  Failed to compress man page at \"man/${manpageName}\". Exit code=%d\n\nAborting...\n" $?


    printf "\t"'install -m 755 "man/'"${manpageName}"'" "'"${INSTALLDIR}"'/share/man/man8'"\n"
    install -m 755 "man/${manpageName}" "${INSTALLDIR}/share/man/man8" || die $? "  Failed to install \"%s\" to \"%s\".  Exit code=%d\n\nAborting...\n" "man/${manpageName}" "${INSTALLDIR}/share/man/man8"
done


echo
true

# vim: set ts=4 sw=4 st=4 expandtab :
