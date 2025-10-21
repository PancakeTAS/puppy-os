#!/usr/bin/env bash

pkgname="libc++"
_pkgname="llvm"
pkgver="21.1.2"
pkgsrcs=(
    "https://github.com/$_pkgname/$_pkgname-project/archive/refs/tags/llvmorg-$pkgver.tar.gz"
)

pkgprepare() {
    cd ${_pkgname}-project-llvmorg-${pkgver}

    cmake -S runtimes -B build -G Ninja \
        -DCMAKE_INSTALL_PREFIX=$pkgdir/usr \
        -DCMAKE_INSTALL_LOCALSTATEDIR="var" \
        -DCMAKE_INSTALL_DATAROOTDIR="share" \
        -DCMAKE_INSTALL_RUNSTATEDIR="run" \
        -DCMAKE_INSTALL_SYSCONFDIR="etc" \
        -DCMAKE_INSTALL_LIBEXECDIR="lib" \
        -DCMAKE_INSTALL_DATADIR="share" \
        -DCMAKE_INSTALL_SBINDIR="bin" \
        -DCMAKE_INSTALL_LIBDIR="lib" \
        -DCMAKE_INSTALL_LOCALEDIR="share/locale" \
        -DCMAKE_INSTALL_INFODIR="share/info" \
        -DCMAKE_INSTALL_MANDIR="share/man" \
        -DCMAKE_INSTALL_DOCDIR="share/doc" \
        -DCMAKE_SYSROOT=/puppyos/target/rootfs \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=On \
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
        -DCMAKE_CXX_FLAGS="-nostdlib /toolchain/lib/clang/21/lib/linux/libclang_rt.builtins-aarch64.a"
}

pkgbuild() {
    cmake --build build
}

pkginstall() {
    cmake --install build --strip

    rm -r \
        $pkgdir/usr/share \
        $pkgdir/usr/include/c++/v1/__cxx03/experimental \
        $pkgdir/usr/include/c++/v1/experimental \
        $pkgdir/usr/lib/libc++experimental.a
}
