# OpenBSD VM management

## Overview

This is your working directory for auto-installation and using the VM.

`ai/` directory contains configuration files used during auto-installation.

`disk.qcow2`, `tftp` and `web/` will be created by `setup.sh` script:

 * `disk.qcow2` is the hard-drive of the VM
 * `tftp/` will be used by builtin TFTP of QEMU for PXE boot
 * `web/` will be served on 8000 port and will be used by OpenBSD installer as
   a temporary source of packages

`OVMF.fd` needs to be added to this directory (copied or symlinked).

## Setup

Run `./setup.sh`, when you see a prompt for response file location (press `a` to
skip 5 second delay before auto-installation starts):

    Response file location? [http://10.0.2.2/install.conf]

Type in `http://10.0.2.2:8000/install.conf`. This is the only manual step, the
rest should happen automatically unless some unexpected failure occurs.

At the end you'll be asked to press a key to reboot, can do that or hit Ctrl+C
to close QEMU and use `./run.sh`.

## VM state after installation

`bash`, `vim` and `git` are installed.

X11 packages are also installed in case of port development, because ports
refuse to build if these are missing.

SSH server is running and forwarded on port 9272 on the host.

`root` has password `root` and it can't log in via SSH.

`user` has no password, but it will have your `~/.ssh/id_rsa.pub` listed in
`~/.ssh/authorized_keys`.

`user` is a member of `wsrc` and `wobj` groups so kernel development can be
done.

## Running VM after installation

Run `./run.sh` to start the VM in console. The serial console will close if you
hit Ctrl+C and can have issues with interactive applications like `less`, so
you probably want to connect over SSH in another terminal:

    ssh user@127.0.0.1 -p 9272
