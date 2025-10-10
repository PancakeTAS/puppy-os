#!/usr/bin/env bash

pkgname="iana-etc"
pkgver="20250929"
pkgsrcs=(
    "https://github.com/Mic92/$pkgname/releases/download/$pkgver/$pkgname-$pkgver.tar.gz"
)

pkgprepare() {
    cd $pkgname-$pkgver
}

pkgbuild() {
    echo "nothing to build"
}

pkginstall() {
    mkdir -p "$pkgdir/etc"

    cp -rv services protocols \
        "$pkgdir/etc"
}
