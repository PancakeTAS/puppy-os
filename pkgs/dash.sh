#!/bin/sh

# metadata
pkgname="dash"
pkgver="0.5.13"
pkgdesc="POSIX compliant shell"
pkgurl="http://gondor.apana.org.au/~herbert/dash/"
pkglic="BSD"

# build information
pkgdeps=(
    "linux-headers-6.16.9"
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
        CFLAGS="-O3" LDFLAGS="-flto" \
        STRIP=llvm-strip
}

pkgbuild() {
    make
}

pkginstall() {
    DESTDIR="$pkgroot" make install-strip

    ln -s dash "$pkgroot/usr/bin/sh"

    rm -rf \
        "$pkgroot/usr/share"
}
