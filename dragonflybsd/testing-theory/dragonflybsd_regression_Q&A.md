# DragonflyBSD tests research

## Releases

**How is DragonflyBSD released?**

Releases occur approximately twice a year. DragonFly release branches only
contain bug and security fixes and are designed for people running production
systems who don't want any surprises. Brand-new features often discussed on
the mailing lists are typically not in release branches.

DragonFly systems based on releases are labeled RELEASE, for example, you
might be running DragonFly X.Y.Z-RELEASE. If you run a daily snapshot or
track git master, you'll see X.Y.Z-DEVELOPMENT as your system version.

## Regression repository

**How are regression tests written (language, transparency, syntax)?**

Tests are mainly written in C/C++ with support of some files with various
formats.

## OS installation in automated test

1. Automatic os installation test are currently implemented in various cases
in our testing env (eg. pfSense, Ubuntu, Debian). They're implemented using
Robot Framework and Bash scripts. Main issue would be creating unattended
installer __and documentation how to create one__.

    - [Auto installer creation guide](https://umbriel.fr/blog/DragonFly_BSD_autoinstall.html)
    - [Similar guide for FreeBSD](https://www.freebsd.org/cgi/man.cgi?bsdinstall(8))

1. Most propably VMs are going to be used during test procedures so automatic
OS installation may not be neccesary.

## Contributing to the regression repository

DragonflyBSD doesn't have contribution guidelines. It may be necessary to
contact maintainers for information.

## Test scope

**What tests should be added?**

All functionalities that will be added should have tests. It will be
possible to describe in more detail after the implementation is completed.

What we probably would  like to check:

Values ​​from the ESRT table, however, a tool from
[this site](https://reviews.freebsd.org/rG24f398e7a153a05a7e94ae8dd623e2b6d28d94eb)
is needed. It seems that API will be compatible so one might work after updating
EFI-specific including having the form like `dev/efi/efi.h`.

Most propably for ESRT tables test we will use `kenv` tool.

Features to be added:

* efi_append_variable() - appends data of size to the variable specified by guid
and name.
* efi_del_variable() - deletes the variable specified by guid and name.
* efi_get_variable() - gets variable's data_size, and its attributes are stored
in attributes.
* efi_get_variable_attributes() - gets attributes for the variable specified by
guid and name.
* efi_get_variable_size() - gets the size of the data for the variable specified
by guid and name.
* efi_get_next_variable_name() - iterates across the currently extant variables,
passing back a guid and name
* efi_guid_to_name() - translates from an efi_guid_t to a well known name.
* efi_guid_to_symbol() - translates from an efi_guid_t to a unique
(within libefivar) C-style symbol name.
* efi_guid_to_str() - allocates a suitable string and populates it with string
representation of a UEFI GUID.
* efi_name_to_guid() - translates from a well known name to an efi_guid_t.
* efi_set_variable() - sets the variable specified by guid and name.
* efi_str_to_guid() - parses a UEFI GUID from string form to an efi_guid_t.
* efi_variables_supported() - checks if EFI variables are accessible.
* efi_generate_file_device_path() - generates an EFI file device path for an EFI
binary from a filesystem path.

To start writing tests, a new folder with matching name tests should be created.
Add a `Makefile` file that handles and sets tests within a given location
and accordingly test files, which in this case will probably be bash scripts,
but it all depends if some other language (C/Perl) doesn't get any easier
write tests.
