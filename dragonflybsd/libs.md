# Instructions for obtaining EFI related libraries on DragonflyBSD

Read [README.md](./README.md) first for general information.

DragonflyBSD already has support for EFI variables in kernel, so no need to use
a custom one.

The plan is:
 * prepare environment for building ports
 * build and install `efivar-bsd` port (might be renamed to `efivar` later)
 * build a test tool
 * verify that it works

## Preparing for using ports

`git`, `gcc` and other basic tools should be installed by default, so we only
need to pull ports tree. Run this and other commands below as a `root` user:

```
git clone --depth 1 -b efivar https://github.com/3mdeb/DPorts.git /usr/dports
```

## Building and installing the port

```
cd /usr/dports/devel/efivar-bsd
# update "distinfo" file in case it diverged due to active development
make makesum
# build and install the port
make install
```

## Prepare user-space tool

```
mkdir ~/efivarlibtest
cd ~/efivarlibtest
curl https://raw.githubusercontent.com/3mdeb/openbsd-src/efivars-api/usr.sbin/efivarlibtest/efivarlibtest.c > efivarlibtest.c
gcc -I/usr/local/include -L/usr/local/lib -Wl,-rpath,/usr/local/lib efivarlibtest.c -lefivar -o efivarlibtest
```

`-rpath` is needed to avoid picking up `/usr/lib/libefivar.so` which comes with
the system. Might need to rename port's library to get rid of this.

## Use the test tool

### Loading `efirt` module

The module that provides `/dev/efi` is not loaded by default, so load it:

```
kldload efirt
```

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
