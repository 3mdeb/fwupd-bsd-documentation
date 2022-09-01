# OpenBSD regression recognition - Q&A

## Releases

**How is OpenBSD released?**

The release information appears on the official project
[website](https://www.openbsd.org/). The new version is probably announced
earlier, by using the official communication channels. All releases contain
the new OS and release notes which accurately describe the changes in the
software.

**How often are OpenBSD releases shipped?**

Twice a year, mainly April/May and September/October - the months are sometimes
different, but since 1996 they release 2 versions of the system a year so this
won't change.

**What is the testing process like before a new version is released?**

No information about the testing process has been founded.

## Regression repository

**What is the regression test range?**

At this point is hard to specify - but there are a lot of tests.

**Where can I find the regression test code?**

[here](https://github.com/openbsd/src/tree/master/regress)

**How are regression tests written (language, transparency, syntax)?**

Lots of small C ++ files with corresponding Makefiles in each folder, lots of
bash scripts and Perl files too and you can find single files with an exotic
extension.

**Is it possible to set up a test infrastructure locally?**

The regression files must be located directly on the platform being tested and
run from there.

**If it is possible to set infra locally, what commands can be used to invoke particular kits and/or test cases?**

With the repo, we only need the regress folder, and when we have it on the
device, just do:

```bash
    cd regress
    make regress
```

and all regression will begin to execute.

**Are any CI / CD mechanisms introduced? If so, what are they?**

No mechanism has been founded.

**Are there a lot of Issues in the test infrastructure repository and are there a lot of requests?**

The repository's description states "Pull requests not accepted - send diffs to the
tech@ mailing list." - [here](https://marc.info/?l=openbsd-tech).
Bugs are also in [the mailing list](https://marc.info/?l=openbsd-bugs), so hard
to say how many of them are open.

## Contributing to the regression repository

It is possible to contribute to the project upstream. See
[this](https://www.openbsd.org/faq/faq5.html#Diff) for how to send patches and
recommendations at the top of [this](https://www.openbsd.org/mail.html).

## Test scope

**What tests should be added?**

All functionalities that will be added should have tests. More it will be
possible to describe in detail after the implementation is completed.

What we would probably like to check:

Values ​​from the ESRT table, however, a tool from
[this site](https://reviews.freebsd.org/rG24f398e7a153a05a7e94ae8dd623e2b6d28d94eb)
is needed. It seems that API will be compatible so one might work after updating
EFI-specific including having the form like `dev/efi/efi.h`.

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
