#!/usr/bin/env bash

pkgname="puppyos"
pkgver="1.0.0"
pkgsrcs=()

pkgprepare() {
    echo "awrruff,, puppy need not prepare :3"
}

pkgbuild() {
    cp -r "$filesdir"/* \
        "$pkgdir/"
}

pkginstall() {
    echo "nothing to install :3"
}
