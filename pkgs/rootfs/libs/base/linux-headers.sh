#!/usr/bin/env bash

pkgname="linux-headers"
_pkgname="linux"
pkgver="6.17"
pkgsrcs=(
    "https://www.kernel.org/pub/$_pkgname/kernel/v6.x/$_pkgname-$pkgver.tar.xz"
)

pkgprepare() {
    cd $_pkgname-$pkgver
}

pkgbuild() {
    make ARCH=arm64 headers
}

pkginstall() {
    make ARCH=arm64 INSTALL_HDR_PATH="$pkgdir/usr" headers_install
}
