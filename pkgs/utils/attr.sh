#!/bin/sh

# metadata
pkgname="attr"
pkgver="2.5.2"
pkgdesc="extended attribute support library"
pkgurl="https://savannah.nongnu.org/projects/attr"
pkglic="LGPLv2"

# build information
pkgdeps=(
    "compiler-rt-21.1.2"
    "musl-1.2.5"
)
pkgsrcs=(
    "http://download.savannah.nongnu.org/releases/$pkgname/$pkgname-$pkgver.tar.xz"
)

# build scripts
pkgprepare() {
    cd $pkgname-$pkgver

    sed 's/#include <locale.h>/#include <locale.h>\n#include <libgen.h>/' \
        -i tools/attr.c

    ./configure \
        --prefix=/usr \
        --sysconfdir=/etc \
        --host=aarch64-dog-linux-musl \
        --disable-dependency-tracking \
        --disable-static \
        --disable-nls \
        --disable-rpath \
        --with-sysroot="$buildroot" \
        CC=clang LD=ld.lld \
        CFLAGS="-O3" LDFLAGS="-flto" \
        AR=llvm-ar RANLIB=llvm-ranlib STRIP=llvm-strip OBJDUMP=llvm-objdump DLLTOOL=llvm-dlltool MANIFEST_TOOL=llvm-mt NM=llvm-nm
}

pkgbuild() {
    make
}

pkginstall() {
    make install-strip DESTDIR="$pkgroot"

    rm -rf \
        "$pkgroot/usr/share/doc" \
        "$pkgroot/usr/share/man" \
        "$pkgroot/usr/lib/pkgconfig" \
        "$pkgroot/usr/lib/libattr.la"
}
