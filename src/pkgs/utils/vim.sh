#!/usr/bin/env bash

pkgname="vim"
pkgver="9.1.1846"
pkgsrcs=(
    "https://github.com/$pkgname/$pkgname/archive/refs/tags/v$pkgver.tar.gz"
)

pkgprepare() {
    cd ${pkgname}-${pkgver}

    ./configure \
        --prefix=/usr \
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
        --disable-darwin \
        --disable-smack \
        --disable-selinux \
        --disable-xsmp \
        --disable-xsmp-interact \
        --disable-netbeans \
        --disable-channel \
        --disable-rightleft \
        --disable-arabic \
        --enable-gui=no \
        --disable-gtktest \
        --disable-icon-cache-update \
        --disable-desktop-database-update \
        --disable-libsodium \
        --disable-sysmouse \
        --disable-nls \
        --enable-year2038 \
        --with-wayland=no \
        --with-features=tiny \
        --with-compiledby=puppyos \
        CC=clang LD=ld.lld \
        CFLAGS="-O3" LDFLAGS="-flto" \
        AR=llvm-ar RANLIB=llvm-ranlib STRIP=llvm-strip OBJDUMP=llvm-objdump DLLTOOL=llvm-dlltool MANIFEST_TOOL=llvm-mt NM=llvm-nm
}

pkgbuild() {
    make
}

pkginstall() {
    make DESTDIR=$pkgdir install

    rm -r \
        $pkgdir/usr/share/{applications,icons,vim} \
        $pkgdir/usr/bin/{rvim,view,rview,vimtutor}

    mkdir -p $pkgdir/usr/share/vim/vim91
    touch $pkgdir/usr/share/vim/vim91/defaults.vim
}
