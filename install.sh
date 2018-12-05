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

PROG_NAME="${BASH_SOURCE[0]}"
PROG_PATH="$(realpath "$0")"
PROG_BASENAME="$(basename "${PROG_PATH}")"

VERSION='1.0.0'

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

printf "DESTDIR=%s\nPREFIX=%s\n\nInstalling into: %s\n" "${DESTDIR}" "${PREFIX}" "${INSTALLDIR}"

mkdir -p "${INSTALLDIR}/bin"

printf "\t"'install -m 755 io-get-sched "'"${INSTALLDIR}"'/bin"'"\n"
install -m 755 io-get-sched "${INSTALLDIR}/bin"
printf "\t"'install -m 755 io-set-sched "'"${INSTALLDIR}"'/bin"'"\n"
install -m 755 io-set-sched "${INSTALLDIR}/bin"
