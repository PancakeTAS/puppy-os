#!/usr/bin/env bash

pkgname="musl"
pkgver="1.2.5"
pkgsrcs=(
    "https://musl.libc.org/releases/$pkgname-$pkgver.tar.gz"
)

pkgprepare() {
    mkdir -p $pkgname-$pkgver/build
    cd ${pkgname}-${pkgver}/build

    ../configure \
        --prefix=/usr \
        --exec-prefix=/usr \
        --bindir=/usr/bin \
        --libdir=/usr/lib \
        --includedir=/usr/include \
        --syslibdir=/usr/lib \
        --target=aarch64-dog-linux-musl \
        --disable-wrapper \
        --disable-static \
        CROSS_COMPILE= CC=clang \
        CFLAGS="-O3" \
        AR=llvm-ar RANLIB=llvm-ranlib \
        LIBCC=/toolchain/lib/clang/21/lib/linux/libclang_rt.builtins-aarch64.a
}

pkgbuild() {
    make
}

pkginstall() {
    DESTDIR=$pkgdir make install
}
