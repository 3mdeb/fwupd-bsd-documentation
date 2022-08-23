# NetBSD Regression Tests Research

- [Repository](https://github.com/NetBSD/src)
- [Tests](https://github.com/NetBSD/src/tree/trunk/tests)
- [Readme](https://github.com/NetBSD/src#readme)

## IMPORTANT

During research occured some problems with installation and booting to NetBSD
OS on various platforms avalible in 3mdeb lab. Unfortunatley, those problems
made it impossible to confirm proper functionality of the regression tests.

## Building NetBSD from repository

- [Building Manual](https://github.com/NetBSD/src/blob/trunk/BUILDING)

To build for amd64 (x86_64) execute below command in the `src` directory:

```bash
    ./build.sh -U -u -j4 -m amd64 -O ~/obj release
```

- [Daily Builds](https://nycdn.netbsd.org/pub/NetBSD-daily/HEAD/latest/)
- [Relases](https://cdn.netbsd.org/pub/NetBSD/)

## Testing

Regression tests are built in NetBSD OS and are performed from terminal.
One-liner to run tests:

```bash
    cd /usr/tests; atf-run | atf-report
```

## Best practices while creating new tests

When adding new tests, please try to follow the following conventions.

1. For library routines, including system calls, the directory structure of
   the tests should follow the directory structure of the real source tree.
   For instance, interfaces available via the C library should follow:

```bash
    src/lib/libc/gen -> src/tests/lib/libc/gen
    src/lib/libc/sys -> src/tests/lib/libc/sys
    ...
```

2. Equivalently, all tests for userland utilities should try to follow their
   location in the source tree. If this can not be satisfied, the tests for
   a utility should be located under the directory to which the utility is
   installed. Thus, a test for env(1) should go to src/tests/usr.bin/env.
   Likewise, a test for tcpdump(8) should be in src/tests/usr.sbin/tcpdump,
   even though the source code for the program is located under src/external.

3. Otherwise use your own discretion.

- [Link](https://github.com/NetBSD/src/blob/trunk/tests/README)