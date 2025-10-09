#!/bin/sh

# metadata
pkgname="iw"
pkgver="6.17"
pkgdesc="nl80211 based configuration utility for wireless devices"
pkgurl="https://wireless.wiki.kernel.org/en/users/documentation/iw"
pkglic="GPL"

# build information
pkgdeps=(
    "linux-headers-6.17"
    "musl-1.2.5"
    "libnl-3.11.0"
)
pkgsrcs=(
    "https://mirrors.edge.kernel.org/pub/software/network/$pkgname/$pkgname-$pkgver.tar.xz"
)

# build scripts
pkgprepare() {
    cd $pkgname-$pkgver
}

pkgbuild() {
    make \
        CC=clang \
        CFLAGS="-O3" LDFLAGS="-flto"
}

pkginstall() {
    llvm-strip --strip-unneeded iw

    mkdir -p "$pkgroot/usr/bin"
    install -Dm755 iw "$pkgroot/usr/bin/iw"
}
