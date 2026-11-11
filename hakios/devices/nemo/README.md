# Realme 6 Nemo (RMX2001)

Nemo uses MediaTek MT6785 / Helio G90T. This profile inherits the shared MT6785 configuration with full 8-core affinity, boot CPU 7, UFS 2.1 service, and native hardware drivers.

## Verified Hardware Profile & Evidence

- **FrameBuffer**: SimpleFb GOP at physical address `0x79D20000` (length `0x022E0000`, 36,569,088 bytes) with stride **1088 pixels per scan line** (4352 bytes/row), 1080×2400 @ 60/90 Hz.
- **Touch**: Tianma / Novatek NT36672C on SPI3 (`0x11013000`), reset GPIO2, IRQ GPIO1, 15 MHz SPI.
- **Physical Keys**: Volume Up GPIO 59, Volume Down GPIO 60, MT6359 PWRAP power key.
- **PMIC & Battery**: MT6359 PMIC fuel gauge communicating over PWRAP (`0x1000D000`).
- **GPU**: ARM Mali-G76 MC4 Bifrost v7 at `0x13040000` with Panfrost DRM service.
- **Storage**: Samsung UFS 2.1 at `0x11270000`.

The machine-readable feature status is in [`device.conf`](device.conf).
Do not flash device partitions. Use temporary fastboot RAM boot only: `fastboot boot NEMO_HAKIOS_XNU_BOOT.img`.
