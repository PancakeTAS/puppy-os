#!/usr/bin/env bash
set -euo pipefail

# Usage: ./script.sh [-C] [-c pkg1,pkg2,pkg3] [-j 1-16]
# Options:
#   -C                Clean the entire cache directory.
#   -c pkg1,pkg2,...  Ignore caches for the specified comma-separated packages.
#   -j n              Override the amount of parallel threads used for Makefiles (default: nproc).
#   -h                Show help/usage.

CLEAN_CACHE=false
SKIP_IMAGE=false
IGNORE_PKGS=""
MAKEFLAGS="-j$(nproc)"

show_help() {
    grep '^#[ ]' "$0" | cut -c 3- | head -n6
    exit 0
}

# parse command line options
while getopts ":Cc:j:hn" opt; do
    case "$opt" in
        C)
            CLEAN_CACHE=true
            ;;
        c)
            IGNORE_PKGS="$OPTARG"
            ;;
        j)
            MAKEFLAGS="-j$OPTARG"
            ;;
        h)
            show_help
            ;;
        n)
            SKIP_IMAGE=true
            ;;
        \?)
            echo "Invalid option: -$OPTARG"
            show_help
            ;;
        :)
            echo "Option -$OPTARG requires an argument."
            show_help
            ;;
    esac
done

export MAKEFLAGS
export PATH="$PWD/toolchain/bin:$PATH"

# prepare file structure
rm -rf build/* || true
rm -rf sysroot/* || true
if [ "$CLEAN_CACHE" = true ]; then
    rm -rf cache/* || true
fi
mkdir -p build sysroot cache dlcache
mkdir -m755 -p \
    sysroot/{dev,sys,proc,run} \
    sysroot/{etc,usr,var,boot} \
    sysroot/usr/{bin,lib,include,share} \
    sysroot/var/{log,cache,lib}
mkdir -m1777 -p \
    sysroot/tmp \
    sysroot/var/tmp
ln -s usr/bin sysroot/bin
ln -s usr/sbin sysroot/sbin
ln -s usr/lib sysroot/lib
ln -s usr/lib64 sysroot/lib64
ln -s bin sysroot/usr/sbin
ln -s lib sysroot/usr/lib64
ln -s ../run sysroot/var/run
ln -s ../run/lock sysroot/var/lock

build() {
    . "$1"

    # check if package is already cached
    if [[ ",$IGNORE_PKGS," == *",$pkgname,"* ]]; then
        echo "==> Ignoring cache for $pkgname-$pkgver"
    elif [ -f "cache/$pkgname-$pkgver.tar.xz" ]; then
        echo "==> Using cached build for $pkgname-$pkgver"

        tar -xhf "cache/$pkgname-$pkgver.tar.xz" -C sysroot
        return
    fi

    echo "==> Obtaining resources for $pkgname-$pkgver"
    TEMPDIR=$(realpath build/$pkgname-$RANDOM)

    mkdir -p "$TEMPDIR"
    trap 'rm -rf "$TEMPDIR"' ERR

    mkdir -p "$TEMPDIR"/{src,pkg}

    # download and extract sources
    for src in "${pkgsrcs[@]}"; do
        base="$(basename "$src")"
        if [ ! -f "dlcache/$base" ]; then
            wget -q --show-progress -O "dlcache/$base" "$src"
        fi

        tar -xhf "dlcache/$base" -C "$TEMPDIR/src"
    done

    srcdir="$(realpath "$TEMPDIR/src")"
    pkgdir="$(realpath "$TEMPDIR/pkg")"
    filesdir="$(realpath files/$pkgname)"
    sysroot="$(realpath sysroot)"

    pushd "$srcdir" >/dev/null

    echo "==> Preparing $pkgname-$pkgver"
    pkgprepare

    echo "==> Building $pkgname-$pkgver"
    pkgbuild

    echo "==> Installing $pkgname-$pkgver"
    pkginstall

    popd >/dev/null

    echo "==> Caching build for $pkgname-$pkgver"
    rm -rf \
        "$pkgdir"/usr/share/{man,doc,info,pkgconfig} \
        "$pkgdir"/usr/share/{bash-completion,zsh,fish} \
        "$pkgdir"/usr/lib/{pkgconfig,cmake} \
        "$pkgdir"/usr/man

    find "$pkgdir" -type d -empty -delete || true
    find "$pkgdir" -name '*.la' -delete || true

    find "$pkgdir"/{bin,lib,usr/bin,usr/lib} \
        -type f -executable -exec llvm-strip --strip-unneeded {} + 2>/dev/null || true

    tar -cpJf "cache/$pkgname-$pkgver.tar.xz" -C "$pkgdir" .

    rm -rf "$TEMPDIR"

    echo "==> Extracting $pkgname-$pkgver to sysroot"
    tar -xhf "cache/$pkgname-$pkgver.tar.xz" -C sysroot
}

### build all packages

# fundamental packages
build "pkgs/base/linux-headers.sh"
build "pkgs/base/musl.sh"
build "pkgs/base/libcxx.sh"
build "pkgs/base/iana-etc.sh"
build "pkgs/base/iana-tz.sh"
build "pkgs/base/hwdata.sh"
build "pkgs/base/puppyos-etc.sh"

# various libraries
build "pkgs/libs/compression/brotli.sh"
build "pkgs/libs/compression/bzip2.sh"
build "pkgs/libs/compression/lz4.sh"
build "pkgs/libs/compression/xz.sh"
build "pkgs/libs/compression/zlib.sh"
build "pkgs/libs/compression/zstd.sh"
build "pkgs/libs/crypto/libxcrypt.sh"
build "pkgs/libs/crypto/openssl.sh"
build "pkgs/libs/crypto/nettle.sh"
build "pkgs/libs/net/libmnl.sh"
build "pkgs/libs/net/libnftnl.sh"
build "pkgs/libs/net/libnl.sh"
build "pkgs/libs/net/libpcap.sh"
build "pkgs/libs/ncurses.sh"

# many utils
build "pkgs/utils/attr.sh"
build "pkgs/utils/file.sh"
build "pkgs/utils/toybox.sh"
build "pkgs/utils/less.sh"
build "pkgs/utils/vi.sh"
build "pkgs/utils/pv.sh"
build "pkgs/utils/linux/kmod.sh"
build "pkgs/utils/linux/pciutils.sh"
build "pkgs/utils/linux/procps-ng.sh"
build "pkgs/utils/linux/util-linux.sh"
build "pkgs/utils/linux/psmisc.sh"
build "pkgs/utils/monitoring/btop.sh"
build "pkgs/utils/net/iproute2.sh"
build "pkgs/utils/net/iputils.sh"
build "pkgs/utils/net/iw.sh"
build "pkgs/utils/net/nftables.sh"
build "pkgs/utils/net/traceroute.sh"
build "pkgs/utils/net/wireguard-tools.sh"
build "pkgs/utils/net/tcpdump.sh"
build "pkgs/utils/net/iperf3.sh"

# other packages
build "pkgs/dash.sh"
build "pkgs/runit.sh"
build "pkgs/hostapd.sh"
build "pkgs/wpa_supplicant.sh"
build "pkgs/dhcpcd.sh"

# bootloader and kernel
build "pkgs/boot/arm-trusted-firmware.sh"
build "pkgs/boot/u-boot.sh"
build "pkgs/boot/linux.sh"

### build the final image

if [ "$SKIP_IMAGE" = true ]; then
    echo "==> Skipping image creation as requested."
    exit 0
fi

echo "==> Building final image. This requires sudo privileges."
export LD_PRELOAD="" # remove any potential fakeroot

# create fip
./sysroot/_tmp/fiptool create \
    --soc-fw sysroot/_tmp/bl31.bin \
    --nt-fw sysroot/_tmp/u-boot.bin \
    build/fip.bin
trap 'rm -f build/fip.bin' ERR

# create 128MB GPT partitioned image
dd if=/dev/zero of=puppy-os.img bs=1M count=128
sgdisk -o -a 1 \
    -n '1:1024:4095' -c '1:bl2' -t '1:ef02' -A '1:set:2' \
    -n '2:4096:8191' -c '2:fip' -t '2:b000' \
    -n '3:8192:73727' -c '3:kernel' -t '3:0700' \
    -n '4:73728:0' -c '4:root' -t '4:8300' \
    puppy-os.img

# map the image to a loop device
LDEV=$(sudo losetup -Pf --show puppy-os.img)
trap 'sudo losetup -d "$LDEV"' ERR

# write bootloader and fip
sudo dd if=sysroot/_tmp/bl2.img of="${LDEV}p1" bs=512 conv=notrunc
sudo dd if=build/fip.bin of="${LDEV}p2" bs=512 conv=notrunc

# write kernel to partition 3
sudo mkfs.vfat -n KERNEL "${LDEV}p3"

sudo mount "${LDEV}p3" /mnt
trap 'sudo umount /mnt' ERR

sudo cp sysroot/boot/* /mnt/

sudo umount /mnt

# write rootfs to partition 4
sudo mkfs.ext4 -L ROOTFS "${LDEV}p4"

sudo mount "${LDEV}p4" /mnt

rm -rf \
    sysroot/boot \
    sysroot/_tmp \
    sysroot/usr/include
sudo cp -a sysroot/* /mnt/
sudo chown -R root:root /mnt

sudo umount /mnt
sudo losetup -d "$LDEV"

echo "==> Build complete"
