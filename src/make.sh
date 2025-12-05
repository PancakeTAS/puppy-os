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
mkdir -p /puppyos/target/rootfs
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

# build essential rootfs libraries
installdir=/puppyos/target/rootfs
install_package src/pkgs/libs/base/linux-headers.sh
install_package src/pkgs/libs/base/musl.sh
install_package src/pkgs/libs/base/libc++.sh

# build compression libraries
install_package src/pkgs/libs/compression/brotli.sh
install_package src/pkgs/libs/compression/bzip2.sh
install_package src/pkgs/libs/compression/lz4.sh
install_package src/pkgs/libs/compression/xz.sh
install_package src/pkgs/libs/compression/zlib.sh
install_package src/pkgs/libs/compression/zstd.sh

# build crypto libraries
install_package src/pkgs/libs/crypto/openssl.sh
install_package src/pkgs/libs/crypto/libxcrypt.sh
install_package src/pkgs/libs/crypto/nettle.sh

# build network libraries
install_package src/pkgs/libs/net/libmnl.sh
install_package src/pkgs/libs/net/libnftnl.sh
install_package src/pkgs/libs/net/libnl.sh
install_package src/pkgs/libs/net/libpcap.sh
install_package src/pkgs/libs/net/libssh2.sh
install_package src/pkgs/libs/net/nghttp2.sh
install_package src/pkgs/libs/net/nghttp3.sh
install_package src/pkgs/libs/net/libpsl.sh
install_package src/pkgs/libs/net/ldns.sh

# build other libraries
install_package src/pkgs/libs/ncurses.sh
install_package src/pkgs/libs/libedit.sh

# build utilities
install_package src/pkgs/utils/attr.sh
install_package src/pkgs/utils/file.sh
install_package src/pkgs/utils/toybox.sh
install_package src/pkgs/utils/less.sh
install_package src/pkgs/utils/vim.sh
install_package src/pkgs/utils/pv.sh
install_package src/pkgs/utils/linux/kmod.sh
install_package src/pkgs/utils/linux/pciutils.sh
install_package src/pkgs/utils/linux/procps-ng.sh
install_package src/pkgs/utils/linux/util-linux.sh
install_package src/pkgs/utils/linux/psmisc.sh
install_package src/pkgs/utils/linux/lsof.sh
install_package src/pkgs/utils/monitoring/lm-sensors.sh
install_package src/pkgs/utils/monitoring/btop.sh
install_package src/pkgs/utils/monitoring/htop.sh
install_package src/pkgs/utils/net/iproute2.sh
install_package src/pkgs/utils/net/iputils.sh
install_package src/pkgs/utils/net/nftables.sh
install_package src/pkgs/utils/net/traceroute.sh
install_package src/pkgs/utils/net/wireguard-tools.sh
install_package src/pkgs/utils/net/tcpdump.sh
install_package src/pkgs/utils/net/iperf3.sh
install_package src/pkgs/utils/net/nmap.sh
install_package src/pkgs/utils/net/curl.sh
install_package src/pkgs/utils/net/ethtool.sh

# build daemons
install_package src/pkgs/daemons/dhcpcd.sh
install_package src/pkgs/daemons/dnsmasq.sh
install_package src/pkgs/daemons/ntp.sh
install_package src/pkgs/daemons/openssh.sh

# other essential packages
install_package src/pkgs/dash.sh
install_package src/pkgs/runit.sh

# build various data packages
install_package src/pkgs/data/iana-tz.sh
install_package src/pkgs/data/hwdata.sh

# clean up unwanted files
rm -r \
    target/rootfs/usr/include

# make initramfs
echo "==> Writing initramfs"
pushd target/rootfs
    mkdir -p dev
    mknod -m 600 dev/console c 5 1
    mknod -m 666 dev/null c 1 3
    find . | cpio -H newc -o --owner root:root > ../../output/initramfs.cpio
popd

echo "==> Done."
