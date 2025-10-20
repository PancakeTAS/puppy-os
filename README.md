# PuppyOS

PuppyOS is a self-compiled, minimalistic operating system designed for the Banana Pi BPI-R4. It is fully compiled using LLVM and does not utilize any GNU projects in the final sysroot.

## Getting Started

### Toolchain

Before you can compile PuppyOS, you need to build a slightly modified version of the LLVM toolchain. This process is described in docs/TOOLCHAIN.md and should be followed carefully.

Please note that the toolchain does not contain every single program required to build PuppyOS. Should you be missing an executable during the build process, simply install it and continue the build.

### Buildscript

The buildscript will download source packages to `dlcache` and extract them to `build`, where after successful build, the package is cached in `cache` and installed to `target`.

It is highly recommended to mount `build` and `target` in memory, if your machine has at least 32GB of RAM:
```bash
mkdir -p /tmp/puppyos-{target,build}
ln -s /tmp/puppyos-build/ build
ln -s /tmp/puppyos-target/ target
```

Next, you should create a `.env` file with the following contents:
```bash
export PATH="path-to-toolchain/bin:$PATH" # ensure the toolchain is first in path
export MAKEFLAGS="-j32" # change 32 to the amount of cores you'd like to build for traditional make
export HOSTCLANG="/bin/clang" # point this to the full path of your host system compiler
unset TERMINFO # terminals with custom TERMINFO such as kitty will cause issues otherwise.
```

In order to start the build process, execute the buildscript through fakeroot:
`fakeroot ./puppyos.sh build`

### Installation

After successful compilation, the installed system resides in the `target` folder.

Before being able to install this system, you need to create the partition table and filesystems on the SD card:
`sudo ./puppyos.sh prepare /dev/<sd card>`

With the partition table ready, you can install/update PuppyOS using this command:
`sudo ./puppyos.sh update /dev/<sd card>`

DO NOT RERUN `./puppyos.sh prepare` WHEN UPDATING THE SYSTEM!

### Post Installation

You will need to set up basic files to get your Linux system to run.

I have provided a simple guide in `docs/CONFIGS.md`, but you might wish to set up your system completely differently.

## More Information

When building a new Linux system, it is important to keep track of which files are accessed by which program or library. This is achieved (with questionable accuracy) in docs/FILES.md.

If you're interested, the process of getting from poweron to usable Linux shell is also described in docs/RUNTIME.md.
