#!/bin/sh

# metadata
pkgname="brotli"
pkgver="1.1.0"
pkgdesc="generic-purpose compression library"
pkgurl="https://github.com/google/brotli"
pkglic="MIT"

# build information
pkgdeps=(
    "linux-headers-6.16.9"
    "musl-1.2.5"
)
pkgsrcs=(
    "https://github.com/google/$pkgname/archive/refs/tags/v$pkgver.tar.gz"
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
        -DCMAKE_C_COMPILER_TARGET="aarch64-dog-linux-musl"
}

pkgbuild() {
    cmake --build build
}

pkginstall() {
    cmake --install build --strip

    rm -rf \
        "$pkgroot/usr/lib/pkgconfig"
}
