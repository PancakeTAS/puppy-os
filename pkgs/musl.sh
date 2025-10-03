#!/bin/sh

# metadata
pkgname="musl"
pkgver="1.2.5"
pkgrel="1"
pkgdesc="Implementation of the C standard library"
pkgurl="https://musl.libc.org"
pkglic="MIT"

# build information
pkgdeps=(
    "compiler-rt-21.1.2"
    "linux-6.16.9"
)
pkgsrcs=(
    "https://musl.libc.org/releases/$pkgname-$pkgver.tar.gz"
)

# build scripts
pkgprepare() {
    mkdir -p $pkgname-$pkgver/build
    cd $pkgname-$pkgver/build

    ../configure \
        --prefix=/usr \
        --target=aarch64-dog-linux-musl \
        --disable-wrapper \
        CROSS_COMPILE= CC=clang \
        CFLAGS="-O3" \
        AR=llvm-ar RANLIB=llvm-ranlib \
        LIBCC="$buildroot/lib/linux/libclang_rt.builtins-aarch64.a"
}

pkgbuild() {
    cd $pkgname-$pkgver/build

    make
}

pkginstall() {
    cd $pkgname-$pkgver/build

    DESTDIR="$pkgroot" make install
}
