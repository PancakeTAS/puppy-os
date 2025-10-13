#!/usr/bin/env bash

pkgname="iputils"
pkgver="20250605"
pkgsrcs=(
    "https://github.com/$pkgname/$pkgname/releases/download/$pkgver/$pkgname-$pkgver.tar.xz"
)

pkgprepare() {
    cd $pkgname-$pkgver

    ./configure
    meson setup \
        -DUSE_CAP=false \
        -DUSE_IDN=false \
        -DBUILD_MANS=false \
        -DUSE_GETTEXT=false \
        -DSKIP_TESTS=true \
        -Dprefix=/usr \
        -Dsbindir=/usr/bin \
        --buildtype release \
        --optimization 3 \
        --cross-file "$rscdir/meson.cross" \
        build
}

pkgbuild() {
    meson build
}

pkginstall() {
    meson install -C build --strip --destdir "$pkgdir"
}
