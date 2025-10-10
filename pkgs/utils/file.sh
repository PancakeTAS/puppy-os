#!/usr/bin/env bash

pkgname="file"
pkgver="5.46"
pkgsrcs=(
    "https://github.com/file/file/archive/refs/tags/FILE5_46.tar.gz"
)

pkgprepare() {
    cd $pkgname-FILE5_46

    autoreconf -fiv
    ./configure \
        --prefix=/usr \
        --sbindir=/usr/bin \
        --libexecdir=/usr/lib \
        --host=aarch64-dog-linux-musl \
        --disable-dependency-tracking \
        --disable-static \
        --enable-zlib \
        --enable-bzlib \
        --enable-xzlib \
        --enable-zstdlib \
        --with-sysroot="$sysroot" \
        CC=clang LD=ld.lld \
        CFLAGS="-O3" LDFLAGS="-flto" \
        AR=llvm-ar RANLIB=llvm-ranlib STRIP=llvm-strip OBJDUMP=llvm-objdump DLLTOOL=llvm-dlltool MANIFEST_TOOL=llvm-mt NM=llvm-nm
}

pkgbuild() {
    make FILE_COMPILE="file --no-sandbox"
}

pkginstall() {
    make DESTDIR="$pkgdir" install-strip
}
