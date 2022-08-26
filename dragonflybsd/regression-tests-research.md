# DragonflyBSD tests research

## Recognition

1. Tests are mainly written in C/C++ with support of some files with various
formats.

1. Tests don't include efi/esrt tests.

1. DragonflyBSD doesn't have contribution guidelines. It may be necessary to
contact maintainers for information.

1. It would be more convenient to create new tests similarly to ones currently
existing in repo. Introduction whole robot framework environment to the project
may raise many questions and create many issues.

## OS installation in automated test

1. Automatic os installation test are currently implemented in various cases
in our testing env (eg. pfSense, Ubuntu, Debian). They're implemented using
Robot Framework and Bash scripts. Main issue would be creating unattended
installer __and documentation how to create one__.

[Auto installer creation guide](https://umbriel.fr/blog/DragonFly_BSD_autoinstall.html)
[Similar guide for FreeBSD](https://www.freebsd.org/cgi/man.cgi?bsdinstall(8))