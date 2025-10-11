#!/usr/bin/env bash

pkgname="traceroute"
pkgver="2.1.6"
pkgsrcs=(
    "https://downloads.sourceforge.net/$pkgname/$pkgname-$pkgver.tar.gz"
)

pkgprepare() {
    cd $pkgname-$pkgver
}

pkgbuild() {
    make \
        CC=clang LD=ld.lld \
        CFLAGS="-O3" LDFLAGS="-flto"
}

pkginstall() {
    make prefix=/usr DESTDIR="$pkgdir" install
}
