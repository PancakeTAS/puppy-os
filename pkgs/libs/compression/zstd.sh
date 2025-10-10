#!/usr/bin/env bash

pkgname="zstd"
pkgver="1.5.7"
pkgsrcs=(
    "https://github.com/facebook/$pkgname/releases/download/v$pkgver/$pkgname-$pkgver.tar.gz"
)

pkgprepare() {
    cd $pkgname-$pkgver

    cmake -S build/cmake -B build -G Ninja \
        -DCMAKE_INSTALL_PREFIX="$pkgdir/usr" \
        -DCMAKE_INSTALL_SBINDIR="bin" \
        -DCMAKE_INSTALL_LIBDIR="lib" \
        -DCMAKE_INSTALL_LIBEXECDIR="lib" \
        -DCMAKE_SYSROOT="$sysroot" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=On \
        -DCMAKE_C_COMPILER=clang \
        -DCMAKE_C_COMPILER_TARGET="aarch64-dog-linux-musl"
}

pkgbuild() {
    cmake --build build
}

pkginstall() {
    cmake --install build --strip

    rm "$pkgdir/usr/lib/libzstd.a"
}
