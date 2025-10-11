#!/usr/bin/env bash

pkgname="psmisc"
pkgver="23.7"
pkgsrcs=(
    "https://gitlab.com/$pkgname/$pkgname/-/archive/v$pkgver/$pkgname-v$pkgver.tar.gz"
)

pkgprepare() {
    cd $pkgname-v$pkgver

    sed -i 's/AC_FUNC_MALLOC//' configure.ac
    sed -i 's/AC_FUNC_REALLOC//' configure.ac

    ./autogen.sh
    ./configure \
        --prefix=/usr \
        --sbindir=/usr/bin \
        --libexecdir=/usr/lib \
        --host=aarch64-dog-linux-musl \
        --disable-dependency-tracking \
        --disable-nls \
        --disable-rpath \
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
