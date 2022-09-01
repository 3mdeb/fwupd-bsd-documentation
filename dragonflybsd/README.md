# DragonflyBSD fwupd port notes

## Preparation

- Installed packages
    - qemu-system-x86-64
    - ovmf
- Downloaded
[latest version](https://mirror-master.dragonflybsd.org/iso-images/?C=M;O=D) of
DragonflyBSD release in uncompressed `.iso` format
- Created Virtual disk with `qemu-img` command (see `Installation` section)

> NOTE: HAMMER2 (default filesystem on DragonflyBSD) was designed to work with >
50GB spaces. From 512MB to 1GB can be reserved for reblocking and UNDO/READ
FIO. 15GB virtual disk was verified and should be enough for kernel development
and verification purposes.

## Scripts

These scripts do not provide full automation but still can be useful

- **vm/setup.sh** - run QEMU machine first time and boot to the default
installer
- **vm/run.sh** - run QEMU machine after instalation

## Installation

DragonflyBSD does not provide support for
[autoinstall](https://man.openbsd.org/autoinstall) utility. We can found
[non-official automation scripts](https://code.umbriel.fr/Nihl/dfly-autoinstall/src/branch/main/install-script/autoinstall.sh)
, but it requires preparing custom `.ISO` with
enabled output on `tty`, which is not available in the image downloaded from
[DragonflyBSD webpage](https://www.dragonflybsd.org/download/#index1h2).

To run DragonflyBSD first time, we need to create a virtual disk and run QEMU
with
mounted `.iso`:

```
$ qemu-img create -f qcow2 disk.qcow2 15G

$ qemu-system-x86_64 -m 2048 -boot d \
   -bios /usr/share/ovmf/x64/OVMF.fd \
   -cdrom dfly-x86_64-6.2.2_REL.iso \
   -drive if=virtio,file=disk.qcow2,format=qcow2 \
   -netdev user,id=mynet0,hostfwd=tcp::7722-:22 \
   -device e1000,netdev=mynet0 -enable-kvm -smp 4 -cpu host
```

> Note that OVMF path may be different in some systems

The installation process isn't difficult; we need to answer a few questions (e.g.
choose filesystem) and was described
[here](https://www.dragonflybsd.org/docs/handbook/Installation/#index3h2).

## Running DragonflyBSD in QEMU

After installing DragonflyBSD we can run QEMU without mounted `.iso`:

```
 $ qemu-system-x86_64 -m 2048 -boot d \
   -bios /usr/share/ovmf/x64/OVMF.fd \
   -drive if=virtio,file=disk.qcow2,format=qcow2 \
   -netdev user,id=mynet0,hostfwd=tcp::7722-:22 \
   -device e1000,netdev=mynet0 -enable-kvm -smp 4 -cpu host
```

As a default, we do not have terminal emulation. Only one output is on the
graphic window with rendered console. To make development and validation easier,
it is good to obtain an SSH connection between host and QEMU machine. To do
that, you should set these values in `/etc/rc.conf` (on host machine):

```
 sshd_enable="YES"
 ifconfig_em0="DHCP"
```

Now you need to send your public key to `/home/root/.ssh/authorized_keys` file
on DragonflyBSD.

```
# scp <username>@<IP of host machine in local network>:<path to publickey> /home/root/.ssh/authorized_keys
```

Now you should be able to connect:
```
$ ssh -p 7722 root@localhost
```

## Building custom kernel

Building custom kernel is described in DragonflyBSD
[handbook](https://www.dragonflybsd.org/docs/handbook/ConfigureKernel/).

Whole procedure must be done on DragonflyBSD, so that's why we use QEMU. Here
are instructions from downloading sources to kernel installation:

1. Download sources

```
# cd /usr
# make src-create-shallow
# make src-update
```

2. Copy and use default x86-64 config

```
# cd /usr/src/sys/config
# mkdir /root/kernels
# cp X86_64_GENERIC /root/kernels/MYKERNEL
# ln -s /root/kernels/MYKERNEL
```

3. Prepare DragonflyBSD toolchanin

> NOTE: It is more challenging for PC than building kernel - it may take a few
hours

```
# cd /usr/src
# make buildworld
```

4. Build kernel

```
# make -j4 buildkernel KERNCONF=MYKERNEL
```

5. Install kernel

```
# make installekernel KERNCONF=MYKERNEL
# reboot
```
