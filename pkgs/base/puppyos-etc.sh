#!/usr/bin/env bash

pkgname="puppyos-etc"
pkgver="1.0.0"
pkgsrcs=()

pkgprepare() {
    echo "awrruff,, puppy need not prepare :3"
}

pkgbuild() {
    mkdir -p "$pkgdir/etc"
    cd "$pkgdir/etc"

    # users
    echo "root:x:0:0::/root:/usr/bin/dash" > passwd
    echo "root::::::::" > shadow

    # groups
    echo "root:x:0:root" > group
    echo "root:::root" > gshadow

    # shells
    echo "/bin/sh" > shells
    echo "/usr/bin/sh" >> shells
    echo "/usr/bin/dash" >> shells

    # dns
    echo "nameserver 1.1.1.1" > resolv.conf

    # hosts
    echo "127.0.0.1 localhost" > hosts
    echo "::1 localhost" >> hosts

    # file systems
    touch fstab
    touch mtab

    # misc
    echo "puppy-os" > hostname
    echo "LANG=C.UTF-8" > locale.conf
    ln -s /usr/share/zoneinfo/Europe/Berlin localtime
    cp "$filesdir/profile" profile
}

pkginstall() {
    echo "nothing to install :3"
}
