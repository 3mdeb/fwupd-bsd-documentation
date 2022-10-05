# Instructions for obtaining EFI related libraries on NetBSD

Read [README.md](./README.md) first for general information.

NetBSD already has support for EFI variables in the kernel, but this
functionality is not yet available in releases, which is why we need to build
the kernel ourselves.

The plan is:
 * install kernel with support for EFI variables
 * prepare environment for building ports
 * build and install `efivar` port
 * build a test tool
 * verify that it works

## Install kernel with support for EFI variables

You can either cross-compile and make an ISO as described in the README or run
the commands below as `root` on an already running NetBSD:

```
# install git
export PATH="/usr/pkg/sbin:/usr/pkg/bin:$PATH"
export PKG_PATH="http://cdn.netbsd.org/pub/pkgsrc/packages/NetBSD/amd64/9.3/All/"
pkg_add git

# clone sources
export GIT_SSL_NO_VERIFY=true
git clone -b os-interface --depth 1 https://github.com/3mdeb/NetBSD-src.git /usr/src

# build the kernel
cd /usr/src/sys/arch/amd64/conf
cp GENERIC MYKERNEL
mkdir /usr/obj
cd /usr/src
./build.sh tools
./build.sh -u -j$(sysctl -n hw.ncpu) kernel=MYKERNEL

# install as a second kernel to be used when needed
cp /usr/obj/sys/arch/amd64/compile/MYKERNEL/netbsd /netbsd.my
# install efiio header
cp /usr/src/sys/sys/efiio.h /usr/include/sys/

# create /dev/efi device file
make -C /usr/src/etc MAKEDEV TOOLDIR=/usr/obj/tooldir.NetBSD-9.3-amd64/ MKDTB=no
cd /dev
sh /usr/src/etc/MAKEDEV efi

# restart the system to load a new kernel
reboot
# press 3 and then run "boot netbsd.my" on > prompt
```

## Preparing for using ports

See above how to install `git`. Run this and other commands below as a `root`
user:

```
git clone -b efivar --depth=1 https://github.com/3mdeb/pkgsrc /usr/pkgsrc
```

## Building and installing the port

```
cd /usr/pkgsrc/devel/efivar/
# update "distinfo" file in case it diverged due to active development
make makesum
# build and install the port
make install
```

## Prepare user-space tool

```
mkdir ~/efivarlibtest
cd ~/efivarlibtest
curl --insecure https://raw.githubusercontent.com/3mdeb/openbsd-src/efivars-api/usr.sbin/efivarlibtest/efivarlibtest.c > efivarlibtest.c
gcc -I/usr/pkg/include -L/usr/pkg/lib -Wl,-rpath,/usr/pkg/lib efivarlibtest.c -lefivar -o efivarlibtest
```

`-rpath` is needed in case `/usr/pkg/lib` is not in library search path, which
seems to be the default.

## Use the test tool

### Adding/updating a variable

```
./efivarlibtest set aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee test newval
```

### Reading a variable

```
./efivarlibtest get aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee test
```

```
aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-test (6):
 HEX: 0x6e 0x65 0x77 0x76 0x61 0x6c
ASCII: newval
```

### Listing variables

```
./efivarlibtest list
```

```
{global}-OsIndicationsSupported
{global}-BootOptionSupport
{global}-LangCodes
{global}-PlatformLangCodes
{global}-PlatformRecovery0000
{global}-ConOutDev
{global}-ErrOutDev
{global}-ConInDev
{global}-BootCurrent
{global}-Boot0000
{global}-Timeout
{global}-PlatformLang
{global}-Lang
{04b37fe8-f6ae-480b-bdd5-37d98c5e89aa}-VarErrorFlag
{global}-Key0000
{global}-Key0001
{global}-ConOut
{global}-ConIn
{global}-ErrOut
{964e5b22-6459-11d2-8e39-00a0c969723b}-NvVars
{global}-Boot0001
{global}-Boot0002
{global}-Boot0003
{global}-BootOrder
{global}-Boot0004
{eb704011-1402-11d3-8e77-00a0c969723b}-MTC
{aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee}-test
```

### Deleting a variable

```
./efivarlibtest delete aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee test
```
