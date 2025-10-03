#!/bin/sh
set -euo pipefail

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <package>"
    exit 1
fi

function echo_stderr() {
    echo -e "\033[1;36m$*\033[0m" >&2
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

# ensure toolchain is present
if [ ! -d "internal/toolchain/bin" ]; then
    mkdir "internal/toolchain"

    echo_stderr ">>> building toolchain"
    PKGDIR="internal" PKGCACHEDIR="$BUILDDIR/toolchain-cache" ./internal/makepkg.sh toolchain

    echo_stderr ">>> extracting toolchain"
    tar -xf "$BUILDDIR/toolchain-cache/llvm-21.1.2.tar.xz" -C "internal/toolchain"

    rm -rf "$BUILDDIR/toolchain-cache"
    echo_stderr ">>> toolchain ready"
fi

export PATH="$PWD/internal/toolchain/bin:$PATH"

# print package information
. "$PKGDIR/$1.sh"
echo_stderr "=== building package: $pkgname-$pkgver"
echo_stderr "> \033[0m\033[3m\"$pkgdesc\""
echo_stderr "from: \033[0m\033[4m$pkgurl"
echo_stderr "license: \033[0m$pkglic"

# recurse through dependencies
resolve_deps() {
    local pkg="$1"

    . "$PKGDIR/$pkg.sh"

    for _dep in "${pkgdeps[@]}"; do
        local dep="$_dep"
        local basedep="${dep%-*}"
        resolve_deps "$basedep"

        if [ ! -f "$PKGCACHEDIR/$dep.tar.xz" ]; then
            echo_stderr ">>> building dependency: $dep"
            ./internal/makepkg.sh "$basedep"
        else
            echo_stderr ">>> dependency already built: $dep"
        fi
    done
}

resolve_deps "$1"

# build package
echo_stderr ">>> building package: $pkgname-$pkgver"
./internal/makepkg.sh "$1"

echo_stderr ">>> package built"
