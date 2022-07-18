#!/bin/bash
shopt -s extglob

svn export --force https://github.com/openwrt/openwrt/branches/openwrt-22.03/target/imagebuilder target/imagebuilder
svn export --force https://github.com/kiddin9/openwrt-packages/tree/master/base-files package/base-files

rm -rf devices/common/patches/{targets.patch,usb.patch}
echo "KERNEL=4.4.60" >> $GITHUB_ENV || true

rm -rf package/libs package/utils package/network package/system package/devel
svn co https://github.com/openwrt/openwrt/branches/openwrt-22.03/package/libs package/libs

./scripts/feeds update -a
./scripts/feeds install -a -p kiddin9 -f
./scripts/feeds install -a

sed -i 's/DEFAULT_PACKAGES +=/DEFAULT_PACKAGES += luci-app-cpufreq automount/' target/linux/ipq60xx/Makefile

echo '
CONFIG_ARM64_CRYPTO=y
CONFIG_CRYPTO_AES_ARM64=y
CONFIG_CRYPTO_AES_ARM64_BS=y
CONFIG_CRYPTO_AES_ARM64_CE=y
CONFIG_CRYPTO_AES_ARM64_CE_BLK=y
CONFIG_CRYPTO_AES_ARM64_CE_CCM=y
CONFIG_CRYPTO_CRCT10DIF_ARM64_CE=y
CONFIG_CRYPTO_AES_ARM64_NEON_BLK=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_GHASH_ARM64_CE=y
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA1_ARM64_CE=y
CONFIG_CRYPTO_SHA256_ARM64=y
CONFIG_CRYPTO_SHA2_ARM64_CE=y
CONFIG_CRYPTO_SHA512_ARM64=y
CONFIG_CRYPTO_SIMD=y
CONFIG_REALTEK_PHY=y
CONFIG_CPU_FREQ_GOV_USERSPACE=y
CONFIG_CPU_FREQ_GOV_ONDEMAND=y
CONFIG_CPU_FREQ_GOV_CONSERVATIVE=y
CONFIG_MOTORCOMM_PHY=y
CONFIG_SENSORS_PWM_FAN=y
CONFIG_ACPI=n
CONFIG_PNP_DEBUG_MESSAGES=y
CONFIG_PINCTRL_BAYTRAIL=n
CONFIG_PINCTRL_CHERRYVIEW=n
CONFIG_PINCTRL_BROXTON=n
CONFIG_PINCTRL_SUNRISEPOINT=n
CONFIG_PINCTRL_QDF2XXX=n
CONFIG_GPIO_AMDPT=n
CONFIG_PCC=n
CONFIG_PMIC_OPREGION=n
CCONFIG_RYPTO_CRC32_ARM64=n
' >> ./target/linux/ipq60xx/config-4.4
