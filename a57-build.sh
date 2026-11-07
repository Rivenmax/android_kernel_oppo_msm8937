#!/bin/bash
# Build KernelSU-Next A57 - FIX V4 - GCC Ubuntu + Image.gz-dtb
set -x
echo "=== Mulai Build A57 ==="

rm -rf KernelSU drivers/kernelsu

curl -LSs "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/next/kernel/setup.sh" | bash -s next

# Defconfig ASLI A57, udah ketemu dari log kamu
DEFCONFIG=msm8937-perf_defconfig
echo "DEFCONFIG: $DEFCONFIG"

# Hapus dulu config lama biar gak warning override
sed -i '/CONFIG_KPROBES/d' arch/arm64/configs/$DEFCONFIG
sed -i '/CONFIG_KALLSYMS/d' arch/arm64/configs/$DEFCONFIG
sed -i '/CONFIG_KSU/d' arch/arm64/configs/$DEFCONFIG
sed -i '/CONFIG_CC_STACKPROTECTOR_STRONG/d' arch/arm64/configs/$DEFCONFIG

echo "CONFIG_KPROBES=y" >> arch/arm64/configs/$DEFCONFIG
echo "CONFIG_KALLSYMS=y" >> arch/arm64/configs/$DEFCONFIG
echo "CONFIG_KALLSYMS_ALL=y" >> arch/arm64/configs/$DEFCONFIG
echo "CONFIG_KSU=y" >> arch/arm64/configs/$DEFCONFIG
echo "CONFIG_CC_STACKPROTECTOR_NONE=y" >> arch/arm64/configs/$DEFCONFIG

# Pake GCC bawaan Ubuntu yang kemarin udah jalan
export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-
make $DEFCONFIG
make -j4 Image.gz-dtb

# Cek hasil - di kernel 3.18 hasil nya Image.gz-dtb, bukan Image.gz doang
ls -lh arch/arm64/boot/
cp arch/arm64/boot/Image.gz-dtb ./Image.gz || cp arch/arm64/boot/Image.gz ./Image.gz || cp arch/arm64/boot/Image ./Image
cp arch/arm64/boot/Image ./Image || true

echo "=== Build selesai! ==="
ls -lh Image.gz Image
