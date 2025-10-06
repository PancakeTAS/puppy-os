#!/bin/sh

# metadata
pkgname="libcxx"
_pkgname="llvm"
pkgver="21.1.2"
pkgdesc="LLVM c++ standard library"
pkgurl="https://libcxx.llvm.org/"
pkglic="Apache-2.0 (LLVM-exception)"

# build information
pkgdeps=(
    "linux-headers-6.16.9"
    "musl-1.2.5"
)
pkgsrcs=(
    "https://github.com/$_pkgname/$_pkgname-project/archive/refs/tags/llvmorg-$pkgver.tar.gz"
)

# build scripts
pkgprepare() {
    cd $_pkgname-project-llvmorg-$pkgver

    LIBCC_PATH=$(echo "$PATH" | cut -d':' -f1)
    LIBCC_PATH=$(dirname "$LIBCC_PATH")

    cmake -S runtimes -B build -G Ninja \
        -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=On \
        -DCMAKE_INSTALL_PREFIX="$pkgroot/usr" \
        -DCMAKE_SYSROOT="$buildroot" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_CXX_COMPILER=clang++ \
        -DCMAKE_C_COMPILER=clang \
        -DCMAKE_ASM_COMPILER_TARGET="aarch64-dog-linux-musl" \
        -DCMAKE_CXX_COMPILER_TARGET="aarch64-dog-linux-musl" \
        -DCMAKE_C_COMPILER_TARGET="aarch64-dog-linux-musl" \
        -DLLVM_ENABLE_RUNTIMES="libunwind;libcxxabi;libcxx" \
        -DLIBCXX_INCLUDE_TESTS=Off \
        -DLIBCXX_INCLUDE_BENCHMARKS=Off \
        -DLIBCXX_USE_COMPILER_RT=true \
        -DLIBCXX_HAS_MUSL_LIBC=On \
        -DLIBUNWIND_USE_COMPILER_RT=true \
        -DLIBCXXABI_USE_COMPILER_RT=true \
        -DLIBCXX_ENABLE_STATIC=Off \
        -DLIBCXXABI_ENABLE_STATIC=Off \
        -DLIBUNWIND_ENABLE_STATIC=Off \
        -DCMAKE_CXX_FLAGS="-nostdlib $LIBCC_PATH/lib/clang/21/lib/linux/libclang_rt.builtins-aarch64.a"
}

pkgbuild() {
    cmake --build build
}

pkginstall() {
    cmake --install build --strip

    rm -rf "$pkgroot/usr/share" \
        "$pkgroot/usr/include/c++/v1/__cxx03/experimental" \
        "$pkgroot/usr/include/c++/v1/experimental" \
        "$pkgroot/usr/lib/libc++experimental.a"
}
