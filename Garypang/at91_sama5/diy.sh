#!/bin/bash

shopt -s extglob

SHELL_FOLDER=$(dirname $(readlink -f "$0"))

sed -i 's/DEFAULT_PACKAGES +=/DEFAULT_PACKAGES += -luci-app-gpsysupgrade autocore-arm luci-app-cpufreq fdisk lsblk btrfs-progs block-mount blkid parted dosfstools e2fsprogs pv losetup uuidgen automount tune2fs resize2fs/' target/linux/at91/Makefile

rm -rf target/linux/at91/base-files/etc/config

echo '
CONFIG_CPU_FREQ_GOV_USERSPACE=y
CONFIG_CPU_FREQ_GOV_ONDEMAND=y
CONFIG_CPU_FREQ_GOV_CONSERVATIVE=y
' >> target/linux/at91/config-5.10

