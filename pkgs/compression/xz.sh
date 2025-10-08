#!/bin/sh

# metadata
pkgname="xz"
pkgver="5.8.1"
pkgdesc="command line tools for XZ and LZMA compressed files"
pkgurl="https://tukaani.org/xz/"
pkglic="BSD"

# build information
pkgdeps=(
    "linux-headers-6.17"
    "musl-1.2.5"
)
pkgsrcs=(
    "https://github.com/tukaani-project/$pkgname/releases/download/v$pkgver/$pkgname-$pkgver.tar.xz"
)

# build scripts
pkgprepare() {
    cd $pkgname-$pkgver

    ./configure \
        --prefix=/usr \
        --host=aarch64-dog-linux-musl \
        --disable-doc \
        --disable-static \
        --disable-nls \
        --disable-rpath \
        --enable-year2038 \
        --with-sysroot="$buildroot" \
        CC=clang LD=ld.lld \
        CFLAGS="-O3" LDFLAGS="-flto" \
        AR=llvm-ar RANLIB=llvm-ranlib STRIP=llvm-strip OBJDUMP=llvm-objdump MANIFEST_TOOL=llvm-mt NM=llvm-nm
}

pkgbuild() {
    make
}

pkginstall() {
    make install-strip DESTDIR="$pkgroot"

    rm -rf \
        "$pkgroot/usr/share" \
        "$pkgroot/usr/lib/pkgconfig"
        "$pkgroot/usr/lib/liblzma.la"
}
