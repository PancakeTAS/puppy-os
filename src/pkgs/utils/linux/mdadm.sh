#!/usr/bin/env bash

pkgname="mdadm"
pkgver="4.4"
pkgsrcs=(
    "https://git.kernel.org/pub/scm/utils/$pkgname/$pkgname.git/snapshot/$pkgname-$pkgver.tar.gz"
)

pkgprepare() {
    cd ${pkgname}-${pkgver}
}

pkgbuild() {
    sed -i 's/off64_t/off_t/g' \
        mdadm.h \
        raid6check.c \
        restripe.c

    make \
        CC=clang \
        CXFLAGS="-O3 -DNO_LIBUDEV -DNAME_MAX=256 -DFALLOC_FL_ZERO_RANGE=0x10 -w"
}

pkginstall() {
    make install \
        BINDIR=/usr/bin \
        DESTDIR=$pkgdir

    rm -rf \
        "${pkgdir}/usr/lib"
}
