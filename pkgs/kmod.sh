#!/bin/sh

# metadata
pkgname="kmod"
pkgver="34.2"
pkgdesc="linux kernel module management tools"
pkgurl="https://git.kernel.org/pub/scm/utils/kernel/kmod/kmod.git"
pkglic="GPLv2"

# build information
pkgdeps=(
    "linux-headers-6.16.9"
    "musl-1.2.5"
    "zlib-1.3.1"
    "xz-5.8.1"
    "zstd-1.5.7"
    "openssl-3.6.0"
)
pkgsrcs=(
    "https://github.com/$pkgname-project/$pkgname/archive/refs/tags/v$pkgver.tar.gz"
)

# build scripts
pkgprepare() {
    cd $pkgname-$pkgver

    ./autogen.sh
    ./configure \
        --prefix=/usr \
        --host=aarch64-dog-linux-musl \
        --disable-dependency-tracking \
        --disable-static \
        --disable-manpages \
        --enable-year2038 \
        --with-zstd \
        --with-xz \
        --with-zlib \
        --with-openssl \
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
        "$pkgroot/usr/share/pkgconfig" \
        "$pkgroot/usr/share/zsh" \
        "$pkgroot/usr/share/fish" \
        "$pkgroot/usr/share/bash-completion" \
        "$pkgroot/usr/lib/pkgconfig" \
        "$pkgroot/usr/lib/libkmod.la"
}
