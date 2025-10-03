#!/bin/sh

# metadata
pkgname="openssl"
pkgver="3.6.0"
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
        shared \
        CROSS_COMPILE= CC=clang CXX=clang++ \
        AR=llvm-ar AS=llvm-as RANLIB=llvm-ranlib \
        CFLAGS="-D__STDC_NO_ATOMICS__" LDFLAGS="-flto"
}

pkgbuild() {
    make
}

pkginstall() {
    make DESTDIR="$pkgroot" install_sw install_ssldirs

    rm -f "$pkgroot/usr/bin/c_rehash"

    rm -f \
        "$pkgroot/usr/lib/libcrypto.a" \
        "$pkgroot/usr/lib/libssl.a"

    rm -rf \
        "$pkgroot/usr/lib/cmake" \
        "$pkgroot/usr/lib/pkgconfig"

    llvm-strip --strip-unneeded \
        "$pkgroot/usr/bin/openssl" \
        "$pkgroot/usr/lib/libssl.so.3" \
        "$pkgroot/usr/lib/libcrypto.so.3"

    llvm-strip --strip-unneeded \
        "$pkgroot/usr/lib/ossl-modules/legacy.so"

    llvm-strip --strip-unneeded \
        "$pkgroot/usr/lib/engines-3/afalg.so" \
        "$pkgroot/usr/lib/engines-3/capi.so" \
        "$pkgroot/usr/lib/engines-3/loader_attic.so" \
        "$pkgroot/usr/lib/engines-3/padlock.so"
}
