#!/usr/bin/env bash

pkgname="libxcrypt"
pkgver="4.4.38"
pkgsrcs=(
    "https://github.com/besser82/$pkgname/releases/download/v$pkgver/$pkgname-$pkgver.tar.xz"
)

pkgprepare() {
    cd $pkgname-$pkgver

    ./configure \
        --prefix=/usr \
        --sbindir=/usr/bin \
        --libexecdir=/usr/lib \
        --host=aarch64-dog-linux-musl \
        --disable-dependency-tracking \
        --disable-static \
        --disable-symvers \
        --enable-year2038 \
        --enable-obsolete-api=no \
        --disable-failure-tokens \
        --with-sysroot="$sysroot" \
        CC=clang LD=ld.lld \
        CFLAGS="-O3" LDFLAGS="-flto" \
        AR=llvm-ar RANLIB=llvm-ranlib STRIP=llvm-strip OBJDUMP=llvm-objdump MANIFEST_TOOL=llvm-mt NM=llvm-nm
}

pkgbuild() {
    make
}

pkginstall() {
    make DESTDIR="$pkgdir" install-strip
}
