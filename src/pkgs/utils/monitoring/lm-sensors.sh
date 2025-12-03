#!/usr/bin/env bash

pkgname="lm-sensors"
pkgver="3.6.2"
_pkgver="3-6-2"
pkgsrcs=(
    "https://github.com/hramrach/$pkgname/archive/refs/tags/V$_pkgver.tar.gz"
)

pkgprepare() {
    cd ${pkgname}-${_pkgver}
}

pkgbuild() {
    make \
        CC=clang LD=ld.lld \
        CFLAGS="-O3" LDFLAGS="-flto"
}

pkginstall() {
    make PREFIX=/usr SBINDIR=/usr/bin DESTDIR=$pkgdir install

    rm \
        $pkgdir/usr/lib/libsensors.a \
        $pkgdir/usr/bin/{sensors-detect,sensors-conf-convert} \
        $pkgdir/usr/bin/{isadump,isaset} \
        $pkgdir/usr/bin/{pwmconfig,fancontrol}
}
