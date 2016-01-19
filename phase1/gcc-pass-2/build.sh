#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="gcc"
PKG_VERSION="5.2.0"

PKG_MPFR="mpfr"
PKG_MPFR_VERSION="3.1.3"
TARBALL_MPFR="${PKG_MPFR}-${PKG_MPFR_VERSION}.tar.xz"

PKG_MPC="mpc"
PKG_MPC_VERSION="1.0.3"
TARBALL_MPC="${PKG_MPC}-${PKG_MPC_VERSION}.tar.gz"

PKG_GMP="gmp"
PKG_GMP_VERSION="6.0.0a"
TARBALL_GMP="${PKG_GMP}-${PKG_GMP_VERSION}.tar.xz"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.bz2"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"
BUILD_DIR="${PKG_NAME}-build"

function prepare() {
    if [[ ! -f "${TARBALL}" ]]
    then
        ln -sv "../../source/$TARBALL" "$TARBALL"
    fi
    
    if [[ ! -f "${TARBALL_MPFR}" ]]
    then
        ln -sv "../../source/$TARBALL_MPFR" "$TARBALL_MPFR"
    fi
    
    if [[ ! -f "${TARBALL_MPC}" ]]
    then
        ln -sv "../../source/$TARBALL_MPC" "$TARBALL_MPC"
    fi
    
    if [[ ! -f "${TARBALL_GMP}" ]]
    then
        ln -sv "../../source/$TARBALL_GMP" "$TARBALL_GMP"
    fi
}

function unpack() {
    tar xf ${TARBALL}
    tar -xf ${TARBALL_MPFR}
    mv -v "${PKG_MPFR}-${PKG_MPFR_VERSION}" "${SRC_DIR}/${PKG_MPFR}"
    tar -xf ${TARBALL_MPC}
    mv -v "${PKG_MPC}-${PKG_MPC_VERSION}" "${SRC_DIR}/${PKG_MPC}"
    tar -xf ${TARBALL_GMP}
    mv -v "${PKG_GMP}-6.0.0" "${SRC_DIR}/${PKG_GMP}"
}

function build() {
    cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
        `dirname $($TARGET-gcc -print-libgcc-file-name)`/include-fixed/limits.h

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
    CC=$TARGET-gcc                                 \
    CXX=$TARGET-g++                                \
    AR=$TARGET-ar                                  \
    RANLIB=$TARGET-ranlib                          \
    ../configure                                   \
    --prefix=/tools                                \
    --with-local-prefix=/tools                     \
    --with-native-system-header-dir=/tools/include \
    --enable-languages=c,c++                       \
    --disable-libstdcxx-pch                        \
    --disable-multilib                             \
    --disable-bootstrap                            \
    --disable-libgomp
    make $MAKE_PARALLEL
    make $MAKE_PARALLEL install
     
    ln -sv gcc /tools/bin/cc
     
    echo 'int main(){return 0;}' > dummy.c
    $TARGET-gcc dummy.c
    readelf -l a.out | grep ': /tools' |& tee test.log
    rm -v dummy.c a.out
}

function clean() {
    rm -rf "${SRC_DIR}" "${BUILD_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;popd;clean
