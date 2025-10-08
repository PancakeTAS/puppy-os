#!/bin/sh

# metadata
pkgname="musl"
pkgver="1.2.5"
pkgdesc="implementation of the C standard library"
pkgurl="https://musl.libc.org"
pkglic="MIT"

# build information
pkgdeps=(
    "linux-headers-6.17"
)
pkgsrcs=(
    "https://musl.libc.org/releases/$pkgname-$pkgver.tar.gz"
)

# build scripts
pkgprepare() {
    mkdir -p $pkgname-$pkgver/build
    cd $pkgname-$pkgver/build

    LIBCC_PATH=$(echo "$PATH" | cut -d':' -f1)
    LIBCC_PATH=$(dirname "$LIBCC_PATH")

    ../configure \
        --prefix=/usr \
        --target=aarch64-dog-linux-musl \
        --disable-wrapper \
        --disable-static \
        CROSS_COMPILE= CC=clang \
        CFLAGS="-O3" \
        AR=llvm-ar \
        LIBCC="$LIBCC_PATH/lib/clang/21/lib/linux/libclang_rt.builtins-aarch64.a"
}

pkgbuild() {
    make
}

pkginstall() {
    DESTDIR="$pkgroot" make install
}
