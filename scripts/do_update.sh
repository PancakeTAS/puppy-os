#!/usr/bin/env bash
if [ -z "$1" ]; then
    echo "Usage: ./puppyos.sh update <device>"
    exit 1
fi

set -euo pipefail

echo "==> This script will update the first four partitions on $1. To cancel, press Ctrl+C within 3 seconds."
sleep 3

if [[ "$1" =~ [0-9]$ ]]; then
    device_="${1}p"
else
    device_="$1"
fi

echo "==> Writing BL2..."
dd if=./target/bl2.img of="${device_}1" conv=fsync

echo "==> Writing FIP..."
dd if=./target/fip.img of="${device_}2" conv=fsync

echo "==> Writing kernel partition..."
mount "${device_}3" /mnt
rm -rf /mnt/*
cp -r ./target/kernel/* /mnt/
chown -R 0:0 /mnt/*
umount /mnt

echo "==> Writing root filesystem..."
mount "${device_}4" /mnt
rm -rf /mnt/*
cp -ar ./target/rootfs/* /mnt/
chown -R 0:0 /mnt/*
umount /mnt

echo "==> Done."
