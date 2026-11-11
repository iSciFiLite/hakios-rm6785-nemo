#!/usr/bin/env python3
# SPDX-License-Identifier: MIT
"""Audit NEMO UEFI repository claims and preserved historical artifacts."""
from pathlib import Path
import hashlib
import os
import re
import subprocess

ROOT = Path(__file__).resolve().parents[1]
readme = (ROOT / "README.md").read_text()
for phrase in (
    "Do not flash",
    "not hardware-tested",
    "UFS Block I/O",
    "Roadmap",
    "HakiOS",
    "reproducible",
):
    if phrase.lower() not in readme.lower():
        raise SystemExit(f"README is missing required status text: {phrase}")

evidence_path = ROOT / "docs/nemo-device-evidence.md"
if not evidence_path.is_file():
    raise SystemExit("The sanitized NEMO device-evidence report is missing")
evidence = evidence_path.read_text()
for phrase in (
    "a0c8df1041b8c652ebfae1f760ec0b0e649e94746c7b7697743919c6cebf1469",
    "0x200000000",
    "0x11270000",
    "0x11fa0000",
    "0x79d20000",
    "0x022e0000",
    "RMX2001",
):
    if phrase.lower() not in evidence.lower():
        raise SystemExit(f"NEMO evidence report is missing expected device fact: {phrase}")
if re.search(r"androidboot\.serialno=[^\s\"']+|serialno\s*=\s*\"[^\"]+\"", evidence, re.I):
    raise SystemExit("A device serial value must not be committed in the evidence report")

required_files = (
    "source/Platforms/Realme/NemoPkg/NemoPkg.dsc",
    "source/Platforms/Realme/NemoPkg/NemoPkg.dec",
    "source/Platforms/Realme/NemoPkg/NemoPkg.fdf",
    "source/Platforms/Realme/NemoPkg/DeviceBuild.py",
    "source/Platforms/Realme/NemoPkg/Include/DXE.inc",
    "source/Platforms/Realme/NemoPkg/Library/MemoryMapLib/MemoryMapLib.inf",
    "source/Platforms/Realme/NemoPkg/Library/MemoryMapLib/MemoryMapLib.c",
    "source/Silicon/Silicium/SiliciumPkg/Drivers/SimpleFbDxe/SimpleFb.c",
    "source/Silicon/Silicium/SiliciumPkg/Drivers/SimpleFbDxe/SimpleFbDxe.inf",
    "source/Silicon/MediaTek/MT6785Pkg/Library/PlatformSecLib/PlatformSecLib.inf",
    "source/Silicon/MediaTek/MT6785Pkg/Library/PlatformSecLib/PlatformSec.c",
    "source/Silicon/MediaTek/MT6785Pkg/Sec/PlatformSec.c",
    "source/Silicon/MediaTek/MT6785Pkg/Sec/PlatformSec.inf",
    "source/Silicon/MediaTek/MT6785Pkg/Sec/Sec.h",
    "source/Silicon/MediaTek/MT6785Pkg/Sec/AArch64/ArchSec.c",
    "source/Silicon/MediaTek/MT6785Pkg/Sec/AArch64/Exception.S",
    "source/Silicon/MediaTek/MT6785Pkg/Sec/AArch64/Helper.S",
    "Resources/Configs/Nemo.toml",
    "tools/verify-uefi-fd.py",
)
for relative in required_files:
    if not (ROOT / relative).is_file():
        raise SystemExit(f"Required file is missing: {relative}")

print("## NEMO repository audit\n")
print("**Result:** required build files and sanitized device evidence are present.")
