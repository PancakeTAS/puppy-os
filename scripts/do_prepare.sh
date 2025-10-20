#!/usr/bin/env bash
if [ -z "$1" ]; then
    echo "Usage: ./puppyos.sh prepare <device>"
    exit 1
fi

set -euo pipefail

echo "==> This script will erase all data on $1. To cancel, press Ctrl+C within 3 seconds."
sleep 3

echo "==> Creating new GPT partition table..."
sgdisk -Z -a 1 \
    -n '1:1024:4095' -c '1:bl2' -t '1:ef02' -A '1:set:2' \
    -n '2:4096:8191' -c '2:fip' -t '2:b000' \
    -n '3:8192:73727' -c '3:kernel' -t '3:0700' \
    -n '4:73728:598015' -c '4:root' -t '4:8300' \
    -n '5:598016:0' -c '5:data' -t '5:8300' \
    "$1" > /dev/null

if [[ "$1" =~ [0-9]$ ]]; then
    device_="${1}p"
else
    device_="$1"
fi

echo "==> Creating filesystems..."
dd if=/dev/zero bs=512 count=4 | tee "${device_}"{3,4,5} >/dev/null
mkfs.vfat -n KERNEL "${device_}3"
mkfs.ext4 -L ROOTFS "${device_}4"
mkfs.f2fs -l DATA   "${device_}5"

echo "==> Done."
