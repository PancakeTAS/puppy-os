#!/usr/bin/env bash

pkgname="procps-ng"
_pkgname="procps"
pkgver="4.0.6"
pkgsrcs=(
    "https://gitlab.com/$pkgname/$_pkgname/-/archive/v$pkgver/$_pkgname-v$pkgver.tar.gz"
)

pkgprepare() {
    cd $_pkgname-v$pkgver

    sed -i 's/AC_FUNC_MALLOC//' configure.ac
    sed -i 's/AC_FUNC_REALLOC//' configure.ac

    ./autogen.sh
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
        --disable-nls \
        --disable-static \
        --disable-rpath \
        --enable-watch8bit \
        --enable-year2038 \
        --with-sysroot=/puppyos/target/rootfs \
        CC=clang LD=ld.lld \
        CFLAGS="-O3" LDFLAGS="-flto" \
        AR=llvm-ar RANLIB=llvm-ranlib STRIP=llvm-strip OBJDUMP=llvm-objdump DLLTOOL=llvm-dlltool MANIFEST_TOOL=llvm-mt NM=llvm-nm
}

pkgbuild() {
    make
}

pkginstall() {
    make DESTDIR=$pkgdir install-strip
}
