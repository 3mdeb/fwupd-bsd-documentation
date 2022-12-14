Overview
========

This is a simple executable for verifying basic functionality of `libefiboot`.

Obtaining and building
======================

First make sure that you've installed `efivar` port according to corresponding
instructions: [OpenBSD](../../openbsd/libs.md), [NetBSD](../../netbsd/libs.md)
or [DragonflyBSD](../../dragonflybsd/libs.md).

```
mkdir ebtest && cd ebtest
# in case of SSL errors, pass --insecure to curl
curl https://github.com/3mdeb/fwupd-bsd-documentation/blob/main/tools/ebtest/ebtest.c
curl https://github.com/3mdeb/fwupd-bsd-documentation/blob/main/tools/ebtest/Makefile
make
```

Usage
=====

The program accepts path to the file for which device path needs to be
generated. The main use case is the path to a file on an ESP (EFI System
Partition). The partition needs to be mounted and can be named differently
depending on the setup.

Each of the example usages below has three sections:

1. Commands that can help in finding ESP partition.
2. Commands to mount it and run the tool.
3. Output of the tool.

NetBSD
------

```
# sysctl -n hw.disknames
ld0 fd0 dk0 dk1 cd0
# dkctl ld0 listwedges
/dev/rld0: 2 wedges:
dk0: 446abcfb-be3c-4dac-8a34-63c5e6b6f1d4, 262144 blocks at 64, type: msdos
dk1: bd80757e-6ac3-4012-895f-a52d27962817, 33292191 blocks at 262208, type: ffs
```

```
mount -t msdos /dev/dk0 /mnt
./ebtest /mnt/EFI/boot/bootx64.efi
```

```
HEX: 0x04 0x01 0x2a 0x00 0x01 0x00 0x00 0x00 0x40 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x04 0x00 0x00 0x00 0x00 0x00 0xfb 0xbc 0x6a 0x44 0x3c 0xbe 0xac 0x4d 0x8a 0x34 0x63 0xc5 0xe6 0xb6 0xf1 0xd4 0x02 0x02 0x04 0x04 0x30 0x00 0x5c 0x00 0x45 0x00 0x46 0x00 0x49 0x00 0x5c 0x00 0x62 0x00 0x6f 0x00 0x6f 0x00 0x74 0x00 0x5c 0x00 0x62 0x00 0x6f 0x00 0x6f 0x00 0x74 0x00 0x78 0x00 0x36 0x00 0x34 0x00 0x2e 0x00 0x65 0x00 0x66 0x00 0x69 0x00 0x00 0x00 0x7f 0xff 0x04 0x00

ASCII: ??*?????@?????????????????jD<??M?4c?????????0?\?E?F?I?\?b?o?o?t?\?b?o?o?t?x?6?4?.?e?f?i???????

DP: HD(1,GPT,446abcfb-be3c-4dac-8a34-63c5e6b6f1d4,0x40,0x40000)/File(\EFI\boot\bootx64.efi)

efi_loadopt_create() has succeeded
```

OpenBSD
-------

```
$ sysctl -n hw.disknames
cd0:,sd0:2ef53e2f306ec9c3,fd0:
$ doas disklabel sd0
# /dev/rsd0c:
type: SCSI
disk: SCSI disk
label: Block Device
duid: 2ef53e2f306ec9c3
flags:
bytes/sector: 512
sectors/track: 63
tracks/cylinder: 255
sectors/cylinder: 16065
cylinders: 4177
total sectors: 67108864
boundstart: 1024
boundend: 67108831
drivedata: 0

16 partitions:
#                size           offset  fstype [fsize bsize   cpg]
  a:         67107776             1024  4.2BSD   2048 16384 12960 # /
  c:         67108864                0  unused
  i:              960               64   MSDOS
```

```
doas mount -t msdos /dev/sd0i /mnt/
doas ./ebtest /mnt/efi/BOOT/BOOTX64.EFI
```

```
HEX: 0x04 0x01 0x2a 0x00 0x01 0x00 0x00 0x00 0x40 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0xc0 0x03 0x00 0x00 0x00 0x00 0x00 0x00 0x58 0x72 0x18 0x3d 0x11 0x34 0x71 0x47 0xa8 0xd3 0x37 0xc3 0x4e 0x95 0x39 0x75 0x02 0x02 0x04 0x04 0x30 0x00 0x5c 0x00 0x65 0x00 0x66 0x00 0x69 0x00 0x5c 0x00 0x42 0x00 0x4f 0x00 0x4f 0x00 0x54 0x00 0x5c 0x00 0x42 0x00 0x4f 0x00 0x4f 0x00 0x54 0x00 0x58 0x00 0x36 0x00 0x34 0x00 0x2e 0x00 0x45 0x00 0x46 0x00 0x49 0x00 0x00 0x00 0x7f 0xff 0x04 0x00

ASCII: ??*?????@???????????????Xr?=?4qG??7?N?9u????0?\?e?f?i?\?B?O?O?T?\?B?O?O?T?X?6?4?.?E?F?I???????

DP: HD(1,GPT,3d187258-3411-4771-a8d3-37c34e953975,0x40,0x3c0)/File(\efi\BOOT\BOOTX64.EFI)

efi_loadopt_create() has succeeded
```

DragonflyBSD
------------

```
# sysctl -n kern.disks
cd0 vbd0 acd0 vn3 vn2 vn1 vn0 md0
# gpt show vbd0
     start      size  index  contents
         0         1      -  PMBR
         1         1      -  Pri GPT header
         2        32      -  Pri GPT table
        34      2014      -  Unused
      2048    262144      0  GPT part - EFI System
    264192  31191040      1  GPT part - DragonFly Label64
  31455232      2015      -  Unused
  31457247        32      -  Sec GPT table
  31457279         1      -  Sec GPT header
```

```
mount -t msdos /dev/vbd0s0 /mnt/
./ebtest /mnt/EFI/BOOT/BOOTX64.EFI
```

```
HEX: 0x04 0x01 0x2a 0x00 0x01 0x00 0x00 0x00 0x00 0x08 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x04 0x00 0x00 0x00 0x00 0x00 0x18 0x39 0xe6 0x06 0x55 0x30 0xed 0x11 0x82 0x98 0x53 0x54 0x00 0x12 0x34 0x56 0x02 0x02 0x04 0x04 0x30 0x00 0x5c 0x00 0x45 0x00 0x46 0x00 0x49 0x00 0x5c 0x00 0x42 0x00 0x4f 0x00 0x4f 0x00 0x54 0x00 0x5c 0x00 0x42 0x00 0x4f 0x00 0x4f 0x00 0x54 0x00 0x58 0x00 0x36 0x00 0x34 0x00 0x2e 0x00 0x45 0x00 0x46 0x00 0x49 0x00 0x00 0x00 0x7f 0xff 0x04 0x00

ASCII: ??*??????????????????????9??U0????ST??4V????0?\?E?F?I?\?B?O?O?T?\?B?O?O?T?X?6?4?.?E?F?I???????

DP: HD(1,GPT,06e63918-3055-11ed-8298-535400123456,0x800,0x40000)/File(\EFI\BOOT\BOOTX64.EFI)

efi_loadopt_create() has succeeded
```
