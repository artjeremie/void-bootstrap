#!/bin/sh
# https://github.com/hoaxdream
# author: hoaxdream
# change the value of User in int_transmission
CORE_UUID=$(blkid -s UUID -o value /dev/nvme1n1p1)
DATA_UUID=$(blkid -s UUID -o value /dev/sda1)

# make dir for games and data
int_chdir()
  {
    cd /media
    mkdir core data
  }
# dump UUID to fstab
int_uuid()
  {
echo "# /dev/nvme1n1p1
UUID=$CORE_UUID /media/core ext4 rw,user,exec 0 0

# /dev/sda1
UUID=$DATA_UUID /media/data ext4 rw,user,exec 0 0" | tee -a /etc/fstab >/dev/null
  }

echo 'directory created'
int_chdir
echo 'uuid'
int_uuid

echo 'Done!'
