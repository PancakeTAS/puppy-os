#!/usr/bin/env bash

pkgname="hostapd"
pkgver="2.11"
pkgsrcs=(
    "https://w1.fi/releases/$pkgname-$pkgver.tar.gz"
)

pkgprepare() {
    cd ${pkgname}-${pkgver}/hostapd

    cp $rscdir/.config .config

    patch ../src/ap/hw_features.c < $rscdir/noscan.patch
}

pkgbuild() {
    make \
        CC=clang \
        CFLAGS_EXTRA="-O3" LDFLAGS="-flto"
}

pkginstall() {
    mkdir -p $pkgdir/usr/bin
    cp -r hostapd{,_cli} \
        $pkgdir/usr/bin/
}
