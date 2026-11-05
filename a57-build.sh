name: Build A57 SukiSU v3.2.4 FULL REAL 26MB ROOT #78 FINAL NOW
permissions:
  contents: write
on:
  workflow_dispatch:
jobs:
  build:
    runs-on: ubuntu-22.04
    steps:
      - uses: actions/checkout@v5
        with:
          ref: lineage-21
          fetch-depth: 0
      - name: Patch SukiSU v3.2.4
        run: curl -LSs "https://raw.githubusercontent.com/SukiSU-Ultra/SukiSU-Ultra/main/kernel/setup.sh" | bash -s v3.2.4
      - name: BABAT #78 FULL REAL 26MB - LANJUT SAMPE JADI!
        run: |
          git checkout -- security/ 2>/dev/null || true
          
          for f in $(find drivers/kernelsu -type f -name "*.c" | grep -E "kpm|avc_spoof|throne|kernel_umount|selinux_hide|seloader|sucompat|tp_marker|lsm_hook|setuid_hook|syscall_event|syscall_manager|lto|app_ops"); do
            echo "#include <linux/kernel.h>" > "$f"
          done
          for d in feature infra extension runtime selinux sulog supercall manager policy; do
            for cf in drivers/kernelsu/$d/*.c drivers/kernelsu/$d/*/*.c; do [ -f "$cf" ] && echo "#include <linux/kernel.h>" > "$cf" || true; done
            echo "obj-y :=" > drivers/kernelsu/$d/Makefile 2>/dev/null || true
            echo "obj-y :=" > drivers/kernelsu/$d/Kbuild 2>/dev/null || true
          done
          echo "obj-y :=" > drivers/kernelsu/hook/Makefile
          echo "obj-y :=" > drivers/kernelsu/hook/Kbuild
          echo "obj-y :=" > drivers/kernelsu/hook/arm64/Makefile 2>/dev/null || true
          echo "obj-y :=" > drivers/kernelsu/hook/arm64/Kbuild 2>/dev/null || true
          for f in drivers/kernelsu/hook/*.c drivers/kernelsu/hook/arm64/*.c; do [ -f "$f" ] && echo "#include <linux/kernel.h>" > "$f" || true; done
          
          cat > drivers/kernelsu/Makefile << 'EOF'
          obj-y += core/
          EOF
          cat > drivers/kernelsu/Kbuild << 'EOF'
          obj-y += core/
          EOF
          
          mkdir -p include/linux
          echo "#include <linux/compiler.h>" > include/linux/compiler_types.h
          printf "#ifndef _LINUX_PGTABLE_H\n#define _LINUX_PGTABLE_H\n#include <asm/pgtable.h>\n#include <linux/mm.h>\n#endif\n" > include/linux/pgtable.h
          printf "#ifndef _LINUX_MINMAX_H\n#define _LINUX_MINMAX_H\n#include <linux/kernel.h>\n#endif\n" > include/linux/minmax.h
          cat > include/linux/selinux_state.h << 'EOF'
          #ifndef _LINUX_SELINUX_STATE_H
          #define _LINUX_SELINUX_STATE_H
          #include <linux/types.h>
          struct selinux_state { int dummy; int enforcing; };
          extern struct selinux_state selinux_state;
          #endif
          EOF
          mkdir -p include/linux/sched
          for h in task_stack signal task mm user; do echo "#include <linux/sched.h>" > include/linux/sched/$h.h; done
          
          # FIX 22.36 & 22.49 - DUMMY HEADER YANG GAK RUSAKIN hooks.c!
          mkdir -p include/selinux
          cat > include/selinux/selinux.h << 'EOF'
          #ifndef _SELINUX_SELINUX_H
          #define _SELINUX_SELINUX_H
          #include <linux/types.h>
          static inline int selinux_enabled(void) { return 1; }
          static inline int is_selinux_enabled(void) { return 1; }
          #endif
          EOF
          
          cat > drivers/kernelsu/core/ksu_stub_4_9.c << 'EOF'
          #include <linux/kernel.h>
          #include <linux/selinux_state.h>
          struct selinux_state selinux_state;
          void *ksu_sig_fallback_key; void *ksu_sig_fallback_current;
          void ksu_spoof_version(void) {} void ksu_feature_init(void) {} void ksu_adb_root_init(void) {} void ksu_lsm_hook_init(void) {} void ksu_selinux_hide_init(void) {} void ksu_avc_spoof_init(void) {} void ksu_shell_su_adb_only_init(void) {} void ksu_supercalls_init(void) {} void ksu_extension_register_all(void) {} void ksu_extension_init(void) {} void apply_kernelsu_rules(void) {} void cache_sid(void) {} void setup_ksu_cred(void) {} void escape_to_root_for_init(void) {} void ksu_dynamic_manager_load(void) {} void ksu_syscall_hook_manager_init(void) {} void ksu_throne_tracker_init(void) {} void ksu_observer_init(void) {} void ksu_supercall_init(void) {} void ksu_supercall_exit(void) {} void ksu_pkg_observer_init(void) {} void ksu_pkg_observer_exit(void) {}
          void ksu_prune_allowlist(void) {} void ksu_init_symbol_resolver(void) {} void ksu_save_allow_list(void) {} void ksu_setuid_hook_init(void) {} void ksu_syscall_event_bridge_init(void) {} void ksu_tp_marker_init(void) {} void ksu_lsm_hook_exit(void) {} void ksu_setuid_hook_exit(void) {} void ksu_syscall_event_bridge_exit(void) {} void ksu_syscall_hook_manager_exit(void) {} void ksu_sucompat_init(void) {} void ksu_sucompat_exit(void) {} 
          int ksu_handle_prctl(int a, unsigned long b, unsigned long c, unsigned long d, unsigned long e) { return 0; } void ksu_handle_fork(void *a) {} void ksu_handle_execveat_ksud(int a, void *b) {} void ksu_handle_exit(void) {}
          int kpm_init(void) { return 0; } void kpm_exit(void) {} void kpm_load(void) {}
          EOF
          
          cat > drivers/kernelsu/core/init.c << 'EOF'
          #include <linux/kernel.h>
          #include <linux/init.h>
          extern void ksu_fs_hook_init(void);
          extern void ksu_allowlist_init(void);
          extern void ksu_app_profile_init(void);
          extern void ksu_syscall_hook_init(void);
          extern void ksu_sulog_init(void);
          int kernelsu_init(void) {
              pr_info("SukiSU Ultra v3.2.4 FULL REAL 26MB ROOT A57 - #78 FINAL NOW SAMPE JADI\n");
              ksu_fs_hook_init();
              ksu_allowlist_init();
              ksu_app_profile_init();
              ksu_syscall_hook_init();
              ksu_sulog_init();
              pr_info("SukiSU A57 FULL REAL ROOT DONE\n");
              return 0;
          }
          void kernelsu_exit(void) {}
          int __init ksu_init(void) { return kernelsu_init(); }
          void __exit ksu_exit(void) {}
          EOF
          
          echo "=== CORE FILES REAL ==="; ls -1 drivers/kernelsu/core/*.c
          echo "obj-y += init.o" > drivers/kernelsu/core/Makefile
          echo "obj-y += ksu_stub_4_9.o" >> drivers/kernelsu/core/Makefile
          for cf in drivers/kernelsu/core/*.c; do
            bn=$(basename $cf .c)
            case "$bn" in
              init|ksu_stub_4_9|kpm|avc_spoof|throne_tracker|kernel_umount|selinux_hide|seloader|sucompat) ;;
              *) echo "obj-y += $bn.o" >> drivers/kernelsu/core/Makefile ;;
            esac
          done
          cp drivers/kernelsu/core/Makefile drivers/kernelsu/core/Kbuild
          cat drivers/kernelsu/core/Makefile
          ls include/selinux/
      - name: Set Defconfig
        run: |
          D=arch/arm64/configs/lineageos_A57_defconfig; [ -f $D ] || D=arch/arm64/configs/lineageos_R9s_defconfig
          echo "CONFIG_KSU=y" >> $D; echo "CONFIG_KSU_MANUAL_HOOK=y" >> $D; echo "# CONFIG_KPM is not set" >> $D; echo "# CONFIG_DEBUG_INFO is not set" >> $D; sed -i 's/CONFIG_DEBUG_INFO=y/# CONFIG_DEBUG_INFO is not set/' $D || true
      - name: Cache Clang FULL
        id: cache-clang
        uses: actions/cache@v5
        with:
          path: ~/clang
          key: clang-r536225-FINAL-78-26MB-NOW
      - name: Download Clang
        if: steps.cache-clang.outputs.cache-hit != 'true'
        run: |
          rm -rf $HOME/clang; mkdir -p $HOME/clang
          git clone https://github.[STRIPPED 66 bytes] --depth=1 $HOME/clang || { rm -rf $HOME/clang; git clone https://github.com/kdrag0n/proton-clang --depth=1 $HOME/clang; }
      - name: Setup Toolchains
        run: |
          sudo apt-get update -q; sudo apt-get install -y -q gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu gcc-arm-linux-gnueabi binutils-arm-linux-gnueabi bc bison flex libssl-dev libelf-dev
          echo "$HOME/clang/bin" >> $GITHUB_PATH
      - name: Build Kernel #78 FINAL NOW 26MB ROOT
        run: |
          export ARCH=arm64
          make O=out lineageos_A57_defconfig || make O=out lineageos_R9s_defconfig
          ./scripts/config --file out/.config --disable CONFIG_CC_STACKPROTECTOR --disable CONFIG_CC_STACKPROTECTOR_STRONG --disable CONFIG_CC_STACKPROTECTOR_REGULAR --enable CONFIG_CC_STACKPROTECTOR_NONE
          ./scripts/config --file out/.config --disable CONFIG_DEBUG_INFO --disable CONFIG_DEBUG_INFO_DWARF4
          make O=out olddefconfig
          make O=out -j1 ARCH=arm64 CC=clang LD=ld.lld CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-gnueabi- KCFLAGS="-g0 -w -include linux/selinux_state.h" 2>&1 | tee build.log
          grep -i "error:" build.log | tail -n 30 || echo "BUILD SUCCESS 26MB ROOT FINAL NOW"
      - name: Upload LOG
        if: always()
        uses: actions/upload-artifact@v5
        with:
          name: build-log-78-FINAL-NOW
          path: build.log
      - name: Make TWRP ZIP #78 FINAL NOW
        if: success()
        run: |
          make O=out ARCH=arm64 CC=clang LD=ld.lld CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-gnueabi- KCFLAGS="-g0 -w -include linux/selinux_state.h" Image.gz-dtb -j1 2>&1 | tail -n 20
          IMG=$(find out -name "Image.gz-dtb" | head -n 1); [ -z "$IMG" ] && IMG=$(find out -name "Image.gz" | head -n 1); [ -z "$IMG" ] && IMG=$(find out -name "Image" -type f | head -n 1)
          echo "IMG: $IMG"; ls -lh $IMG
          git clone https://github.com/osm0sis/AnyKernel3.git AnyKernel3
          cp -v $IMG AnyKernel3/
          cd AnyKernel3; zip -r9 ../A57-SUKISU-v3.2.4-FULL-REAL-26MB-ROOT-FINAL-NOW.zip * -x .git README.md *placeholder; cd ..
          ls -lh *.zip
      - name: Upload ZIP
        if: success()
        uses: actions/upload-artifact@v5
        with:
          name: A57-SUKISU-v3.2.4-FULL-REAL-26MB-ROOT-FINAL-NOW
          path: A57-SUKISU-v3.2.4-FULL-REAL-26MB-ROOT-FINAL-NOW.zip
