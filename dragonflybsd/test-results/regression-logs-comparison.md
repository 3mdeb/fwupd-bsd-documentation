# Regression logs comparison

This document compares the results of tests that have been performed using tests
from the [regression folder](https://github.com/DragonFlyBSD/DragonFlyBSD/tree/master/tools/regression).

## Configuration

Tests have been performed on two diffrent Virtual Machines(VM):

1. VM with latest stable version(6.2.2) of DragonFlyBSD.
1. VM with custom version of DragonFlyBSD based on stable version(6.2.2).

   Customization comes down to configuring the system in accordance with the
   documentation contained in [esrt-api.md](/dragonflybsd/esrt-api.md) and
   [libs.md](/dragonflybsd/libs.md).

## Test results

1. Stable Version:
   * PASSED: 732
   * FAILED: 4
1. Custom Version:
   * PASSED: 732
   * FAILED: 4

## Logs from tests

Logs from the tests are aviable on the
[cloud](https://cloud.3mdeb.com/index.php/apps/files/?dir=/projects/BSD/dragonflybsd&fileid=517420).

## Summary

The test results on both machines are identical, which proves that they have
been entered changes in the custom version don't adversely affect on the
operating system.
