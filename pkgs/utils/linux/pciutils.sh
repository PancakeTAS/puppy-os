#!/usr/bin/env bash

pkgname="pciutils"
pkgver="3.14.0"
pkgsrcs=(
    "https://github.com/$pkgname/$pkgname/releases/download/v$pkgver/$pkgname-$pkgver.tar.gz"
)

pkgprepare() {
    cd $pkgname-$pkgver
}

pkgbuild() {
    make all ZLIB=no DNS=no SHARED=yes HWDB=no \
        CROSS_COMPILE= HOST=aarch64-dog-linux-gnu \
        CC=clang OPT="-O3 -flto" \
        PREFIX=/usr SHAREDIR=/usr/share/hwdata MANDIR=/usr/share/man SBINDIR=/usr/bin
}

pkginstall() {
    make DESTDIR="$pkgdir" install install-lib \
        PREFIX=/usr SHAREDIR=/usr/share/hwdata MANDIR=/usr/share/man SBINDIR=/usr/bin

    rm -r "$pkgdir"/usr/share/hwdata
}
