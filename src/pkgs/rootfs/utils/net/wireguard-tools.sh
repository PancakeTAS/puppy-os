#!/usr/bin/env bash

pkgname="wireguard-tools"
pkgver="1.0.20260223"
pkgsrcs=(
    "https://git.zx2c4.com/$pkgname/snapshot/$pkgname-$pkgver.tar.xz"
)

pkgprepare() {
    cd ${pkgname}-${pkgver}/src
}

pkgbuild() {
    make \
        CC=clang \
        CFLAGS_EXTRA="-O3" LDFLAGS="-flto"
}

pkginstall() {
    make DESTDIR=$pkgdir install

    rm -r $pkgdir/usr/lib/systemd
}
