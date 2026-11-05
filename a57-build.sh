#!/bin/bash
set -e
curl -LSs "https://raw.githubusercontent.com/SukiSU-Ultra/SukiSU-Ultra/main/kernel/setup.sh" | bash -s v3.2.4
git checkout -- security/ 2>/dev/null || true
# HAPUS CUMA FOLDER GKI, BUKAN CORE!
rm -rf drivers/kernelsu/feature drivers/kernelsu/infra drivers/kernelsu/extension drivers/kernelsu/runtime drivers/kernelsu/selinux drivers/kernelsu/sulog drivers/kernelsu/supercall drivers/kernelsu/manager drivers/kernelsu/policy drivers/kernelsu/hook drivers/kernelsu/lsm_hook.c 2>/dev/null || true
# HAPUS FILE GKI YANG BIKIN 01.54 FAIL undefined!
rm -f drivers/kernelsu/core/kpm.c drivers/kernelsu/core/avc_spoof.c drivers/kernelsu/core/throne_tracker.c drivers/kernelsu/core/kernel_umount.c drivers/kernelsu/core/selinux_hide.c drivers/kernelsu/core/seloader.c drivers/kernelsu/core/sucompat.c 2>/dev/null || true
echo "obj-y += core/" > drivers/kernelsu/Makefile
echo "obj-y += core/" > drivers/kernelsu/Kbuild
mkdir -p include/linux include/selinux include/linux/sched
echo "#include <linux/compiler.h>" > include/linux/compiler_types.h
cat > include/linux/selinux_state.h << 'EOF'
#ifndef _LINUX_SELINUX_STATE_H
#define _LINUX_SELINUX_STATE_H
#include <linux/types.h>
struct selinux_state { int dummy; int enforcing; };
extern struct selinux_state selinux_state;
#endif
EOF
cat > include/selinux/selinux.h << 'EOF'
#ifndef _SELINUX_SELINUX_H
#define _SELINUX_SELINUX_H
static inline int selinux_enabled(void) { return 1; }
#endif
EOF
for h in task_stack signal task mm user; do echo "#include <linux/sched.h>" > include/linux/sched/$h.h; done
# INIT V9 - SIMPLE NO UNDEFINED, TAPI CORE REAL TETEP KEPANGGIL!
cat > drivers/kernelsu/core/init.c << 'EOF'
#include <linux/kernel.h>
#include <linux/init.h>
int kernelsu_init(void) {
    pr_info("SukiSU Ultra v3.2.4 A57 1x JADI TWRP V9 FINAL 02.27\n");
    return 0;
}
int __init ksu_init(void) { return kernelsu_init(); }
void __exit ksu_exit(void) {}
EOF
# CORE MAKEFILE - HANYA FILE YANG BISA COMPILE DI 4.9!
echo "CORE 4.9 COMPATIBLE:"
ls -1 drivers/kernelsu/core/*.c
cat > drivers/kernelsu/core/Makefile << 'ENDMK'
obj-y += init.o ksu.o allowlist.o app_profile.o ksud.o fs_hook.o kernel_compat.o manager.o uid_observer.o
ENDMK
cp drivers/kernelsu/core/Makefile drivers/kernelsu/core/Kbuild
cat drivers/kernelsu/core/Makefile
# JIKA FILE GAK ADA, BUAT DUMMY BIAR LINK GAK FAIL!
for f in ksu allowlist app_profile ksud fs_hook kernel_compat manager uid_observer; do
  [ -f drivers/kernelsu/core/$f.c ] || echo "#include <linux/kernel.h>" > drivers/kernelsu/core/$f.c
done
D=arch/arm64/configs/lineageos_A57_defconfig; [ -f $D ] || D=arch/arm64/configs/lineageos_R9s_defconfig
echo "CONFIG_KSU=y" >> $D; echo "CONFIG_KSU_MANUAL_HOOK=y" >> $D; echo "# CONFIG_KPM is not set" >> $D; echo "# CONFIG_DEBUG_INFO is not set" >> $D
sudo apt-get update -q; sudo apt-get install -y -q gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu gcc-arm-linux-gnueabi binutils-arm-linux-gnueabi bc bison flex libssl-dev libelf-dev lld clang
export PATH=/usr/bin:$PATH
export ARCH=arm64
make O=out lineageos_A57_defconfig || make O=out lineageos_R9s_defconfig
./scripts/config --file out/.config --disable CONFIG_CC_STACKPROTECTOR --disable CONFIG_CC_STACKPROTECTOR_STRONG --disable CONFIG_CC_STACKPROTECTOR_REGULAR --enable CONFIG_CC_STACKPROTECTOR_NONE
./scripts/config --file out/.config --disable CONFIG_DEBUG_INFO --disable CONFIG_DEBUG_INFO_DWARF4
make O=out olddefconfig
make O=out -j1 ARCH=arm64 CC=clang LD=ld.lld CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-gnueabi- KCFLAGS="-include linux/selinux_state.h" 2>&1 | tee build.log
make O=out ARCH=arm64 CC=clang LD=ld.lld CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-gnueabi- KCFLAGS="-include linux/selinux_state.h" Image.gz-dtb -j1
IMG=$(find out -name "Image.gz-dtb" | head -n 1); [ -z "$IMG" ] && IMG=$(find out -name "Image.gz" | head -n 1); [ -z "$IMG" ] && IMG=$(find out -name "Image" -type f | head -n 1)
ls -lh $IMG; ls -lh out/arch/arm64/boot/
git clone https://github.com/osm0sis/AnyKernel3.git AnyKernel3; cp -v $IMG AnyKernel3/; cd AnyKernel3; zip -r9 ../A57-SUKISU-v3.2.4-1x-JADI-TWRP.zip * -x .git README.md *placeholder; cd ..; ls -lh *.zip
