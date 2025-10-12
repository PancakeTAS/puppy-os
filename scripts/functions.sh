#!/usr/bin/env bash

# Build a package from its script.
# Usage: build_package <package_script>
build_package() {
    . "$1"

    # prepare temporary build directory
    TEMPDIR=$(realpath build/${pkgname}-${pkgver}-${RANDOM})
    mkdir -p "$TEMPDIR"/{src,pkg}
    trap 'rm -rf "$TEMPDIR"' ERR

    # download and extract sources
    echo "==> Obtaining resources for $pkgname-$pkgver"
    for src in "${pkgsrcs[@]}"; do
        base="$(basename "$src")"
        if [ ! -f "dlcache/$base" ]; then
            wget -q --show-progress -O "dlcache/$base" "$src"
        fi

        tar -xhf "dlcache/$base" -C "$TEMPDIR/src"
    done

    # set environment variables for the build
    srcdir="$(realpath "$TEMPDIR/src")"
    pkgdir="$(realpath "$TEMPDIR/pkg")"
    rscdir="$(realpath "resources/$pkgname")"

    # run the build
    pushd "$srcdir" >/dev/null

    echo "==> Preparing $pkgname-$pkgver"
    pkgprepare

    echo "==> Building $pkgname-$pkgver"
    pkgbuild

    echo "==> Installing $pkgname-$pkgver"
    pkginstall

    popd >/dev/null

    # archive the built package
    echo "==> Caching build for $pkgname-$pkgver"
    rm -rf \
        "$pkgdir"/usr/share/{man,doc,info,pkgconfig} \
        "$pkgdir"/usr/share/{bash-completion,zsh,fish} \
        "$pkgdir"/usr/lib/{pkgconfig,cmake} \
        "$pkgdir"/usr/man

    find "$pkgdir" -name '*.la' -delete || true
    find "$pkgdir" -type d -empty -delete || true

    find "$pkgdir"/{bin,lib,usr/bin,usr/lib} \
        -type f -executable -exec llvm-strip --strip-unneeded {} + 2>/dev/null || true

    tar -cpJf "cache/$pkgname-$pkgver.tar.xz" -C "$pkgdir" .

    rm -rf "$TEMPDIR"

    echo "==> Build and caching of $pkgname-$pkgver complete"
}

# Install a package into a directory, building it if necessary.
# Usage: install_package <package_script>
install_package() {
    . "$1"

    if [ -f "cache/$pkgname-$pkgver.tar.xz" ]; then
        echo "==> Using cached build for $pkgname-$pkgver"
    else
        build_package "$1"
    fi

    echo "==> Installing $pkgname-$pkgver"
    tar -xhf "cache/$pkgname-$pkgver.tar.xz" -C "$sysroot"
}
