#!/usr/bin/env bash

pkgname="brotli"
pkgver="1.1.0"
pkgsrcs=(
    "https://github.com/google/$pkgname/archive/refs/tags/v$pkgver.tar.gz"
)

pkgprepare() {
    cd ${pkgname}-${pkgver}

    cmake -S . -B build -G Ninja \
        -DCMAKE_INSTALL_PREFIX=$pkgdir/usr \
        -DCMAKE_INSTALL_LOCALSTATEDIR="var" \
        -DCMAKE_INSTALL_DATAROOTDIR="share" \
        -DCMAKE_INSTALL_RUNSTATEDIR="run" \
        -DCMAKE_INSTALL_SYSCONFDIR="etc" \
        -DCMAKE_INSTALL_LIBEXECDIR="lib" \
        -DCMAKE_INSTALL_DATADIR="share" \
        -DCMAKE_INSTALL_SBINDIR="bin" \
        -DCMAKE_INSTALL_LIBDIR="lib" \
        -DCMAKE_INSTALL_LOCALEDIR="share/locale" \
        -DCMAKE_INSTALL_INFODIR="share/info" \
        -DCMAKE_INSTALL_MANDIR="share/man" \
        -DCMAKE_INSTALL_DOCDIR="share/doc" \
        -DCMAKE_SYSROOT=/puppyos/target/rootfs \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=On \
        -DCMAKE_C_COMPILER=clang \
        -DCMAKE_C_COMPILER_TARGET="x86_64-dog-linux-musl"
}

pkgbuild() {
    cmake --build build
}

pkginstall() {
    cmake --install build --strip
}
