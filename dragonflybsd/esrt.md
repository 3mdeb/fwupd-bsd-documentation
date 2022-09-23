# Instructions for getting ESRT on DragonFlyBSD

Read [README.md](./README.md) first for general information.

The plan is:
 * obtain `esrt` branch of https://github.com/3mdeb/DragonFlyBSD/tree/esrt
 fork of DragonFlyBSD source tree
 * compile kernel
 * compile EFI bootloader
 * install both of them
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
# git remote add 3mdeb https://github.com/3mdeb/DragonFlyBSD.git
# git fetch 3mdeb
# git checkout 3mdeb/esrt
```

## Kernel compilation and installation

```
# cd /usr/src/sys/config
# mkdir /root/kernels
# cp X86_64_GENERIC /root/kernels/MYKERNEL
# ln -s /root/kernels/MYKERNEL

# make -j4 nativekernel KERNCONF=MYKERNEL
# make installkernel KERNCONF=MYKERNEL
```

## EFI bootloader compilation and installation

```
# cd /usr/src/stand/boot/efi/libefi
# make

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
# kldload efirt
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
