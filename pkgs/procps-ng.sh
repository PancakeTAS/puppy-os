#!/bin/sh

# metadata
pkgname="procps-ng"
_pkgname="procps"
pkgver="4.0.5"
pkgdesc="utilities for system monitoring and proces management"
pkgurl="https://gitlab.com/procps-ng/procps"
pkglic="GPLv2"

# build information
pkgdeps=(
    "linux-headers-6.16.9"
    "libcxx-21.1.2"
    "musl-1.2.5"
    "ncurses-6.5"
)
pkgsrcs=(
    "https://gitlab.com/$pkgname/$_pkgname/-/archive/v$pkgver/$_pkgname-v$pkgver.tar.gz"
)

# build scripts
pkgprepare() {
    cd $_pkgname-v$pkgver

    sed -i 's/AC_FUNC_MALLOC//' configure.ac
    sed -i 's/AC_FUNC_REALLOC//' configure.ac

    ./autogen.sh
    ./configure \
        --prefix=/usr \
        --host=aarch64-dog-linux-musl \
        --disable-dependency-tracking \
        --disable-nls \
        --disable-static \
        --disable-rpath \
        --enable-watch8bit \
        --enable-year2038 \
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

    rm -rv \
        "$pkgroot/usr/share" \
        "$pkgroot/usr/lib/pkgconfig" \
        "$pkgroot/usr/lib/libproc2.la"
}
