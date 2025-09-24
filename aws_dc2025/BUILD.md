# Build settings

After adding the required directories for DC2025 and before starting any services, the current file system looks like (all are encrypted as per security requirements, the row order has been amended to be more intuitive):

```
Filesystem                        Type      Size  Used Avail Use% Mounted on
efivarfs                          efivarfs  128K  4.4K  119K   4% /sys/firmware/efi/efivars
/dev/nvme1n1p4                    xfs        63G  3.9G   59G   7% /
/dev/nvme1n1p3                    xfs       960M  324M  637M  34% /boot
/dev/nvme1n1p2                    vfat      200M  7.1M  193M   4% /boot/efi
/dev/mapper/vg_var-lv_var         xfs       128G  949M  128G   1% /var
/dev/mapper/vg_tmp-lv_tmp         xfs       100G  746M  100G   1% /tmp
/dev/mapper/vg_cdx-lv_cdx         ext4      503G   28K  478G   1% /mnt/data/dc/cdx/data
/dev/mapper/vg_output-lv_output   xfs       5.0T   36G  5.0T   1% /mnt/data/dc/heritrix/output
/dev/mapper/vg_scratch-lv_scratch ext4      503G   28K  478G   1% /mnt/data/dc/heritrix/scratch
/dev/mapper/vg_state-lv_state     xfs       5.0T   36G  5.0T   1% /mnt/data/dc/heritrix/state
/dev/mapper/vg_kafka-lv_kafka     xfs       4.0T   29G  4.0T   1% /mnt/data/dc/kafka
```
