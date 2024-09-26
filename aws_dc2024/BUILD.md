# Build settings

After adding the required directories for DC2024, the current file system looks like (all are encrypted as per security requirements):

```
Filesystem                      Type      Size  Used Avail Use% Mounted on
/dev/nvme0n1p4                  xfs        63G  4.0G   59G   7% /
/dev/nvme0n1p3                  xfs       960M  431M  530M  45% /boot
/dev/nvme8n1p1                  ext4      755G   28K  717G   1% /mnt/data/dc/heritrix/scratch
/dev/nvme4n1p1                  ext4     1007G   28K  956G   1% /mnt/data/dc/cdx/data
/dev/nvme0n1p2                  vfat      200M  7.1M  193M   4% /boot/efi
/dev/nvme6n1p1                  ext4      494G  3.6G  466G   1% /ukwa
/dev/mapper/vg_tmp-lv_tmp       xfs       128G  946M  128G   1% /tmp
/dev/mapper/vg_var-lv_var       xfs       256G  7.1G  249G   3% /var
/dev/mapper/vg_kafka-lv_kafka   xfs       2.0T   15G  2.0T   1% /mnt/data/dc/kafka
/dev/mapper/vg_output-lv_output xfs       5.0T   36G  5.0T   1% /mnt/data/dc/heritrix/output
/dev/mapper/vg_state-lv_state   xfs       5.0T   36G  5.0T   1% /mnt/data/dc/heritrix/state
```
