#!/usr/bin/env python3
# SPDX-License-Identifier: MIT
"""Check the assembled HakiOS/Mu-Silicium/NEMO source contracts."""
from pathlib import Path
import re
import sys

if len(sys.argv) != 2:
    raise SystemExit("usage: verify-hakios-integration.py MU_WORKSPACE")
root = Path(sys.argv[1])

checks = {
    "BootShim XNUP copy hook": (
        root / "BootShim/BootShim.S",
        ("#ifdef PAYLOAD_BASE", "_PayloadLoop:", "ldr   w6, [x4, #4]"),
    ),
    "HakiOS BDS loader hook": (
        root / "Silicon/Silicium/SiliciumPkg/Library/BootManagerLib/BootManager.c",
        ('#include "XnuLoader.h"', "XnuLoaderMain ();"),
    ),
    "HakiOS loader source in library": (
        root / "Silicon/Silicium/SiliciumPkg/Library/BootManagerLib/BootManagerLib.inf",
        ("XnuLoader.c",),
    ),
}
for label, (path, needles) in checks.items():
    if not path.is_file():
        raise SystemExit(f"{label}: missing {path.relative_to(root)}")
    content = path.read_text(errors="replace")
    for needle in needles:
        if needle not in content:
            raise SystemExit(f"{label}: missing expected source marker {needle!r}")

memory_map = (root / "Platforms/Realme/NemoPkg/Library/MemoryMapLib/MemoryMapLib.c").read_text()
reserved = re.search(
    r'\{\s*"XNU Payload Reserved"\s*,\s*0xF0000000ULL\s*,\s*0x04000000ULL\s*,\s*AddMem\s*,\s*SYS_MEM\s*,\s*SYS_MEM_CAP\s*,\s*Reserv',
    memory_map,
)
if reserved is None:
    raise SystemExit("NEMO map does not reserve the HakiOS XNUP handoff window")

framebuffer = (root / "Silicon/Silicium/SiliciumPkg/Drivers/SimpleFbDxe/SimpleFb.c").read_text()
for marker in (
    "PcdFrameBufferPixelsPerScanLine",
    "mFrameBuffer.Mode->Info->PixelsPerScanLine    = PixelsPerScanLine;",
    "*FrameBufferSize = FrameBufferRegion.Length;",
    "mFrameBuffer.Mode->FrameBufferSize = FrameBufferSize;",
):
    if marker not in framebuffer:
        raise SystemExit(f"NEMO GOP stride/size support is missing: {marker}")

platform = (root / "Platforms/Realme/NemoPkg/NemoPkg.dsc").read_text()
if not re.search(r"(?m)^\s*gNemoPkgTokenSpaceGuid\.PcdFrameBufferPixelsPerScanLine\|1088\s*$", platform):
    raise SystemExit("NEMO GOP stride does not use the measured 1088-pixel virtual width")

config = (root / "Resources/Configs/Nemo.toml").read_text()
if not re.search(r"(?m)^base\s*=\s*0x40000000\s*$", config):
    raise SystemExit("NEMO FD base does not match the HakiOS BootShim configuration")
if not re.search(r"(?m)^size\s*=\s*0x400000\s*$", config):
    raise SystemExit("NEMO FD size does not match the HakiOS BootShim configuration")

print("HakiOS XNUP/BDS hooks and NEMO base, size, and reserved-memory contracts are present")
