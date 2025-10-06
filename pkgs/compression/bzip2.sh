#!/bin/sh

# metadata
pkgname="bzip2"
pkgver="1.0.8"
pkgdesc="data compression program"
pkgurl="https://sourceware.org/bzip2/"
pkglic="BSD"

# build information
pkgdeps=(
    "linux-headers-6.16.9"
    "musl-1.2.5"
)
pkgsrcs=(
    "https://sourceware.org/pub/$pkgname/$pkgname-$pkgver.tar.gz"
)

# build scripts
pkgprepare() {
    cd $pkgname-$pkgver
}

pkgbuild() {
    make -f Makefile-libbz2_so \
        CC=clang \
        CFLAGS="-fpic -fPIC -O3 -flto"
    make bzip2 bzip2recover \
        CC=clang \
        CFLAGS="-O3" LDFLAGS="-flto" \
        AR=llvm-ar RANLIB=llvm-ranlib
}

pkginstall() {
    make install PREFIX="$pkgroot/usr"

    cp libbz2.so.1.0.8 "$pkgroot/usr/lib/libbz2.so.1.0.8"
    ln -s libbz2.so.1.0.8 "$pkgroot/usr/lib/libbz2.so"

    rm -rf \
        "$pkgroot/usr/man" \
        "$pkgroot/usr/lib/libbz2.a"

    llvm-strip --strip-unneeded \
        "$pkgroot/usr/lib/libbz2.so.1.0.8" \
        "$pkgroot/usr/bin/bzip2recover" \
        "$pkgroot/usr/bin/bzcat" \
        "$pkgroot/usr/bin/bunzip2" \
        "$pkgroot/usr/bin/bzip2"
}
