#!/usr/bin/env bash

pkgname="openntpd"
pkgver="6.8p1"
pkgsrcs=(
    "https://cdn.openbsd.org/pub/OpenBSD/OpenNTPD/$pkgname-$pkgver.tar.gz"
)

pkgprepare() {
    cd $pkgname-$pkgver

    ./configure \
        --prefix=/usr \
        --sbindir=/usr/bin \
        --libexecdir=/usr/lib \
        --sysconfdir=/etc \
        --host=aarch64-dog-linux-musl \
        --disable-dependency-tracking \
        --disable-static \
        --disable-nls \
        --with-sysroot="$sysroot" \
        CC=clang LD=ld.lld \
        AR=llvm-ar RANLIB=llvm-ranlib STRIP=llvm-strip OBJDUMP=llvm-objdump MANIFEST_TOOL=llvm-mt NM=llvm-nm
}

pkgbuild() {
    make
}

pkginstall() {
    make DESTDIR="$pkgdir" install
}
