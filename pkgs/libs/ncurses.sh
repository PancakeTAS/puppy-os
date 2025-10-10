#!/usr/bin/env bash

pkgname="ncurses"
pkgver="6.5"
pkgsrcs=(
    "https://invisible-island.net/archives/$pkgname/$pkgname-6.5.tar.gz"
)

pkgprepare() {
    cd $pkgname-$pkgver

    ./configure \
        --prefix=/usr \
        --sbindir=/usr/bin \
        --libexecdir=/usr/lib \
        --host=aarch64-dog-linux-musl \
        --without-ada \
        --without-manpages \
        --without-tests \
        --without-pkg-config \
        --with-shared \
        --without-debug \
        --without-normal \
        --enable-widec \
        --with-strip-program=llvm-strip \
        CC=clang CXX=clang++ \
        CFLAGS="-O3" LDFLAGS="-flto" \
        AR=llvm-ar RANLIB=llvm-ranlib NM=llvm-nm \
        BUILD_CC=/bin/clang
}

pkgbuild() {
    make
}

pkginstall() {
    make DESTDIR="$pkgdir" install

}
