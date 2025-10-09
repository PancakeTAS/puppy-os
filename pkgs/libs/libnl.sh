#!/bin/sh

# metadata
pkgname="libnl"
pkgver="3.11.0"
pkgdesc="library for dealing with netlink sockets"
pkgurl="https://github.com/thom311/libnl/"
pkglic="GPL"

# build information
pkgdeps=(
    "linux-headers-6.17"
    "musl-1.2.5"
)
pkgsrcs=(
    "https://github.com/thom311/$pkgname/releases/download/libnl3_11_0/$pkgname-$pkgver.tar.gz"
)

# build scripts
pkgprepare() {
    cd $pkgname-$pkgver

    autoreconf -vif
    ./configure \
        --prefix=/usr \
        --build=x86_64-dog-linux-musl \
        --host=aarch64-dog-linux-musl \
        --disable-dependency-tracking \
        --disable-static \
        --disable-debug \
        --with-sysroot="$buildroot" \
        CC=clang LD=ld.lld \
        CFLAGS="-O3" LDFLAGS="-flto" \
        AR=llvm-ar RANLIB=llvm-ranlib STRIP=llvm-strip OBJDUMP=llvm-objdump DLLTOOL=llvm-dlltool MANIFEST_TOOL=llvm-mt NM=llvm-nm
}

pkgbuild() {
    make
}

pkginstall() {
    make DESTDIR="$pkgroot" install-strip

    find "$pkgroot" -name '*.la' -delete

    rm -rf \
        "$pkgroot/usr/lib/pkgconfig" \
        "$pkgroot/usr/share/man"
}
