#!/usr/bin/env bash
# Cloud Agent install for the krosdai/.github repository.
#
# Prepares the lint/format toolchain used by this repo:
#   - mise + the native AutoCorrect CLI (pinned via mise.toml / mise.lock)
#   - Node dependencies via the pnpm version pinned in package.json
#
# The script is idempotent and safe to run repeatedly.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# Prefer the image's Node that satisfies package.json "engines" (>=22.22.1).
# nvm's default (v22.22.x) is placed ahead of any injected shims so pnpm and its
# scripts run under an engines-compatible Node.
NVM_BIN_DIR=""
if [ -s "$HOME/.nvm/nvm.sh" ]; then
  export NVM_DIR="$HOME/.nvm"
  # shellcheck disable=SC1091
  . "$HOME/.nvm/nvm.sh"
  nvm use default >/dev/null 2>&1 || true
  NVM_BIN_DIR="$(nvm which default 2>/dev/null | xargs -r dirname || true)"
fi

# --- mise: manages the native AutoCorrect CLI used by `pnpm format` + hooks ---
export PATH="${NVM_BIN_DIR:+$NVM_BIN_DIR:}$HOME/.local/bin:$PATH"
if ! command -v mise >/dev/null 2>&1; then
  curl -fsSL https://mise.run | sh
fi

# Ensure future interactive shells can locate mise (idempotent).
BASHRC="$HOME/.bashrc"
if [ -f "$BASHRC" ] && ! grep -qF "mise activate bash" "$BASHRC"; then
  printf '\n# Added by Cloud Agent environment setup\neval "$(%s/.local/bin/mise activate bash)"\n' "$HOME" >> "$BASHRC"
fi

# Trust this repo's mise config and install the pinned tools.
mise trust "$REPO_ROOT"
mise install

# --- Node dependencies (pnpm is pinned via package.json "packageManager") ---
pnpm install --frozen-lockfile

echo "Cloud Agent environment install complete."
