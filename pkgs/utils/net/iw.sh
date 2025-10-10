#!/usr/bin/env bash

pkgname="iw"
pkgver="6.17"
pkgsrcs=(
    "https://mirrors.edge.kernel.org/pub/software/network/$pkgname/$pkgname-$pkgver.tar.xz"
)

pkgprepare() {
    cd $pkgname-$pkgver
}

pkgbuild() {
    make \
        CC=clang \
        CFLAGS="-O3" LDFLAGS="-flto"
}

pkginstall() {
    install -Dm755 iw "$pkgdir/usr/bin/iw"
}
