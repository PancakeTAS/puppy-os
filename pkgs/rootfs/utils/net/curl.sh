#!/usr/bin/env bash

pkgname="curl"
pkgver="8.16.0"
pkgsrcs=(
    "https://github.com/$pkgname/$pkgname/releases/download/$pkgname-8_16_0/$pkgname-$pkgver.tar.xz"
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
        --disable-debug \
        --enable-optimize \
        --disable-static \
        --with-openssl \
        --with-openssl-quic \
        --with-libssh2 \
        --disable-docs \
        --with-sysroot="$sysroot" \
        CC=clang CXX=clang++ LD=ld.lld \
        CFLAGS="-O3" LDFLAGS="-flto" \
        AR=llvm-ar RANLIB=llvm-ranlib STRIP=llvm-strip OBJDUMP=llvm-objdump MANIFEST_TOOL=llvm-mt NM=llvm-nm
}

pkgbuild() {
    make
}

pkginstall() {
    make DESTDIR="$pkgdir" install-strip

    rm -r "$pkgdir"/usr/share/aclocal
}
