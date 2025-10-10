#!/usr/bin/env bash

pkgname="libnftnl"
pkgver="1.3.0"
pkgsrcs=(
    "https://www.netfilter.org/pub/$pkgname/$pkgname-$pkgver.tar.xz"
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
        --with-sysroot="$sysroot" \
        CC=clang LD=ld.lld \
        CFLAGS="-O3 -I\"$sysroot/usr/include\" -w" LDFLAGS="-flto -L\"$sysroot/usr/lib\"" \
        AR=llvm-ar RANLIB=llvm-ranlib STRIP=llvm-strip OBJDUMP=llvm-objdump DLLTOOL=llvm-dlltool MANIFEST_TOOL=llvm-mt NM=llvm-nm
}

pkgbuild() {
    make
}

pkginstall() {
    make DESTDIR="$pkgdir" install-strip
}
