#!/bin/sh

# metadata
pkgname="zstd"
pkgver="1.5.7"
pkgdesc="fast real-time compression algorithm"
pkgurl="https://facebook.github.io/zstd/"
pkglic="BSD"

# build information
pkgdeps=(
    "linux-headers-6.16.9"
    "libcxx-21.1.2"
    "musl-1.2.5"
)
pkgsrcs=(
    "https://github.com/facebook/$pkgname/releases/download/v$pkgver/$pkgname-$pkgver.tar.gz"
)

# build scripts
pkgprepare() {
    cd $pkgname-$pkgver

    cmake -S build/cmake -B build -G Ninja \
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
        "$pkgroot/usr/lib/libzstd.a" \
        "$pkgroot/usr/lib/cmake" \
        "$pkgroot/usr/lib/pkgconfig" \
        "$pkgroot/usr/share"
}
