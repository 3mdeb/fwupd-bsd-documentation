# NetBSD tests research

## Releases

**How is NetBSD released?**

The release information appears on the official project
[website](https://www.netbsd.org/). The new version is probably announced
earlier, by using the official communication channels. All releases contain
the new OS and release notes which accurately describe the changes in the
software.

**How often are NetBSD releases shipped?**

Releases occur approximately once a year (looking at the last 4 years,
earlier - very inregullary).

According to the OS glossary, stabale version releases are called formal
releases. 

Release map is available on the page dedicated to the
[project](https://www.netbsd.org/releases/release-map.html).

**What is the testing process like before a new version is released?**

No information about the testing process has been founded.

## Regression repository

**What is the regression test range?**

At this point is hard to specify - but there are a lot of tests.

**Where can I find the regression test code?**

[here](https://github.com/NetBSD/src/tree/trunk/tests)

**How are regression tests written (language, transparency, syntax)?**

Lots of small C files with corresponding Makefiles in each folder, also lots of
bash scripts.

**Is it possible to set infra locally, what commands can be used to invoke particular kits and/or test cases?**

The regression files must be located directly on the platform being tested and
run from there.

With the repo, we only need the regress folder, and when we have it on the
device, just do:

```bash
    cd /usr/tests; atf-run | atf-report
```

and all regression will begin to execute.

**Are any CI / CD mechanisms introduced? If so, what are they?**

No mechanism has been founded.

**Are there a lot of Issues in the test infrastructure repository and are there a lot of requests?**

The repository does not contain `Issues` section. All bugs should be reported
by using [web form](https://www.netbsd.org/cgi-bin/sendpr.cgi?gndb=netbsd)

## Contributing to the regression repository

Full contribute documentation is available on the
[project site](https://www.netbsd.org/contrib/).

## Test scope

**What tests should be added?**

All functionalities that will be added should have tests. It will be
possible to describe in more detail after the implementation is completed.

What we probably would  like to check:

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

**Do the project developers provide any additional information regarding the tests**

Project developers informs about test best practices, which might be founded
in [README file](https://github.com/NetBSD/src/blob/trunk/tests/README).

## Additional information: OS installation in automated test

1. Automatic os installation test are currently implemented in various cases
in our testing env (eg. pfSense, Ubuntu, Debian). They're implemented using
Robot Framework and Bash scripts. Main issue would be creating unattended
installer __and documentation how to create one__.

[NetBSD unattended installer creation](https://unix.stackexchange.com/questions/250289/automatic-install-netbsd-iso)
[pfSense installerconfig](https://pcengines.github.io/apu2-documentation/pfsense_installerconfig/)
[NetBSD supported hardware](https://www.netbsd.org/ports/)
