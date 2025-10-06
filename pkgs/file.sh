#!/bin/sh

# metadata
pkgname="file"
pkgver="5.46"
pkgdesc="file type identification utility"
pkgurl="https://www.darwinsys.com/file/"
pkglic="file"

# build information
pkgdeps=(
    "linux-headers-6.16.9"
    "musl-1.2.5"
    "zlib-1.3.1"
    "bzip2-1.0.8"
    "xz-5.8.1"
    "zstd-1.5.7"
)
pkgsrcs=(
    "https://github.com/file/file/archive/refs/tags/FILE5_46.tar.gz"
)

# build scripts
pkgprepare() {
    cd $pkgname-FILE5_46

    autoreconf -fiv
    ./configure \
        --prefix=/usr \
        --host=aarch64-dog-linux-musl \
        --disable-dependency-tracking \
        --disable-static \
        --enable-zlib \
        --enable-bzlib \
        --enable-xzlib \
        --enable-zstdlib \
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
        "$pkgroot/usr/share" \
        "$pkgroot/usr/lib/pkgconfig" \
        "$pkgroot/usr/lib/libmagic.la"
}
