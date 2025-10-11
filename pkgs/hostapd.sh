#!/usr/bin/env bash

pkgname="hostapd"
pkgver="2.11"
pkgsrcs=(
    "https://w1.fi/releases/$pkgname-$pkgver.tar.gz"
)

pkgprepare() {
    cd $pkgname-$pkgver/hostapd

    cp "$filesdir/config.txt" .config
}

pkgbuild() {
    make \
        CC=clang \
        CFLAGS_EXTRA="-O3" LDFLAGS="-flto"
}

pkginstall() {
    mkdir -p \
        "$pkgdir/etc/hostapd" \
        "$pkgdir/usr/bin"

    cp -r hostapd{,_cli} \
        "$pkgdir/usr/bin/"
    cp -r hostapd.{accept,conf,deny,eap_user,radius_clients,vlan,wpa_psk} \
        "$pkgdir/etc/hostapd/"
}
