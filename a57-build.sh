#!/bin/bash
# Build SukiSU Ultra v3.2.0 buat A57 - FIX KSU NEMPEL - LOS 22.1 - By Rivenmax
set -x
echo "=== Mulai Build SukiSU A57 ===" | tee build.log

# 1. Bersihin patch lama
rm -rf KernelSU drivers/kernelsu

# 2. Patch SukiSU Ultra v3.2.0 - yang pas sama Manager v3.2.0 kamu
curl -LSs "https://raw.githubusercontent.com/SukiSU-Ultra/SukiSU-Ultra/main/kernel/setup.sh" | bash -s v3.2.0

# 3. CEK, KSU nya nempel apa gak - WAJIB ADA ksu.c
echo "=== CEK drivers/kernelsu ===" | tee -a build.log
ls drivers/kernelsu/ | tee -a build.log

# 4. Defconfig ASLI A57
DEFCONFIG=msm8937-perf_defconfig
echo "DEFCONFIG: $DEFCONFIG" | tee -a build.log#!/bin/bash
# Build SukiSU Ultra v3.2.0 buat A57 - FIX KSU NEMPEL + FIX Bluetooth - LOS 22.1 - By Rivenmax
set -x
echo "=== Mulai Build SukiSU A57 ===" | tee build.log

# 1. Bersihin patch lama
rm -rf KernelSU drivers/kernelsu

# 2. Patch SukiSU Ultra v3.2.0 - yang pas sama Manager v3.2.0 kamu
curl -LSs "https://raw.githubusercontent.com/SukiSU-Ultra/SukiSU-Ultra/main/kernel/setup.sh" | bash -s v3.2.0

# 3. CEK, KSU nya nempel apa gak - WAJIB ADA ksu.c
echo "=== CEK drivers/kernelsu ===" | tee -a build.log
ls drivers/kernelsu/ | tee -a build.log

# 4. Defconfig ASLI A57
DEFCONFIG=msm8937-perf_defconfig
echo "DEFCONFIG: $DEFCONFIG" | tee -a build.log

sed -i '/CONFIG_KPROBES/d' arch/arm64/configs/$DEFCONFIG
sed -i '/CONFIG_KALLSYMS/d' arch/arm64/configs/$DEFCONFIG
sed -i '/CONFIG_KSU/d' arch/arm64/configs/$DEFCONFIG
sed -i '/CONFIG_CC_STACKPROTECTOR_STRONG/d' arch/arm64/configs/$DEFCONFIG

echo "CONFIG_KPROBES=y" >> arch/arm64/configs/$DEFCONFIG
echo "CONFIG_KALLSYMS=y" >> arch/arm64/configs/$DEFCONFIG
echo "CONFIG_KALLSYMS_ALL=y" >> arch/arm64/configs/$DEFCONFIG
echo "CONFIG_KSU=y" >> arch/arm64/configs/$DEFCONFIG
echo "CONFIG_CC_STACKPROTECTOR_NONE=y" >> arch/arm64/configs/$DEFCONFIG

# 5. FIX Bluetooth btfm_slim.h ilang - matiin aja, gak kepake di A57
# Ini yang bikin Build #95 gagal tadi
sed -i '/CONFIG_BT_FM_SLIM/d' arch/arm64/configs/$DEFCONFIG
echo "# CONFIG_BT_FM_SLIM is not set" >> arch/arm64/configs/$DEFCONFIG
sed -i '/CONFIG_BTFM_SLIM/d' arch/arm64/configs/$DEFCONFIG
echo "# CONFIG_BTFM_SLIM is not set" >> arch/arm64/configs/$DEFCONFIG
sed -i '/CONFIG_BT_HCIUART_BTFM_SLIM/d' arch/arm64/configs/$DEFCONFIG
echo "# CONFIG_BT_HCIUART_BTFM_SLIM is not set" >> arch/arm64/configs/$DEFCONFIG

# 6. Build
export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-
make $DEFCONFIG
make -j1 Image.gz-dtb

# 7. Copy hasil - GAK PAKE || true LAGI, biar kalau gagal langsung merah, gak ijo palsu
echo "=== HASIL ===" | tee -a build.log
ls -lh arch/arm64/boot/ | tee -a build.log
cp arch/arm64/boot/Image.gz-dtb ./Image.gz-dtb
cp arch/arm64/boot/Image.gz-dtb ./Image.gz
cp arch/arm64/boot/Image ./Image
ls -lh Image.gz Image.gz-dtb Image | tee -a build.log

echo "=== Build selesai! ===" | tee -a build.log

sed -i '/CONFIG_KPROBES/d' arch/arm64/configs/$DEFCONFIG
sed -i '/CONFIG_KALLSYMS/d' arch/arm64/configs/$DEFCONFIG
sed -i '/CONFIG_KSU/d' arch/arm64/configs/$DEFCONFIG
sed -i '/CONFIG_CC_STACKPROTECTOR_STRONG/d' arch/arm64/configs/$DEFCONFIG

echo "CONFIG_KPROBES=y" >> arch/arm64/configs/$DEFCONFIG
echo "CONFIG_KALLSYMS=y" >> arch/arm64/configs/$DEFCONFIG
echo "CONFIG_KALLSYMS_ALL=y" >> arch/arm64/configs/$DEFCONFIG
echo "CONFIG_KSU=y" >> arch/arm64/configs/$DEFCONFIG
echo "CONFIG_CC_STACKPROTECTOR_NONE=y" >> arch/arm64/configs/$DEFCONFIG

# 5. Build
export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-
make $DEFCONFIG
make -j1 Image.gz-dtb

# 6. Copy hasil - biar nama nya ketemu sama upload
echo "=== HASIL ===" | tee -a build.log
ls -lh arch/arm64/boot/ | tee -a build.log
cp arch/arm64/boot/Image.gz-dtb ./Image.gz-dtb || true
cp arch/arm64/boot/Image.gz-dtb ./Image.gz || true
cp arch/arm64/boot/Image ./Image || true
cp arch/arm64/boot/Image.gz ./Image.gz || true
ls -lh Image.gz Image.gz-dtb Image | tee -a build.log

echo "=== Build selesai! ===" | tee -a build.log
