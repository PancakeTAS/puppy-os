#!/bin/sh

# metadata
pkgname="runit"
pkgver="2.2.0"
pkgdesc="cross-platform unix init scheme with service supervision"
pkgurl="http://gondor.apana.org.au/~herbert/dash/"
pkglic="BSD"

# build information
pkgdeps=(
    "linux-headers-6.17"
    "musl-1.2.5"
)
pkgsrcs=(
    "https://smarden.org/$pkgname/$pkgname-$pkgver.tar.gz"
)

# build scripts
pkgprepare() {
    cd admin/$pkgname-$pkgver

    sed -i 's/-static//g' src/Makefile

    echo "clang -O3" > src/conf-cc
    echo "clang -flto -s" > src/conf-ld
}

pkgbuild() {
    ./package/compile
}

pkginstall() {
    mkdir -p "$pkgroot/usr"
    mv command "$pkgroot/usr/bin"
}
