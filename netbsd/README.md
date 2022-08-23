# NetBSD fwupd port notes

## Table of contents

- [NetBSD fwupd port notes](#netbsd-fwupd-port-notes)
  - [Table of contents](#table-of-contents)
  - [Running NetBSD in QEMU](#running-netbsd-in-qemu)
  - [Customising the kernel](#customising-the-kernel)
    - [Prerequisites](#prerequisites)
    - [Building the kernel](#building-the-kernel)
    - [Running a virtual machine with a custom kernel](#running-a-virtual-machine-with-a-custom-kernel)
    - [NetBSD ESRT recognition - implementation proposition](#netbsd-esrt-recognition---implementation-proposition)

## Running NetBSD in QEMU

Wiki entry:
- https://wiki.qemu.org/Hosts/BSD#NetBSD

NetBSD users mailing list might contain some info regarding the installation 
process:
- http://mail-index.netbsd.org/netbsd-users/

## Customising the kernel

Thorough documentation and instructions:
- http://netbsd.org/docs/kernel/

### Prerequisites
- CVS (Concurrent Versioning System) installed
  - `sudo apt install cvs`
- NetBSD source files, preferably from a stable version
  - http://ftp.netbsd.org/pub/NetBSD/NetBSD-release-9/src/
  - alternative git mirror - https://github.com/IIJ-NetBSD/netbsd-src

### Building the kernel

Crosscompilation guide:
- http://netbsd.org/docs/guide/en/chap-build.html

- download the sources using cvs
  - `cvs checkout -r netbsd-9-3-RELEASE -P src`
  - this is quite a bit slower than using git and may take a few minutes
- build the toolchain
  - `./build.sh -U -u -N 1 -j8 -O ~/obj -m amd64 -a x86_64 tools`
- create a custom kernel configuration and modify the kernel
  - `cd src/sys/arch/amd64/conf`
  - `cp GENERIC MYKERNEL`
  - you can modify the system as you wish, most of the kernel files are placed 
  in 
    - `src/sys/arch` (architecture specific)
    - `src/sys/dev` (devices)
- build the kernel
  - `./build.sh -U -u -N 1 -j8 -O /home/pcichowski/obj -m amd64 -a x86_64 kernel=MYKERNEL`
- build a release (userland)
  - `./build.sh -U -u -N 1 -j2 -O ~/obj -m arm64 -a x86_64 release`
  - the option `-j2` is used here - it selects how many cores will be used for 
  compilation, here it is reduced to 2 because 8 threads may produce errors 
  with multiple `make` branches
- create an iso image
  - `./build.sh -U -u -j2 -O ~/obj -m evbarm -a aarch64 iso-image`
  - the image is present at `~/obj/releasedir/images`

### Running a virtual machine with a custom kernel

A quick and easy way to run NetBSD on QEMU is `virt-manager`, it has a GUI 
creator for a VM

Select the created .iso image

At the last step, check configure VM before installing and proceed

Select OVMF (UEFI) as the firmware

Run the VM

### NetBSD ESRT recognition - implementation proposition

x86 architecture configuration in NetBSD has EFI implemented, although it isn't 
clear if it's variables are accessible via userland

UEFI system and config tables are printed during boot, as well as physical 
addresses to efi boot and runtime services.
- EFI Boot services are not useful to us, because the operating system has 
already taken control of the platform
- EFI Runtime services will come in handy, as they contain EFI variable getters/
setters

Based on the work done here:
- OpenBSD ESRT:
  - https://github.com/3mdeb/openbsd-src/compare/master...3mdeb:openbsd-src:esrt
- linux implementation:
  -  https://github.com/torvalds/linux/blob/master/drivers/firmware/efi/esrt.c
- some NetBSD implementation (probably WIP, unmerged)
  - https://github.com/NetBSD/src/commit/25ff60a647236a2f67fc08ecac96a14fecffd6f1

A proposed implementation of ESRT:
- add a define directive with the correct GUID for a ESRT table (EFI 
specification)
- ESRT table and entry structures
- `efi_init_esrt` - a function to remap the table and fill records on boot?
- `efi_attach` function - adds a device?
- `efi_match` function - compares devices?
- `efi_get_esrt` function - returns esrt table
- `efi_dump_esrt` function - prints the whole table
- function to check if esrt exists 

- manipulation of EFI variables - they could be accessible via the EFI runtime 
service or may require having an entire interface written - e.g. a efivar 
implementation

Changes added either to `src/sys/arch/x86/x86/efi.c , efi.h` or a new file 
`esrt.c , esrt.h` in the same location

The linux implementation of ESRT is quite nice and could be a good foundation, 
provided that netbsd has similar libraries

The table will then be accessible as a kernel variable - using sysctl