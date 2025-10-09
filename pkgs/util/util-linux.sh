#!/bin/sh

# metadata
pkgname="util-linux"
pkgver="2.41.2"
pkgdesc="utilities for interfacing with the Linux kernel"
pkgurl="https://github.com/util-linux/util-linux"
pkglic="GPLv2"

# build information
pkgdeps=(
    "linux-headers-6.17"
    "ncurses-6.5"
    "bzip2-1.0.8"
    "musl-1.2.5"
    "zstd-1.5.7"
    "zlib-1.3.1"
    "file-5.46"
    "xz-5.8.1"
)
pkgsrcs=(
    "https://github.com/$pkgname/$pkgname/archive/refs/tags/v$pkgver.tar.gz"
)

# build scripts
pkgprepare() {
    cd $pkgname-$pkgver

    ./autogen.sh
    ./configure \
        --prefix=/usr \
        --host=aarch64-dog-linux-musl \
        --disable-dependency-tracking \
        --disable-nls \
        --disable-static \
        --disable-rpath \
        --disable-agetty \
        --disable-plymouth_support \
        --disable-cramfs \
        --disable-minix \
        --enable-tunelp \
        --disable-last \
        --disable-raw \
        --disable-vipw \
        --disable-nologin \
        --disable-sulogin \
        --disable-su \
        --disable-runuser \
        --enable-pg \
        --disable-wall \
        --disable-pylibmount \
        --disable-pg-bell \
        --disable-use-tty-group \
        --with-sysroot="$buildroot" \
        --without-readline \
        --without-cap-ng \
        --without-user \
        --without-systemd \
        --without-econf \
        --without-btrfs \
        --without-python \
        --disable-liblastlog2 \
        --enable-usrdir-path \
        --disable-makeinstall-chown \
        --disable-makeinstall-setuid \
        --disable-makeinstall-tty-setgid \
        CC=clang CXX=clang++ LD=ld.lld \
        CFLAGS="-O3" LDFLAGS="-flto" \
        AR=llvm-ar RANLIB=llvm-ranlib STRIP=llvm-strip OBJDUMP=llvm-objdump DLLTOOL=llvm-dlltool MANIFEST_TOOL=llvm-mt NM=llvm-nm
}

pkgbuild() {
    make
}

pkginstall() {
    make install-strip DESTDIR="$pkgroot"

    rm -rv \
        "$pkgroot/usr/share" \
        "$pkgroot/usr/lib/pkgconfig" \
        "$pkgroot/usr/lib/libsmartcols.la" \
        "$pkgroot/usr/lib/libblkid.la" \
        "$pkgroot/usr/lib/libfdisk.la" \
        "$pkgroot/usr/lib/libmount.la" \
        "$pkgroot/usr/lib/libuuid.la"

}
