#!/bin/sh
set -euo pipefail

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <package>"
    exit 1
fi

function echo_stderr() {
    echo -e "\033[1;32m$*\033[0m" >&2
}

# get working directories
: "${PKGDIR:=pkgs}"
: "${BUILDDIR:=build}"
: "${SRCCACHEDIR:=cache/srcs}"
: "${PKGCACHEDIR:=cache/pkgs}"

mkdir -pv \
    "$PKGDIR" \
    "$BUILDDIR" \
    "$SRCCACHEDIR" \
    "$PKGCACHEDIR"

# prepare temporary file structure
TEMPDIR="$BUILDDIR/$RANDOM"
BUILDROOT="$TEMPDIR/buildroot"
SRCDIR="$TEMPDIR/src"
PKGROOT="$TEMPDIR/pkgroot"

mkdir "$TEMPDIR"
trap 'rm -rf "$TEMPDIR"' ERR
trap 'rm -rf "$TEMPDIR"' EXIT

mkdir "$BUILDROOT"
pushd "$BUILDROOT" >/dev/null
    mkdir -p usr/{include,lib,libexec,bin}
    ln -sf usr/bin bin
    ln -sf usr/bin sbin
    ln -sf usr/lib lib
    ln -sf usr/lib libexec
    ln -sf usr/lib lib64
    ln -sf bin usr/sbin
    ln -sf lib usr/lib64
    ln -sf lib usr/libexec
popd >/dev/null

mkdir \
    "$SRCDIR" \
    "$PKGROOT"

# prepare package build
. "$PKGDIR/$1.sh"

for dep in "${pkgdeps[@]}"; do
    if [ ! -f "$PKGCACHEDIR/$dep.tar.xz" ]; then
        echo_stderr "!!! missing dependency $dep"
        exit 1
    fi

    echo_stderr ">>> extracting dependency $dep"
    tar -xf "$PKGCACHEDIR/$dep.tar.xz" -C "$BUILDROOT"
done

for src in "${pkgsrcs[@]}"; do
    base="$(basename "$src")"
    if [ ! -f "$SRCCACHEDIR/$base" ]; then
        echo_stderr ">>> downloading source $base"
        wget -q --show-progress -O "$SRCCACHEDIR/$base" "$src"
    fi

    echo_stderr ">>> extracting source $base"
    tar -xf "$SRCCACHEDIR/$base" -C "$SRCDIR"
done

pkgroot="$(realpath "$PKGROOT")"
buildroot="$(realpath "$BUILDROOT")"

ln -sf "$buildroot" "/tmp/dog-buildroot"
pushd "$SRCDIR" >/dev/null

echo_stderr ">>> preparing $pkgname-$pkgver"
pkgprepare

echo_stderr ">>> building $pkgname-$pkgver"
pkgbuild

echo_stderr ">>> installing $pkgname-$pkgver"
pkginstall

popd >/dev/null

# create package archive
echo_stderr ">>> archiving $pkgname-$pkgver"
tar -cJf "$PKGCACHEDIR/$pkgname-$pkgver.tar.xz" -C "$PKGROOT" .

# cleanup
rm -rf "$TEMPDIR"
rm /tmp/dog-buildroot

echo_stderr ">>> done"
