/**
  NEMO RMX2001 static memory map derived directly from decrypted C.18 OFP
  firmware and live DTB evidence. System RAM holes are left unmapped to protect
  modem, TEE, ADSP, SPM, and vendor carveouts.

  SPDX-License-Identifier: BSD-2-Clause-Patent
**/
#include <Library/MemoryMapLib.h>

#define SYSTEM_RAM(Name, Start, EndInclusive) \
  { Name, Start, (EndInclusive) - (Start) + 1, AddMem, SYS_MEM, SYS_MEM_CAP, Conv, WRITE_BACK_XN }

#define MMIO_REGION(Name, Start, Size) \
  { Name, Start, Size, AddDev, MMAP_IO, UNCACHEABLE, MmIO, NS_DEVICE }

STATIC EFI_MEMORY_REGION_DESCRIPTOR mMemoryMap[] = {
  // 4 MiB FD and 256 KiB primary stack windows
  { "UEFI FD",              0x40000000ULL, 0x00400000ULL, AddMem, SYS_MEM, SYS_MEM_CAP, BsCode, WRITE_BACK },
  { "UEFI Stack",           0x40400000ULL, 0x00040000ULL, AddMem, SYS_MEM, SYS_MEM_CAP, BsData, WRITE_BACK_XN },
  // First live System RAM bank ends at 0x4CDFFFFF; contiguous DXE heap.
  { "DXE Heap",             0x40440000ULL, 0x0C9C0000ULL, AddMem, SYS_MEM, SYS_MEM_CAP, Conv, WRITE_BACK_XN },

  // Non-overlapping System RAM extents from RMX2001 live DTB (C.18 global decrypted OFP).
  SYSTEM_RAM ("RAM 01", 0x4D100000ULL, 0x55FFFFFFULL),
  SYSTEM_RAM ("RAM 02", 0x56720000ULL, 0x77FEFFFFULL),
  SYSTEM_RAM ("RAM 03", 0x78000000ULL, 0x79D1FFFFULL),
  // Bootloader-owned display memory (Nemo physical base 0x79D20000, length 0x022E0000)
  { "Display Reserved",     0x79D20000ULL, 0x022E0000ULL, NoHob, MMAP_IO, INITIALIZED, Conv, NS_DEVICE },
  SYSTEM_RAM ("RAM 04", 0x7FE00000ULL, 0x7FEBFFFFULL),
  SYSTEM_RAM ("RAM 05", 0x80000000ULL, 0x8BFFFFFFULL),
  SYSTEM_RAM ("RAM 06", 0x8CD00000ULL, 0x8DFFFFFFULL),
  SYSTEM_RAM ("RAM 07", 0x8E170000ULL, 0x9FAFFFFFULL),
  SYSTEM_RAM ("RAM 08", 0x9FF00000ULL, 0xABFFFFFFULL),
  SYSTEM_RAM ("RAM 09", 0xBC000000ULL, 0xBD51FFFFULL),
  SYSTEM_RAM ("RAM 10", 0xC0000000ULL, 0xEFFFFFFFULL),
  // HakiOS BootShim XNUP handoff window: 64 MiB reserved RAM
  { "XNU Payload Reserved", 0xF0000000ULL, 0x04000000ULL, AddMem, SYS_MEM, SYS_MEM_CAP, Reserv, WRITE_BACK_XN },
  SYSTEM_RAM ("RAM 11", 0xF4000000ULL, 0xFFDFFFFFULL),
  SYSTEM_RAM ("RAM 12", 0xFFF00000ULL, 0x13FFFEFFFULL),
  SYSTEM_RAM ("RAM 13", 0x140000000ULL, 0x23FFFEFFFULL),

  // MMIO regions
  MMIO_REGION ("GIC Distributor",   0x0C000000ULL, 0x00040000ULL),
  MMIO_REGION ("GIC Redistributor", 0x0C040000ULL, 0x00200000ULL),
  MMIO_REGION ("GIC Config",        0x0C53A650ULL, 0x00000050ULL),
  MMIO_REGION ("UART",              0x11002000ULL, 0x00001000ULL),
  MMIO_REGION ("UFS HCI",           0x11270000ULL, 0x00002300ULL),
  MMIO_REGION ("UFS PHY",           0x11FA0000ULL, 0x0000C000ULL),
};

UINTN
EFIAPI
GetMemoryMap (
  OUT EFI_MEMORY_REGION_DESCRIPTOR **MemoryMap
  )
{
  *MemoryMap = mMemoryMap;
  return sizeof (mMemoryMap) / sizeof (mMemoryMap[0]);
}
