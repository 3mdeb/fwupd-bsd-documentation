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

The building process is done on your host machine, and the produced image is
meant to be ran on NetBSD started in QEMU.

It comprises of a few steps:
- downloading the sources
- build the toolchain
- build the kernel
- build a release
- produce `.iso` image (CD/DVD)

Thorough documentation and instructions:
- http://netbsd.org/docs/kernel/

### Prerequisites
- QEMU installed (to emulate an amd64 system)
  - `sudo apt install qemu-systemx86_64`
- NetBSD source files, 3mdeb provides github fork
  - https://github.com/3mdeb/NetBSD-src

### Building the kernel

We will build the kernel using cross compile toolchain that needs to be build
from NetBSD sources. Crosscompilation guide for reference
- http://netbsd.org/docs/guide/en/chap-build.html

To cross compile NetBSD and custom kernel using 3mdeb fork please follow the
steps:

* Clone the sources using cvs
  ```bash
  git clone https://github.com/3mdeb/NetBSD-src.git src
  ```

* Create directory for build artifacts and set variable with that path
  ```bash
  export NETBSD_OBJ=/home/$USER/obj
  mkdir -p $NETBSD_OBJ
  ```

* Build the toolchain
  ```bash
  ./build.sh -U -u -N 1 -j$(nproc) -O $NETBSD_OBJ -m amd64 -a x86_64 tools
  ```

* Create a custom kernel configuration and modify the kernel
  ```bash
  cd src/sys/arch/amd64/conf
  cp GENERIC MYKERNEL
  ```

* Modify the system as you wish, most of the kernel files are placed in
    - `src/sys/arch` (architecture specific)
    - `src/sys/dev` (devices)

* Build the kernel
  ```bash
  ./build.sh -U -u -N 1 -j$(nproc) -O $NETBSD_OBJ -m amd64 -a x86_64 kernel=MYKERNEL
  ```

* Build a release (userland)
  ```bash
  ./build.sh -U -u -N 1 -j$(nproc) -O $NETBSD_OBJ -m amd64 -a x86_64 release
  ```

* Create an iso image
  ```bash
  ./build.sh -U -u -j$(nproc) -O $NETBSD_OBJ -m amd64 -a x86_64 iso-image
  ```
  >Note: the image is present at `$NETBSD_OBJ/releasedir/images`

### Running a virtual machine with a custom kernel

In order to run NetBSD with a custom kernel we will run the prepared iso
installer image and use it to install the system on generated qcow2 disk.

To run custom kernel please follow the next two steps after finishing
instructions from [kernel building section](#building-the-kernel).

* Install NetBSD on qcow2 disk image using [setup](./vm/setup.sh) script.
>Note: Enter `cd0` when the system asks for `root device`, press enter on
everything else, run installer from CDROM.

* Run freshly installed NetBSD by running [run](./vm/run.sh) script.

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
- NetBSD implementation, but for the ARM architecture
  - https://github.com/NetBSD/src/commit/25ff60a647236a2f67fc08ecac96a14fecffd6f1

A proposed implementation of ESRT:
- add a define directive with the correct GUID for a ESRT table (EFI
specification)
- ESRT table and entry structures
- `efi_init_esrt` - a function to remap the table and fill records on boot?
- `efi_attach` function - initializes device and/or data for managing it
- `efi_match` function - checks whether device is present
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
