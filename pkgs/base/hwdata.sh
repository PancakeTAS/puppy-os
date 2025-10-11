#!/usr/bin/env bash

pkgname="hwdata"
pkgver="0.400"
pkgsrcs=(
    "https://github.com/vcrhonek/$pkgname/archive/refs/tags/v$pkgver.tar.gz"
)

pkgprepare() {
    cd "$pkgname-$pkgver"

    ./configure \
        --prefix=/usr \
        --disable-blacklist
}

pkgbuild() {
    echo "nothing to build"
}

pkginstall() {
    make DESTDIR="$pkgdir" install
}
