# PuppyOS

PuppyOS is a self-compiled, minimalistic operating system designed for the Banana Pi BPI-R4. It is fully compiled using LLVM and does not utilize any GNU projects in the final sysroot.

## Getting Started

Compiling PuppyOS is a fairly simple process and can be done on nearly any system thanks to Docker.

Quick note, the "Preparing the toolchain" section may take quite a bit of time, it may be worth reading it _before_ this next section.

### Preparing the installation drive

This step creates the required partitions on your SD card or similar. Please note that PuppyOS uses an immutable base image hosted on a separate partition than configuration files and runtime data. Using the later "update" steps, it is possible to replace the bootloader, kernel and immutable base image while keeping all system files untouched.

First you will need to create the appropriate partitions for PuppyOS:
```bash
sgdisk -Z -a 1 \
    -n '1:1024:4095' -c '1:bl2' -t '1:ef02' -A '1:set:2' \
    -n '2:4096:8191' -c '2:fip' -t '2:b000' \
    -n '3:8192:73727' -c '3:kernel' -t '3:0700' \
    -n '4:73728:598015' -c '4:root' -t '4:8300' \
    -n '5:598016:0' -c '5:data' -t '5:8300' \
    "/dev/<specify the block device here>"
```

Next, you should create the partitions. PuppyOS uses the flash-friendly filesystem.
```bash
mkfs.vfat -n KERNEL "/dev/<block device>p3"
mkfs.f2fs -l ROOTFS "/dev/<block device>p4"
mkfs.f2fs -l DATA   "/dev/<block device>p5"
```

If you wish to use a different filesystem for the rootfs partition, you must also edit the `rootfstype` in the U-Boot environment file located at `src/resources/u-boot/env.txt`.

### Preparing the toolchain

Before you can compile PuppyOS, you need to build a slightly modified version of clang+lld. This, alongside the remaining required utilities are built into a Docker image.

You can build the docker image by running the following in your console:
```bash
docker buildx build -t puppyos .
```

### Building with Docker

If you built the Docker image as described, then you should be able to run the Docker container now to compile PuppyOS:
```bash
docker run -it \
    --tmpfs /puppyos/build:exec \
    --tmpfs /puppyos/target:exec \
    -v "$(pwd)/cache:/puppyos/cache" \
    -v "$(pwd)/dlcache:/puppyos/dlcache" \
    -v "$(pwd)/src:/puppyos/src" \
    -v "$(pwd)/output:/puppyos/output" \
    puppyos
```

It is recommended to mount `build` and `target` in memory to speed up compilation and reduce flash degradation, however should you be on limited memory (less than 32 gigabytes) you may choose to omit the two flags responsible.

You may optionally decide not to persist the cache or download cache. If you choose to do that, then you may get rid of the two options for that as well.

The output files will be in <...>

### Installing or Updating the System

After successful compilation, the next step is to write the first four partitions to the drive.
For your convenience, the `update.sh` script has been provided:
```bash
sudo ./update.sh /dev/<block device>
```

### Post Installation

If this is your first time installing PuppyOS, you will need to mount the last partition and set up essential files for the Linux machine to work.

I have provided a simple guide in docs/CONFIGS.md you can follow which also explains the basics of the runit service management.

## More Information

When building a new Linux system, it is important to keep track of which files are accessed by which program or library. This is achieved (with questionable accuracy) in docs/FILES.md.

If you're interested, the process of getting from poweron to usable Linux shell is also described in docs/RUNTIME.md.
