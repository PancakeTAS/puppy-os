#!/usr/bin/env bash

pkgname="linux"
_pkgname="BPI-Router-Linux"
pkgver="6.17"
_pkgver=7cd33ba5a1a51ae9ef7393613e9d079082765a0d
pkgsrcs=(
    "https://github.com/frank-w/$_pkgname/archive/$_pkgver/$pkgname-$pkgver.tar.gz"
    "https://gitlab.com/kernel-firmware/linux-firmware/-/archive/20250917/linux-firmware-20250917.tar.gz"
)

pkgprepare() {
    cd $_pkgname-$_pkgver

    # setup kernel embedded firmware directory
    mkdir -p firmware/mediatek/
    cp -r "../linux-firmware-20250917/mediatek/mt7996" \
        firmware/mediatek/mt7996

    # apply dts override
    cat "$filesdir/dts_override.txt" >> arch/arm64/boot/dts/mediatek/mt7988a-bananapi-bpi-r4.dts

    # write kconfig
    cp "$filesdir/config.txt" .config
    make HOSTCC=/bin/clang \
        LLVM=1 ARCH=arm64 olddefconfig
}

pkgbuild() {
    make HOSTCC=/bin/clang \
        LLVM=1 ARCH=arm64 \
        Image dtbs modules
}

pkginstall() {
    mkdir -p "$pkgdir/boot"

    # install kernel modules
    make HOSTCC=/bin/clang \
        LLVM=1 ARCH=arm64 \
        INSTALL_MOD_PATH="$pkgdir/usr" \
        INSTALL_MOD_STRIP=1 \
        modules_install

    find "$pkgdir/usr/lib/modules" -type f -name build -delete

    # install kernel image
    cp arch/arm64/boot/Image \
        "$pkgdir/boot/$pkgname-$pkgver.Image"

    # apply dtb overlay
    fdtoverlay -i arch/arm64/boot/dts/mediatek/mt7988a-bananapi-bpi-r4.dtb \
        arch/arm64/boot/dts/mediatek/mt7988a-bananapi-bpi-r4-sd.dtbo \
        -o "$pkgdir/boot/$pkgname-$pkgver.mt7988a-bananapi-bpi-r4.dtb"
}
