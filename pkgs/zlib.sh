#!/bin/sh

# metadata
pkgname="zlib"
pkgver="1.3.1"
pkgrel="1"
pkgdesc="Compression library implementing the deflate compression method found in gzip and PKZIP"
pkgurl="https://zlib.net"
pkglic="Zlib"

# build information
pkgdeps=(
    "compiler-rt-21.1.2"
    "linux-6.16.9"
    "musl-1.2.5"
)
pkgsrcs=(
    "https://musl.net/$pkgname-$pkgver.tar.xz"
)

# build scripts
pkgprepare() {
    cd $pkgname-$pkgver

    cmake -S . -B build -G Ninja \
        -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=On \
        -DCMAKE_INSTALL_PREFIX="$pkgroot/usr" \
        -DCMAKE_SYSROOT="$buildroot" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_C_COMPILER=clang \
        -DCMAKE_C_COMPILER_TARGET="aarch64-dog-linux-musl" \
        -DSKIP_INSTALL_FILES=ON
}

pkgbuild() {
    cd $pkgname-$pkgver

    cmake --build build
}

pkginstall() {
    cd $pkgname-$pkgver

    cmake --install build --strip
}
