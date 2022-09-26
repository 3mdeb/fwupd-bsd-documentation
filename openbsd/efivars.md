# Instructions for getting user-space EFI vars API on OpenBSD

Read [README.md](./README.md) first for general information.

This is very similar to what's described in [esrt.md](./esrt.md) and
[esrt-api.md](./esrt-api.md), but duplication is intentional for simplicity.

The plan is:
 * obtain `efivars-api` branch of https://github.com/3mdeb/openbsd-src fork of
   OpenBSD source tree
 * compile kernel
 * compile EFI bootloader
 * install both of them and create `/dev/efi`
 * compile and install test tool that uses EFI vars API
 * change security level, reboot and check that it works

## Preparation

As a regular user assuming `doas` is configured:

```
# install git package
doas pkg_add git

# add your user to wsrc and wobj groups (relogin to apply these changes)
doas user mod -G wsrc,wobj $USER

git clone --depth 1 -b efivars-api https://github.com/3mdeb/openbsd-src /usr/src
```

## Kernel compilation

```
# /sys/ is a symbolic link to /usr/src/sys/, go there to setup kernel build
cd /sys/arch/amd64/conf/

# generate configuration (the file is already there on the branch)
config CUSTOM

# build the kernel for the first time
make -C ../compile/CUSTOM -j$(sysctl -n hw.ncpu)
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
doas mount -t msdos /dev/sd0i /mnt/

# install EFI bootloader
doas cp /sys/arch/amd64/stand/efiboot/bootx64/BOOTX64.EFI /mnt/efi/BOOT/

# unmount EFI partition
doas umount /mnt/

# create /dev/efi file
doas sh -c 'cd /dev && /usr/src/etc/etc.amd64/MAKEDEV efi'
```

## Prepare user-space tool

```
# build sample tool
make -C /usr/src/usr.sbin/efivartest

# install it
doas make -C /usr/src/usr.sbin/efivartest install
```

## Change [security level](https://man.openbsd.org/OpenBSD-7.1/securelevel.7)

Use permanently insecure mode to be able to set EFI variables while system is
boot in multiuser mode:

```
doas sh -c 'echo sysctl kern.securelevel=-1 > /etc/rc.securelevel'
```

Alternative is to boot in single user mode.

## Reboot

```
doas reboot
```

When bootloader asks for input (`boot>` prompt), type in `bsd.custom` and press
Enter key.

## Use the tool

### Adding/updating a variable

```
doas efivartest set aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee test newval
```

### Reading a variable

```
doas efivartest get aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee test
```

```
aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-test (6):
 HEX: 0x6e 0x65 0x77 0x76 0x61 0x6c
 ASCII: newval
```

### Listing variables

```
doas efivartest list
```

```
8be4df61-93ca-11d2-aa0d-00e098032b8c-OsIndicationsSupported
8be4df61-93ca-11d2-aa0d-00e098032b8c-BootOptionSupport
8be4df61-93ca-11d2-aa0d-00e098032b8c-LangCodes
8be4df61-93ca-11d2-aa0d-00e098032b8c-PlatformLangCodes
8be4df61-93ca-11d2-aa0d-00e098032b8c-PlatformRecovery0000
8be4df61-93ca-11d2-aa0d-00e098032b8c-BootCurrent
8be4df61-93ca-11d2-aa0d-00e098032b8c-ConInDev
8be4df61-93ca-11d2-aa0d-00e098032b8c-ConOutDev
8be4df61-93ca-11d2-aa0d-00e098032b8c-ErrOutDev
8be4df61-93ca-11d2-aa0d-00e098032b8c-Boot0000
8be4df61-93ca-11d2-aa0d-00e098032b8c-Timeout
8be4df61-93ca-11d2-aa0d-00e098032b8c-PlatformLang
8be4df61-93ca-11d2-aa0d-00e098032b8c-Lang
04b37fe8-f6ae-480b-bdd5-37d98c5e89aa-VarErrorFlag
8be4df61-93ca-11d2-aa0d-00e098032b8c-Key0000
8be4df61-93ca-11d2-aa0d-00e098032b8c-Key0001
964e5b22-6459-11d2-8e39-00a0c969723b-NvVars
8be4df61-93ca-11d2-aa0d-00e098032b8c-Boot0001
8be4df61-93ca-11d2-aa0d-00e098032b8c-Boot0002
8be4df61-93ca-11d2-aa0d-00e098032b8c-Boot0003
8be4df61-93ca-11d2-aa0d-00e098032b8c-BootOrder
8be4df61-93ca-11d2-aa0d-00e098032b8c-Boot0004
378d7b65-8da9-4773-b6e4-a47826a833e1-RTC
8be4df61-93ca-11d2-aa0d-00e098032b8c-Boot0005
eb704011-1402-11d3-8e77-00a0c969723b-MTC
8be4df61-93ca-11d2-aa0d-00e098032b8c-ConOut
8be4df61-93ca-11d2-aa0d-00e098032b8c-ConIn
8be4df61-93ca-11d2-aa0d-00e098032b8c-ErrOut
aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-test
```

### Deleting a variable

```
doas efivartest delete aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee test
```
