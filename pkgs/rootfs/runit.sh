#!/usr/bin/env bash

pkgname="runit"
pkgver="2.2.0"
pkgsrcs=(
    "https://smarden.org/$pkgname/$pkgname-$pkgver.tar.gz"
)

pkgprepare() {
    cd admin/$pkgname-$pkgver

    sed -i 's/-static//g' src/Makefile
    sed -i "s|/service/|\/run\/runit\/service/|" src/sv.c

    echo "clang -O3" > src/conf-cc
    echo "clang -flto -s" > src/conf-ld
}

pkgbuild() {
    ./package/compile
}

pkginstall() {
    mkdir -p "$pkgdir/usr/bin"

    cp command/* \
        "$pkgdir/usr/bin"
}
