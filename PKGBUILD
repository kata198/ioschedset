# Maintainer: Tim Savannah <kata198@gmail.com>
##############################################

#############################################################
#
# ioschedset inline PKGBUILD -
#      This is not the official PKGBUILD for ioschedset,
#       that can be found:
#  https://aur.archlinux.org/packages/ioschedset
#
# This is a modified version which will build the same package,
#  but works from the git tree itself rather than a source tarball.
#
# This PKGBUILD is intended for local builds and installations, for
#  distribution please use the aforementioned official PKGBUILD.
####################################################################

pkgname=ioschedset
pkgver=1.0.0
pkgrel=1
pkgdesc="Commandline tools to query and/or set the I/O schedulers for block devices on Linux systems."
arch=('any')
license=('GPLv3')
url="http://github.com/kata198/ioschedset"
depends=('bash')
# NO TARBALL - THIS VERSION WORKS DIRECTLY FROM THE GIT TREE
source=()
sha512sums=()

build() {
    true;
}

package() {
  mkdir -p "${pkgdir}"

  # cd into the git tree
  cd "${startdir}"

  # Run installer into pkgdir
  ./install.sh DESTDIR="${pkgdir}"
}
