# NetBSD - Regression logs comparison

This document compares the results of tests that have been performed using tests
from the [tests folder](https://github.com/NetBSD/src/tree/trunk/tests).

## Configuration

Tests have been performed on two different Virtual Machines(VM):

1. VM with the latest stable version - `NetBSD-9.3-amd64`.
1. VM with the custom version of NetBSD.
    [Instructions how to make one](https://github.com/3mdeb/fwupd-bsd-documentation/tree/main/netbsd).
    However setup of custom image failed due to incomplete/incorrect
    documentation.

## Test results

1. Stable Version:
   * PASSED: 8247
   * FAILED: 6
1. Custom Version:
   * PASSED: -
   * FAILED: -

## Logs from tests

Results from the tests are available on the
[cloud](https://cloud.3mdeb.com/index.php/s/5ZXcec2KpxPGCQS). Unfortunatley
regression test script doesn't tell where logs could be find or if there are
any generated.

## Summary

* Stable version gets `PASS` on most of the tests included in the repo.
* Building custom image from the documentation fails due to many errors and
    not clear instructions.
