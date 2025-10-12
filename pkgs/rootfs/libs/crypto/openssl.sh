#!/usr/bin/env bash

pkgname="openssl"
pkgver="3.6.0"
pkgsrcs=(
    "https://github.com/$pkgname/$pkgname/releases/download/$pkgname-$pkgver/$pkgname-$pkgver.tar.gz"
)

pkgprepare() {
    cd $pkgname-$pkgver

    ./Configure linux-aarch64 \
        --prefix=/usr \
        --libdir=/usr/lib \
        --openssldir=/etc/ssl \
        enable-ktls enable-fips \
        enable-brotli zlib enable-zstd \
        shared \
        CROSS_COMPILE= CC=clang CXX=clang++ \
        AR=llvm-ar AS=llvm-as RANLIB=llvm-ranlib \
        CFLAGS="-D__STDC_NO_ATOMICS__" LDFLAGS="-flto"
}

pkgbuild() {
    make
}

pkginstall() {
    make DESTDIR="$pkgdir" install_sw install_ssldirs

    rm \
        "$pkgdir/usr/bin/c_rehash" \
        "$pkgdir/usr/lib/libcrypto.a" \
        "$pkgdir/usr/lib/libssl.a"
}
