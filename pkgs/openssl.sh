#!/bin/sh

# metadata
pkgname="openssl"
pkgver="3.6.0"
pkgrel=1
pkgdesc="Open Source toolkit for SSL and TLS"
pkgurl="https://openssl.net"
pkglic="Zlib"

# build information
pkgdeps=(
    "compiler-rt-21.1.2"
    "libcxx-21.1.2"
    "linux-6.16.9"
    "musl-1.2.5"
)
pkgsrcs=(
    "https://github.com/$pkgname/$pkgname/releases/download/$pkgname-$pkgver/$pkgname-$pkgver.tar.gz"
)

# build scripts
pkgprepare() {
    cd $pkgname-$pkgver

    ./Configure linux-aarch64 \
        --prefix=/usr \
        --libdir=/usr/lib \
        --openssldir=/usr/share/ssl \
        enable-ktls enable-fips \
        no-padlockeng no-capieng no-afalgeng no-loadereng \
        shared \
        CROSS_COMPILE= CC=clang CXX=clang++ \
        AR=llvm-ar AS=llvm-as RANLIB=llvm-ranlib \
        CFLAGS="-O3 -D__STDC_NO_ATOMICS__" LDFLAGS="-flto"
}

pkgbuild() {
    cd $pkgname-$pkgver

    make
}

pkginstall() {
    cd $pkgname-$pkgver

    make DESTDIR="$pkgroot" install_sw install_ssldirs

    llvm-strip --strip-unneeded "$pkgroot/usr/lib/ossl-modules/legacy.so" \
        "$pkgroot/usr/lib/libcrypto.so.3" \
        "$pkgroot/usr/lib/libssl.so.3" \
        "$pkgroot/usr/bin/openssl"

    rm -rfv "$pkgroot/usr/bin/c_rehash" \
        "$pkgroot/usr/lib/cmake" \
        "$pkgroot/usr/lib/pkgconfig" \
        "$pkgroot/usr/lib/engines-3"
}
