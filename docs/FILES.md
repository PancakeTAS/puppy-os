This file attempts to document the files and directories each package may read or write to.
Anything in the standard libraries /dev, /proc, /tmp, /sys, /var/run, /run is not mentioned here,
though keep in mind that stuff like /dev/shm is not always present.

Here's all programs that do NOT require any files:
- brotli, bzip2, lz4, xz, zlib, zstd
- libxcrypt
- libmnl, libnftnl
- iputils, iw
- procps-ng
- toybox

== musl
- /bin/sh: used for anything executing processes
- /etc/passwd: used for various user lookups
- /etc/shadow: used for password lookups
- /etc/group: used for various group lookups
- /etc/resolv.conf: resolving DNS
- /etc/hosts: also resolving DNS
- /etc/services: used for name resolution
- /etc/shells: required by getusershells()
- /usr/share/zoneinfo: used by various localization
- /etc/localtime: used for time zones

== libcxx
- /usr/share/zoneinfo: used by various localization
- /etc/localtime: used for time zones

== openssl
- </etc>/ssl: obviously

== libnl
- </etc>/libnl: obviously

== ncurses
- </usr/share>/terminfo: database

== hostapd
- </etc>/hostapd: obviously

== iproute2
- </usr/share>/iproute2: database

== nftables
- </etc>/passwd, </etc>/group: printing uid/gid
- </etc>/services: translating services
- </etc>/protocols: translating protocols

== attr
- </etc>/xattr.conf: main configuration

== file
- <usr/share>/misc/magic/magic.msc: file detection stuff

== kmod
- </etc,/usr/lib>/modprobe.d: main configuration
- </usr/lib>/modules/<kernel>: modules information from a kernel

== util-linux
- /etc/adjtime: for hwclock
- /etc/fstab, /etc/mtab: for mount
- /etc/subuid, /etc/subgid: required for all things user
- /etc/shells: also required for things
- /etc/passwd, /etc/gshadow, /etc/group, /etc/shadow: required for all things users

== dash
- /etc/profile
