#!/usr/bin/env bash

pkgname="u-boot"
pkgver="v2025.04"
_pkgver="397b49fb00377705b990f9623fa76737394825a4"
pkgsrcs=(
    "https://github.com/frank-w/$pkgname/archive/$_pkgver/$pkgname.tar.gz"
)

pkgprepare() {
    cd $pkgname-$_pkgver

    sed -i 's/$(CROSS_COMPILE)readelf/llvm-readelf/' Makefile

    cp "$filesdir/config.txt" .config
    cp "$filesdir/env.txt" uEnv_r4.txt
}

pkgbuild() {
    ARCH=arm64 make u-boot.bin \
        HOSTCC=/bin/clang \
        CC=clang LD=ld.lld AS=llvm-as \
        CROSS_COMPILE=aarch64-linux-gnu- \
        AR=llvm-ar NM=llvm-nm STRIP=llvm-strip \
        OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump \
        UBOOTRELEASE="v2025.04"
}

pkginstall() {
    mkdir -p "$pkgdir/_tmp"

    cp u-boot.bin \
        "$pkgdir/_tmp"
}
