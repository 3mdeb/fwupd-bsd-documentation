#!/bin/bash

if [ ! -f disk.qcow2 ]; then
    echo "disk.qcow2 doesn't exists! Run setup.sh first."
    exit 1
fi

if [ ! -f OVMF.fd ]; then
    echo 'OVMF.fd is missing!'
    exit 1
fi

qemu-system-x86_64 -m 2048 \
                   -drive if=virtio,file=disk.qcow2,format=qcow2 \
                   -enable-kvm \
                   -netdev user,id=mynet0,hostfwd=tcp:127.0.0.1:9272-:22 \
                   -device virtio-net,netdev=mynet0 \
                   -bios OVMF.fd \
                   -smp $(nproc) \
                   -cpu host \
                   -serial stdio \
                   -display none \
                   -s
