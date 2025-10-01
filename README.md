## Package Manager: doggy

This project uses an in-house package manager "doggy" to save time recompiling. In order to set up doggy, you must first manually prepare the toolchain:
```bash
$ doggy -p pkgs_toolchain -c cache_toolchain [-b /dev/shm/dog] llvm
$ mkdir -p toolchain && tar xJf cache_toolchain/pkgs/llvm -C toolchain
$ rm -rf cache_toolchain
```
Now you can compile any package like this, which will automatically compile all dependencies:
```bash
$ doggy -b /dev/shm/dog <package>
```
