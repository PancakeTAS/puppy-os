#!/usr/bin/env bash

pkgname="bzip2"
pkgver="1.0.8"
pkgsrcs=(
    "https://sourceware.org/pub/$pkgname/$pkgname-$pkgver.tar.gz"
)

pkgprepare() {
    cd ${pkgname}-${pkgver}
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
    make PREFIX=$pkgdir/usr install

    cp libbz2.so.1.0.8 $pkgdir/usr/lib/libbz2.so.1.0.8
    ln -s libbz2.so.1.0.8 $pkgdir/usr/lib/libbz2.so.1.0
    ln -s libbz2.so.1.0.8 $pkgdir/usr/lib/libbz2.so

    rm $pkgdir/usr/bin/{bzcmp,bzegrep,bzfgrep,bzless}
    ln -s bzdiff $pkgdir/usr/bin/bzcmp
    ln -s bzgrep $pkgdir/usr/bin/bzegrep
    ln -s bzgrep $pkgdir/usr/bin/bzfgrep
    ln -s bzmore $pkgdir/usr/bin/bzless

    rm $pkgdir/usr/lib/libbz2.a
}
