# OpenBSD fwupd port notes

## Crash course

Scroll through the slides at https://openbsdjumpstart.org/ if you want to get a
general idea about OpenBSD.

## Installation/usage scripts

During manual installation OpenBSD asks user a number of questions to guide
the installation process. After a successful installation regular user created
during installation (root otherwise) has a mail with replies given during the
setup. This mail can then be used to replay installation in automatic way. You
can read resources listed below if you want to know the details. Only overview
is described here. Go to [vm/README.md](vm/README.md) for usage instructions.

This involves mirroring OpenBSD installation files, which are then used both for
PXE startup and installation. The installation is done in EFI mode with GPT
partitioning of the whole disk into EFI partition and OpenBSD root. You're
expected to provide `OVMF.fd` file to be used by QEMU.

A custom package for OpenBSD is prepared and is picked up by installation which
makes system useable on the first run.

Resources:
 * https://man.openbsd.org/autoinstall
 * https://man.openbsd.org/install.site.5
 * https://www.skreutz.com/posts/autoinstall-openbsd-on-qemu/
 * https://eradman.com/posts/autoinstall-openbsd.html

## Running OpenBSD in QEMU manually

[Instructions on QEMU's Wiki](https://wiki.qemu.org/Hosts/BSD#OpenBSD)

[AMD64 platform description](https://www.openbsd.org/amd64.html)

[Installation notes](https://ftp.openbsd.org/pub/OpenBSD/7.1/amd64/INSTALL.amd64)

```
wget https://www.mirrorservice.org/pub/OpenBSD/7.1/amd64/miniroot71.img

qemu-img create -f qcow2 obsd.qcow2 32G

# for installation
qemu-system-x86_64 -m 2048 \
                   -hda miniroot71.img \
                   -drive if=virtio,file=obsd.qcow2,format=qcow2 \
                   -enable-kvm \
                   -netdev user,id=mynet0 \
                   -device virtio-net,netdev=mynet0 \
                   -bios OVMF.fd \
                   -smp $(nproc) \
                   -cpu host

# for use (including debugging)
qemu-system-x86_64 -m 2048 \
                   -drive if=virtio,file=obsd.qcow2,format=qcow2 \
                   -enable-kvm \
                   -netdev user,id=mynet0,hostfwd=tcp:127.0.0.1:9272-:22 \
                   -device virtio-net,netdev=mynet0 \
                   -bios OVMF.fd \
                   -smp $(nproc) \
                   -cpu host \
                   -serial stdio \
                   -display none \
                   -s
```

## Building custom kernel

[FAQ - Building the System from Source](https://www.openbsd.org/faq/faq5.html#Custom)

[`man config`](https://man.openbsd.org/config)

[`man options`](https://man.openbsd.org/options)

The following sequence of commands demonstrates how to prepare sources and build
kernal binary. It assumes the user is called `user`.

```
# log in as root and enable doas command (equivalent of sudo) then do the rest
# as a regular user
echo 'permit nopass user as root' >> /etc/doas.conf
```

```
# install git package
doas pkg_add git

# add your user to wsrc and wobj groups (relogin to apply these changes)
doas user mod -G wsrc,wobj user

# install OpenBSD sources
git clone https://github.com/openbsd/src /usr/src

# /sys/ is a symbolic link to /usr/src/sys/, go there to setup kernel build
cd /sys/arch/amd64/conf/

# copy multi-processor configuration file under a different name
cp GENERIC.MP CUSTOM

# apply your configuration
config CUSTOM

# build the kernel for the first time (takes about 3 minutes)
make -C ../compile/CUSTOM -j6

# copy the kernel image into / for convenience
doas cp /sys/arch/amd64/compile/CUSTOM/obj/bsd /bsd.custom
```

Now can reboot and run `> bios bsd.custom` command in bootloader to load newly
build kernel. Verify the result with `uname`:

```
$ uname -a
OpenBSD openbsd.my.domain 7.2 CUSTOM#0 amd64
```

Create `/etc/boot.conf` with `set image bsd.custom` if you want to load this
kernel by default.

If you kernel stops booting, just type `bsd` and hit enter in bootloader's
prompt to load original kernel.

## Kernel development

[`man options`](https://man.openbsd.org/options)

[`man style`](https://man.openbsd.org/style)

[`man files.conf`](https://man.openbsd.org/files.conf)

[NetBSD Documentation](https://www.netbsd.org/docs/) is applicable to OpenBSD,
not 100%, but significant portion. See
[NetBSD Internals](https://www.netbsd.org/docs/internals/en/index.html) in
particular for kernel.

See [Debugging OpenBSD kernel](./kernel-debugging.md).

## Resources

If you need more details on OpenBSD, there are:

 * [Man-pages online](https://man.openbsd.org/intro.7)
 * [OpenBSD Handbook](https://www.openbsdhandbook.com/)
