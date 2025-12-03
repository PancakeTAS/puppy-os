#!/usr/bin/env bash

pkgname="iproute2"
pkgver="6.16.0"
pkgsrcs=(
    "https://mirrors.edge.kernel.org/pub/linux/utils/net/$pkgname/$pkgname-$pkgver.tar.xz"
)

pkgprepare() {
    cd ${pkgname}-${pkgver}

    PKG_CONFIG=false ./configure \
        --prefix=/usr \
        --color=auto
}

pkgbuild() {
    CFLAGS="-O3 -flto" make \
        HOSTCC=/usr/bin/clang CC=clang \
        AR=llvm-ar
}

pkginstall() {
    DESTDIR=$pkgdir SBINDIR='/usr/bin' \
        make install

    rm -r $pkgdir/usr/lib/tc
}
