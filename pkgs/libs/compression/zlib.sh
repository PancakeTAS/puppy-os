#!/usr/bin/env bash

pkgname="zlib"
pkgver="1.3.1"
pkgsrcs=(
    "https://zlib.net/$pkgname-$pkgver.tar.xz"
)

pkgprepare() {
    cd $pkgname-$pkgver

    cmake -S . -B build -G Ninja \
        -DCMAKE_INSTALL_PREFIX="$pkgdir/usr" \
        -DCMAKE_INSTALL_SBINDIR="bin" \
        -DCMAKE_INSTALL_LIBDIR="lib" \
        -DCMAKE_INSTALL_LIBEXECDIR="lib" \
        -DCMAKE_SYSROOT="$sysroot" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=On \
        -DCMAKE_C_COMPILER=clang \
        -DCMAKE_C_COMPILER_TARGET="aarch64-dog-linux-musl" \
        -DZLIB_BUILD_EXAMPLES=Off
}

pkgbuild() {
    cmake --build build
}

pkginstall() {
    cmake --install build --strip

    rm "$pkgdir/usr/lib/libz.a"
}
