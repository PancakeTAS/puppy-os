#!/bin/sh

# metadata
pkgname="toybox"
pkgver="0.8.12"
pkgdesc="collection of standard UNIX command line tools"
pkgurl="https://landley.net/toybox"
pkglic="BSD"

# build information
pkgdeps=(
    "openssl-3.6.0"
    "linux-headers-6.17"
    "musl-1.2.5"
    "zlib-1.3.1"
)
pkgsrcs=(
    "https://www.landley.net/$pkgname/downloads/$pkgname-$pkgver.tar.gz"
)

# build scripts
_utils=('base32' 'base64' 'baseenc' 'basename' 'cat' 'cp' 'chgrp' 'chroot' 'chown' 'chmod' 'cksum' 'comm' 'cut' 'date' 'dd' 'df' 'dirname' 'du' 'echo' 'env' 'expand' 'expr' 'factor' 'false' 'fmt' 'fold' 'groups' 'head' 'hostid' 'id' 'install' 'link' 'logname' 'ln' 'ls' 'md5sum' 'mkdir' 'mkfifo' 'mknod' 'mktemp' 'mv' 'nice' 'nohup' 'nproc' 'nl' 'od' 'paste' 'printenv' 'printf' 'pwd' 'rm' 'rmdir' 'readlink' 'realpath' 'seq' 'sha1sum' 'sha224sum' 'sha256sum' 'sha384sum' 'sha512sum' 'shred' 'sleep' 'sort' 'sort_float' 'split' 'stat' 'stty' 'shuf' 'sync' 'tac' 'tail' 'tee' 'test' 'timeout' 'tr' 'touch' 'tsort' 'true' 'truncate' 'tty' 'uname' 'uniq' 'unlink' 'wc' 'who' 'whoami' 'yes') # coreutils
_utils+=('bc' 'patch' 'ascii' 'cpio' 'time' 'sed' 'tar' 'awk') # respective packages
_utils+=('fgrep' 'egrep' 'grep') # grep
_utils+=('getconf' 'iconv') # subset of glibc
_utils+=('find' 'xargs') # findutils
_utils+=('cmp' 'diff') # subset of diffutils

pkgprepare() {
    cd $pkgname-$pkgver

    make allnoconfig
    echo "CONFIG_TOYBOX_LIBCRYPTO=y" >> .config
    echo "CONFIG_TOYBOX_LIBZ=y" >> .config
    echo "CONFIG_TOYBOX_FLOAT=y" >> .config

    for util in "${_utils[@]}"; do
        util_upper=$(echo "$util" | tr '[:lower:]' '[:upper:]')
        echo "CONFIG_${util_upper}=y" >> .config
    done
}

pkgbuild() {
    make \
        CROSS_COMPILE= CC=clang \
        STRIP=llvm-strip \
        CFLAGS="-w" LDFLAGS="-w" \
        LDOPTIMIZE="-flto" OPTIMIZE="-O3"
}

pkginstall() {
    mkdir -p "$pkgroot/usr/bin"
    cp -p toybox "$pkgroot/usr/bin/"

    for util in "${_utils[@]}"; do
        ln -sf toybox "$pkgroot/usr/bin/$util"
    done

    rm -f "$pkgroot/usr/bin/sort_float" \
        "$pkgroot/usr/bin/baseenc"
}
