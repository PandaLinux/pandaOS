#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="gcc"
PKG_VERSION="5.3.0"

PKG_MPFR="mpfr"
PKG_MPFR_VERSION="3.1.3"
TARBALL_MPFR="${PKG_MPFR}-${PKG_MPFR_VERSION}.tar.xz"

PKG_MPC="mpc"
PKG_MPC_VERSION="1.0.3"
TARBALL_MPC="${PKG_MPC}-${PKG_MPC_VERSION}.tar.gz"

PKG_GMP="gmp"
PKG_GMP_VERSION="6.1.0"
TARBALL_GMP="${PKG_GMP}-${PKG_GMP_VERSION}.tar.xz"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.bz2"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"
BUILD_DIR="${PKG_NAME}-build"

function prepare() {
	ln -sv "../../source/$TARBALL" "$TARBALL"
	ln -sv "../../source/$TARBALL_MPFR" "$TARBALL_MPFR"
	ln -sv "../../source/$TARBALL_MPC" "$TARBALL_MPC"
	ln -sv "../../source/$TARBALL_GMP" "$TARBALL_GMP"
}

function unpack() {
    tar xf ${TARBALL}
    tar -xf ${TARBALL_MPFR}
    mv -v "${PKG_MPFR}-${PKG_MPFR_VERSION}" "${SRC_DIR}/${PKG_MPFR}"
    tar -xf ${TARBALL_MPC}
    mv -v "${PKG_MPC}-${PKG_MPC_VERSION}" "${SRC_DIR}/${PKG_MPC}"
    tar -xf ${TARBALL_GMP}
    mv -v "${PKG_GMP}-${PKG_GMP_VERSION}" "${SRC_DIR}/${PKG_GMP}"
}

function build() {
    for file in \
        $(find gcc/config -name linux64.h -o -name linux.h -o -name sysv4.h)
    do
        cp -uv $file{,.orig}
	sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' \
	    -e 's@/usr@/tools@g' $file.orig > $file
	echo '
              #undef STANDARD_STARTFILE_PREFIX_1
              #undef STANDARD_STARTFILE_PREFIX_2
              #define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
              #define STANDARD_STARTFILE_PREFIX_2 ""' >> $file
	touch $file.orig
    done


    mkdir "${BUILD_DIR}" &&
    cd "${BUILD_DIR}" &&
    ../configure --target="$TARGET"                             \
		 --prefix=/tools                                \
		 --with-glibc-version=2.11                      \
		 --with-sysroot="$MOUNT_POINT"                  \
		 --with-newlib                                  \
		 --without-headers                              \
		 --with-local-prefix=/tools                     \
		 --with-native-system-header-dir=/tools/include \
		 --disable-nls                                  \
		 --disable-shared                               \
		 --disable-multilib                             \
		 --disable-decimal-float                        \
		 --disable-threads                              \
		 --disable-libatomic                            \
		 --disable-libgomp                              \
		 --disable-libquadmath                          \
		 --disable-libssp                               \
		 --disable-libvtv                               \
		 --disable-libstdcxx                            \
		 --enable-languages=c,c++
     make $MAKE_PARALLEL
}

function check() {
	echo " "
}

function instal() {
     make $MAKE_PARALLEL install
}

function clean() {
    rm -rf "${SRC_DIR}" "${BUILD_DIR}" "$TARBALL" "$TARBALL_MPFR" "$TARBALL_MPC" "$TARBALL_GMP"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
