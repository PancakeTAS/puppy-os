#!/bin/sh

# metadata
pkgname="u-boot"
pkgver="v2025.04"
_pkgver="397b49fb00377705b990f9623fa76737394825a4"
pkgdesc="universal bootloader"
pkgurl="https://u-boot.org/"
pkglic="GPLv2"

# build information
pkgdeps=(
)
pkgsrcs=(
    "https://github.com/frank-w/$pkgname/archive/$_pkgver/$pkgname.tar.gz"
)

# build scripts
UBOOTENV=$(cat <<'ENDOFUBOOTENV'
kernel_addr_r=0x46000000
fdt_addr_r=0x48000000

load_kernel=fatload mmc 0:3 ${kernel_addr_r} /linux-6.17.Image
load_fdt=fatload mmc 0:3 ${fdt_addr_r} /linux-6.17.mt7988a-bananapi-bpi-r4.dtb

console='console=ttyS0,115200n1 loglevel=8'
root='root=/dev/mmcblk0p4 rootwait rootfstype=ext4 ro'
set_args=setenv bootargs ${console} ${root}

bootdelay=0
bootcmd=run load_kernel; run load_fdt; run set_args; booti ${kernel_addr_r} - ${fdt_addr_r}

bootmenu_0=1. Boot Linux.=run bootcmd
bootmenu_default=0
ENDOFUBOOTENV
)

pkgprepare() {
    cd $pkgname-$_pkgver

    make mt7988a_bpir4_sd_defconfig

	sed -i 's/$(CROSS_COMPILE)readelf/llvm-readelf/' Makefile

	echo "$UBOOTENV" > ./uEnv_r4.txt
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
    cp -v \
        u-boot.bin \
        "$pkgroot"
}
