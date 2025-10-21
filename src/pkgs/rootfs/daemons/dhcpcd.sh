#!/usr/bin/env bash

pkgname="dhcpcd"
pkgver="10.2.4"
pkgsrcs=(
    "https://github.com/NetworkConfiguration/$pkgname/releases/download/v$pkgver/$pkgname-$pkgver.tar.xz"
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
        --datarootdir=/usr/share \
        --host=aarch64-dog-linux-musl \
        --without-udev \
        --with-openssl \
        CC=clang LD=ld.lld \
        CFLAGS="-O3" LDFLAGS="-flto" \
        AR=llvm-ar RANLIB=llvm-ranlib STRIP=llvm-strip OBJDUMP=llvm-objdump MANIFEST_TOOL=llvm-mt NM=llvm-nm
}

pkgbuild() {
    make
}

pkginstall() {
    make DESTDIR=$pkgdir/ install

    rm -r $pkgdir/usr/share/dhcpcd
}
