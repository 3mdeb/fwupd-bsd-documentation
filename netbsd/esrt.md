# Instructions for viewing ESRT on NetBSD

Read [README.md](./README.md) first for general information.

The plan is:
 * obtain `esrt-tests` branch of https://github.com/3mdeb/NetBSD-src fork of
   NetBSD source tree
 * compile kernel and produce installation image
 * check that it works

## Build system image

* Clone the sources

```bash
mkdir netbsd
cd netbsd
git clone --depth 1 -b esrt-tests https://github.com/3mdeb/NetBSD-src src
cd src
```

* Build toolchain, kernel and release, produce an `.iso` image

```bash
./build.sh -U -j$(nproc) -N 1 -m amd64 tools
./build.sh -U -u -j$(nproc) -N 1 -m amd64 kernel=GENERIC
./build.sh -U -u -j$(nproc) -N 1 -m amd64 release
./build.sh -U -u -j$(nproc) -N 1 -m amd64 iso-image
```

Produced image is at `obj/releasedir/images/NetBSD-9.99.100-amd64.iso`

Copy it to the `netbsd` directory for ease of use

```bash
cp obj/releasedir/images/NetBSD-9.99.100-amd64.iso ../
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

```bash
git clone https://github.com/tianocore/edk2
cd edk2
git submodule update --init
make -C BaseTools
( . edksetup.sh && build -a X64 -p OvmfPkg/OvmfPkgX64.dsc -t GCC5 -b RELEASE -n 5 )
```

`OVMF.fd` should be present at `Build/OvmfPkg/RELEASE_GCC5/FV/OVMF.fd`

Also copy it to the `netbsd` directory

```bash
cp Build/OvmfX64/RELEASE_GCC5/FV/OVMF.fd ../
```

### Installation process

Create a disk image

```bash
qemu-img create -f qcow2 disk.qcow2 15G
```

Run the installer:

```bash
    qemu-system-x86_64 \
        -m 2048 \
        -boot d \
        -bios OVMF.fd \
        -cdrom NetBSD-9.99.100-amd64.iso \
        -drive if=virtio,file=disk.qcow2,format=qcow2 \
        -enable-kvm \
        -netdev user,id=mynet0,hostfwd=tcp::7722-:22 \
        -device virtio-net,netdev=mynet0 \
        -smp $(nproc) \
        -cpu host
```

Enter `cd0` when the system asks for `root device`, press enter on everything
else.

Follow the default installation - create default partition tables and press
enter on any other option.

If the `Release set xbase` does not exist, continue and `Skip set group` - this
package set is the X window system, for our purpose we only need the terminal

Finish the configuration and exit QEMU.

Then run the installed system (this command can be used for regular usage)

```bash
qemu-system-x86_64 \
        -m 2048 \
        -drive if=virtio,file=disk.qcow2,format=qcow2 \
        -enable-kvm \
        -display gtk \
        -netdev user,id=mynet0,hostfwd=tcp:127.0.0.1:9272-:22 \
        -device virtio-net,netdev=mynet0 \
        -bios OVMF.fd \
        -smp $(nproc) \
        -s \
        -cpu host
```

### Checking out ESRT values

Now if you check out output of `dmesg` and your device has any ESRT entries, you
should see something like the following at the top of `dmesg`'s output:

```bash
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
