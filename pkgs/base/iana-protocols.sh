#!/bin/sh

# metadata
pkgname="iana-protocols"
pkgver="20250929"
pkgdesc="iana protocols and services"
pkgurl="https://github.com/Mic92/iana-etc"
pkglic="MIT"

# build information
pkgdeps=(
)
pkgsrcs=(
    "https://github.com/Mic92/iana-etc/releases/download/$pkgver/iana-etc-$pkgver.tar.gz"
)

# build scripts
pkgprepare() {
    cd iana-etc-$pkgver
}

pkgbuild() {
    echo "nothing to build"
}

pkginstall() {
    mkdir -p "$pkgroot/etc"

    cp -rv services protocols \
        "$pkgroot/etc"
}
