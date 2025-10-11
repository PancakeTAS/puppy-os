#!/usr/bin/env bash

pkgname="htop"
pkgver="3.4.1"
pkgsrcs=(
    "https://github.com/$pkgname-dev/$pkgname/releases/download/$pkgver/$pkgname-$pkgver.tar.xz"
)

pkgprepare() {
    cd $pkgname-$pkgver

    ./configure \
        --prefix=/usr \
        --sbindir=/usr/bin \
        --libexecdir=/usr/lib \
        --sysconfdir=/etc \
        --host=aarch64-dog-linux-musl \
        --disable-dependency-tracking \
        --disable-static \
        --disable-nls \
        --enable-sensors \
        --with-sysroot="$sysroot" \
        CC=clang LD=ld.lld \
        AR=llvm-ar RANLIB=llvm-ranlib STRIP=llvm-strip OBJDUMP=llvm-objdump MANIFEST_TOOL=llvm-mt NM=llvm-nm
}

pkgbuild() {
    make
}

pkginstall() {
    make DESTDIR="$pkgdir" install-strip

    rm -r "$pkgdir"/usr/share/{pixmaps,icons,applications}
}
