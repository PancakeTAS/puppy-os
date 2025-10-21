#!/usr/bin/env bash

pkgname="openssh"
pkgver="10.2p1"
pkgsrcs=(
    "https://ftp.spline.de/pub/OpenBSD/OpenSSH/portable/$pkgname-$pkgver.tar.gz"
)

pkgprepare() {
    cd ${pkgname}-${pkgver}

    ./configure \
        --prefix=/usr \
        --bindir=/usr/bin \
        --sbindir=/usr/bin \
        --libexecdir=/usr/lib/ssh \
        --sysconfdir=/etc/ssh \
        --sharedstatedir=/var/lib \
        --localstatedir=/var \
        --runstatedir=/run \
        --libdir=/usr/lib \
        --includedir=/usr/include \
        --datarootdir=/usr/share \
        --host=aarch64-dog-linux-musl \
        --disable-strip \
        --disable-etc-default-login \
        --disable-lastlog \
        --disable-utmp \
        --disable-utmpx \
        --disable-wtmp \
        --disable-wtmpx \
        --disable-libutil \
        --disable-pututline \
        --disable-pututxline \
        --without-rpath \
        --with-ssl-engine \
        --with-4in6 \
        --with-privsep-user=nobody \
        --with-privsep-path=/var/empty \
        --with-pid-dir=/run \
        --with-default-path='/usr/bin' \
        CC=clang LD=ld.lld \
        CFLAGS="-O3" LDFLAGS="-flto" \
        AR=llvm-ar RANLIB=llvm-ranlib OBJDUMP=llvm-objdump MANIFEST_TOOL=llvm-mt NM=llvm-nm
}

pkgbuild() {
    make
}

pkginstall() {
    make DESTDIR=$pkgdir install
}
