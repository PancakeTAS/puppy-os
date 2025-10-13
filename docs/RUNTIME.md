# Runtime

Short and simple description of the hardware process, getting from zero to something on the Mediatek SoC.

The hardware powers on and is hardwired to read and execute the first stage bootloader (bl1) from the TF-A (ARM Trusted Firmware) project.

The bootloader searches for a partition called "bl2" with the legacy BIOS attribute set on the SD card and jumps to it.

The bootloader "bl2", now with an initialized serial console, searches for a partition called "fip", which is a special image format that contains the third stage bootloader "bl31" as well as any other binary blob "bl33" we provide (this would be U-Boot in our case).

U-Boot is then programmed to load the kernel and execute it. U-Boot also loads a flattened device tree. A device tree is a datastructure used on SoCs that describes at which memory adresses all hardware components are positioned. Unlike something like PCIe, there isn't a standardized way to "scan" for hardware, which is why a DTB (device tree blob) is required.

The kernel arguments passed to Linux from U-Boot tell it to mount the next partition as root partition and execute the runit init system.

The runit init system on the now fresh Linux system can barely be considered an init system, as all the initialization is written in bash by the user. It executes the `1` file, which mounts the essential virtual file systems and some other misc things (check out the script to see the full initialization).

After executing `1`, runit launches it's primitive service manager (read the runit wiki for more information) and hands off serial to the main shell (dash).
