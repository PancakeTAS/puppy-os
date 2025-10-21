#!/usr/bin/env bash
set -euo pipefail

#
# THIS SCRIPT IS INTENDED TO RUN IN A
# DOCKER CONTAINER AND MAY CAUSE DAMAGE
# IF RUN ON A HOST SYSTEM DIRECTLY.
#

cd /puppyos
export MAKEFLAGS="-j$(nproc)"

# make basic rootfs structure
mkdir -p /puppyos/target/{,kernel,rootfs,tools}
pushd /puppyos/target/rootfs >/dev/null
    mkdir -m755 \
        dev sys proc run mnt \
        etc usr var opt \
        usr/{bin,lib,share,include} \
        var/{cache,db,lib} \
        var/empty
    mkdir -m750 root
    mkdir -m1777 tmp
    ln -s usr/bin bin
    ln -s usr/lib lib
    mkdir -m1777 var/tmp
    ln -s ../run var/run
    ln -s ../run/lock var/lock
    ln -s ../run/log var/log
popd >/dev/null

# function for building a package
build_package() {
    . "$1"

    # prepare temporary build directory
    TEMPDIR=/puppyos/build/${pkgname}-${pkgver}
    mkdir -p $TEMPDIR/{src,pkg}
    trap 'rm -rf $TEMPDIR' ERR

    # download and extract sources
    echo "==> Obtaining resources for $pkgname-$pkgver"
    for src in "${pkgsrcs[@]}"; do
        base="$(basename "$src")"
        if [ ! -f "dlcache/$base" ]; then
            wget -q --show-progress -O "dlcache/$base" "$src"
        fi

        tar -xhf "dlcache/$base" -C $TEMPDIR/src
    done

    # set environment variables for the build
    srcdir=$TEMPDIR/src
    pkgdir=$TEMPDIR/pkg
    rscdir=/puppyos/src/resources/$pkgname

    # run the build
    pushd $srcdir >/dev/null

    echo "==> Preparing $pkgname-$pkgver"
    pkgprepare

    echo "==> Building $pkgname-$pkgver"
    pkgbuild

    echo "==> Installing $pkgname-$pkgver"
    pkginstall

    popd >/dev/null

    # archive the built package
    echo "==> Caching build for $pkgname-$pkgver"
    rm -rf \
        $pkgdir/usr/share/{man,doc,info,pkgconfig} \
        $pkgdir/usr/share/{bash-completion,zsh,fish} \
        $pkgdir/usr/lib/{pkgconfig,cmake} \
        $pkgdir/usr/man \
        $pkgdir/etc

    find $pkgdir -name '*.la' -delete || true
    find $pkgdir -type d -empty -delete || true

    find $pkgdir/{bin,lib,usr/bin,usr/lib} \
        -type f -executable -exec llvm-strip --strip-unneeded {} + 2>/dev/null || true

    tar -cpJf cache/${pkgname}-${pkgver}.tar.xz -C $pkgdir .

    rm -rf $TEMPDIR
}

# function for installing (and building) a package
install_package() {
    . "$1"

    if [ -f cache/$pkgname-$pkgver.tar.xz ]; then
        echo "==> Using cached build for $pkgname-$pkgver"
    else
        build_package "$1"
    fi

    tar -xhf cache/$pkgname-$pkgver.tar.xz -C $installdir
}

# build kernel-related stuff
installdir=/puppyos/target
install_package src/pkgs/kernel/arm-trusted-firmware.sh
install_package src/pkgs/kernel/u-boot.sh
install_package src/pkgs/kernel/linux.sh

# build essential rootfs libraries
installdir=/puppyos/target/rootfs
install_package src/pkgs/rootfs/libs/base/linux-headers.sh
install_package src/pkgs/rootfs/libs/base/musl.sh
install_package src/pkgs/rootfs/libs/base/libc++.sh

# build compression libraries
install_package src/pkgs/rootfs/libs/compression/brotli.sh
install_package src/pkgs/rootfs/libs/compression/bzip2.sh
install_package src/pkgs/rootfs/libs/compression/lz4.sh
install_package src/pkgs/rootfs/libs/compression/xz.sh
install_package src/pkgs/rootfs/libs/compression/zlib.sh
install_package src/pkgs/rootfs/libs/compression/zstd.sh

# build crypto libraries
install_package src/pkgs/rootfs/libs/crypto/openssl.sh
install_package src/pkgs/rootfs/libs/crypto/libxcrypt.sh
install_package src/pkgs/rootfs/libs/crypto/nettle.sh

# build network libraries
install_package src/pkgs/rootfs/libs/net/libmnl.sh
install_package src/pkgs/rootfs/libs/net/libnftnl.sh
install_package src/pkgs/rootfs/libs/net/libnl.sh
install_package src/pkgs/rootfs/libs/net/libpcap.sh
install_package src/pkgs/rootfs/libs/net/libssh2.sh
install_package src/pkgs/rootfs/libs/net/nghttp2.sh
install_package src/pkgs/rootfs/libs/net/nghttp3.sh
install_package src/pkgs/rootfs/libs/net/libpsl.sh
install_package src/pkgs/rootfs/libs/net/ldns.sh

# build other libraries
install_package src/pkgs/rootfs/libs/ncurses.sh
install_package src/pkgs/rootfs/libs/libedit.sh

# build utilities
install_package src/pkgs/rootfs/utils/attr.sh
install_package src/pkgs/rootfs/utils/file.sh
install_package src/pkgs/rootfs/utils/toybox.sh
install_package src/pkgs/rootfs/utils/less.sh
install_package src/pkgs/rootfs/utils/vim.sh
install_package src/pkgs/rootfs/utils/pv.sh
install_package src/pkgs/rootfs/utils/linux/kmod.sh
install_package src/pkgs/rootfs/utils/linux/pciutils.sh
install_package src/pkgs/rootfs/utils/linux/procps-ng.sh
install_package src/pkgs/rootfs/utils/linux/util-linux.sh
install_package src/pkgs/rootfs/utils/linux/psmisc.sh
install_package src/pkgs/rootfs/utils/linux/lsof.sh
install_package src/pkgs/rootfs/utils/monitoring/lm-sensors.sh
install_package src/pkgs/rootfs/utils/monitoring/btop.sh
install_package src/pkgs/rootfs/utils/monitoring/htop.sh
install_package src/pkgs/rootfs/utils/net/iproute2.sh
install_package src/pkgs/rootfs/utils/net/iputils.sh
install_package src/pkgs/rootfs/utils/net/iw.sh
install_package src/pkgs/rootfs/utils/net/nftables.sh
install_package src/pkgs/rootfs/utils/net/traceroute.sh
install_package src/pkgs/rootfs/utils/net/wireguard-tools.sh
install_package src/pkgs/rootfs/utils/net/tcpdump.sh
install_package src/pkgs/rootfs/utils/net/iperf3.sh
install_package src/pkgs/rootfs/utils/net/nmap.sh
install_package src/pkgs/rootfs/utils/net/curl.sh
install_package src/pkgs/rootfs/utils/net/ethtool.sh

# build daemons
install_package src/pkgs/rootfs/daemons/hostapd.sh
install_package src/pkgs/rootfs/daemons/wpa_supplicant.sh
install_package src/pkgs/rootfs/daemons/dhcpcd.sh
install_package src/pkgs/rootfs/daemons/dnsmasq.sh
install_package src/pkgs/rootfs/daemons/ntp.sh
install_package src/pkgs/rootfs/daemons/openssh.sh

# other essential packages
install_package src/pkgs/rootfs/dash.sh
install_package src/pkgs/rootfs/runit.sh

# build various data packages
install_package src/pkgs/rootfs/data/iana-tz.sh
install_package src/pkgs/rootfs/data/hwdata.sh

# finish partitions
./target/tools/fiptool create \
    --soc-fw target/tools/bl31.bin \
    --nt-fw target/tools/u-boot.bin \
    target/fip.img

# clean up
rm -r \
    target/tools \
    target/rootfs/usr/include

# copy output files
echo "==> Writing output files"
cp target/bl2.img output
cp target/fip.img output
tar cJf output/kernel.tar.xz -C target/kernel .
tar cpJf output/rootfs.tar.xz -C target/rootfs .
echo "==> Done."
