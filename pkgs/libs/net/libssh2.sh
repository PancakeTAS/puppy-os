#!/usr/bin/env bash

pkgname="libssh2"
pkgver="1.11.1"
pkgsrcs=(
    "https://libssh2.org/download/$pkgname-$pkgver.tar.xz"
)

pkgprepare() {
    cd $pkgname-$pkgver

    ./configure \
        --prefix=/usr \
        --sbindir=/usr/bin \
        --libexecdir=/usr/lib \
        --host=aarch64-dog-linux-musl \
        --disable-doc \
        --disable-static \
        --disable-nls \
        --disable-rpath \
        --disable-debug \
        --enable-year2038 \
        --with-libz \
        --with-crypto=openssl \
        --with-libssl-prefix="$sysroot/usr" \
        --with-libz-prefix="$sysroot/usr" \
        --with-sysroot="$sysroot" \
        LIBSSL=ssl \
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
