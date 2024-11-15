# Build settings

After adding the required directories for DC2024, the current file system looks like (all are encrypted as per security requirements, the row order has been amended to be more intuitive):

```
Filesystem                      Type      Size  Used Avail Use% Mounted on
/dev/nvme0n1p4                  xfs        63G  4.0G   59G   7% /
/dev/nvme0n1p3                  xfs       960M  431M  530M  45% /boot
/dev/nvme0n1p2                  vfat      200M  7.1M  193M   4% /boot/efi
/dev/mapper/vg_tmp-lv_tmp       xfs       128G  946M  128G   1% /tmp
/dev/mapper/vg_var-lv_var       xfs       256G  7.1G  249G   3% /var
/dev/nvme8n1p1                  ext4      755G   28K  717G   1% /mnt/data/dc/heritrix/scratch
/dev/nvme4n1p1                  ext4     1007G   28K  956G   1% /mnt/data/dc/cdx/data
/dev/mapper/vg_kafka-lv_kafka   xfs       2.0T   15G  2.0T   1% /mnt/data/dc/kafka
/dev/mapper/vg_output-lv_output xfs       5.0T   36G  5.0T   1% /mnt/data/dc/heritrix/output
/dev/mapper/vg_state-lv_state   xfs       5.0T   36G  5.0T   1% /mnt/data/dc/heritrix/state
/dev/nvme6n1p1                  ext4      494G  3.6G  466G   1% /ukwa
```

After 45 days of DC2024 running, the current file system looks like:
```
Filesystem                      Type      Size  Used Avail Use% Mounted on
/dev/nvme0n1p4                  xfs        63G  5.5G   58G   9% /
/dev/nvme0n1p3                  xfs       960M  435M  526M  46% /boot
/dev/nvme0n1p2                  vfat      200M  7.1M  193M   4% /boot/efi
/dev/mapper/vg_tmp-lv_tmp       xfs       128G  946M  128G   1% /tmp
/dev/mapper/vg_var-lv_var       xfs       256G   35G  222G  14% /var
/dev/nvme9n1p1                  ext4      755G  567M  716G   1% /mnt/data/dc/heritrix/scratch
/dev/nvme1n1p1                  ext4     1007G   68G  888G   8% /mnt/data/dc/cdx/data
/dev/mapper/vg_kafka-lv_kafka   xfs       4.0T  423G  3.6T  11% /mnt/data/dc/kafka
/dev/mapper/vg_state-lv_state   xfs        15T   12T  3.4T  78% /mnt/data/dc/heritrix/state
/dev/mapper/vg_output-lv_output xfs       5.0T  1.5T  3.6T  30% /mnt/data/dc/heritrix/output
/dev/nvme10n1p1                 ext4      494G  6.4G  463G   2% /ukwa
```

Note that several volumes have increased in size already, especially `/mnt/data/dc/heritrix/state` which is an LVM volume of three 5TiB 'disks' now.
