#!/bin/sh

# metadata
pkgname="puppy-os"
pkgver="1.0.0"
pkgdesc="awrruff!! :3"
pkgurl="https://breedable.pet/"
pkglic="GPLv2"

# build information
pkgdeps=(
    "arm-trusted-firmware-2.13"
    "u-boot-v2025.04"
    "linux-6.17"
    "libcxx-21.1.2"
    "musl-1.2.5"
    "brotli-1.1.0"
    "bzip2-1.0.8"
    "lz4-1.10.0"
    "xz-5.8.1"
    "zlib-1.3.1"
    "zstd-1.5.7"
    "libxcrypt-4.4.38"
    "openssl-3.6.0"
    "attr-2.5.2"
    "dash-0.5.13"
    "file-5.46"
    "kmod-34.2"
    "ncurses-6.5"
    "procps-ng-4.0.5"
    "toybox-0.8.12"
)
pkgsrcs=(
)

# build scripts
pkgprepare() {
    echo "awrruff,, puppy need not prepare :3"
}

pkgbuild() {
    mkdir mnt

    "$buildroot/fiptool" create \
        --soc-fw "$buildroot/bl31.bin" \
        --nt-fw "$buildroot/u-boot.bin" \
        "fip.bin"

    # (danger zone, beware of sudo and losetup)
    dd if=/dev/zero of=image.bin bs=1M count=96
    LDEV=$(sudo losetup -f --show image.bin)

    sudo sgdisk -o -a 1 \
        -n '1:1024:4095' -c '1:bl2' -t '1:ef02' -A '1:set:2' \
        -n '2:4096:8191' -c '2:fip' -t '2:b000' \
        -n '3:8192:73727' -c '3:kernel' -t '3:0700' \
        -n '4:73728:0' -c '4:root' -t '4:8300' \
        "$LDEV"

    sudo losetup -d "$LDEV"
    sudo losetup -P "$LDEV" image.bin

    sudo dd \
        if="$buildroot/bl2.img" \
        of="${LDEV}p1"
    sudo dd \
        if=fip.bin \
        of="${LDEV}p2"

    sudo mkfs.vfat -n KERNEL "${LDEV}p3"
    sudo mount "${LDEV}p3" mnt
    sudo cp "$buildroot/Image" \
        ./mnt/linux-6.17.Image
    sudo cp "$buildroot/mt7988a-bananapi-bpi-r4.dtb" \
        ./mnt/linux-6.17.mt7988a-bananapi-bpi-r4.dtb
    sudo umount mnt

    sudo mkfs.ext4 -L ROOTFS "${LDEV}p4"
    sudo mount "${LDEV}p4" mnt
    sudo cp -rv \
        "$buildroot/usr" \
        "$buildroot/bin" \
        "$buildroot/sbin" \
        "$buildroot/lib" \
        "$buildroot/libexec" \
        "$buildroot/lib64" \
        mnt
    sudo rm -rv \
        "mnt/include"
    sudo umount mnt

    sudo losetup -d "$LDEV"
}

pkginstall() {
    cp -v image.bin \
        "$pkgroot/puppy-os.img"
}
