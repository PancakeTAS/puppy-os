# PuppyOS

PuppyOS is a self-compiled, minimalistic operating system designed for the Banana Pi BPI-R4. It is fully compiled using LLVM and does not utilize any GNU projects in the final sysroot.

## Getting Started

Before you can compile PuppyOS, you need to build the toolchain. This is a manual process, so the user can ensure the toolchain is functioning as intended before wasting precious cycles on compiling the rest of the system.

Read TOOLCHAIN.md for more information on building the toolchain.

It should be noted that the toolchain does not contain *all* tools required to build the system. There is also no documentation for which binaries are required, although I should mention that you HAVE to have a clang compiler, capable of compiling for AArch64 in /bin/clang (this is hardcoded, sorry about that).

The build script attempts to properly cleanup before exiting in case of errors, though do not rely on this and check for yourself.

If you've got all that, simply execute `build.sh` to build the system.

## More Information

When building a new Linux system, it is important to keep track of which files are accessed by which program or library. This is achieved (with questionable accuracy) in FILES.md.

If you're interested, the process of getting from poweron to usable Linux shell is also described in RUNTIME.md.
