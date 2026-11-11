# HakiOS MT6785 — NEMO and SALAA

> [!NOTE]
> **Inclusive Development Active**: This component is developed in lockstep with the NEMO UEFI firmware and BootShim in the unified inclusive repository: [**iSciFiLite/hakios-rm6785-nemo**](https://github.com/iSciFiLite/hakios-rm6785-nemo). All cross-layer enhancements, shared memory map definitions, and unified fastboot boot image packaging are authored atomically here. Standalone repositories are synchronized at release milestones via `tools/split-subtrees.sh`.

An experimental HakiOS port for the Realme 6 (RMX2001, NEMO; Helio G90T) and Realme 7 (RMX2151, SALAA; Helio G95). It reuses HakiOS's MediaTek/XNU integration while maintaining separate board profiles.

## Status & Driver Coverage

Hosted dual-compilation and source integration for the MT6785 XNU Darwin kernel and the open userland payload are **100% complete**. All 7 dedicated MT6785 hardware drivers are compiled into `hakios-kernel` and packaged into `NEMO_HAKIOS_XNU_BOOT.img`.

| Area | Implementation in HakiOS MT6785 | Driver & Architecture |
|---|---|---|
| **SoC** | MediaTek MT6785 (Helio G90T / G95) | Dedicated SoC ID (`0x0785`/`0x2240`) and AUXADC/LVTS thermal driver (`hakios.mtk6785_socinfo.c`). |
| **CPU** | 8 cores: 6× Cortex-A55 @ 2.0 GHz + 2× Cortex-A76 @ 2.05 GHz | Full 8-core affinity map; boot CPU 7 (`cpus=8 bootcpu=7`); PSCI SMC conduit declared in `xnuloader`. |
| **Display** | 1080×2400, 32 bpp, **1088 stride** | LK SimpleFb GOP framebuffer at `0x79D20000`, length `0x022E0000`, rowBytes 4352 (`Boot_Video`). |
| **Touch** | Tianma / Novatek NT36672C Multi-Touch | Dedicated driver (`hakios.nt36672c.c`) normalizing coordinates to 65535 and exposing `/dev/hakios-touch`. |
| **Keys & Clocks** | Hardware buttons & APMIXEDSYS DVFS | Dedicated driver (`hakios.mtk6785_keys.c`) polling GPIO 59 (Vol Up), GPIO 60 (Vol Down), MT6359 PWRAP (Power Key), and APMIXEDSYS PLL registers. |
| **Battery & PMIC** | MT6359 PMIC battery fuel gauge | Dedicated driver (`hakios.mtk6785_pmic.c`) interfacing via PWRAP (`0x1000D000`) for `HakiosBattery` `IOPMPowerSource`. |
| **Storage** | Samsung UFS 2.1 (KM8V8001JM-B813) | UFSHCI driver (`hakios.ufs.c`, `hakios.ufshc.c`) at `0x11270000` exposing `/dev/ufs_xnusys` block device. |
| **GPU** | ARM Mali-G76 MC4 Bifrost v7 | Dedicated GPU driver (`hakios.mtk6785_mali.c`, `hakios.mtk6785_mali.cpp`), controlling SPM power domains (`MFG_ASYNC`, `MFG`, `MFG_CORE0..3`), TOPCKGEN 900 MHz clock mux, and Panfrost DRM service. |
| **Wireless** | MT6785 CONNSYS Subsystem | Dedicated driver (`hakios.mtk6785_connsys.c`) managing CONNSYS bus, firmware handoff, and network interfaces. |
| **Boot Image** | Fastboot RAM Boot Image | `NEMO_HAKIOS_XNU_BOOT.img` (Android v2 header, BootShim, NEMO UEFI FD, XNUP payload, C.18 ramdisk & DTB). |
| **Hardware Boot Test** | Gating next step | Requires physical test on handset via `fastboot boot NEMO_HAKIOS_XNU_BOOT.img`. |

Detailed device notes are in [`devices/nemo`](devices/nemo) and [`devices/salaa`](devices/salaa).
Shared SoC facts and the compatibility breakdown are in [`mtk/mt6785/README.md`](mtk/mt6785/README.md).

## What this tree configures

- `xnuloader` has a compile-time MT6785 platform description: GICv3 address range, 6+2 CPU map,
  UFSHCI base `0x11270000`, and direct use of a firmware GOP framebuffer. It uses PSCI to start
  additional cores.
- `mtk/mt6785/configs/mt6785.config` requests eight XNU CPUs (`bootcpu=7`), the UEFI UFS block
  service (`ufs=2`), and read-only `xnusys` root selection (`ufs_root=1`).
- `make loader DEVICE=nemo` selects the MT6785 EFI platform.
