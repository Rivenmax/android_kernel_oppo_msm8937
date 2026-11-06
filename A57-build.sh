#!/bin/bash
# Build KernelSU-Next for Oppo A57 - LOS 22.1

# Bersihin patch lama
rm -rf KernelSU drivers/kernelsu

# Tanam KernelSU-Next (yang work di kernel 3.18 A57)
curl -LSs "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/next/kernel/setup.sh" | bash -s next

# Aktifin config KSU
echo "CONFIG_KPROBES=y" >> arch/arm64/configs/a57_defconfig
echo "CONFIG_KALLSYMS=y" >> arch/arm64/configs/a57_defconfig
echo "CONFIG_KSU=y" >> arch/arm64/configs/a57_defconfig

# Build kernel
make a57_defconfig
make -j$(nproc) Image.gz dtbs

echo "Build selesai! boot.img siap"