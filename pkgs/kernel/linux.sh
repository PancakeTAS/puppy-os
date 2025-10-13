#!/usr/bin/env bash

pkgname="linux"
_pkgname="BPI-Router-Linux"
pkgver="6.17"
_pkgver=7cd33ba5a1a51ae9ef7393613e9d079082765a0d
pkgsrcs=(
    "https://github.com/frank-w/$_pkgname/archive/$_pkgver/$pkgname-$pkgver.tar.gz"
    "https://gitlab.com/kernel-firmware/$pkgname-firmware/-/archive/20250917/$pkgname-firmware-20250917.tar.gz"
    "https://mirrors.edge.kernel.org/pub/software/network/wireless-regdb/wireless-regdb-2025.10.07.tar.xz"
)

pkgprepare() {
    cd $_pkgname-$_pkgver

    # setup kernel embedded firmware directory
    mkdir -p firmware/mediatek/
    cp -r "../linux-firmware-20250917/mediatek/mt7996" \
        firmware/mediatek/mt7996

    # install wireless regulatory database
    cp ../wireless-regdb-2025.10.07/regulatory.db{,.p7s} \
        firmware/

    # apply dts override
    cat "$rscdir/mt7988a-bananapi-bpi-r4.dts.suffix" >> \
        arch/arm64/boot/dts/mediatek/mt7988a-bananapi-bpi-r4.dts

    # write kconfig
    cp "$rscdir/.config" .config
    make HOSTCC=/bin/clang \
        LLVM=1 ARCH=arm64 olddefconfig
}

pkgbuild() {
    make HOSTCC=/bin/clang \
        LLVM=1 ARCH=arm64 \
        Image dtbs modules
}

pkginstall() {
    mkdir -p "$pkgdir"/{kernel,rootfs}

    # install kernel modules
    make HOSTCC=/bin/clang \
        LLVM=1 ARCH=arm64 \
        INSTALL_MOD_PATH="$pkgdir/rootfs/usr" \
        INSTALL_MOD_STRIP=1 \
        modules_install

    find "$pkgdir/rootfs/usr/lib/modules" -name build -delete

    # install kernel image
    cp arch/arm64/boot/Image \
        "$pkgdir/kernel/$pkgname-$pkgver.Image"

    # apply dtb overlay
    fdtoverlay -i arch/arm64/boot/dts/mediatek/mt7988a-bananapi-bpi-r4.dtb \
        arch/arm64/boot/dts/mediatek/mt7988a-bananapi-bpi-r4-sd.dtbo \
        -o "$pkgdir/kernel/$pkgname-$pkgver.mt7988a-bananapi-bpi-r4.dtb"
}
