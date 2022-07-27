#!/bin/bash

rm -rf target/linux package/kernel package/boot package/firmware/linux-firmware include/{kernel-*,netfilter.mk}
latest="$(curl -sfL https://github.com/openwrt/openwrt/commits/master/include | grep -o 'href=".*>kernel: bump 5.15' | head -1 | cut -d / -f 5 | cut -d '"' -f 1)"
mkdir new; cp -rf .git new/.git
cd new
[ "$latest" ] && git reset --hard $latest || git reset --hard origin/master
git checkout HEAD^
[ "$(echo $(git log -1 --pretty=short) | grep "kernel: bump 5.15")" ] && git checkout $latest
cp -rf --parents target/linux package/kernel package/boot package/firmware/linux-firmware include/{kernel-*,netfilter.mk} ../
cd -

kernel_v="$(cat include/kernel-5.15 | grep LINUX_KERNEL_HASH-* | cut -f 2 -d - | cut -f 1 -d ' ')"
echo "KERNEL=${kernel_v}" >> $GITHUB_ENV || true
sed -i "s?targets/%S/.*'?targets/%S/$kernel_v'?" include/feeds.mk

rm -rf target/linux/generic/pending-5.15/444-mtd-nand-rawnand-add-support-for-Toshiba-TC58NVG0S3H.patch

sh -c "curl -sfL https://github.com/coolsnowwolf/lede/commit/06fcdca1bb9c6de6ccd0450a042349892b372220.patch | patch -d './' -p1 --forward"
svn export --force https://github.com/openwrt/packages/trunk/kernel feeds/packages/kernel
svn export --force  https://github.com/openwrt/packages/trunk/net/xtables-addons feeds/packages/net/xtables-addons

svn co https://github.com/coolsnowwolf/lede/trunk/target/linux/generic/hack-5.15 target/linux/generic/hack-5.15
rm -rf target/linux/generic/hack-5.15/{220-gc_sections*,781-dsa-register*,780-drivers-net*}
curl -sfL https://raw.githubusercontent.com/openwrt/openwrt/openwrt-22.03/package/kernel/linux/modules/video.mk -o package/kernel/linux/modules/video.mk

sed -i "s/tty\(0\|1\)::askfirst/tty\1::respawn/g" target/linux/*/base-files/etc/inittab

echo "
CONFIG_TESTING_KERNEL=y
CONFIG_PACKAGE_kmod-ipt-coova=n
CONFIG_PACKAGE_kmod-usb-serial-xr_usb_serial_common=n
CONFIG_PACKAGE_kmod-pf-ring=n
" >> devices/common/.config
