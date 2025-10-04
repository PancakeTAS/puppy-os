#!/bin/sh

# metadata
pkgname="ncurses"
pkgver="6.5"
pkgdesc="SysV R4.0 curses emulation library"
pkgurl="https://invisible-island.net/ncurses/ncurses.html"
pkglic="MIT"

# build information
pkgdeps=(
    "compiler-rt-21.1.2"
    "libcxx-21.1.2"
    "linux-6.16.9"
    "musl-1.2.5"
)
pkgsrcs=(
    "https://invisible-island.net/archives/$pkgname/$pkgname-6.5.tar.gz"
)

# build scripts
pkgprepare() {
    cd $pkgname-$pkgver

    ./configure \
        --prefix=/usr \
        --host=aarch64-dog-linux-musl \
        --without-ada \
        --without-manpages \
        --without-tests \
        --without-pkg-config \
        --with-shared \
        --without-debug \
        --without-normal \
        --enable-widec \
        --disable-root-access \
        --disable-root-environ \
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
    make install DESTDIR="$pkgroot"

    llvm-strip --strip-unneeded \
        "$pkgroot/usr/lib/libformw.so.6.5" \
        "$pkgroot/usr/lib/libmenuw.so.6.5" \
        "$pkgroot/usr/lib/libncursesw.so.6.5" \
        "$pkgroot/usr/lib/libpanelw.so.6.5"
}
