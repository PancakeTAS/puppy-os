FROM archlinux:latest

# first pass dependencies
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm \
        base-devel wget python \
        cmake ninja \
        clang lld \
        rsync && \
    pacman -Scc --noconfirm

WORKDIR /build

# compile llvm
RUN wget -qO- "https://github.com/llvm/llvm-project/releases/download/llvmorg-21.1.6/llvm-project-21.1.6.src.tar.xz" | \
        tar xJ && \
    cd /build/llvm-project-21.1.6.src && \
    cmake -S llvm -B build -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_SYSTEM_NAME="Linux" \
        -DCMAKE_INSTALL_PREFIX=/toolchain \
        -DCMAKE_C_COMPILER=clang \
        -DCMAKE_CXX_COMPILER=clang++ \
        -DLLVM_USE_LINKER=lld \
        -DLLVM_ENABLE_LTO=Thin \
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
        -DDEFAULT_SYSROOT=/puppyos/target/rootfs && \
    cmake --build build && \
    cmake --install build --strip && \
    cd ../.. && \
    rm -rf /build/llvm-project-21.1.6.src

RUN mkdir -p /tmp/puppyos-sysroot

# grab kernel headers
RUN wget -qO- "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.17.tar.xz" | \
        tar xJ && \
    cd /build/linux-6.17 && \
    make ARCH=arm64 headers -j$(nproc) && \
    make ARCH=arm64 INSTALL_HDR_PATH="/tmp/puppyos-sysroot/usr" headers_install -j$(nproc) && \
    cd ../.. && \
    rm -rf /build/linux-6.17

# grab musl headers
RUN wget -qO- "https://musl.libc.org/releases/musl-1.2.5.tar.gz" | \
        tar xz && \
    cd /build/musl-1.2.5 && \
    ./configure \
        --prefix=/usr \
        --host=aarch64-dog-linux-musl \
        CROSS_COMPILE= CC=clang && \
    make DESTDIR="/tmp/puppyos-sysroot" install-headers -j$(nproc) && \
    cd ../.. && \
    rm -rf /build/musl-1.2.5

ENV PATH="/toolchain/bin:$PATH"

# build compiler-rt
RUN wget -qO- "https://github.com/llvm/llvm-project/releases/download/llvmorg-21.1.6/llvm-project-21.1.6.src.tar.xz" | \
        tar xJ && \
    cd /build/llvm-project-21.1.6.src && \
    cmake -S compiler-rt -B build-rt -G Ninja \
        -DCMAKE_INSTALL_PREFIX="/toolchain/lib/clang/21" \
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
        -DCMAKE_C_FLAGS="-nostdlib" && \
    cmake --build build-rt && \
    cmake --install build-rt --strip && \
    cd ../.. && \
    rm -rf /build/llvm-project-21.1.6.src

RUN rm -rf /build

# second pass dependencies
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm \
        fakeroot meson \
        dtc uboot-tools \
        tinyxxd \
        bc && \
    pacman -Scc --noconfirm

# prepare puppy-os environment
WORKDIR /puppyos

RUN mkdir -p \
    dlcache cache \
    build target \
    src output

# start bash by default
CMD ["./src/make.sh"]
