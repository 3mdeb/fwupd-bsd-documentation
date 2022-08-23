# OpenBSD VM management

## Overview

This is your working directory for auto-installation and using 
the VM.


`disk.qcow2` will be created by `setup.sh` script:

 * `disk.qcow2` is the 32G hard-drive of the VM

### Prerequisites

These files need to be added to this directory (copied or 
symlinked).

* NetBSD installer image (`.iso`)
* UEFI binary (`OVMF.fd`) 

## Setup

Run `./setup.sh`, follow the GUI installation setting everything 
as default and selecting minimal installation.

This process takes a few minutes, after it's finished close the 
VM and use run the VM.

## Running VM after installation

Run `./run.sh` to start the VM in graphical mode. Running QEMU in 
console currently doesn't work.
