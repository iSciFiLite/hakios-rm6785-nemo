# NEMO UEFI — Realme 6 / RMX2001 / MT6785

> [!NOTE]
> **Inclusive Development Active**: This component is developed in lockstep with the HakiOS kernel and XnuLoader in the unified inclusive repository: [**iSciFiLite/hakios-rm6785-nemo**](https://github.com/iSciFiLite/hakios-rm6785-nemo). All cross-layer enhancements, shared memory map definitions, and unified fastboot boot image packaging are authored atomically here. Standalone repositories are synchronized at release milestones via `tools/split-subtrees.sh`.

**Status updated 2026-11-11.** This repository contains a NEMO EDK II platform overlay for [Mu-Silicium](https://github.com/Project-Silicium/Mu-Silicium), plus a pinned [HakiOS UEFI](https://github.com/oosexgang/hakios-uefi) integration and a hosted combined HakiOS/XNU Android-v2 boot image. CI can verify the build and container; only a phone test can verify LK acceptance, UEFI entry, the XNU handoff, or peripherals.

> **Do not flash these images.** The combined image is intended only for a temporary `fastboot boot` RAM test from an external USB host, after the owner has a known recovery route and an unlocked bootloader. It does not write the boot or LK partitions. Its LK acceptance and hardware behavior are unverified and not hardware-tested on phone. The FD base overlaps Android's normal kernel load area, so it must replace the stock kernel payload exactly as packaged.

## Support and verification status

| Area | Implemented now | Evidence and remaining limit |
|---|---|---|
| **NEMO platform** | AArch64 SEC/DXE, board package `NemoPkg`, memory descriptors, SimpleFb GOP, standard EDK II BDS/Shell | Mu-Silicium platform overlay based on decrypted C.18 OFP and live DTB; not hardware-tested on phone. |
| **Mu-Silicium** | Pinned workspace overlays and reproducible package configuration | Generic Mu-Silicium overlay adapted to MT6785 Helio G90T. |
| **HakiOS UEFI** | Upstream BootShim/XNUP and BootManager/XnuLoader patch stack; NEMO overlay; separate hosted build and BootShim job | Build result is recorded in the GitHub Actions workflow. A successful compile is source integration only. |
| **HakiOS/XNU fastboot handoff** | NEMO MT6785 kernel config and UEFI profile; hosted XNU build and XNUP packaging | The combined image uses the matching HakiOS FD and BootShim plus the pinned MT6785 kernel in HakiOS's XNUP format. Hosted builds do not establish phone compatibility. |
| **NEMO HakiOS/XNU boot image** | **Combined image packaging pipeline ready** | Android v2 boot image (`NEMO_HAKIOS_XNU_BOOT.img`). Combines gzip(BootShim + NEMO FD + XNUP payload with 7 native MT6785 drivers + open hello ramdisk) with verified stock C.18 ramdisk and DTB. `fastboot boot` only; no phone test yet. |
| **GOP / Framebuffer** | Uses live-DT display reservation and reports 1080×2400, 32 bpp, **1088 pixels per scan line** | Physical base at **`0x79D20000`**, length **`0x022E0000`** (36,569,088 bytes = 34.88 MiB), matching `mblock-14-framebuffer` and `atag,videolfb`. Stride 1088 pixels per scanline (4352 bytes/row). |
| **Internal UFS** | Read-only UFSHCI register probe at `0x11270000`; optional eight Block I/O placeholders report no media | Stock C.18 and live DT confirm MediaTek UFSHCI at `0x11270000` and MPHY at `0x11FA0000`. UFS Block I/O stub publishes protocol; `ReadBlocks` returns `EFI_NO_MEDIA` until native link negotiation is added. |
| **UART / Serial** | MT6785 SerialPortLib configures `0x11002000`, MTK mode 3, 115200-8N1 from 26 MHz clock | Pinmux: GPIO53 (RX), GPIO54 (TX) at 1.8V TTL. Hosted compilation only. |
| **USB** | Generic USB bus, keyboard, and mass-storage class modules are included | MT6785 SSUSB host driver not present; not a blocker for RAM boot. |
| **CPU, GIC, timer, reset** | Generic Arm/GIC code and MT6785 core/PSCI declarations are included | PSCI SMC conduit declared; 8 cores (6× A55 + 2× A76). Boot core 7. |
| **Touchscreen** | Novatek NF NT36672C over SPI3 (`0x11013000`) | Live DT confirms Tianma/Novatek NT36672C, reset GPIO2, IRQ GPIO1, 15 MHz SPI. Dedicated `hakios.nt36672c.c` driver streams coordinates. |
| **Physical Keys** | GPIO 59 (Vol Up), GPIO 60 (Vol Down), MT6359 PWRAP (Power Key) | Dedicated buttons driver in OS layer; LK powers key defaults. |

## Device identity and evidence

The profile is based on the actual decrypted C.18 OFP firmware and live device tree evidence supplied for RMX2001. The full sanitized inventory is in [`docs/nemo-device-evidence.md`](docs/nemo-device-evidence.md).

| Observation | Value |
|---|---|
| `ro.product.model` | `RMX2001` (Realme 6) |
| Project Code | `19661` (`oppo6785`) |
| Stock Firmware | `RMX2001_11_C.18` |
| Stock Boot SHA-256 | `a0c8df1041b8c652ebfae1f760ec0b0e649e94746c7b7697743919c6cebf1469` |
| Live DT memory | Base `0x40000000`, size `0x200000000` (8 GiB physical span) |
| Live DT UFS declarations | HCI `0x11270000`, PHY `0x11fa0000` |
| Live DT display reservation | `0x79d20000`, length `0x022e0000` (36,569,088 bytes) |
| Panel & Stride | Tianma NT36672C, 1080×2400, stride `1088` pixels |
| Historical FD layout | Base `0x40000000`, size 4 MiB; stack begins at `0x40400000` |

## Design choices

- Use the **MT6785/RMX2001 device evidence** for address maps and target setup.
- Keep generic UEFI services and standard class drivers in the image by default.
- Keep the bootloader's existing framebuffer (`0x79D20000`) and publish its observed stride (1088 pixels).
- Reserve `0xF0000000–0xF3FFFFFF` from UEFI allocations for HakiOS's 64 MiB XNUP handoff. The hosted audit checks this interval does not overlap NEMO RAM descriptors.
- Preserve upstream Mu-Silicium and HakiOS notices and pin their source commits. Do not commit proprietary phone firmware, extracted vendor DXE drivers, signing keys, or raw serial-bearing DTBs.

## Roadmap

1. **Device Facts**: Grounded in C.18 OFP and live DTB (Complete).
2. **NemoPkg Platform**: Full EDK II package with 24 non-overlapping descriptors (Complete).
3. **Hosted Build**: GitHub Actions pipeline for dual compilation and boot image assembly (Complete).
4. **Hardware Verification**: One-shot temporary RAM boot test on unlocked device (`fastboot boot NEMO_HAKIOS_XNU_BOOT.img`).
