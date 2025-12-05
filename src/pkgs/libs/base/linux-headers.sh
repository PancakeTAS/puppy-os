#!/usr/bin/env bash

pkgname="linux-headers"
_pkgname="linux"
pkgver="6.18"
pkgsrcs=(
    "https://cdn.kernel.org/pub/$_pkgname/kernel/v6.x/$_pkgname-$pkgver.tar.xz"
)

pkgprepare() {
    cd ${_pkgname}-${pkgver}
}

pkgbuild() {
    make ARCH=x86_64 headers
}

pkginstall() {
    make ARCH=x86_64 INSTALL_HDR_PATH=$pkgdir/usr headers_install
}
