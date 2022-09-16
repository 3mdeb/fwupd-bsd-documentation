# Instructions for getting ESRT on OpenBSD

Read [README.md](./README.md) first for general information.

The plan is:
 * obtain `esrt` branch of https://github.com/3mdeb/openbsd-src fork of OpenBSD
   source tree
 * compile kernel
 * compile EFI bootloader
 * install both of them
 * reboot and check that it works

## Preparation

As a regular user assuming `doas` is configured:

```
# install git package
doas pkg_add git

# add your user to wsrc and wobj groups (relogin to apply these changes)
doas user mod -G wsrc,wobj $USER

git clone --depth 1 -b esrt https://github.com/3mdeb/openbsd-src /usr/src
```

## Kernel compilation

```
# /sys/ is a symbolic link to /usr/src/sys/, go there to setup kernel build
cd /sys/arch/amd64/conf/

# generate configuration (the file is already there on the branch)
config CUSTOM

# build the kernel for the first time
make -C ../compile/CUSTOM -j$(nproc)
```

## EFI bootloader compilation

```
make -C /sys/arch/amd64/stand/efiboot/bootx64
```

## Installation

```
# copy the kernel image into root for convenience
doas cp /sys/arch/amd64/compile/CUSTOM/obj/bsd /bsd.custom

# mount EFI partition
mount -t msdos /dev/sd0i /mnt/

# install EFI bootloader
cp /sys/arch/amd64/stand/efiboot/bootx64/BOOTX64.EFI /mnt/efi/BOOT/

# unmount EFI partition
umount /mnt/
```

## Reboot

```
doas reboot
```

When bootloader asks for input (`boot>` prompt), type in `bsd.custom` and press
Enter key.

Now if you check out output of `dmesg` and your device has any ESRT entries, you
should see something like the following at the top of `dmesg`'s output:

```
ESRT FwResourceCount = 2
ESRT[0]:
  FwClass: 415f009f-fb1d-4cc3-8a25-5710a7705918
  FwType: 0x00000001
  FwVersion: 0x00000005
  LowestSupportedFwVersion: 0x00000001
  CapsuleFlags: 0x00040000
  LastAttemptVersion: 0x00000000
  LastAttemptStatus: 0x00000000
ESRT[1]:
  FwClass: 79a731b2-61ad-415c-aafc-7af0eba00e4e
  FwType: 0x00000002
  FwVersion: 0x00000004
  LowestSupportedFwVersion: 0x00000003
  CapsuleFlags: 0x00020000
  LastAttemptVersion: 0x00000005
  LastAttemptStatus: 0x00000005
```
