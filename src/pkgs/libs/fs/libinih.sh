#!/usr/bin/env bash

pkgname="libinih"
pkgver="r62"
pkgsrcs=(
    "https://github.com/benhoyt/inih/archive/refs/tags/$pkgver.tar.gz"
)

pkgprepare() {
    cd inih-${pkgver}

    ./configure
    meson setup \
        -Dprefix=/usr \
        -Dtests=false \
        --buildtype release \
        --optimization 3 \
        --cross-file $rscdir/meson.cross \
        build
}

pkgbuild() {
    meson build
}

pkginstall() {
    meson install -C build --strip --destdir $pkgdir
}
