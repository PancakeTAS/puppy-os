#!/usr/bin/env bash

pkgname="ntp"
pkgver="4.2.8p18"
pkgsrcs=(
    "https://downloads.nwtime.org/$pkgname/4.2.8/$pkgname-$pkgver.tar.gz"
)

pkgprepare() {
    cd $pkgname-$pkgver

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
        --disable-nls \
        --without-rpath \
        --enable-ipv6 \
        --with-yielding-select=yes \
        --enable-local-libevent \
        --with-sysroot="$sysroot" \
        CC=clang LD=ld.lld \
        AR=llvm-ar RANLIB=llvm-ranlib STRIP=llvm-strip OBJDUMP=llvm-objdump MANIFEST_TOOL=llvm-mt NM=llvm-nm
}

pkgbuild() {
    make
}

pkginstall() {
    make DESTDIR="$pkgdir" install

    rm -r "$pkgdir"/usr/share/ntp
}
