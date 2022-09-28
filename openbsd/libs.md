# Instructions for obtaining EFI related libraries on OpenBSD

Read [README.md](./README.md) first for general information. Note that building
ports requires system with installed X11 parts of base system, you can load
`bsd.rd` from `boot >` prompt, pick "Update" and install the missing packages if
needed.

The plan is:
 * install kernel with support for EFI variables
 * prepare environment for building ports
 * build and install `efivar` port
 * compile and install test tool that uses `libefivar`
 * verify that it works

## Install kernel with support for EFI variables

Follow steps outlined in [efivars.md](./efivars.md) for this.

## Preparing for using ports

To prepare using ports as a regular user `user` perform these steps as `root`:

```
cat > /etc/mk.conf <<EOF
WRKOBJDIR=/usr/obj/ports
DISTDIR=/usr/distfiles
PACKAGE_REPOSITORY=/usr/packages
EOF

mkdir -p /usr/ports /usr/distfiles /usr/packages
chown user:wobj /usr/distfiles /usr/packages/

# to be able to use ports as a regular user which is part of `wheel` group
chmod -R g+w /usr/ports/

# upgrade to 7.2, to make pkg_add work again (upstream made an incompatible
# change compared to 7.1 and because the kernel being run is 7.2, pkg_add will
# use binary packages for 7.2 as well)
sysupgrade
```

## Building and installing the port

As a regular user assuming `doas` is configured:

```
git clone --depth 1 -b efivar https://github.com/3mdeb/ports /usr/ports

cd /usr/ports/devel/efivar
# update "distinfo" file in case it diverged due to active development
make makesum
# build and install the port (building as root as well to install dependencies)
doas make install
```

## Prepare user-space tool

```
# build sample tool
make -C /usr/src/usr.sbin/efivarlibtest

# install it
doas make -C /usr/src/usr.sbin/efivarlibtest install
```

## Use the test tool (almost identical to `efivartest`)

### Adding/updating a variable

```
doas efivarlibtest set aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee test newval
```

### Reading a variable

```
doas efivarlibtest get aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee test
```

```
aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-test (6):
 HEX: 0x6e 0x65 0x77 0x76 0x61 0x6c
 ASCII: newval
```

### Listing variables

```
doas efivarlibtest list
```

The difference from `efivartest` is here, `libefivar` can replace GUIDs with
their mnemonics.

```
{global}-OsIndicationsSupported
{global}-BootOptionSupport
{global}-LangCodes
{global}-PlatformLangCodes
{global}-PlatformRecovery0000
{global}-BootCurrent
{global}-ConInDev
{global}-ConOutDev
{global}-ErrOutDev
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
{378d7b65-8da9-4773-b6e4-a47826a833e1}-RTC
{global}-Boot0005
{eb704011-1402-11d3-8e77-00a0c969723b}-MTC
{aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee}-test
```

### Deleting a variable

```
doas efivarlibtest delete aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee test
```
