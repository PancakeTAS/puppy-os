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
  "compiler-rt-21.1.2"
  "linux-6.16.9"
  "musl-1.2.5"
)
pkgsrcs=(
    "https://github.com/$_pkgname/$_pkgname-project/archive/refs/tags/llvmorg-$pkgver.tar.gz"
)

# build scripts
pkgprepare() {
    cd $_pkgname-project-llvmorg-$pkgver

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
        -DCMAKE_CXX_FLAGS="-nostdlib $buildroot/usr/lib/linux/libclang_rt.builtins-aarch64.a" \
        -DCMAKE_C_FLAGS="-unwindlib=none"
}

pkgbuild() {
    cmake --build build
}

pkginstall() {
    cmake --install build

    llvm-strip --strip-unneeded \
        "$pkgroot/usr/lib/libunwind.so.1.0" \
        "$pkgroot/usr/lib/libc++abi.so.1.0" \
        "$pkgroot/usr/lib/libc++.so.1.0"

    rm -rf "$pkgroot/usr/share"
}
