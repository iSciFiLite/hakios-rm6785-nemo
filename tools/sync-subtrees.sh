#!/usr/bin/env bash
# ==============================================================================
# tools/sync-subtrees.sh — Pull upstream updates from standalone repositories
# ==============================================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

UEFI_REMOTE="${UEFI_REMOTE:-https://github.com/iSciFiLite/rmx2001-nemo-uefi.git}"
HAKIOS_REMOTE="${HAKIOS_REMOTE:-https://github.com/iSciFiLite/hakios-mt6785.git}"
UEFI_BRANCH="${UEFI_BRANCH:-main}"
HAKIOS_BRANCH="${HAKIOS_BRANCH:-main}"

echo "==> Pulling uefi/ subtree from $UEFI_REMOTE ($UEFI_BRANCH)..."
git subtree pull --prefix=uefi "$UEFI_REMOTE" "$UEFI_BRANCH" --squash -m "sync(uefi): pull updates from rmx2001-nemo-uefi"

echo "==> Pulling hakios/ subtree from $HAKIOS_REMOTE ($HAKIOS_BRANCH)..."
git subtree pull --prefix=hakios "$HAKIOS_REMOTE" "$HAKIOS_BRANCH" --squash -m "sync(hakios): pull updates from hakios-mt6785"

echo "==> Subtrees successfully updated!"
