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
        --bindir=/usr/bin \
        --sbindir=/usr/bin \
        --libexecdir=/usr/lib \
        --sysconfdir=/etc \
        --sharedstatedir=/var/lib \
        --localstatedir=/var \
        --runstatedir=/run \
        --libdir=/usr/lib \
        --includedir=/usr/include \
        --datarootdir=/usr/share \
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

    for lib in ncurses form panel menu; do
        printf "INPUT(-l${lib}w)\n" > "$pkgdir"/usr/lib/lib${lib}.so
    done
    for lib in tic tinfo curses; do
        printf "INPUT(-lncursesw)\n" > "$pkgdir"/usr/lib/lib${lib}.so
    done
}
