#!/usr/bin/env bash

pkgname="libssh2"
pkgver="1.11.1"
pkgsrcs=(
    "https://libssh2.org/download/$pkgname-$pkgver.tar.xz"
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
        --host=x86_64-dog-linux-musl \
        --disable-static \
        --disable-rpath \
        --disable-debug \
        --enable-year2038 \
        --with-libz \
        --with-crypto=openssl \
        --with-libssl-prefix=/puppyos/target/rootfs/usr \
        --with-libz-prefix=/puppyos/target/rootfs/usr \
        --with-sysroot=/puppyos/target/rootfs \
        LIBSSL=ssl \
        CC=clang LD=ld.lld \
        CFLAGS="-O3" LDFLAGS="-flto" \
        AR=llvm-ar RANLIB=llvm-ranlib STRIP=llvm-strip OBJDUMP=llvm-objdump MANIFEST_TOOL=llvm-mt NM=llvm-nm
}

pkgbuild() {
    make
}

pkginstall() {
    make DESTDIR=$pkgdir install-strip
}
