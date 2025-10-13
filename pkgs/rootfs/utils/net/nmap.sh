#!/usr/bin/env bash

pkgname="nmap"
pkgver="7.98"
pkgsrcs=(
    "https://nmap.org/dist/$pkgname-$pkgver.tar.bz2"
)

pkgprepare() {
    cd $pkgname-$pkgver

    sed -e '/strlcat/d' -i libdnet-stripped/acconfig.h
    sed -i 's/strip;/llvm-strip;/' configure
    sed -i 's/strip;/llvm-strip;/' ncat/configure
    sed -i 's/strip;/llvm-strip;/' nping/configure

    ./configure \
        --prefix=/usr \
        --bindir=/usr/bin \
        --sbindir=/usr/bin \
        --libexecdir=/usr/lib \
        --sysconfdir=/etc \
        --sharedstatedir=/var/lib \
        --localstatedir=/var \
        --libdir=/usr/lib \
        --includedir=/usr/include \
        --datarootdir=/usr/share \
        --host=aarch64-dog-linux-musl \
        --disable-doc \
        --disable-nls \
        --disable-rpath \
        --without-ndiff \
        --without-zenmap \
        --with-libpcre=included \
        --with-libdnet=included \
        --without-liblua \
        --with-liblinear=included \
        --enable-year2038 \
        --with-sysroot="$sysroot" \
        CC=clang CXX=clang++ LD=ld.lld \
        CFLAGS="-O3" LDFLAGS="-flto" \
        AR=llvm-ar RANLIB=llvm-ranlib OBJDUMP=llvm-objdump MANIFEST_TOOL=llvm-mt NM=llvm-nm
}

pkgbuild() {
    make
}

pkginstall() {
    make DESTDIR="$pkgdir" install
}
