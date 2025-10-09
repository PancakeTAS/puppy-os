#!/bin/sh

# metadata
pkgname="nftables"
pkgver="1.1.5"
pkgdesc="netfilter tables userspace tools"
pkgurl="https://netfilter.org/projects/nftables/"
pkglic="GPLv2"

# build information
pkgdeps=(
    "linux-headers-6.17"
    "libnftnl-1.3.0"
    "libmnl-1.0.5"
    "musl-1.2.5"
)
pkgsrcs=(
    "https://www.netfilter.org/pub/$pkgname/$pkgname-$pkgver.tar.xz"
)

# build scripts
pkgprepare() {
    cd $pkgname-$pkgver

    ./configure \
        --prefix=/usr \
        --sbindir=/usr/bin \
        --sysconfdir=/etc \
        --host=aarch64-dog-linux-musl \
        --disable-dependency-tracking \
        --disable-man-doc \
        --without-cli \
        --with-mini-gmp \
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
        "$pkgroot/usr/lib/pkgconfig" \
        "$pkgroot/usr/share" \
        "$pkgroot/etc" \
        "$pkgroot/usr/lib/libnftables.la"
}
