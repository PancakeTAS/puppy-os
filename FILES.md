# Files

This file attempts to document the files and directories each package may read or write to.

It is assumed that the following mountpoints exist:
- `/dev`: Must be the kernels devfs.
- `/proc`: Must be the kernels virtual proc filesystem.
- `/sys`: Must be the kernels sysfs.
- `/run`: Should be a tmpfs.
- `/tmp`: Should be a tmpfs with the sticky bit set.
- `/var/lock`: Should be a tmpfs or symlink to `../run/lock`.
- `/var/tmp`: Should be a normal directory with the sticky bit set.
- `/var/run`: Should be a tmpfs or symlink to `../run`.

## Projects without special file acess

After examining various packages, the following is a list of projects that do not read outside of the aforementioned directories.

As of right now, not a single compression library uses any system directories.
- brotli
- bzip2
- lz4
- xz
- zlib
- zstd

The following libraries do not use system directories either:
- libxcrypt
- libmnl
- libnftnl

These userspace tools do not use any system directories either:
- iputils
- iw
- procps-ng
- toybox
- iperf3
- less
- traceroute

## Projects with special files access

### musl - The C standard library

The C standard library obviously requires various files.

Anything related to user or group lookups requires these files:
- `/etc/passwd`
- `/etc/shadow`
- `/etc/group`
- `/etc/shells`

Various things related to name or address resolution utilize these:
- `/etc/resolv.conf`
- `/etc/hosts`
- `/etc/services`

Localization methods require these files:
- `/usr/share/zoneinfo`
- `/etc/localtime`

### libc++ - The C++ standard library

The C++ standard library only relies on certain localization files:
- `/usr/share/zoneinfo`
- `/etc/localtime`

### nftables - The userspace firewall management

The `nft` utility may decide to showcase user and group ids:
- `/etc/passwd`
- `/etc/group`

.. or translate ports into services using:
- `/etc/services`
- `/etc/protocols`

### kmod - Kernel management utils

The kmod configuration files lie in:
- `/etc/modprobe.d`
- `/usr/lib/modprobe.d`

Furthermore, kernel information is accessed from:
- `/usr/lib/modules/<uname>`

### util-linux - Linux utilities

When using `login` or similar utils, these directories are required:
- `/etc/passwd`
- `/etc/shadow`
- `/etc/group`
- `/etc/gshadow`
- `/etc/subuid`
- `/etc/subgid`
- `/etc/shells`

Finally, using `mount` uses these files:
- `/etc/fstab`
- `/etc/mtab`

### dhcpcd - DHCP control daemon

This one is a bit more intricate:
- `/etc/dhcpcd.conf`
- `/usr/lib/dhcpcd-run-hooks`
- `/usr/lib/dhcpcd`
- `/var/lib/dhcpcd`

It also reads/writes optional files from hooks

### dnsmasq - DNS (and more) server

Nothing out of the ordinary:
- `/var/lib/misc/dnsmasq.leases`
- `/etc/dnsmasq.conf`
- `/etc/resolv.conf`
- `/etc/hosts`
- `/etc/ethers`

### hostapd - HostAP daemon (this INCLUDES wpa_supplicant)

HostAPD uses seemingly random files:
- `/etc/tnc_config`
- `/etc/ssl`
- `/usr/bin/x-www-browser` ???

### ntpd - NTP daemon

Files as expected:
- `/etc/ntpd.conf`
- `/var/db/ntpd.drift`

### pciutils - PCI Utilities

Files as expected:
- `/etc/pci`
- `/lib/modules/`

### ... - Various projects

The following is a list of projects that only require one simple path:
- openssl: `/etc/ssl`
- ncurses: `/usr/share/terminfo`
- iproute2: `/usr/share/iproute2`
- attr: `/etc/xattr.conf`
- file: `/usr/share/misc/magic.msc`
- dash: `/etc/profile`
- lsof: `/etc/mtab`
- psmisc: `/etc/mtab`
- htop: `/etc/os-release`
- vim: `/usr/share/vim`
- wireguard-tools: `/etc/wireguard`
- lm-sensors: `/etc/sensors[3].conf`
- btop: `/usr/share/btop`
