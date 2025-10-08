#!/bin/sh

# metadata
pkgname="arm-trusted-firmware"
pkgver="2.13"
_pkgver="78a0dfd927bb00ce973a1f8eb4079df0f755887a"
pkgdesc="secure bootloader"
pkgurl="https://www.trustedfirmware.org/"
pkglic="BSD"

# build information
pkgdeps=(
)
pkgsrcs=(
    "https://github.com/mtk-openwrt/$pkgname/archive/$_pkgver/$pkgver.tar.gz"
)

# build scripts
pkgprepare() {
    cd $pkgname-$_pkgver
}

pkgbuild() {
    make all \
        ARCH=aarch64 PLAT=mt7988 \
        CROSS_COMPILE= CC=clang LD=ld.lld \
        CFLAGS=-w ENABLE_LTO=1 \
        BUILD_STRING='awruff~' \
        BOOT_DEVICE=sdmmc \
        DRAM_USE_COMB=1

    make fiptool \
        HOSTCC=/bin/clang
}

pkginstall() {
    cp -v \
        build/mt7988/release/bl2.img \
        build/mt7988/release/bl31.bin \
        "$pkgroot"
    cp -v \
        tools/fiptool/fiptool \
        "$pkgroot"
}
