#!/usr/bin/env bash

pkgname="iproute2"
pkgver="6.19.0"
pkgsrcs=(
    "https://mirrors.edge.kernel.org/pub/linux/utils/net/$pkgname/$pkgname-$pkgver.tar.xz"
)

pkgprepare() {
    cd ${pkgname}-${pkgver}

    sed -i 's/__u8/unsigned char/g' \
        include/color.h \
        include/json_print.h
    sed -i 's/__u32/unsigned int/g' \
        include/color.h \
        include/json_print.h
    sed -i 's/__u64/unsigned long long/g' \
        include/color.h \
        include/json_print.h

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
