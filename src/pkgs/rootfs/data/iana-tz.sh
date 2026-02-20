#!/usr/bin/env bash

pkgname="iana-tz"
pkgver="2025c"
pkgsrcs=(
    "https://data.iana.org/time-zones/releases/tzcode$pkgver.tar.gz"
    "https://data.iana.org/time-zones/releases/tzdata$pkgver.tar.gz"
)

pkgprepare() {
    echo "nothing to prepare"
}

pkgbuild() {
    make ZFLAGS="-b fat"
}

pkginstall() {
    make install DESTDIR=$pkgdir

    rm -r \
        $pkgdir/usr/bin \
        $pkgdir/usr/lib \
        $pkgdir/usr/sbin \
        $pkgdir/usr/share/man
}
