#!/bin/bash
# Build SukiSU Ultra v3.2.0 buat A57 - FIX KSU NEMPEL
set -x

rm -rf KernelSU drivers/kernelsu

# 1. Patch SukiSU Ultra v3.2.0 (yang pas sama Manager v3.2.0 kamu)
curl -LSs "https://raw.githubusercontent.com/SukiSU-Ultra/SukiSU-Ultra/main/kernel/setup.sh" | bash -s v3.2.0

# 2. CEK, KSU nya nempel apa gak - kalau folder ini gak ada, STOP, jangan lanjut build
ls drivers/kernelsu/
echo "KALAU DI ATAS GAK ADA FILE ksu.c, BERARTI PATCH GAGAL, JANGAN LANJUT!"

DEFCONFIG=msm8937-perf_defconfig

sed -i '/CONFIG_KSU/d' arch/arm64/configs/$DEFCONFIG
sed -i '/CONFIG_KPROBES/d' arch/arm64/configs/$DEFCONFIG
echo "CONFIG_KPROBES=y" >> arch/arm64/configs/$DEFCONFIG
echo "CONFIG_KALLSYMS=y" >> arch/arm64/configs/$DEFCONFIG
echo "CONFIG_KALLSYMS_ALL=y" >> arch/arm64/configs/$DEFCONFIG
echo "CONFIG_KSU=y" >> arch/arm64/configs/$DEFCONFIG

export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-
make $DEFCONFIG
make -j1 Image.gz-dtb

echo "=== CEK HASIL ==="
ls -lh arch/arm64/boot/
cp arch/arm64/boot/Image.gz-dtb ./Image.gz || true
