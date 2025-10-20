# Runtime

Short and simple description of the hardware process, getting from zero to something on the Mediatek SoC.

The hardware powers on and is hardwired to read and execute the first stage bootloader (bl1) from the TF-A (ARM Trusted Firmware) project.

The bootloader searches for a partition called "bl2" with the legacy BIOS attribute set on the SD card and jumps to it.

The bootloader "bl2", now with an initialized serial console, searches for a partition called "fip", which is a special image format that contains the third stage bootloader "bl31" as well as any other binary blob "bl33" we provide (this would be U-Boot in our case).

U-Boot is then programmed to load the kernel and execute it. U-Boot also loads a flattened device tree. A device tree is a datastructure used on SoCs that describes at which memory adresses all hardware components are positioned. Unlike something like PCIe, there isn't a standardized way to "scan" for hardware, which is why a DTB (device tree blob) is required.

The kernel arguments passed to Linux from U-Boot tell it to mount the next partition as read-only root partition and execute the "init system".

The "init system" is a fairly simple shell script, which mounts the usual virtual filesystems, as well as the "overlay" filesystem, containing configuration files and more. It then replaces itself with runit.

The runit system is configured by you.
