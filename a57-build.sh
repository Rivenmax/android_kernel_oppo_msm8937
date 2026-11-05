#!/bin/bash
set -e
curl -LSs "https://raw.githubusercontent.com/SukiSU-Ultra/SukiSU-Ultra/main/kernel/setup.sh" | bash -s v3.2.4
git checkout -- security/ 2>/dev/null || true
rm -rf drivers/kernelsu/feature drivers/kernelsu/infra drivers/kernelsu/extension drivers/kernelsu/runtime drivers/kernelsu/selinux drivers/kernelsu/sulog drivers/kernelsu/supercall drivers/kernelsu/manager drivers/kernelsu/policy drivers/kernelsu/hook 2>/dev/null || true
find drivers/kernelsu -type f \( -name "*kpm*" -o -name "*avc_spoof*" -o -name "*throne*" -o -name "*kernel_umount*" \) -exec sh -c 'echo "#include <linux/kernel.h>" > "$1"' _ {} \; 2>/dev/null || true
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
# NO DUMMY KSU_STUB! BIAR SIZE GEDE!
rm -f drivers/kernelsu/core/ksu_stub_4_9.c drivers/kernelsu/core/kpm.c drivers/kernelsu/core/avc_spoof.c drivers/kernelsu/core/throne_tracker.c 2>/dev/null || true
cat > drivers/kernelsu/core/init.c << 'EOF'
#include <linux/kernel.h>
#include <linux/init.h>
extern void ksu_fs_hook_init(void);
extern void ksu_allowlist_init(void);
extern void ksu_app_profile_init(void);
extern void ksu_syscall_hook_init(void);
extern void ksu_sulog_init(void);
int kernelsu_init(void) {
    pr_info("SukiSU Ultra v3.2.4 FOR 4.9 ONLY FULL REAL NO DUMMY V7\n");
    ksu_fs_hook_init();
    ksu_allowlist_init();
    ksu_app_profile_init();
    ksu_syscall_hook_init();
    ksu_sulog_init();
    return 0;
}
void kernelsu_exit(void) {}
int __init ksu_init(void) { return kernelsu_init(); }
void __exit ksu_exit(void) {}
EOF
# AUTO CORE MAKEFILE FULL REAL SEMUA FILE!
echo "obj-y += init.o" > drivers/kernelsu/core/Makefile
for cf in drivers/kernelsu/core/*.c; do bn=$(basename $cf .c); [ "$bn" = "init" ] && continue; [ "$bn" = "kpm" ] && continue; [ "$bn" = "avc_spoof" ] && continue; [ "$bn" = "throne_tracker" ] && continue; echo "obj-y += $bn.o" >> drivers/kernelsu/core/Makefile; done
cp drivers/kernelsu/core/Makefile drivers/kernelsu/core/Kbuild
cat drivers/kernelsu/core/Makefile
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
git clone https://github.com/osm0sis/AnyKernel3.git AnyKernel3; cp -v $IMG AnyKernel3/; cd AnyKernel3; zip -r9 ../A57-SUKISU-v3.2.4-FOR-4.9-ONLY-FULL-26MB.zip * -x .git README.md *placeholder; cd ..; ls -lh *.zip
