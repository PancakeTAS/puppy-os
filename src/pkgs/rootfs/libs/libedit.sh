#!/usr/bin/env bash

pkgname="libedit"
pkgver="20251016-3.1"
pkgsrcs=(
    "https://thrysoee.dk/editline/$pkgname-$pkgver.tar.gz"
)

pkgprepare() {
    cd ${pkgname}-${pkgver}

    ./configure \
        --prefix=/usr \
        --bindir=/usr/bin \
        --sbindir=/usr/bin \
        --libexecdir=/usr/lib \
        --sysconfdir=/etc \
        --sharedstatedir=/var/lib \
        --localstatedir=/var \
        --runstatedir=/run \
        --libdir=/usr/lib \
        --includedir=/usr/include \
        --datarootdir=/usr/share \
        --host=aarch64-dog-linux-musl \
        --disable-dependency-tracking \
        --disable-static \
        --disable-examples \
        --enable-widec \
        --with-sysroot=/puppyos/target/rootfs \
        CC=clang CXX=clang++ LD=ld.lld \
        CFLAGS="-O3 -D__STDC_ISO_10646__" LDFLAGS="-flto" \
        AR=llvm-ar RANLIB=llvm-ranlib STRIP=llvm-strip OBJDUMP=llvm-objdump MANIFEST_TOOL=llvm-mt NM=llvm-nm
}

pkgbuild() {
    make
}

pkginstall() {
    make DESTDIR=$pkgdir install
}
