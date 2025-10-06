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

mkdir -p \
    "$PKGDIR" \
    "$BUILDDIR" \
    "$SRCCACHEDIR" \
    "$PKGCACHEDIR"

# flatten package directory
mkdir -p "$BUILDDIR/pkgs"
find "$PKGDIR" -type f -name '*.sh' -exec cp -u {} "$BUILDDIR/pkgs/" \;
export PKGDIR="$BUILDDIR/pkgs"

# ensure toolchain is present
if [ ! -d "internal/toolchain/bin" ]; then
    mkdir "internal/toolchain"

    echo_stderr ">>> building cross-compiler toolchain"
    ./internal/makepkg.sh llvm

    echo_stderr ">>> extracting toolchain"
    tar -xf "$PKGCACHEDIR/llvm-21.1.2.tar.xz" -C "internal/toolchain"
    export PATH="$PWD/internal/toolchain/bin:$PATH"

    echo_stderr ">>> building compiler builtins library"
    ./internal/makepkg.sh linux-headers
    ./internal/makepkg.sh musl-headers
    ./internal/makepkg.sh compiler-rt

    echo_stderr ">>> extracting compiler builtins library"
    tar -xf "$PKGCACHEDIR/compiler-rt-21.1.2.tar.xz" -C "internal/toolchain"

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
