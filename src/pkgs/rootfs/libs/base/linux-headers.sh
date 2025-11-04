#!/usr/bin/env bash

pkgname="linux-headers"
_pkgname="linux"
_pkgname2="linux-bpi-r4"
pkgver="6.18-rc4"
pkgsrcs=(
    "https://github.com/PancakeTAS/$_pkgname2/archive/refs/heads/$_pkgname-$pkgver.tar.gz"
)

pkgprepare() {
    cd ${_pkgname2}-${_pkgname}-${pkgver}
}

pkgbuild() {
    make ARCH=arm64 headers
}

pkginstall() {
    make ARCH=arm64 INSTALL_HDR_PATH=$pkgdir/usr headers_install
}
