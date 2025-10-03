#!/bin/sh

# metadata
pkgname="linux"
pkgver="6.16.9"
pkgdesc="The Linux kernel"
pkgurl="https://kernel.org/"
pkglic="GPL-2.0-only"

# build information
pkgdeps=(
)
pkgsrcs=(
    "https://www.kernel.org/pub/$pkgname/kernel/v6.x/$pkgname-$pkgver.tar.xz"
)

# build scripts
pkgprepare() {
    cd $pkgname-$pkgver
}

pkgbuild() {
    make ARCH=arm64 headers
}

pkginstall() {
    make ARCH=arm64 INSTALL_HDR_PATH="$pkgroot/usr" headers_install
}

# TODO: kernel, modules, etc.
