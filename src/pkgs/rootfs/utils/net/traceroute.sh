#!/usr/bin/env bash

pkgname="traceroute"
pkgver="2.1.6"
pkgsrcs=(
    "https://downloads.sourceforge.net/$pkgname/$pkgname-$pkgver.tar.gz"
)

pkgprepare() {
    cd ${pkgname}-${pkgver}
}

pkgbuild() {
    make \
        CC=clang LD=ld.lld \
        AR=llvm-ar RANLIB=llvm-ranlib \
        CFLAGS="-O3" LDFLAGS="-flto"
}

pkginstall() {
    make prefix=/usr DESTDIR=$pkgdir install
}
