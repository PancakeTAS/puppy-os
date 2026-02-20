#!/usr/bin/env bash

pkgname="btop"
pkgver="1.4.6"
pkgsrcs=(
    "https://github.com/aristocratos/$pkgname/archive/refs/tags/v$pkgver.tar.gz"
)

pkgprepare() {
    cd ${pkgname}-${pkgver}

    cmake -S . -B build -G Ninja \
        -DCMAKE_INSTALL_PREFIX=$pkgdir/usr \
        -DCMAKE_SYSROOT=/puppyos/target/rootfs \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=On \
        -DCMAKE_CXX_COMPILER=clang++ \
        -DCMAKE_CXX_COMPILER_TARGET="aarch64-dog-linux-musl" \
        -DBUILD_TESTING=Off \
        -DBTOP_GPU=Off \
        -DBTOP_LTO=On
}

pkgbuild() {
    cmake --build build
}

pkginstall() {
    cmake --install build --strip

    rm -r $pkgdir/usr/share/{icons,applications}
}
