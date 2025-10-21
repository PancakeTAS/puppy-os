#!/usr/bin/env bash

pkgname="wpa_supplicant"
pkgver="2.11"
pkgsrcs=(
    "https://w1.fi/releases/$pkgname-$pkgver.tar.gz"
    "https://github.com/PancakeTAS/libdbus-stub/archive/refs/tags/v1.0.0.tar.gz"
)

pkgprepare() {
    cd ${pkgname}-${pkgver}/wpa_supplicant

    cp $rscdir/.config .config
}

pkgbuild() {
    make -C ../../libdbus-stub-1.0.0 \
        libdbus-1.a \
        CC=clang
    make \
        CC=clang \
        CFLAGS_EXTRA="-O3" LDFLAGS="-flto" \
        DBUS_LIBS=../../libdbus-stub-1.0.0/libdbus-1.a
}

pkginstall() {
    make BINDIR=/usr/bin DESTDIR=$pkgdir install
}
