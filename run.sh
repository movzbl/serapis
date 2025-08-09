#!/bin/sh

set -e

(sleep 0.5; wmctrl -r "QEMU" -e 0,400,30,1238,960) &

qemu-system-x86_64 -cpu host \
                   -enable-kvm \
                   -smp 8 \
                   -m 1G \
                   -bios /usr/share/ovmf/OVMF.fd \
                   -drive file=fat:rw:build/disk,format=raw,media=disk \
                   -vga std \
                   -display gtk,zoom-to-fit=on \
                   -net none
