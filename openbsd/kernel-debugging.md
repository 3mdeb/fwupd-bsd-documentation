# Debugging OpenBSD kernel

Read [Debugging the OpenBSD kernel via QEMU][post],
which is a bit outdated, but still mostly correct.

Things to note:

 * no need to add `makeoptions DEBUG="-g"` to the config, it's default value and
   `bsd.gdb` is always built for you
 * compiling with `-O0` results in failures due to too large stack frames, can
   use `-Og` though:
   ```
   makeoptions COPTIMIZE="-Og"
   ```
 * `option DIAGNOSTIC` is on by default
 * there is also `option DEBUG`, but it makes kernel unusable, it loads very
   slow and I didn't notice any extra verbose output

## How to prepare the host for debugging

Have OpenBSD sources cloned locally.

Copy `/sys/arch/amd64/compile/CUSTOM/obj/bsd.gdb` locally.

To be able to start pre-configured `gdb` using `gdb -x gdbinit` create
`gdbinit` file like this one (edit path to sources):

```
define binst
    save breakpoints bp.dump
    delete
    source bp.dump
    info break
end
document binst
    re-install breakpoints
end

file bsd.gdb
set substitute-path /usr/src ../src
target remote :1234
```

## How to attach properly

To debug kernel startup `gdb` has to connect to QEMU after kernel image is
loaded, but before it started executing. Below is one way to do this.

In bootloader's prompt run the kernel in configuration mode (UKC) by passing it
`-c` option:

```
> bsd.custom -c
```

In another terminal start `gdb` (`gdb -x gdbinit`). Set breakpoints and then
run `continue` command.

Go back to OpenBSD VM and run `exit` command to continue boot.

## How to pause kernel

Pressing Ctrl+C in gdb will do that. The QEMU will also pause right after you've
attached to it, so don't forget to do `continue`.

## Debugging after a reboot

Mind that reboot wipes the memory along with breakpoints, so they won't be
usable after a reboot, but `gdb` will still think they are there (`info break`).

You basically have to setup them after a reboot. Luckily, `gdb` makes this easy,
see `binst` custom command above in `gdbinit` file.

## When kernel aborts

Such situations will through you into kernel debugger. At this point execution
stack has been changed by the debugger and using `gdb` is not really useful, so
you most likely want to do `boot reboot` or `boot poweroff`.

[post]: https://markshroyer.com/2013/01/debugging-openbsd-via-qemu/
