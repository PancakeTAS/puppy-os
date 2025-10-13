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

# build essential rootfs libraries
sysroot="$(realpath target/rootfs)"
rm /tmp/puppyos-sysroot && ln -s "$sysroot" /tmp/puppyos-sysroot
install_package pkgs/rootfs/libs/base/linux-headers.sh
install_package pkgs/rootfs/libs/base/musl.sh
install_package pkgs/rootfs/libs/base/libc++.sh

# build compression libraries
install_package pkgs/rootfs/libs/compression/brotli.sh
install_package pkgs/rootfs/libs/compression/bzip2.sh
install_package pkgs/rootfs/libs/compression/lz4.sh
install_package pkgs/rootfs/libs/compression/xz.sh
install_package pkgs/rootfs/libs/compression/zlib.sh
install_package pkgs/rootfs/libs/compression/zstd.sh

# build crypto libraries
install_package pkgs/rootfs/libs/crypto/openssl.sh
install_package pkgs/rootfs/libs/crypto/libxcrypt.sh
install_package pkgs/rootfs/libs/crypto/nettle.sh

# build network libraries
install_package pkgs/rootfs/libs/net/libmnl.sh
install_package pkgs/rootfs/libs/net/libnftnl.sh
install_package pkgs/rootfs/libs/net/libnl.sh
install_package pkgs/rootfs/libs/net/libpcap.sh
install_package pkgs/rootfs/libs/net/libssh2.sh
install_package pkgs/rootfs/libs/net/nghttp2.sh
install_package pkgs/rootfs/libs/net/nghttp3.sh
install_package pkgs/rootfs/libs/net/libpsl.sh
install_package pkgs/rootfs/libs/net/ldns.sh

# build other libraries
install_package pkgs/rootfs/libs/ncurses.sh
install_package pkgs/rootfs/libs/libedit.sh

# build utilities
install_package pkgs/rootfs/utils/attr.sh
install_package pkgs/rootfs/utils/file.sh
install_package pkgs/rootfs/utils/toybox.sh
install_package pkgs/rootfs/utils/less.sh
install_package pkgs/rootfs/utils/vim.sh
install_package pkgs/rootfs/utils/pv.sh
install_package pkgs/rootfs/utils/linux/kmod.sh
install_package pkgs/rootfs/utils/linux/pciutils.sh
install_package pkgs/rootfs/utils/linux/procps-ng.sh
install_package pkgs/rootfs/utils/linux/util-linux.sh
install_package pkgs/rootfs/utils/linux/psmisc.sh
install_package pkgs/rootfs/utils/linux/lsof.sh

# build various data packages
install_package pkgs/rootfs/data/iana-tz.sh
install_package pkgs/rootfs/data/hwdata.sh

# finish partitions
./target/tools/fiptool create \
    --soc-fw target/tools/bl31.bin \
    --nt-fw target/tools/u-boot.bin \
    target/fip.img
