#!/bin/sh

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="gtest"
PKG_VERSION="1.7.0"

TARBALL="${PKG_NAME}-${PKG_VERSION}.zip"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"
BUILD_DIR="${PKG_NAME}-build"

function prepare() {
    if [[ ! -f "${TARBALL}" ]]
    then
        ln -sv "/source/$TARBALL" "$TARBALL"
    fi
}

function unpack() {
    unzip -q ${TARBALL}
}

function build() {
	mkdir "${BUILD_DIR}" &&
	pushd "${BUILD_DIR}"	
		cmake -DBUILD_SHARED_LIBS=ON -DCMAKE_SKIP_RPATH=ON ..
		make $MAKE_PARALLEL
	popd
}

function check() {
	echo " "
}

function instal() {
	mkdir -pm 0755 /usr/{lib,include/${PKG_NAME}/internal,share/licenses/${PKG_NAME},src/${PKG_NAME}/src,src/${PKG_NAME}/cmake}
	install -m 0644 ${BUILD_DIR}/lib${PKG_NAME}{,_main}.so /usr/lib
	install -m 0644 include/${PKG_NAME}/*.h /usr/include/${PKG_NAME}
	install -m 0644 include/${PKG_NAME}/internal/*.h /usr/include/${PKG_NAME}/internal/
	install -m 0644 LICENSE /usr/share/licenses/${PKG_NAME}/
	install -m 0644 "fused-src/${PKG_NAME}"/* /usr/src/${PKG_NAME}/src/
	install -m 0644 "CMakeLists.txt" /usr/src/${PKG_NAME}/
	install -m 0644 "cmake"/* /usr/src/${PKG_NAME}/cmake/
}

function clean() {
    rm -rf "${SRC_DIR}" "${BUILD_DIR}"
}

clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_CHECK = TRUE ]] && check;instal;popd;clean
