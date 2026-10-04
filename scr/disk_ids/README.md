# Disk Id options for portable backup/restore

## For newer Kernels and file systems.

UUID vs. PARTUUID (GPT): Linux unterscheidet zwischen der UUID (ID des
Dateisystems im Superblock) und der PARTUUID (ID der Partition in der
GPT-Partitionstabelle der Festplatte).

PARTUUID (Partition UUID / GUID) einer GPT (GUID Partition Table).

UUIDs much more reliable than labels
UUID amon kernels and world unique independent of which kernel reads it

PARTUUID to be completely independent of installed file systems

### admin PARTUUID
linux
blkid -o value -s PARTUUID /dev/sdb1
macos
gpt show -i 1 /dev/disk2
windows nt
Get-Disk | Get-Partition | Select-Object DiskNumber, PartitionNumber, Guid
bsd
gpart show -p geom /dev/ada0

### user PARTUUID

Users have to use virtual fs like /sys and /proc, system daemons udisk (linux),
launchservices (macos).

linux
lsblk -d -n -o PARTUUID /dev/sdb1
macos
diskutil info disk2s1 | awk '/Partition UUID/ {print $3}'
windows nt
Get-CimInstance Win32_Volume | Select-Object DriveLetter, DeviceID
  (Die "DeviceID" enthält bei GPT-Systemen die standardisierte Volume-GUID)
bsd
virtual kernel dir (devfs masked) or sysctl request of storage systems

### most portabl linux

* filesystem uuid (FSUUID)
* dont use fs specific tools like tune2fs, xfs_db btrfs inspect-internal
* use libblkid and kernel abstraction
* /dev/disk/by-uuid/
* findmnt
  - PATH_ACT=$(findmnt -n -c -o TARGET --source UUID="$UUID")
