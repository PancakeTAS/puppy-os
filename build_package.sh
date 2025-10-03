#!/bin/sh
set -euo pipefail

# get working directories
: "${PKGDIR:=pkgs}"
: "${BUILDDIR:=build}"
: "${CACHEDIR:=cache}"

mkdir -pv \
    "$PKGDIR" \
    "$BUILDDIR" \
    "$CACHEDIR"

# prepare temporary file structure
TEMPDIR="$BUILDDIR/$RANDOM"
BUILDROOT="$TEMPDIR/buildroot"
SRCDIR="$TEMPDIR/src"
PKGROOT="$TEMPDIR/pkgroot"

mkdir -v "$TEMPDIR"
trap 'rm -rvf "$TEMPDIR"' ERR

mkdir -v "$BUILDROOT"
pushd "$BUILDROOT"
	mkdir -pv usr/{include,lib,libexec,bin}
	ln -sfv usr/bin bin
	ln -sfv usr/bin sbin
	ln -sfv usr/lib lib
	ln -sfv usr/lib libexec
	ln -sfv usr/lib lib64
	ln -sfv bin usr/sbin
	ln -sfv lib usr/lib64
popd

mkdir -v \
    "$SRCDIR" \
    "$PKGROOT"

# prepare package build
. "$PKGDIR/$1.sh"

for src in "${pkgsrcs[@]}"; do
    base="$(basename "$src")"
    if [ ! -f "$CACHEDIR/$base" ]; then
        echo ">>> downloading $base"
        wget -O "$CACHEDIR/$base" "$src"
    fi

    echo ">>> extracting $base"
    tar -xf "$CACHEDIR/$base" -C "$BUILDROOT"
done

for dep in "${pkgdeps[@]}"; do
    if [ ! -f "$CACHEDIR/$dep.tar.xz" ]; then
        echo "!!! missing dependency $dep"
    fi

    echo ">>> extracting dependency $dep"
    tar -xf "$CACHEDIR/$dep.tar.xz" -C "$SRCDIR"
done

pkgroot="$(realpath "$PKGROOT")"
buildroot="$(realpath "$BUILDROOT")"

pushd "$SRCDIR"

echo ">>> preparing $pkgname-$pkgver-$pkgrel"
pkgprepare

echo ">>> building $pkgname-$pkgver-$pkgrel"
pkgbuild

echo ">>> installing $pkgname-$pkgver-$pkgrel"
pkginstall

popd

# create package archive
echo ">>> archiving $pkgname-$pkgver-$pkgrel"
tar -cJf "$CACHEDIR/$pkgname-$pkgver-$pkgrel.tar.xz" -C "$PKGROOT" .
