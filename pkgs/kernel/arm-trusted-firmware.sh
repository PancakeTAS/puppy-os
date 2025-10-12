#!/usr/bin/env bash

pkgname="arm-trusted-firmware"
pkgver="2.13"
_pkgver="78a0dfd927bb00ce973a1f8eb4079df0f755887a"
pkgsrcs=(
    "https://github.com/mtk-openwrt/$pkgname/archive/$_pkgver/$pkgver.tar.gz"
)

pkgprepare() {
    cd $pkgname-$_pkgver
}

pkgbuild() {
    make all \
        ARCH=aarch64 PLAT=mt7988 \
        CROSS_COMPILE= \
        CC=clang CXX=clang++ LD=ld.lld AR=llvm-ar NM=llvm-nm STRIP=llvm-strip OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump \
        CFLAGS=-Wno-error ENABLE_LTO=1 \
        BUILD_STRING='awruff~' \
        BOOT_DEVICE=sdmmc \
        DRAM_USE_COMB=1

    make fiptool \
        HOSTCC=/bin/clang
}

pkginstall() {
    mkdir -p "$pkgdir/tools"

    cp build/mt7988/release/bl31.bin tools/fiptool/fiptool \
        "$pkgdir/tools"
    cp build/mt7988/release/bl2.img \
        "$pkgdir"
}
