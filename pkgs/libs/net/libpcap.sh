#!/usr/bin/env bash

pkgname="libpcap"
pkgver="1.10.5"
pkgsrcs=(
    "https://www.tcpdump.org/release/$pkgname-$pkgver.tar.xz"
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
        --disable-dbus \
        --without-gcc \
        --enable-year2038 \
        --with-sysroot="$sysroot" \
        CC=clang LD=ld.lld \
        CFLAGS="-O3" LDFLAGS="-flto" \
        AR=llvm-ar RANLIB=llvm-ranlib STRIP=llvm-strip OBJDUMP=llvm-objdump MANIFEST_TOOL=llvm-mt NM=llvm-nm
}

pkgbuild() {
    make
}

pkginstall() {
    make DESTDIR="$pkgdir" install

    rm "$pkgdir/usr/lib/libpcap.a"
}
