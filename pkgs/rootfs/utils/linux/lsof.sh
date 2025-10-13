#!/usr/bin/env bash

pkgname="lsof"
pkgver="4.99.5"
pkgsrcs=(
    "https://github.com/lsof-org/$pkgname/releases/download/$pkgver/$pkgname-$pkgver.tar.gz"
)

pkgprepare() {
    cd $pkgname-$pkgver

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
        --enable-year2038 \
        --without-libtirpc \
        --without-selinux \
        --with-sysroot="$sysroot" \
        CC=clang CXX=clang++ LD=ld.lld \
        CFLAGS="-O3" LDFLAGS="-flto" \
        AR=llvm-ar RANLIB=llvm-ranlib STRIP=llvm-strip OBJDUMP=llvm-objdump DLLTOOL=llvm-dlltool MANIFEST_TOOL=llvm-mt NM=llvm-nm
}

pkgbuild() {
    make
}

pkginstall() {
    make DESTDIR="$pkgdir" install-strip
}
