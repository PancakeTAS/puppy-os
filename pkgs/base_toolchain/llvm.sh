#!/bin/sh

# metadata
pkgname="llvm"
pkgver="21.1.2"
pkgdesc="llvm toolchain"
pkgurl="https://llvm.org/"
pkglic="Apache-2.0 (LLVM-exception)"

# build information
pkgdeps=(
)
pkgsrcs=(
    "https://github.com/$pkgname/$pkgname-project/archive/refs/tags/llvmorg-$pkgver.tar.gz"
)

# build scripts
pkgprepare() {
    cd $pkgname-project-llvmorg-$pkgver

        # -DLLVM_ENABLE_LTO=Thin \

    cmake -S llvm -B build -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_SYSTEM_NAME="Linux" \
        -DCMAKE_INSTALL_PREFIX="$pkgroot" \
        -DLLVM_CCACHE_BUILD=On \
        -DCMAKE_C_COMPILER=clang \
        -DCMAKE_CXX_COMPILER=clang++ \
        -DLLVM_USE_LINKER=lld \
        -DLLVM_TARGETS_TO_BUILD=AArch64 \
        -DLLVM_BUILD_TOOLS=On \
        -DLLVM_ENABLE_EH=On \
        -DLLVM_ENABLE_RTTI=On \
        -DLLVM_ENABLE_LIBCXX=On \
        -DLLVM_ENABLE_PROJECTS="clang;lld" \
        -DLLVM_ENABLE_RUNTIMES="" \
        -DLLVM_DEFAULT_TARGET_TRIPLE=aarch64-dog-linux-musl \
        -DCLANG_DEFAULT_RTLIB="compiler-rt" \
        -DCLANG_DEFAULT_CXX_STDLIB="libc++" \
        -DCLANG_DEFAULT_LINKER="lld" \
        -DDEFAULT_SYSROOT="/tmp/dog-buildroot"
}

pkgbuild() {
    cmake --build build
}

pkginstall() {
    cmake --install build --strip
}
