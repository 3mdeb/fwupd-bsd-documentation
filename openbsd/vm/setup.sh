#!/usr/bin/env bash

# OpenBSD version (if V is 71, then VV is 7.1)
V=71
VV=${V:0:1}.${V:1:1}

function safety_checks() {
    if [ -f disk.qcow2 ]; then
        echo "disk.qcow2 already exists, won't format! Remove it to do setup."
        exit 1
    fi
}

function dependency_checks() {
    local fulfilled=y

    if [ ! -f OVMF.fd ]; then
        echo 'OVMF.fd is missing!'
        fulfilled=n
    fi

    if ! command -v python3 > /dev/null; then
        echo 'python3 not found!'
        fulfilled=n
    fi

    if ! command -v rsync > /dev/null; then
        echo 'rsync not found!'
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

function prepare_mirror() {
    if [ -f web/.mirrorred.$VV ]; then
        echo ">>> Skipping mirroring OpenBSD $VV, it's already done"
        return
    fi

    echo ">>> Mirroring $V in web/pub/OpenBSD/$VV/amd64..."

    mkdir -p web/pub/OpenBSD/$VV/amd64

    rsync --archive --files-from=- --verbose \
        rsync://ftp.halifax.rwth-aachen.de/openbsd/$VV/amd64/ \
        web/pub/OpenBSD/$VV/amd64 << EOF
BOOTX64.EFI
SHA256.sig
base$V.tgz
bsd
bsd.mp
bsd.rd
comp$V.tgz
man$V.tgz
xbase$V.tgz
xfont$V.tgz
xserv$V.tgz
xshare$V.tgz
EOF

    if [ $? -ne 0 ]; then
        echo ">>> FAILED: mirroring $V"
        exit 1
    fi

    touch web/.mirrorred.$VV
}

function prepare_sitescript() {
    if [ -f ~/.ssh/id_rsa.pub ]; then
        cp ~/.ssh/id_rsa.pub ai/site/
    fi

    ( cd ai/site && tar -czf ../../web/pub/OpenBSD/$VV/amd64/site$V.tgz . )
    ( cd web/pub/OpenBSD/$VV/amd64/ && ls -l > index.txt )
}

function prepare_autoinstall() {
    echo ">>> Preparing auto-install files..."
    ln -fs ../ai/install.conf ../ai/disklabel web/
}

function prepare_tftp() {
    echo ">>> Preparing tftp/ root..."

    rm -rf tftp

    mkdir tftp
    ln -s ../web/pub/OpenBSD/$VV/amd64/BOOTX64.EFI tftp/auto_install
    ln -s ../web/pub/OpenBSD/$VV/amd64/bsd.rd tftp/bsd.rd

    mkdir tftp/etc
    cp ai/boot.conf tftp/etc/
}

function install_openbsd() {
    echo ">>> Starting installation..."

    python3 -m http.server --directory web --bind 127.0.0.1 8000 > /dev/null &
    python_pid=$!

    qemu-img create -f qcow2 disk.qcow2 32G

    qemu-system-x86_64 -m 2048 \
                       -drive if=virtio,file=disk.qcow2,format=qcow2 \
                       -enable-kvm \
                       -netdev user,id=mynet0,tftp=tftp/,bootfile=auto_install \
                       -device virtio-net,netdev=mynet0 \
                       -bios OVMF.fd \
                       -smp $(nproc) \
                       -cpu host \
                       -serial stdio \
                       -display none

    kill "$python_pid"
}

safety_checks
dependency_checks
prepare_mirror
prepare_sitescript
prepare_autoinstall
prepare_tftp
install_openbsd
