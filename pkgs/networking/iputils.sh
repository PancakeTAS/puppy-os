#!/bin/sh

# metadata
pkgname="iputils"
pkgver="20250605"
pkgdesc="ip monitoring utilities"
pkgurl="https://github.com/iputils/iputils"
pkglic="BSD"

# build information
pkgdeps=(
    "linux-headers-6.17"
    "musl-1.2.5"
)
pkgsrcs=(
    "https://github.com/$pkgname/$pkgname/releases/download/$pkgver/$pkgname-$pkgver.tar.xz"
)

MESON_CROSS=$(cat <<'EOF'
[binaries]
c = 'clang'
cpp = 'clang++'
ar = 'llvm-ar'
strip = 'llvm-strip'
EOF
)

# build scripts
pkgprepare() {
    cd $pkgname-$pkgver

    echo "$MESON_CROSS" > meson.cross

    ./configure
    meson setup \
        -DUSE_CAP=false \
        -DUSE_IDN=false \
        -DBUILD_MANS=false \
        -DUSE_GETTEXT=false \
        -DSKIP_TESTS=true \
        -Dprefix=/usr \
        --buildtype release \
        --optimization 3 \
        --cross-file meson.cross \
        build
}

pkgbuild() {
    meson build
}

pkginstall() {
    meson install -C build \
        --strip --destdir "$pkgroot"
}
