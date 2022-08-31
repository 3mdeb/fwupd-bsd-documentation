# NetBSD VM management

## Overview

This is your working directory for auto-installation and using the VM.

If it doesn't exist, `disk.qcow2` (the 32G hard-drive of the VM) will be 
created by `setup.sh` script

If it does, the script will delete it and create again (with user confirmation)

### Prerequisites

These files need to be added to this directory (copied or 
symlinked).

* NetBSD installer image (`.iso`) - this can be sourced from:
  * a stable NetBSD release, like
   https://www.netbsd.org/releases/formal-9/NetBSD-9.3.html (CD/DVD 
   installation image)
  * produced from sources
    * this requires going through all build steps, that is building kernel, 
    building release and producing iso-image
    * instructions about building can be found at the main README (one 
    directory up)
    * the `.iso` file can be found at `~/obj/releasedir/images`
* UEFI binary (`OVMF.fd`)
  * difficult to find online, included with some template ESRT in this directory
  * built from sources - follow the instructions (in order):
    * https://github.com/tianocore/tianocore.github.io/wiki/Common-instructions 
    * https://github.com/tianocore/edk2/blob/master/OvmfPkg/README
    * or use TL;DR:
        ```
          git clone https://github.com/tianocore/edk2
          cd edk2
          git submodule update --init
          make -C BaseTools
          ( . edksetup.sh && build -a X64 -p OvmfPkg/OvmfPkgX64.dsc -t GCC5 -b RELEASE -n 5 )
        ```

## Setup

Run `./setup.sh`, follow the GUI installation setting everything 
as default and selecting minimal installation.

This process takes a few minutes, after it's finished close the 
VM and use `./run.sh` to run the VM.

## Running VM after installation

Run `./run.sh` to start the VM in graphical mode. Running QEMU in 
console currently doesn't work.
