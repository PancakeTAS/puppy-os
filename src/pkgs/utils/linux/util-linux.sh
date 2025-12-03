#!/usr/bin/env bash

pkgname="util-linux"
pkgver="2.41.2"
pkgsrcs=(
    "https://github.com/$pkgname/$pkgname/archive/refs/tags/v$pkgver.tar.gz"
)

pkgprepare() {
    cd ${pkgname}-${pkgver}

    sed -i "114 i usrsbin_execdir='\${exec_prefix}/bin'" configure.ac

    ./autogen.sh
    ./configure \
        --prefix=/usr \
        --exec-prefix=/usr \
        --bindir=/usr/bin \
        --sbindir=/usr/bin \
        --libexecdir=/usr/lib \
        --sysconfdir=/etc \
        --sharedstatedir=/var/lib \
        --localstatedir=/var \
        --runstatedir=/run \
        --libdir=/usr/lib \
        --includedir=/usr/include \
        --datarootdir=/usr/share \
        --host=x86_64-dog-linux-musl \
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
        --disable-hwclock \
        --disable-runuser \
        --enable-pg \
        --disable-wall \
        --disable-pylibmount \
        --disable-pg-bell \
        --disable-use-tty-group \
        --without-readline \
        --without-cap-ng \
        --without-user \
        --without-systemd \
        --without-econf \
        --without-btrfs \
        --without-python \
        --disable-liblastlog2 \
        --enable-usrdir-path \
        --with-sysroot=/puppyos/target/rootfs \
        CC=clang CXX=clang++ LD=ld.lld \
        CFLAGS="-O3" LDFLAGS="-flto" \
        AR=llvm-ar RANLIB=llvm-ranlib STRIP=llvm-strip OBJDUMP=llvm-objdump DLLTOOL=llvm-dlltool MANIFEST_TOOL=llvm-mt NM=llvm-nm
}

pkgbuild() {
    make
}

pkginstall() {
    make DESTDIR=$pkgdir install-strip
}
