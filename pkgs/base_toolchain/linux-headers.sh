#!/bin/sh

# metadata
pkgname="linux-headers"
_pkgname="linux"
pkgver="6.17"
pkgdesc="the Linux kernel header files"
pkgurl="https://kernel.org/"
pkglic="GPL-2.0-only"

# build information
pkgdeps=(
)
pkgsrcs=(
    "https://www.kernel.org/pub/$_pkgname/kernel/v6.x/$_pkgname-$pkgver.tar.xz"
)

# build scripts
pkgprepare() {
    cd $_pkgname-$pkgver
}

pkgbuild() {
    make ARCH=arm64 headers
}

pkginstall() {
    make ARCH=arm64 INSTALL_HDR_PATH="$pkgroot/usr" headers_install
}
