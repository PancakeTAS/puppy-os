#!/usr/bin/env bash

pkgname="libnftnl"
pkgver="1.3.1"
pkgsrcs=(
    "https://www.netfilter.org/pub/$pkgname/$pkgname-$pkgver.tar.xz"
)

pkgprepare() {
    cd ${pkgname}-${pkgver}

    ./configure \
        --prefix=/usr \
        --bindir=/usr/bin \
        --sbindir=/usr/bin \
        --libexecdir=/usr/lib \
        --sysconfdir=/etc \
        --sharedstatedir=/var/lib \
        --localstatedir=/var \
        --runstatedir=/run \
        --libdir=/usr/lib \
        --includedir=/usr/include \
        --datarootdir=/usr/share \
        --host=aarch64-dog-linux-musl \
        --disable-dependency-tracking \
        --disable-static \
        --with-sysroot=/puppyos/target/rootfs \
        CC=clang LD=ld.lld \
        CFLAGS="-O3 -I/puppyos/target/rootfs/usr/include -w" LDFLAGS="-flto -L/puppyos/target/rootfs/usr/lib" \
        AR=llvm-ar RANLIB=llvm-ranlib STRIP=llvm-strip OBJDUMP=llvm-objdump DLLTOOL=llvm-dlltool MANIFEST_TOOL=llvm-mt NM=llvm-nm
}

pkgbuild() {
    make
}

pkginstall() {
    make DESTDIR=$pkgdir install-strip
}
