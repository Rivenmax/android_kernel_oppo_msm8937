#!/bin/bash
# Build KernelSU-Next A57 - FIX V3 - GCC 4.9 buat kernel 3.18
set -x
echo "=== Mulai Build A57 ==="

rm -rf KernelSU drivers/kernelsu

# 1. Download toolchain jadul yang cocok sama kernel 3.18
# GCC 11 bikin vmlinux gagal link di 3.18
if [ ! -d "gcc-4.9" ]; then
  git clone --depth=1 https://github.[STRIPPED 77 bytes].9 gcc-4.9
fi

curl -LSs "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/next/kernel/setup.sh" | bash -s next

DEFCONFIG=$(ls arch/arm64/configs/*a57*defconfig arch/arm64/configs/*msm8937*defconfig 2>/dev/null | head -n 1 | xargs -n1 basename)
echo "DEFCONFIG: $DEFCONFIG"

echo "CONFIG_KPROBES=y" >> arch/arm64/configs/$DEFCONFIG
echo "CONFIG_KALLSYMS=y" >> arch/arm64/configs/$DEFCONFIG
echo "CONFIG_KALLSYMS_ALL=y" >> arch/arm64/configs/$DEFCONFIG
echo "CONFIG_KSU=y" >> arch/arm64/configs/$DEFCONFIG

# 2. Build pake GCC 4.9, target Image aja (bukan Image.gz)
export ARCH=arm64
export CROSS_COMPILE=$(pwd)/gcc-4.9/bin/aarch64-linux-android-
export PATH=$(pwd)/gcc-4.9/bin:$PATH
make $DEFCONFIG
make -j$(nproc) Image

# 3. Bikin Image.gz manual, biar gak gagal di target Image.gz
gzip -c arch/arm64/boot/Image > arch/arm64/boot/Image.gz
cp arch/arm64/boot/Image.gz ./Image.gz
cp arch/arm64/boot/Image ./Image

echo "=== Build selesai! ==="
ls -lh Image.gz Image
