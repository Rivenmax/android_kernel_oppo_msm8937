#!/bin/bash
# Build KernelSU-Next for Oppo A57 - LOS 22.1 - By WAHYU - FIX V2
set -x

echo "=== Mulai Build KernelSU-Next A57 ==="

# 1. Bersihin patch lama
rm -rf KernelSU drivers/kernelsu

# 2. Cek defconfig yang bener ada apa aja
echo "=== LIST DEFCONFIG ==="
ls arch/arm64/configs/ | grep -i -E "a57|msm8937|oppo"

# 3. Tanam KernelSU-Next
curl -LSs "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/next/kernel/setup.sh" | bash -s next

# 4. Cari defconfig otomatis
DEFCONFIG=$(ls arch/arm64/configs/*a57*defconfig arch/arm64/configs/*msm8937*defconfig 2>/dev/null | head -n 1 | xargs -n1 basename)
echo "DEFCONFIG KETEMU: $DEFCONFIG"

# 5. Aktifin config KSU di defconfig yang ketemu
echo "CONFIG_KPROBES=y" >> arch/arm64/configs/$DEFCONFIG
echo "CONFIG_KALLSYMS=y" >> arch/arm64/configs/$DEFCONFIG
echo "CONFIG_KALLSYMS_ALL=y" >> arch/arm64/configs/$DEFCONFIG
echo "CONFIG_KSU=y" >> arch/arm64/configs/$DEFCONFIG

# 6. Build kernel - JANGAN disembunyiin ke build.log lagi
export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-
make $DEFCONFIG
make -j$(nproc) Image.gz dtbs

# 7. Copy hasil
cp arch/arm64/boot/Image.gz ./Image.gz || true
cp arch/arm64/boot/Image ./Image || true

echo "=== Build selesai! ==="
ls -lh Image.gz Image
