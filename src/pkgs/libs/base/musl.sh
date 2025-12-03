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
        --target=x86_64-dog-linux-musl \
        --disable-wrapper \
        --disable-static \
        CROSS_COMPILE= CC=clang \
        CFLAGS="-O3" \
        AR=llvm-ar RANLIB=llvm-ranlib \
        LIBCC=/toolchain/lib/clang/21/lib/linux/libclang_rt.builtins-x86_64.a
}

pkgbuild() {
    make
}

pkginstall() {
    DESTDIR=$pkgdir make install
}
