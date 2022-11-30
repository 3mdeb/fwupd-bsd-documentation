# Regression logs comparison

This document compares the results of tests that have been performed using tests
from the [regression folder](https://github.com/openbsd/src/tree/master/regress).

## Configuration

Tests have been performed on two different Virtual Machines(VM):

1. VM with the latest stable version(7.2) of OpenBSD.
1. VM with the custom version of OpenBSD based on the stable version(7.2).

   Customization comes down to configuring the system in accordance with the
   documentation contained in [esrt.md](/openbsd/esrt.md).

## Test results

1. Stable Version:
   * PASSED: 4366
   * UNEXPECTED_PASS: 1
   * EXPECTED FAILED: 50
   * FAILED: 186
   * SKIPPED: 42
1. Custom Version:
   * PASSED: 644
   * EXPECTED FAILED: 8
   * FAILED: 2

   > The regression on custom version just got stuck after 654 tests. This is
   > probably due to the specification of the prepared VM, but it makes it
   > impossible to fully compare the results.

## Logs from tests

Logs from the tests are available on the
[cloud](https://cloud.3mdeb.com/index.php/apps/files/?dir=/projects/BSD/openbsd/).

## Summary

Due to the inability to perform full regression on the custom version, the
results are not suitable for meaningful comparison.
