## Reading ESRT values from Ubuntu

It may be usefull to verify that values printed by BSDs are correct - in cases
where we work on real hardware instead of QEMU with fake OVMF where we can get
faked values from sources.

Full path for ESRT entries is `/sys/firmware/efi/esrt`

### Printing all of ESRT values:

We can do this with commands:
```
# cd /sys/firmware/efi/esrt
# find ./ -type f | xargs sudo tail -n +1
```

Example of output:
```
==> ./fw_resource_count_max <==
1

==> ./fw_resource_count <==
1

==> ./entries/entry0/fw_class <==
212026ee-fde4-4d08-ac41-c62cb4036a42

==> ./entries/entry0/lowest_supported_fw_version <==
70918

==> ./entries/entry0/last_attempt_version <==
0

==> ./entries/entry0/last_attempt_status <==
0

==> ./entries/entry0/fw_type <==
1

==> ./entries/entry0/fw_version <==
70918

==> ./entries/entry0/capsule_flags <==
0x20000

==> ./fw_resource_version <==
1

```
