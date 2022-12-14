#!/bin/bash

VERSION="9.99.100"
ARCH="amd64"

IMAGE_FILENAME="NetBSD-$VERSION-$ARCH.iso"

IMAGE_PATH="$NETBSD_OBJ/releasedir/images/$IMAGE_FILENAME"

function delete_confirmation() {
    if [ ! -f disk.qcow2 ]; then
        return
    else
        echo "Setup utility will permanently delete the previous disk image!"
        while true; do
            read -p "Do you want to proceed? y/n " yn
            case $yn in
                [Yy]* ) rm disk.qcow2; break;;
                [Nn]* ) exit 1;;
                * ) echo "Please answer yes or no.";;
            esac
        done
    fi 
}

function safety_checks() {
    if [ -f disk.qcow2 ]; then
        echo "disk.qcow2 already exists, won't format! Remove it to do setup."
        exit 1
    fi

    if [ ! -f $IMAGE_PATH ]; then
        echo "Installer image .iso not found, copy it or create a symlink here"
        exit 1
    fi
}

function dependency_checks() {
    local fulfilled=y

    if [ ! -f OVMF.fd ]; then
        echo 'OVMF.fd is missing!'
        fulfilled=n
    fi

    if ! command -v qemu-img > /dev/null; then
        echo 'qemu-img not found!'
        fulfilled=n
    fi

    if ! command -v qemu-system-x86_64 > /dev/null; then
        echo 'qemu-system-x86_64 not found!'
        fulfilled=n
    fi

    if [ "$fulfilled" != y ]; then
        exit 1
    fi
}

function install_netbsd() {
    echo ">>>> Starting installation..."

    echo "  >> Creating image"
    qemu-img create -f qcow2 disk.qcow2 32G

    echo "  >> Running QEMU"
    qemu-system-x86_64 \
        -m 2048 \
        -boot d \
        -bios OVMF.fd \
        -cdrom $IMAGE_FILENAME \
        -drive if=virtio,file=disk.qcow2,format=qcow2 \
        -enable-kvm \
        -netdev user,id=mynet0,hostfwd=tcp::7722-:22 \
        -device virtio-net,netdev=mynet0 \
	-smp $(nproc) \
        -cpu host
}

delete_confirmation
ln -sf $IMAGE_PATH $IMAGE_FILENAME
safety_checks
dependency_checks
install_netbsd
