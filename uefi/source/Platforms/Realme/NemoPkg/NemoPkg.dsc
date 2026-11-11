##
# Nemo / Realme 6 RMX2001 / MediaTek MT6785 (Helio G90T).
# SPDX-License-Identifier: BSD-2-Clause-Patent
##
[Defines]
  PLATFORM_NAME                  = NEMO
  PLATFORM_GUID                  = C9480112-E51B-4A73-A65B-9721DF762B54
  PLATFORM_VERSION               = 0.1
  DSC_SPECIFICATION              = 0x00010005
  OUTPUT_DIRECTORY               = Build/NEMO
  SUPPORTED_ARCHITECTURES        = AARCH64
  BUILD_TARGETS                  = RELEASE|DEBUG
  SKUID_IDENTIFIER               = DEFAULT
  FLASH_DEFINITION               = Platforms/Realme/NemoPkg/NemoPkg.fdf
  DEFINE ENABLE_SECUREBOOT       = 0
  USE_CUSTOM_DISPLAY_DRIVER      = 0

!include Silicon/MediaTek/MT6785Pkg/MT6785Pkg.dsc.inc

[PcdsFixedAtBuild]
  # Live RMX2001 evidence: /memory base 0x40000000, size 8 GiB span.
  gArmTokenSpaceGuid.PcdSystemMemoryBase|0x40000000
  gArmTokenSpaceGuid.PcdSystemMemorySize|0x200000000
  # 4 MiB FD layout placed at 0x40000000; stack begins at 0x40400000.
  gArmTokenSpaceGuid.PcdFdBaseAddress|0x40000000
  gArmTokenSpaceGuid.PcdFdSize|0x00400000
  gArmTokenSpaceGuid.PcdFvBaseAddress|0x40000000
  gArmTokenSpaceGuid.PcdFvSize|0x00400000
  gEfiMdeModulePkgTokenSpaceGuid.PcdFirmwareVendor|L"realme"
  gEfiMdeModulePkgTokenSpaceGuid.PcdFirmwareVersionString|L"RMX2001_11_C.18"
  gArmPlatformTokenSpaceGuid.PcdCPUCoresStackBase|0x40400000
  gArmPlatformTokenSpaceGuid.PcdCPUCorePrimaryStackSize|0x40000
  # SimpleFbDxe display description for Nemo's 1080x2400 panel
  gSiliciumPkgTokenSpaceGuid.PcdFrameBufferWidth|1080
  gSiliciumPkgTokenSpaceGuid.PcdFrameBufferHeight|2400
  gSiliciumPkgTokenSpaceGuid.PcdFrameBufferColorDepth|32
  # Stride: 1088 pixels per scan line
  gNemoPkgTokenSpaceGuid.PcdFrameBufferPixelsPerScanLine|1088
  # Live DT atag,videolfb: fb_base=0x79d20000, vramSize=0x022e0000
  gNemoPkgTokenSpaceGuid.PcdFrameBufferBase|0x79D20000
  gNemoPkgTokenSpaceGuid.PcdFrameBufferSize|0x022E0000
  # Serial SimpleTextInOut must connect without a user-created boot option.
  gEfiMdeModulePkgTokenSpaceGuid.PcdConInConnectOnDemand|FALSE
  gEfiMdePkgTokenSpaceGuid.PcdPlatformBootTimeOut|0

  gSiliciumPkgTokenSpaceGuid.PcdSmbiosSystemManufacturer|"realme"
  gSiliciumPkgTokenSpaceGuid.PcdSmbiosSystemModel|"Realme 6"
  gSiliciumPkgTokenSpaceGuid.PcdSmbiosSystemRetailModel|"RMX2001"
  gSiliciumPkgTokenSpaceGuid.PcdSmbiosSystemRetailSku|"RMX2001"
  gSiliciumPkgTokenSpaceGuid.PcdSmbiosSystemBoardModel|"NEMO"

[Components]
  Silicon/MediaTek/MT6785Pkg/Sec/PlatformSec.inf
  MdeModulePkg/Core/Dxe/DxeMain.inf
  MdeModulePkg/Universal/PCD/Dxe/Pcd.inf
  ArmPkg/Drivers/CpuDxe/CpuDxe.inf
  MdeModulePkg/Core/RuntimeDxe/RuntimeDxe.inf
  MdeModulePkg/Universal/SecurityStubDxe/SecurityStubDxe.inf
  MdeModulePkg/Universal/WatchdogTimerDxe/WatchdogTimer.inf
  MdeModulePkg/Universal/CapsuleRuntimeDxe/CapsuleRuntimeDxe.inf
  MdeModulePkg/Universal/ResetSystemRuntimeDxe/ResetSystemRuntimeDxe.inf
  MdeModulePkg/Universal/ReportStatusCodeRouter/RuntimeDxe/ReportStatusCodeRouterRuntimeDxe.inf
  MdeModulePkg/Universal/StatusCodeHandler/RuntimeDxe/StatusCodeHandlerRuntimeDxe.inf
  MdeModulePkg/Universal/Variable/RuntimeDxe/VariableRuntimeDxe.inf
  EmbeddedPkg/EmbeddedMonotonicCounter/EmbeddedMonotonicCounter.inf
  EmbeddedPkg/SimpleTextInOutSerial/SimpleTextInOutSerial.inf
  EmbeddedPkg/RealTimeClockRuntimeDxe/RealTimeClockRuntimeDxe.inf
  EmbeddedPkg/MetronomeDxe/MetronomeDxe.inf
  MdeModulePkg/Universal/PrintDxe/PrintDxe.inf
  MdeModulePkg/Universal/DevicePathDxe/DevicePathDxe.inf
  MdeModulePkg/Universal/Console/ConPlatformDxe/ConPlatformDxe.inf
  MdeModulePkg/Universal/Console/ConSplitterDxe/ConSplitterDxe.inf
  MdeModulePkg/Universal/Console/GraphicsConsoleDxe/GraphicsConsoleDxe.inf
  MdeModulePkg/Universal/HiiDatabaseDxe/HiiDatabaseDxe.inf
  MdeModulePkg/Universal/Disk/DiskIoDxe/DiskIoDxe.inf
  MdeModulePkg/Universal/Disk/PartitionDxe/PartitionDxe.inf
  MdeModulePkg/Universal/Disk/UnicodeCollation/EnglishDxe/EnglishDxe.inf
  FatPkg/EnhancedFatDxe/Fat.inf
  MdeModulePkg/Bus/Usb/UsbBusDxe/UsbBusDxe.inf
  MdeModulePkg/Bus/Usb/UsbKbDxe/UsbKbDxe.inf
  MdeModulePkg/Bus/Usb/UsbMassStorageDxe/UsbMassStorageDxe.inf
  SiliciumPkg/Drivers/SimpleFbDxe/SimpleFbDxe.inf
  ArmPkg/Drivers/ArmGicDxe/ArmGicDxe.inf
  ArmPkg/Drivers/TimerDxe/TimerDxe.inf
  # MT6785 UFS Block I/O stub: publishes EFI_BLOCK_IO_PROTOCOL for 8 LUNs
  # at UFS HCI 0x11270000 / M-PHY 0x11fa0000 (DT-confirmed).
  Silicon/MediaTek/MT6785Pkg/Drivers/UfsBlockIoDxe/UfsBlockIoDxe.inf
  MdeModulePkg/Universal/BdsDxe/BdsDxe.inf
  ShellPkg/Application/Shell/Shell.inf

[BuildOptions]
GCC:*_*_*_CC_FLAGS = -fno-stack-protector
