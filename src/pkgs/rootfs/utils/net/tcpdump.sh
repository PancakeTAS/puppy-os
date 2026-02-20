#!/usr/bin/env bash

pkgname="tcpdump"
pkgver="4.99.6"
pkgsrcs=(
    "https://www.tcpdump.org/release/$pkgname-$pkgver.tar.xz"
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
        --without-gcc \
        CC=clang LD=ld.lld \
        CFLAGS="-O3" LDFLAGS="-flto" \
        AR=llvm-ar RANLIB=llvm-ranlib STRIP=llvm-strip OBJDUMP=llvm-objdump MANIFEST_TOOL=llvm-mt NM=llvm-nm
}

pkgbuild() {
    make
}

pkginstall() {
    make DESTDIR=$pkgdir install

    rm $pkgdir/usr/bin/tcpdump.4.99.6
}
