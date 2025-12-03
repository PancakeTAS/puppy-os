#!/usr/bin/env bash

pkgname="dash"
pkgver="0.5.13.1"
pkgsrcs=(
    "http://gondor.apana.org.au/~herbert/$pkgname/files/$pkgname-$pkgver.tar.gz"
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
        --host=x86_64-dog-linux-musl \
        --disable-dependency-tracking \
        --with-libedit \
        CC=clang \
        CFLAGS="-O3" LDFLAGS="-flto" \
        AR=llvm-ar RANLIB=llvm-ranlib STRIP=llvm-strip OBJDUMP=llvm-objdump MANIFEST_TOOL=llvm-mt NM=llvm-nm
}

pkgbuild() {
    make
}

pkginstall() {
    make DESTDIR=$pkgdir install-strip

    ln -s dash $pkgdir/usr/bin/sh
}
