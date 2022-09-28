# Instructions for getting ESRT on NetBSD

Read [README.md](./README.md) first for general information.

The plan is:
 * obtain `os-interface` branch of https://github.com/3mdeb/NetBSD-src fork of
   NetBSD source tree
 * compile kernel and produce installation image
 * check that it works

## Build system image

Clone the sources
```
mkdir netbsd

cd netbsd

git clone --depth 1 -b esrt-tests https://github.com/3mdeb/NetBSD-src

cd src
```

Build toolchain, kernel and release, produce an `.iso` image
```
./build.sh -U -j8 -N 1 -m amd64 tools
./build.sh -U -u -j8 -N 1 -m amd64 kernel=GENERIC
./build.sh -U -u -j8 -N 1 -m amd64 release
./build.sh -U -u -j8 -N 1 -m amd64 iso-image
```

Produced image is at `obj/releasedir/images/NetBSD-9.99.100-amd64.iso`

Symlink it to the `netbsd` directory for ease of use

```
ln -s obj/releasedir/images/NetBSD-9.99.100-amd64.iso ../
```

## Install NetBSD

Make sure you are in the `netbsd` directory (`cd ..` after building system)

### OVMF

Running QEMU in EFI mode requires EFI firmware in a form of OVMF.fd file.

Linux distributions can provide one in some package in which case the file can 
be found at a path similar to /usr/share/ovmf/x64/OVMF.fd or /usr/share/ovmf
OVMF.fd.

It can also be built manually by cloning https://github.com/tianocore/edk2/ 
along with its submodules and building with the following commands in its root:

```
git clone https://github.com/tianocore/edk2
cd edk2
git submodule update --init
make -C BaseTools
( . edksetup.sh && build -a X64 -p OvmfPkg/OvmfPkgX64.dsc -t GCC5 -b RELEASE -n 5 )
```

`OVMF.fd` should be present at `Build/OvmfPkg/RELEASE_GCC5/FV/OVMF.fd`

Also symlink it to the `netbsd` directory

```
ln -s Build/OvmfPkg/RELEASE_GCC5/FV/OVMF.fd ../
```

### Installation process

Create a disk image, and grab symlink the install cd image: 

```
qemu-img create -f qcow2 disk.qcow2 15G

ln -s obj/releasedir/images/NetBSD-9.99.100-amd64.iso NetBSD-9.99.100-amd64.iso
```

Run the installer:

```
    qemu-system-x86_64 \
        -m 2048 \
        -boot d \
        -bios OVMF.fd \
        -cdrom NetBSD-9.99.100-amd64.iso \
        -drive if=virtio,file=disk.qcow2,format=qcow2 \
        -enable-kvm \
        -netdev user,id=mynet0,hostfwd=tcp::7722-:22 \
        -device virtio-net,netdev=mynet0 \
        -smp 6 \
        -cpu host
```

Follow the default installation - create default partition tables and press
enter on any other option. Finish the configuration and exit QEMU.

Then run the installed system (this command can be used for regular usage)

```
qemu-system-x86_64 \
        -m 2048 \
        -drive if=virtio,file=disk.qcow2,format=qcow2 \
        -enable-kvm \
        -display gtk \
        -netdev user,id=mynet0,hostfwd=tcp:127.0.0.1:9272-:22 \
        -device virtio-net,netdev=mynet0 \
        -bios OVMF.fd \
        -smp 6 \
        -s \
        -cpu host
```

### Use the tool

`dmesg` won't contain ESRT output, but it can be obtained by running the
`efitable` tool like this:

```
efitable -t esrt
```

Output should resemble this:

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
