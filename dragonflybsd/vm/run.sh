#!/usr/bin/env bash

if [ ! -f disk.qcow2 ]; then
    echo "disk.qcow2 doesn't exists! Run setup.sh first."
    exit 1
fi

echo "Running QEMU..."
qemu-system-x86_64 -m 2048 \
                   -drive if=virtio,file=disk.qcow2,format=qcow2 \
                   -enable-kvm \
                   -display gtk \
                   -netdev user,id=mynet0,hostfwd=tcp:127.0.0.1:9272-:22 \
                   -device e1000,netdev=mynet0 \
                   -bios OVMF.fd \
                   -smp 6 \
                   -s \
                   -cpu host
