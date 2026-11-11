# NEMO Device Evidence — Realme 6 / RMX2001 / MT6785

Sanitized device facts, physical memory reservations, and hardware register contracts derived directly from RMX2001 C.18 decrypted OFP firmware and live device tree evidence.

---

## 1. Device Identification & Platform Evidence

| Property | Value / Evidence | Provenance |
|---|---|---|
| **Model** | `RMX2001` (Realme 6) | C.18 OFP / Projectconfig `19661` |
| **Project Code** | `19661` / `oppo6785` | `Projectconfig.xml`, `bootargs: androidboot.prjname=19661` |
| **SoC** | MediaTek MT6785 (Helio G90T) | Live DT `model = "MT6785V/CC"` / `compatible = "mediatek,MT6785"` |
| **Chip ID** | `0x0785` (Hardware ID `0x2240`) | `chipid@08000000` / `atag,chipid` |
| **Stock Firmware** | `RMX2001_11_C.18` | Global decrypted OFP |
| **Stock Boot Image SHA-256** | `a0c8df1041b8c652ebfae1f760ec0b0e649e94746c7b7697743919c6cebf1469` | Exact 33,554,432-byte stock Android v2 image |
| **Boot Header** | Android Boot Image v2, 2048-byte pages | Page size 2048, header size 1660 |
| **Kernel Entry Address** | `0x40080000` | Stock header `kernel_addr = 0x40080000` |
| **Ramdisk Load Address** | `0x47C80000` | Stock header `ramdisk_addr = 0x47C80000` |
| **DTB Load Address** | `0x4BC80000` | Stock header `dtb_addr = 0x4BC80000` |

---

## 2. Physical Memory Map & Hardware Reservations

The live device tree confirms an 8 GiB physical DRAM span:
- Base: `0x40000000`
- Span: `0x200000000` (ends at `0x240000000`)
- Rank 0: `0x40000000 - 0x140000000` (4 GiB, `mblock-1-dramc-rk0` at `0x13ffff000`)
- Rank 1: `0x140000000 - 0x240000000` (4 GiB, `mblock-2-dramc-rk1` at `0x23ffff000`)

### Complete Live Reserved Memory Blocks (`mblock`)

| Block Name | Base Address | Size | End Address | Subsystem / Purpose |
|---|---|---|---|---|
| `mblock-4-atf-reserved` | `0x4CE00000` | `0x00200000` (2.0 MiB) | `0x4CFFFFFF` | ARM Trusted Firmware |
| `mblock-11-ram_console` | `0x4D000000` | `0x00010000` (64 KiB) | `0x4D00FFFF` | Early RAM Console |
| `mblock-12-pstore` | `0x4D010000` | `0x000E0000` (896 KiB) | `0x4D0EFFFF` | Kernel Ramoops / Pstore |
| `mblock-13-minirdump` | `0x4D0F0000` | `0x00010000` (64 KiB) | `0x4D0FFFFF` | Mini RAM dump |
| `mblock-22-reserve-memory-adsp` | `0x56000000` | `0x00720000` (7.12 MiB) | `0x5671FFFF` | Audio DSP Firmware & Buffer |
| `mblock-16-SPM-reserved` | `0x77FF0000` | `0x00010000` (64 KiB) | `0x77FFFFFF` | System Power Manager |
| `mblock-14-framebuffer` | `0x79D20000` | `0x022E0000` (34.88 MiB) | `0x7BFFFFFF` | **Display Framebuffer (Nemo)** |
| `mblock-9-tee-reserved` | `0x7C000000` | `0x03C00000` (60.0 MiB) | `0x7FBFFFFF` | TrustZone / TEE |
| `mblock-7-tee-secmem` | `0x7FC00000` | `0x00200000` (2.0 MiB) | `0x7FDFFFFF` | TEE Secure Memory |
| `mblock-8-SSPM-reserved` | `0x7FEC0000` | `0x00100000` (1.0 MiB) | `0x7FFBFFFF` | Secure SPM |
| `mblock-3-log_store` | `0x7FFC0000` | `0x00040000` (256 KiB) | `0x7FFFFFFF` | Bootloader Log Store |
| `mblock-21-ap_md_c_smem` | `0x8C000000` | `0x00D00000` (13.0 MiB) | `0x8CCFFFFF` | Modem Shared Memory (Cacheable) |
| `mblock-20-ap_md_nc_smem` | `0x8E000000` | `0x00170000` (1.44 MiB) | `0x8E16FFFF` | Modem Shared Memory (Non-cacheable) |
| `mblock-17-SCP-reserved` | `0x9FB00000` | `0x00400000` (4.0 MiB) | `0x9FEFFFFF` | System Companion Processor |
| `mblock-19-md_mem_usage` | `0xAC000000` | `0x10000000` (256.0 MiB) | `0xBBFFFFFF` | Modem Image & Dynamic Working RAM |
| `mblock-18-ccci_tag_mem` | `0xBD520000` | `0x00010000` (64 KiB) | `0xBD52FFFF` | CCCI Modem Tag |
| `mblock-15-vpu_binary` | `0xBD530000` | `0x02A10000` (42.06 MiB) | `0xBFF3FFFF` | Vision Processing Unit Firmware |
| `mblock-6-atf-log-reserved` | `0xBFF40000` | `0x00040000` (256 KiB) | `0xBFF7FFFF` | ATF Runtime Log Buffer |
| `mblock-5-atf-ramdump-reserved`| `0xBFF80000` | `0x00080000` (512 KiB) | `0xBFFFFFFF` | ATF Ramdump Buffer |
| `mblock-10-PICACHU` | `0xFFE00000` | `0x00100000` (1.0 MiB) | `0xFFEFFFFF` | Camera / ISP Algorithm Buffer |
| `mblock-1-dramc-rk0` | `0x13FFFF000` | `0x00001000` (4 KiB) | `0x13FFFFFFF` | DRAM Controller Rank 0 |
| `mblock-2-dramc-rk1` | `0x23FFFF000` | `0x00001000` (4 KiB) | `0x23FFFFFFF` | DRAM Controller Rank 1 |

---

## 3. Peripheral Register Contracts

- **UART0 Serial**: MMIO `0x11002000`, size `0x1000`. High-speed mode 3, 115200-8N1 from 26 MHz clock.
  * Pins: GPIO53 (RX), GPIO54 (TX) at 1.8V TTL.
- **UFS 2.1 Storage**: Controller HCI at `0x11270000`, size `0x2300`. MPHY at `0x11FA0000`, size `0xC000`.
- **GICv3 Interrupt Controller**:
  * Distributor: `0x0C000000`, length `0x40000`
  * Redistributor: `0x0C040000`, length `0x200000`
  * Config: `0x0C53A650`, length `0x50`
- **Display Framebuffer**: Base `0x79D20000`, length `0x022E0000` (36,569,088 bytes).
  * Resolution: 1080×2400 @ 60/90 Hz.
  * Scanline Stride: 1088 pixels (4352 bytes/row).
- **Touch Controller**: Tianma / Novatek NT36672C on SPI3 (`0x11013000`).
  * Reset GPIO: GPIO2 (`0x02`)
  * IRQ GPIO: GPIO1 (`0x01`)
  * Max SPI Clock: 15 MHz (`0xE4E1C0`)
- **Physical Buttons**:
  * Volume Up: GPIO 59 (`0x3B`)
  * Volume Down: GPIO 60 (`0x3C`)
  * Power Key: MT6359 PMIC via PWRAP (`0x1000D000`), keycode 116 (`0x74`)
- **CPU Topology**: 8 cores (6× Cortex-A55 @ 2.0 GHz + 2× Cortex-A76 @ 2.05 GHz).
  * MPIDR: `0x000`, `0x100`, `0x200`, `0x300`, `0x400`, `0x500`, `0x600`, `0x700`. Boot CPU: 7.
