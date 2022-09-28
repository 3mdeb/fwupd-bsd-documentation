# Instructions for getting user-space ESRT API on DragonFlyBSD

Read [README.md](./README.md) first for general information.

The plan is:
 * obtain `ioctl-efitool` branch of
 https://github.com/3mdeb/DragonFlyBSD/tree/ioctl-efitool fork of DragonFlyBSD
 source tree
 * compile and install kernel
 * compile and install tool that uses ESRT API
 * reboot and check that it works

## Preparation

As a root on installed DragonFlyBSD:

```
# cd /usr
# make src-create-shallow
# make src-update
```

Sources initialization may take a while. After that, add 3mdeb repository:

```
# cd /usr/src
# git remote add 3mdeb https://github.com/3mdeb/DragonFlyBSD.git
# git fetch 3mdeb
# git checkout 3mdeb/ioctl-efitool
```

## Kernel compilation and installation

```
# cd /usr/src/sys/config
# mkdir /root/kernels
# cp X86_64_GENERIC /root/kernels/MYKERNEL
# ln -s /root/kernels/MYKERNEL

# make -j4 -C ../../ nativekernel KERNCONF=MYKERNEL
# make -C ../../ installkernel KERNCONF=MYKERNEL
```

## Prepare user-space tool and reboot

```
# cd /usr/src/usr.sbin/efitable
# make
# make install
# reboot
```

## Verification

Kernel and bootloader from 3mdeb sources should be installed which was described
in [Building custom kernel](#Building-custom-kernel) section. To verify ESRT
tables functionality you need to load EFI runtime module:

```
# kldload efirt
```

and execute `efitable` tool:

```
# efitable -t esrt
```

Output should resemble this:

```
ESRT FwResourceCount = 1
ESRT[0]:
  FwClass: 212026ee-fde4-4d08-ac41-c62cb4036a42
  FwType: 0x00000001
  FwVersion: 0x00011506
  LowestSupportedFwVersion: 0x00011506
  CapsuleFlags: 0x00020000
  LastAttemptVersion: 0x00000000
  LastAttemptStatus: 0x00000000
```
