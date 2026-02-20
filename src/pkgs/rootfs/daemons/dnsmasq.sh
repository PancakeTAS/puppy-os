#!/usr/bin/env bash

pkgname="dnsmasq"
pkgver="2.92"
pkgsrcs=(
    "https://thekelleys.org.uk/$pkgname/$pkgname-$pkgver.tar.xz"
)

pkgprepare() {
    cd ${pkgname}-${pkgver}
}

pkgbuild() {
    make \
        CC=clang \
        CFLAGS="-O3" LDFLAGS="-flto" \
        COPTS="-DHAVE_TFTP -DHAVE_DHCDP -DHAVE_DHCP6 -DHAVE_SCRIPT -DHAVE_IPSET -DHAVE_AUTH -DHAVE_DNSSEC -DHAVE_INOTIFY -DNO_GMP"
}

pkginstall() {
    make install \
        CC=clang \
        CFLAGS="-O3" LDFLAGS="-flto" \
        PREFIX=/usr BINDIR=/usr/bin \
        DESTDIR=$pkgdir
}
