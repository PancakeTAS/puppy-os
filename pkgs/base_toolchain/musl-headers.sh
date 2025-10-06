#!/bin/sh

# metadata
pkgname="musl-headers"
_pkgname="musl"
pkgver="1.2.5"
pkgdesc="headers of musl standard library"
pkgurl="https://musl.libc.org"
pkglic="MIT"

# build information
pkgdeps=(
    "linux-headers-6.16.9"
)
pkgsrcs=(
    "https://musl.libc.org/releases/$_pkgname-$pkgver.tar.gz"
)

# build scripts
pkgprepare() {
    mkdir -p $_pkgname-$pkgver/build
    cd $_pkgname-$pkgver/build

    ../configure \
        --prefix=/usr \
        --target=aarch64-dog-linux-musl \
        CROSS_COMPILE= CC=clang
}

pkgbuild() {
    echo "nothing to build"
}

pkginstall() {
    DESTDIR="$pkgroot" make install-headers
}
