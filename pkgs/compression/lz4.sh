#!/bin/sh

# metadata
pkgname="lz4"
pkgver="1.10.0"
pkgdesc="extremely fast compression algorithm"
pkgurl="https://lz4.org/"
pkglic="GPLv2"

# build information
pkgdeps=(
    "linux-headers-6.16.9"
    "musl-1.2.5"
)
pkgsrcs=(
    "https://github.com/$pkgname/$pkgname/releases/download/v$pkgver/$pkgname-$pkgver.tar.gz"
)

# build scripts
pkgprepare() {
    cd $pkgname-$pkgver
}

pkgbuild() {
    make \
        CC=clang LD=ld.lld \
        CFLAGS="-O3" LDFLAGS="-flto" \
        AR=llvm-ar
    make -C programs \
        CC=clang LD=ld.lld \
        CFLAGS="-O3" LDFLAGS="-flto" \
        AR=llvm-ar
}

pkginstall() {
    make install DESTDIR="$pkgroot" PREFIX=/usr

    rm -rf \
        "$pkgroot/usr/share" \
        "$pkgroot/usr/lib/pkgconfig" \
        "$pkgroot/usr/lib/liblz4.a"

    llvm-strip --strip-unneeded \
        "$pkgroot/usr/lib/liblz4.so.1.10.0" \
        "$pkgroot/usr/bin/lz4"
}
