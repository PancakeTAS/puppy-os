#!/usr/bin/env bash

pkgname="linux"
pkgver="6.18"
pkgsrcs=(
    "https://cdn.kernel.org/pub/$pkgname/kernel/v6.x/$pkgname-$pkgver.tar.xz"
    "https://gitlab.com/kernel-firmware/$pkgname-firmware/-/archive/20251125/$pkgname-firmware-20251125.tar.gz"
)

pkgprepare() {
    cd $pkgname-$pkgver

    # setup kernel embedded firmware directory
    mkdir -p firmware/rtl_nic/
    cp -r ../linux-firmware-20251125/rtl_nic/rtl8168h-2.fw \
        firmware/rtl_nic/rtl8168h-2.fw

    # write kconfig
    cp $rscdir/.config .config
    make HOSTCC=/usr/bin/clang \
        LLVM=1 olddefconfig
}

pkgbuild() {
    make HOSTCC=/usr/bin/clang \
        LLVM=1 \
        bzImage
}

pkginstall() {
    cp arch/x86/boot/bzImage \
        $pkgdir/${pkgname}-${pkgver}.bzImage
}
