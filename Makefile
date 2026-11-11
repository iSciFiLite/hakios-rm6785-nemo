# ==============================================================================
# HakiOS RM6785 NEMO Unified — Makefile
# Inclusive Development of UEFI Firmware & HakiOS XNU Kernel Ecosystem
# ==============================================================================

SHELL := /usr/bin/env bash
DEVICE ?= nemo
JOBS ?= $(shell nproc 2>/dev/null || echo 4)

.PHONY: all help audit check test-config uefi-audit hakios-check \
        split-subtrees sync-subtrees clean

all: help

help:
	@echo "HakiOS RM6785 NEMO Unified Development"
	@echo "======================================="
	@echo "Inclusive build & audit targets:"
	@echo "  make audit           - Run all UEFI memory-map, firmware, and HakiOS audits"
	@echo "  make check           - Validate HakiOS device profiles and defconfigs"
	@echo "  make test-config     - Test HakiOS Nemo and Salaa defconfig generation"
	@echo "  make uefi-audit      - Run NEMO UEFI firmware and memory map checks"
	@echo "  make hakios-check    - Check HakiOS MT6785 driver integrity and platform stubs"
	@echo "  make split-subtrees  - Synchronize subtrees back to rmx2001-nemo-uefi and hakios-mt6785"
	@echo "  make sync-subtrees   - Pull upstream changes into uefi/ and hakios/ subtrees"
	@echo ""
	@echo "HakiOS OS & Kernel targets (inside hakios/):"
	@echo "  make defconfig DEVICE=nemo  - Generate HakiOS configuration for NEMO"
	@echo "  make loader DEVICE=nemo     - Compile xnuloader.efi for MT6785"
	@echo "  make kernel DEVICE=nemo     - Compile HakiOS XNU kernel for MT6785"
	@echo ""
	@echo "UEFI Firmware targets (inside uefi/):"
	@echo "  See uefi/README.md for hosted or local Mu-Silicium build steps"

audit: uefi-audit hakios-check

uefi-audit:
	@echo "==> Auditing NEMO UEFI memory map..."
	python3 uefi/tools/audit-memory-map.py
	@echo "==> Auditing NEMO UEFI firmware declarations..."
	python3 uefi/tools/firmware-audit.py

hakios-check:
	@echo "==> Checking HakiOS device definitions..."
	python3 hakios/tools/hakios-device.py check nemo salaa
	@echo "==> Checking HakiOS driver metadata..."
	python3 hakios/tools/drivers-check.py
	@echo "==> Testing HakiOS NEMO configuration..."
	python3 hakios/tools/hakios-config.py defconfig nemo
	python3 hakios/tools/hakios-config.py show

check: audit

test-config:
	@echo "==> Testing Nemo defconfig..."
	python3 hakios/tools/hakios-config.py defconfig nemo
	@echo "==> Testing Salaa defconfig..."
	python3 hakios/tools/hakios-config.py defconfig salaa

defconfig:
	@echo "==> Configuring HakiOS for $(DEVICE)..."
	python3 hakios/tools/hakios-config.py defconfig $(DEVICE)

loader:
	@echo "==> Building HakiOS xnuloader for $(DEVICE)..."
	$(MAKE) -C hakios DEVICE=$(DEVICE) loader

kernel:
	@echo "==> Building HakiOS XNU kernel for $(DEVICE)..."
	$(MAKE) -C hakios DEVICE=$(DEVICE) JOBS=$(JOBS) kernel

split-subtrees:
	bash tools/split-subtrees.sh

sync-subtrees:
	bash tools/sync-subtrees.sh

clean:
	rm -f hakios/.config hakios/.config.old
