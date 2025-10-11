#!/usr/bin/env bash

pkgname="puppyos-init"
pkgver="1.0.0"
pkgsrcs=()

pkgprepare() {
    echo "awrruff,, puppy need not prepare :3"
}

pkgbuild() {
    cd "$pkgdir"

    # set default shell
    mkdir -p usr/bin
    ln -s dash usr/bin/sh

    # set init system
    ln -s runit usr/bin/init

    # create runit structure
    mkdir -p etc
    cp -r "$filesdir"/runit etc/

}

pkginstall() {
    echo "nothing to install :3"
}
