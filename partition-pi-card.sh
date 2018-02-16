#!/bin/bash


DEV="$1"
PKG="$2"

if [ ! -f "$PKG" ]; then
	echo "$PKG - file not accessible"
	exit 1
fi

partprobe
fdisk -l "$DEV"
if fdisk -l /dev/sdc | grep '^Disk /' | egrep " [0-9][0-9]\.[0-9] GiB"; then
	echo "Device looks like a SD-Card size-wise"
else
	echo "Device doesn't look like a SD-Card size-wise !!!"
fi

echo -n "Enter 'y' to continue ... "
read dummy
if [ "$dummy" != 'y' ]; then
	echo "Exiting"
	exit 1
fi

# to create the partitions programatically (rather than manually)
# we're going to simulate the manual input to fdisk
# The sed script strips off all the comments so that we can 
# document what we're doing in-line with the actual commands
# Note that a blank line (commented as "defualt" will send a empty
# line terminated with a newline to take the fdisk default.
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk ${DEV}
  o # clear the in memory partition table
  n # new partition
  p # primary partition
  1 # partition number 1
    # default - start at beginning of disk 
    # default - end at end of disk
  y # remove signature
  t # change partition type
  c # W95 FAT32 (LBA)
  a # make a partition bootable
  p # print the in-memory partition table
  w # write the partition table
  q # and we're done
EOF

sync
partprobe
sleep 1

mkfs.vfat "${DEV}1"
fatlabel "${DEV}" "RASPBERRYPI"
fatlabel "${DEV}"

mkdir -p /tmp/raspberrypi-sdcard
umount /tmp/raspberrypi-sdcard
mount "${DEV}1" /tmp/raspberrypi-sdcard
pushd /tmp/raspberrypi-sdcard

if file "$PKG" | grep ' Zip archive data'; then
	unzip "$PKG"
fi

sync
sleep 1
umount /tmp/raspberrypi-sdcard












