#!/bin/sh
# https://github.com/hoaxdream
# Author: hoaxdream

# Change the value according to your hdd/sdd.
CORE_UUID=$(blkid -s UUID -o value /dev/nvme1n1p1)
DATA_UUID=$(blkid -s UUID -o value /dev/sda1)

makedir() {
    cd /media
    mkdir core data
}

getuuid() {
echo "# /dev/nvme1n1p1
UUID=$CORE_UUID /media/core ext4 rw,user,exec 0 0

# /dev/sda1
UUID=$DATA_UUID /media/data ext4 rw,user,exec 0 0" | tee -a /etc/fstab >/dev/null
}

efikernelhook() {
    cat > /etc/default/efibootmgr-kernel-hook << EOF
# Options for the kernel hook script installed by the efibootmgr package.
MODIFY_EFI_ENTRIES=1
OPTIONS="root=/dev/nvme0n1p2 rw quiet loglevel=0 console=tty2 nvidia-drm.modeset=1 nowatchdog ipv6.disable=1 udev.log_level=3"
DISK="/dev/nvme0n1"
PART=1
EOF
}

pamsession() {
    echo "-session optional pam_rundir.so" | tee -a /etc/pam.d/system-login > /dev/null
}

powersave() {
    cat > /etc/modprobe.d/audio_powersave.conf << EOF
# test /etc/modprobe.d/audio_powersave.conf
options snd_ac97_codec power_save=0
# For HD audio cards:
options snd_hda_intel power_save=0
EOF
}

setulimit() {
    ed -s /etc/security/limits.conf << EOF
    $ i
hoaxdream       soft    nofile          1048576
hoaxdream       hard    nofile          1048576
.
wq
EOF
}

service() {
    ln -sf /etc/sv/dbus /var/service
    ln -sf /etc/sv/seatd /var/service
    ln -sf /etc/sv/cronie /var/service
}

# Make directory for other hdd/sdd.
makedir

# Set UUID of other hdd/sdd in fstab.
getuuid

# Set efibootmgr kernel hook
efikernelhook

# Let pam create the directory for all users on login
pamsession

# Disable powersave
powersave

# Set ulimit for some lutris games to work.
setulimit

# Set dbus service
service

echo '\033[0;32mRun sudo ./post.sh and reboot.'
