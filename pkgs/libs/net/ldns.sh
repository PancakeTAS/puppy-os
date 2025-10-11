#!/usr/bin/env bash

pkgname="ldns"
pkgver="1.8.4"
pkgsrcs=(
    "https://www.nlnetlabs.nl/downloads/$pkgname/$pkgname-$pkgver.tar.gz"
)

pkgprepare() {
    cd $pkgname-$pkgver

    ./configure \
        --prefix=/usr \
        --sbindir=/usr/bin \
        --libexecdir=/usr/lib \
        --host=aarch64-dog-linux-musl \
        --disable-dependency-tracking \
        --enable-poll \
        --disable-rpath \
        --with-drill \
        --enable-year2038 \
        --with-sysroot="$sysroot" \
        CC=clang CXX=clang++ LD=ld.lld \
        CFLAGS="-O3" LDFLAGS="-flto" \
        AR=llvm-ar RANLIB=llvm-ranlib STRIP=llvm-strip OBJDUMP=llvm-objdump MANIFEST_TOOL=llvm-mt NM=llvm-nm
}

pkgbuild() {
    make
}

pkginstall() {
    make DESTDIR="$pkgdir" install

    rm "$pkgdir/usr/lib/libldns.a"
}
