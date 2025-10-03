#!/bin/sh

# metadata
pkgname="dash"
pkgver="0.5.13"
pkgrel=1
pkgdesc="POSIX compliant shell"
pkgurl="http://gondor.apana.org.au/~herbert/dash/"
pkglic="BSD"

# build information
pkgdeps=(
    "compiler-rt-21.1.2"
    "linux-6.16.9"
    "musl-1.2.5"
)
pkgsrcs=(
    "http://gondor.apana.org.au/~herbert/$pkgname/files/$pkgname-$pkgver.tar.gz"
)

# build scripts
pkgprepare() {
    cd $pkgname-$pkgver

    ./configure \
        --prefix=/usr \
        --host=aarch64-dog-linux-musl \
        --disable-dependency-tracking \
        CC=clang \
        CFLAGS="-O3" LDFLAGS="-flto"
}

pkgbuild() {
    cd $pkgname-$pkgver

    make
}

pkginstall() {
    cd $pkgname-$pkgver

    DESTDIR="$pkgroot" make install

    llvm-strip --strip-unneeded "$pkgroot/usr/bin/dash"
    ln -sfv dash "$pkgroot/usr/bin/sh"
    rm -rfv "$pkgroot/usr/share"
}
