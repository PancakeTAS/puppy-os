#!/bin/sh

# metadata
pkgname="iproute2"
pkgver="6.16.0"
pkgdesc="ip routing utilities"
pkgurl="https://git.kernel.org/pub/scm/network/iproute2/iproute2.git"
pkglic="GPLv2"

# build information
pkgdeps=(
    "linux-headers-6.17"
    "musl-1.2.5"
)
pkgsrcs=(
    "https://mirrors.edge.kernel.org/pub/linux/utils/net/$pkgname/$pkgname-$pkgver.tar.xz"
)

# build scripts
pkgprepare() {
    cd $pkgname-$pkgver

    PKG_CONFIG=false ./configure \
        --prefix=/usr \
        --color=auto
}

pkgbuild() {
    CFLAGS="-O3 -flto" make \
        HOSTCC=/bin/clang CC=clang \
        AR=llvm-ar
}

pkginstall() {
    DESTDIR="$pkgroot" SBINDIR='/usr/bin' \
        make install

    rm -rf \
        "$pkgroot/usr/share/bash-completion" \
        "$pkgroot/usr/share/man" \
        "$pkgroot/usr/lib/tc" \

}
