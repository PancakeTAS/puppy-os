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
    "linux-6.16.9"
)
pkgsrcs=(
    "https://musl.libc.org/releases/musl-1.2.5.tar.gz"
    "https://github.com/$_pkgname/$_pkgname-project/archive/refs/tags/llvmorg-$pkgver.tar.gz"
)

# build scripts
pkgprepare() {
    cd musl-1.2.5
    mkdir -p build && cd build

    ../configure \
        --prefix=/usr \
        --target=aarch64-dog-linux-musl \
        CROSS_COMPILE= CC=clang

    DESTDIR="$buildroot" make install-headers

    cd ../..
    cd $_pkgname-project-llvmorg-$pkgver

    cmake -S compiler-rt -B build -G Ninja \
        -DCMAKE_INSTALL_PREFIX="$pkgroot/usr" \
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

    mkdir -p "$pkgroot/usr/lib/clang/lib"
    mv "$pkgroot/usr/lib/linux" \
        "$pkgroot/usr/lib/clang/lib/aarch64-dog-linux-musl"

    cd "$pkgroot/usr/lib/clang/lib/aarch64-dog-linux-musl"
    mv "libclang_rt.builtins-aarch64.a" "libclang_rt.builtins.a"
    mv "clang_rt.crtbegin-aarch64.o" "crtbeginS.o"
    mv "clang_rt.crtend-aarch64.o" "crtendS.o"
}
