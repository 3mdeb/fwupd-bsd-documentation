# Instructions for obtaining EFI related libraries on OpenBSD

Read [README.md](./README.md) first for general information. Note that building
ports requires system with installed X11 parts of base system, you can load
`bsd.rd` from `boot >` prompt, pick "Update" and install the missing packages if
needed.

The plan is:
 * install kernel with support for EFI variables
 * prepare environment for building ports
 * build and install `efivar` port
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

mkdir /usr/distfiles /usr/packages
chown user:wobj /usr/distfiles /usr/packages/

# to be able to use ports as a regular user which is part of `wheel` group
chmod -r g+w /usr/ports/
```

## Building and installing the port

As a regular user assuming `doas` is configured:

```
git clone --depth 1 -b efivar https://github.com/3mdeb/ports /usr/ports

cd /usr/ports/devel/efivar
# build the port as a regular user
make package
# install as root
doas make install
```

## Use `efivar` binary

### Adding/updating a variable

```
echo -n newval > value
doas efivar -w -n aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-test -f value
```

### Reading a variable

```
doas efivar -p -n aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-test
```

```
GUID: aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee
Name: "test"
Attributes:
	Non-Volatile
	Boot Service Access
	Runtime Service Access
Value:
00000000  6e 65 77 76 61 6c                                 |newval          |
```

### Listing variables

```
doas efivar -l
```

```
8be4df61-93ca-11d2-aa0d-00e098032b8c-OsIndicationsSupported
8be4df61-93ca-11d2-aa0d-00e098032b8c-BootOptionSupport
8be4df61-93ca-11d2-aa0d-00e098032b8c-LangCodes
8be4df61-93ca-11d2-aa0d-00e098032b8c-PlatformLangCodes
8be4df61-93ca-11d2-aa0d-00e098032b8c-PlatformRecovery0000
8be4df61-93ca-11d2-aa0d-00e098032b8c-BootCurrent
8be4df61-93ca-11d2-aa0d-00e098032b8c-ConInDev
8be4df61-93ca-11d2-aa0d-00e098032b8c-ConOutDev
8be4df61-93ca-11d2-aa0d-00e098032b8c-ErrOutDev
8be4df61-93ca-11d2-aa0d-00e098032b8c-Boot0000
8be4df61-93ca-11d2-aa0d-00e098032b8c-Timeout
8be4df61-93ca-11d2-aa0d-00e098032b8c-PlatformLang
8be4df61-93ca-11d2-aa0d-00e098032b8c-Lang
04b37fe8-f6ae-480b-bdd5-37d98c5e89aa-VarErrorFlag
8be4df61-93ca-11d2-aa0d-00e098032b8c-Key0000
8be4df61-93ca-11d2-aa0d-00e098032b8c-Key0001
964e5b22-6459-11d2-8e39-00a0c969723b-NvVars
8be4df61-93ca-11d2-aa0d-00e098032b8c-Boot0001
8be4df61-93ca-11d2-aa0d-00e098032b8c-Boot0002
8be4df61-93ca-11d2-aa0d-00e098032b8c-Boot0003
8be4df61-93ca-11d2-aa0d-00e098032b8c-BootOrder
8be4df61-93ca-11d2-aa0d-00e098032b8c-Boot0004
378d7b65-8da9-4773-b6e4-a47826a833e1-RTC
8be4df61-93ca-11d2-aa0d-00e098032b8c-Boot0005
aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee-test
eb704011-1402-11d3-8e77-00a0c969723b-MTC
8be4df61-93ca-11d2-aa0d-00e098032b8c-ConOut
8be4df61-93ca-11d2-aa0d-00e098032b8c-ConIn
8be4df61-93ca-11d2-aa0d-00e098032b8c-ErrOut
```

### Deleting a variable

The tool doesn't support this operation.
