# OpenBSD regression recognition - Q&A

## Releases

**How is OpenBSD released?**

The release information appears on the official project
[website](https://www.openbsd.org/). The new version is probably announced
earlier, by using the official communication channels. All releases contain
the new OS and release notes which accurately describe the changes in the
software.

**How often are OpenBSD releases shipped?**

Twice a year, mainly April/May and September/October - the months are sometimes
different, but since 1996 they release 2 versions of the system a year so this
won't change.

**What is the testing process like before a new version is released?**

Can't find any information about the tests of the released operation system.

## Regression repository

**What is the regression test range?**

At this point is hard to specify - but there are a lot of tests.

**Where can I find the regression test code?**

[here](https://github.com/openbsd/src/tree/master/regress)

**How are regression tests written (language, transparency, syntax)?**

Lots of small C ++ files with corresponding Makefiles in each folder, lots of
bash scripts and Perl files too and you can find single files with an exotic
extension.

**How do we contribute to the test code repository?**

It is possible to contribute to the project upstream.

**Is it possible to set up a test infrastructure locally?**

The regression files must be located directly on the platform being tested and
run from there.

**If it is possible to set infra locally, what commands can be used to invoke particular kits and/or test cases?**

With the repo, we only need the regress folder, and when we have it on the
device, just do:

```bash
    cd regress
    make regress
```

and all regression will begin to execute.

**Are any CI / CD mechanisms introduced? If so, what are they?**

None mechanism has been founded

**Are there a lot of Issues in the test infrastructure repository and are there a lot of requests?**

The repository's description states "Pull requests not accepted - send diffs to the
tech@ mailing list." - [here](https://marc.info/?l=openbsd-tech).
Bugs are also in [the mailing list](https://marc.info/?l=openbsd-bugs), so hard
to say how many of them are open.
