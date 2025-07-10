#!/usr/bin/env bash
#

systemctl start docker.service
systemctl start containerd.service

storage_device=
device_crypt_name=
keyfile_name=
mount_location=

printf "%s\n" "Opening encrypted drive [$storage_device] as [$device_crypt_name]. Using keyfile [$keyfile_name]."
sudo cryptsetup open "$storage_device" "$device_crypt_name" --key-file /etc/cryptsetup-keys.d/"$keyfile_name" || exit

printf "%s\n" "Mounting encrypted partition at [$mount_location]"
sudo mount /dev/mapper/"$device_crypt_name" "$mount_location" || exit