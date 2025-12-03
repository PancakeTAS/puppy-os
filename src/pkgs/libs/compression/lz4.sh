#!/usr/bin/env bash

pkgname="lz4"
pkgver="1.10.0"
pkgsrcs=(
    "https://github.com/$pkgname/$pkgname/releases/download/v$pkgver/$pkgname-$pkgver.tar.gz"
)

pkgprepare() {
    cd ${pkgname}-${pkgver}
}

pkgbuild() {
    make \
        CC=clang LD=ld.lld \
        CFLAGS="-O3" LDFLAGS="-flto" \
        AR=llvm-ar
    make -C programs \
        CC=clang LD=ld.lld \
        CFLAGS="-O3" LDFLAGS="-flto"
}

pkginstall() {
    make DESTDIR=$pkgdir PREFIX=/usr install

    rm $pkgdir/usr/lib/liblz4.a
}
