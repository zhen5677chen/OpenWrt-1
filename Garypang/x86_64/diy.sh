#!/bin/bash

SHELL_FOLDER=$(dirname $(readlink -f "$0"))
bash $SHELL_FOLDER/../common/kernel_5.15.sh

svn co https://github.com/coolsnowwolf/lede/trunk/target/linux/x86/patches-5.15 target/linux/x86/patches-5.15
rm -rf target/linux/x86/patches-5.15/.svn

curl -sfL https://raw.githubusercontent.com/coolsnowwolf/lede/master/package/kernel/linux/modules/video.mk -o package/kernel/linux/modules/video.mk

sed -i "s/ +PACKAGE_kmod-backlight:kmod-backlight//" package/kernel/linux/modules/video.mk

sed -i 's/DEFAULT_PACKAGES +=/DEFAULT_PACKAGES += autocore-x86 kmod-usb-hid kmod-mmc kmod-sdhci usbutils pciutils lm-sensors-detect kmod-alx kmod-vmxnet3 kmod-igbvf kmod-iavf kmod-bnx2x kmod-pcnet32 kmod-tulip kmod-r8125 kmod-8139cp kmod-8139too kmod-i40e kmod-drm-i915 kmod-i915-gvt kmod-mlx4-core kmod-mlx5-core fdisk lsblk/' target/linux/x86/Makefile

mv -f tmp/r81* feeds/kiddin9/
sed -i 's,kmod-r8169,kmod-r8168,g' target/linux/x86/image/64.mk
sed -i 's/256/1024/g' target/linux/x86/image/Makefile

echo '
CONFIG_ACPI=y
CONFIG_X86_ACPI_CPUFREQ=y
CONFIG_NR_CPUS=512
' >> ./target/linux/x86/config-5.15

sed -i "s/enabled '0'/enabled '1'/g" feeds/packages/utils/irqbalance/files/irqbalance.config

