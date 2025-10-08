#!/bin/sh

# metadata
pkgname="libxcrypt"
pkgver="4.4.38"
pkgdesc="modern library for hashing passwords"
pkgurl="https://github.com/besser82/libxcrypt/"
pkglic="LGPL-v2.1"

# build information
pkgdeps=(
    "linux-headers-6.17"
    "libcxx-21.1.2"
    "musl-1.2.5"
)
pkgsrcs=(
    "https://github.com/besser82/$pkgname/releases/download/v$pkgver/$pkgname-$pkgver.tar.xz"
)

# build scripts
pkgprepare() {
    cd $pkgname-$pkgver
    ./configure \
        --prefix=/usr \
        --host=aarch64-dog-linux-musl \
        --disable-dependency-tracking \
        --disable-static \
        --disable-symvers \
        --enable-year2038 \
        --enable-obsolete-api=no \
        --disable-failure-tokens \
        --with-sysroot="$buildroot" \
        CC=clang LD=ld.lld \
        CFLAGS="-O3" LDFLAGS="-flto" \
        AR=llvm-ar RANLIB=llvm-ranlib STRIP=llvm-strip OBJDUMP=llvm-objdump MANIFEST_TOOL=llvm-mt NM=llvm-nm
}

pkgbuild() {
    make
}

pkginstall() {
    make install-strip DESTDIR="$pkgroot"

    rm -rf \
        "$pkgroot/usr/share" \
        "$pkgroot/usr/lib/libcrypt.la" \
        "$pkgroot/usr/lib/pkgconfig"
}
