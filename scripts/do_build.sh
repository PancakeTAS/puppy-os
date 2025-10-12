#!/usr/bin/env bash
set -euo pipefail

. scripts/functions.sh

# prepare environment
mkdir -p build dlcache cache

rm -rf target/* build/* || true
mkdir -p target/{,kernel,rootfs,tools}

pushd target/rootfs >/dev/null
    mkdir -m755 \
        dev sys proc run mnt \
        etc usr var \
        usr/{bin,lib,share,include}
    mkdir -m750 root
    mkdir -m1777 tmp
    ln -s usr/bin bin
    ln -s usr/lib lib
popd >/dev/null

# build kernel-related stuff
sysroot="$(realpath target)"
ln -s "$sysroot" /tmp/puppyos-sysroot
install_package pkgs/kernel/arm-trusted-firmware.sh
install_package pkgs/kernel/u-boot.sh
install_package pkgs/kernel/linux.sh

# finish partitions
./target/tools/fiptool create \
    --soc-fw target/tools/bl31.bin \
    --nt-fw target/tools/u-boot.bin \
    target/fip.img
