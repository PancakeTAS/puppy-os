#!/bin/sh

# metadata
pkgname="iana-timezones"
pkgver="2025b"
pkgdesc="timezone data"
pkgurl="https://www.iana.org/time-zones"
pkglic="MIT"

# build information
pkgdeps=(
)
pkgsrcs=(
    "https://data.iana.org/time-zones/releases/tzcode$pkgver.tar.gz"
    "https://data.iana.org/time-zones/releases/tzdata$pkgver.tar.gz"
)

# build scripts
pkgprepare() {
    echo "nothing to prepare"
}

pkgbuild() {
    make ZFLAGS="-b fat"
}

pkginstall() {
    make install DESTDIR="$pkgroot"

    rm -rf \
        "$pkgroot/etc" \
        "$pkgroot/usr/bin" \
        "$pkgroot/usr/lib" \
        "$pkgroot/usr/sbin" \
        "$pkgroot/usr/share/man"
}
