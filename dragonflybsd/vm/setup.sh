#!/usr/bin/env bash

if [ ! -f dfly-x86_64-6.2.2_REL.iso ]; then
    echo "dfly-x86_64-6.2.2_REL.iso doesn't exists!"
    echo "I will try to download it from dragonflybsd.org..."
    wget https://mirror-master.dragonflybsd.org/iso-images/dfly-x86_64-6.2.2_REL.iso
    echo "Run script again or download iso manually"
    exit 1
fi

if [ ! -f disk.qcow2 ]; then
    echo "Preparing virtual disk..."
    qemu-img create -f qcow2 disk.qcow2 15G
fi

echo "Running QEMU..."
qemu-system-x86_64 -m 2048 -boot d \
   -bios OVMF.fd \
   -cdrom dfly-x86_64-6.2.2_REL.iso \
   -drive if=virtio,file=disk.qcow2,format=qcow2 \
   -netdev user,id=mynet0,hostfwd=tcp::9272-:22 \
   -device e1000,netdev=mynet0 -enable-kvm -smp 4 -cpu host
