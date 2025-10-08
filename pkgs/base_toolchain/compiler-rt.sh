#!/bin/sh

# metadata
pkgname="compiler-rt"
_pkgname="llvm"
pkgver="21.1.2"
pkgdesc="compiler-rt runtime libraries"
pkgurl="https://compiler-rt.llvm.org/"
pkglic="Apache-2.0 (LLVM-exception)"

# build information
pkgdeps=(
    "linux-headers-6.17"
    "musl-headers-1.2.5"
)
pkgsrcs=(
    "https://github.com/$_pkgname/$_pkgname-project/archive/refs/tags/llvmorg-$pkgver.tar.gz"
)

# build scripts
pkgprepare() {
    cd $_pkgname-project-llvmorg-$pkgver

    cmake -S compiler-rt -B build -G Ninja \
        -DCMAKE_INSTALL_PREFIX="$pkgroot/lib/clang/21" \
        -DCMAKE_SYSROOT="$buildroot" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_CXX_COMPILER=clang++ \
        -DCMAKE_C_COMPILER=clang \
        -DCMAKE_ASM_COMPILER_TARGET="aarch64-dog-linux-musl" \
        -DCMAKE_CXX_COMPILER_TARGET="aarch64-dog-linux-musl" \
        -DCMAKE_C_COMPILER_TARGET="aarch64-dog-linux-musl" \
        -DCOMPILER_RT_DEFAULT_TARGET_ONLY=ON \
        -DCOMPILER_RT_BUILD_CTX_PROFILE=OFF \
        -DCOMPILER_RT_BUILD_SANITIZERS=OFF \
        -DCOMPILER_RT_BUILD_LIBFUZZER=OFF \
        -DCOMPILER_RT_BUILD_BUILTINS=ON \
        -DCOMPILER_RT_BUILD_MEMPROF=OFF \
        -DCOMPILER_RT_BUILD_PROFILE=OFF \
        -DCOMPILER_RT_BUILD_XRAY=OFF \
        -DCOMPILER_RT_BUILD_ORC=OFF \
        -DCOMPILER_RT_BUILD_CRT=ON \
        -DCMAKE_CXX_FLAGS="-nostdlib" \
        -DCMAKE_C_FLAGS="-nostdlib"
}

pkgbuild() {
    cmake --build build
}

pkginstall() {
    cmake --install build --strip
}
