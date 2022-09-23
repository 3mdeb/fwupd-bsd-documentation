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
   -netdev user,id=mynet0,hostfwd=tcp::9272-:22 \
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
   -netdev user,id=mynet0,hostfwd=tcp::9272-:22 \
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
$ ssh -p 9272 root@localhost
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

3. Add 3mdeb repo to remotes
```
# git remote add 3mdeb https://github.com/3mdeb/DragonFlyBSD.git
# git checkout 3mdeb/esrt
```

3. Build kernel (no need to build toolchain, because we're not cross-compiling)

First time:

```
# make -j4 nativekernel KERNCONF=MYKERNEL
```

Future times (`nativekernel` always starts from scratch, so use it only once or
to do a rebuild):

```
# make -j4 quickkernel KERNCONF=MYKERNEL
```

4. Install kernel

```
# make installkernel KERNCONF=MYKERNEL
# reboot
```

Mind that rebooting might not be necessary if you can test your changes by
loading a module with `kldload` command.

5. Building/installing EFI bootloader

First time (need to build `/usr/src/stand/lib/` to avoid cryptic build
failures):

```
# cd /usr/src/stand
# make
# cd /usr/src/stand/boot/efi/loader
# make
# make install
# reboot
```

Future times:

```
# cd /usr/src/stand/boot/efi/loader
# make
# make install
# reboot
```

## Verification

Kernel and bootloader from 3mdeb sources should be installed which was described
in [Building custom kernel](#Building-custom-kernel) section. To verify ESRT
tables functionality you need to load EFI runtime module:

```
# kldload eifrt
```

Then you should see similar output in `dmesg` or main monitor (it should not be
visible on ttyS0 or SSH connection console)

```
esrt->fw_resource_count = 1
esrt->fw_resource_count_max = 1
esrt->fw_resource_version = 1
ESRT[0]:
  Fw Type: 0x00000001
  Fw Ckass: 212026ee-fde4-4d08-ac41-c62cb4036a42
  Fw Version: 0x00011506
  Lowest Supported Fw Version: 0x00011506
  Capsule Flags: 0x00020000
  Last Attempt Version: 0x00000000
  Last Attempt Status: 0x00000000
```

## Troubleshooting

In case of errors with binutils during building bootloader:

```
/usr/libexec/binutils234/elf/nm: 'netif.o': No such file
/usr/libexec/binutils234/elf/nm: 'nfs.o': No such file
/usr/libexec/binutils234/elf/nm: 'dosfs.o': No such file
/usr/libexec/binutils234/elf/nm: 'ext2fs.o': No such file
/usr/libexec/binutils234/elf/nm: 'splitfs.o': No such file
/usr/libexec/binutils234/elf/nm: 'hammer1.o': No such file
/usr/libexec/binutils234/elf/nm: 'hammer2.o': No such file
/usr/libexec/binutils234/elf/ar: hammer2.o: No such file or directory
*** [libstand32.a] Error code 1
```

try to build `libefi` first:

```
# cd /usr/src/stand/boot/efi/libefi
# make
```
