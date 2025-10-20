# Toolchain

This guide describes how to build the toolchain for PuppyOS.

## Building the toolchain

Download and extract the LLVM 21 release tarball, then build LLVM using the following command:
```bash
$ cmake -S llvm -B build -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_SYSTEM_NAME="Linux" \
  -DCMAKE_INSTALL_PREFIX="PATH-TO-TOOLCHAIN" \
  -DCMAKE_C_COMPILER=clang \
  -DCMAKE_CXX_COMPILER=clang++ \
  -DLLVM_ENABLE_LTO=Thin \
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
  -DDEFAULT_SYSROOT="/tmp/puppyos-sysroot"
$ cmake --build build
$ cmake --install build --strip
```

If you wish to compile without LTO to speed up the build significantly, remove `-DLLVM_ENABLE_LTO=Thin`. Make sure PATH-TO-TOOLCHAIN is adjusted to point to `<repo-root/toolchain>` (or wherever you'd like to install the toolchain to).

Temporarily create the `/tmp/puppyos-sysroot` directory.

Next, download and extract the kernel tarball and install them to `/tmp/puppyos-sysroot`. This is required to build the compiler runtimes:
```bash
$ make ARCH=arm64 headers
$ make ARCH=arm64 INSTALL_HDR_PATH="/tmp/puppyos-sysroot/usr" headers_install
```

Do the same for the musl tarball (NOTE: You will need to supply _any_ valid compiler capable of compiling to aarch64 for autoconf to succeed.):
```bash
$ mkdir -p build && cd build
$ ../configure \
    --prefix=/usr \
    --target=aarch64-dog-linux-musl \
    CROSS_COMPILE= CC=clang
$ make DESTDIR="/tmp/puppyos-sysroot" install-headers
```
Finally, head back into the LLVM release tarball and build compiler-rt:
```bash
$ export PATH="PATH-TO-TOOLCHAIN/bin:$PATH"
$ cmake -S compiler-rt -B build -G Ninja \
  -DCMAKE_INSTALL_PREFIX="PATH-TO-TOOLCHAIN/lib/clang/21" \
  -DCMAKE_SYSROOT="/tmp/puppyos-sysroot" \
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
$ cmake --build build
$ cmake --install build --strip
```

That's it, the toolchain is now installed to `toolchain`. Make sure to add the contained bin folder to your path when building!
