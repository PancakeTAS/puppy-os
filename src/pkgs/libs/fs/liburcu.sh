#!/usr/bin/env bash

pkgname="liburcu"
pkgver="0.15.5"
pkgsrcs=(
    "https://lttng.org/files/urcu/userspace-rcu-$pkgver.tar.bz2"
)

pkgprepare() {
    cd userspace-rcu-${pkgver}

    sed -i 's/ld-linux/ld-musl/g' \
        extras/abi/*/x86_64-pc-linux-gnu/*

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
        --host=x86_64-dog-linux-musl \
        --disable-dependency-tracking \
        --disable-shared \
        --enable-static \
        --with-sysroot=/puppyos/target/rootfs \
        CC=clang CXX=clang++ LD=ld.lld LD_CXX=ld.lld \
        CFLAGS="-O3 -Wl,-dynamic-linker=/usr/lib/ld-musl-x86_64.so.1" LDFLAGS="-flto" \
        AR=llvm-ar RANLIB=llvm-ranlib STRIP=llvm-strip OBJDUMP=llvm-objdump DLLTOOL=llvm-dlltool MANIFEST_TOOL=llvm-mt NM=llvm-nm
}

pkgbuild() {
    make V=1
}

pkginstall() {
    make DESTDIR=$pkgdir install-strip
}
