#!/bin/sh

# metadata
pkgname="libnftnl"
pkgver="1.3.0"
pkgdesc="netfilter library interfacing with nf_tables"
pkgurl="https://netfilter.org/projects/libnftnl/"
pkglic="GPLv2"

# build information
pkgdeps=(
    "linux-headers-6.17"
    "musl-1.2.5"
    "libmnl-1.0.5"
)
pkgsrcs=(
    "https://www.netfilter.org/pub/$pkgname/$pkgname-$pkgver.tar.xz"
)

# build scripts
pkgprepare() {
    cd $pkgname-$pkgver

    ./configure \
        --prefix=/usr \
        --host=aarch64-dog-linux-musl \
        --disable-dependency-tracking \
        --disable-static \
        --with-sysroot="$buildroot" \
        CC=clang LD=ld.lld \
        CFLAGS="-O3 -I\"$buildroot/usr/include\" -w" LDFLAGS="-flto -L\"$buildroot/usr/lib\"" \
        AR=llvm-ar RANLIB=llvm-ranlib STRIP=llvm-strip OBJDUMP=llvm-objdump DLLTOOL=llvm-dlltool MANIFEST_TOOL=llvm-mt NM=llvm-nm
}

pkgbuild() {
    make
}

pkginstall() {
    make install-strip DESTDIR="$pkgroot"

    rm -rf \
        "$pkgroot/usr/lib/pkgconfig" \
        "$pkgroot/usr/lib/libnftnl.la"
}
