#!/usr/bin/env bash

pkgname="xfsprogs"
pkgver="6.17.0"
pkgsrcs=(
    "https://git.kernel.org/pub/scm/fs/xfs/$pkgname-dev.git/snapshot/$pkgname-dev-$pkgver.tar.gz"
)

pkgprepare() {
    cd ${pkgname}-dev-${pkgver}

    make configure
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
        --enable-cxx-stdlib \
        --enable-gettext=no \
        --enable-lto=yes \
        --enable-libicu=no \
        --with-sysroot=/puppyos/target/rootfs \
        CC=clang LD=ld.lld \
        CFLAGS="-O3" LDFLAGS="-flto" \
        AR=llvm-ar RANLIB=llvm-ranlib STRIP=llvm-strip OBJDUMP=llvm-objdump DLLTOOL=llvm-dlltool MANIFEST_TOOL=llvm-mt NM=llvm-nm
}

pkgbuild() {
    make
}

pkginstall() {
    make PKG_USER=root PKG_GROUP=root \
        DIST_ROOT="${pkgdir}" DESTDIR=$pkgdir \
        PKG_SBIN_DIR="/usr/bin" \
        install install-dev
}
