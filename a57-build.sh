#!/bin/bash
# Build KernelSU-Next for Oppo A57 - LOS 22.1 - By WAHYU

set -e
echo "=== Mulai Build KernelSU-Next A57 ===" | tee build.log

# 1. Bersihin patch lama SukiSU 324 yang gagal
rm -rf KernelSU drivers/kernelsu >> build.log 2>&1 || true

# 2. Tanam KernelSU-Next (yang work di kernel 3.18 A57)
curl -LSs "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/next/kernel/setup.sh" | bash -s next >> build.log 2>&1

# 3. Aktifin config
echo "CONFIG_KPROBES=y" >> arch/arm64/configs/a57_defconfig
echo "CONFIG_KALLSYMS=y" >> arch/arm64/configs/a57_defconfig
echo "CONFIG_KALLSYMS_ALL=y" >> arch/arm64/configs/a57_defconfig
echo "CONFIG_KSU=y" >> arch/arm64/configs/a57_defconfig

# 4. Build kernel
export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-
make a57_defconfig >> build.log 2>&1
make -j$(nproc) Image.gz dtbs >> build.log 2>&1

# 5. Copy hasil biar gampang di-download
cp arch/arm64/boot/Image.gz ./Image.gz || true
cp arch/arm64/boot/Image ./Image || true

echo "=== Build selesai! boot.img siap ===" | tee -a build.log
ls -lh Image.gz Image || true
