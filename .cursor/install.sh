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
# Install a pinned mise release and verify its published SHA-256 checksum before
# executing it. This matches the rest of the repo's pinning discipline (mise.lock
# checksums, package.json "packageManager" sha512) instead of piping whatever
# https://mise.run serves at runtime straight to sh.
export PATH="${NVM_BIN_DIR:+$NVM_BIN_DIR:}$HOME/.local/bin:$PATH"
if ! command -v mise >/dev/null 2>&1; then
  mise_version="v2026.8.5"
  case "$(uname -m)" in
    x86_64 | amd64) mise_target="linux-x64" ;;
    aarch64 | arm64) mise_target="linux-arm64" ;;
    *)
      echo "Unsupported architecture for mise install: $(uname -m)" >&2
      exit 1
      ;;
  esac
  mise_base="https://github.com/jdx/mise/releases/download/${mise_version}"
  mise_tmp="$(mktemp -d)"
  curl -fsSL --retry 3 -o "$mise_tmp/mise" "${mise_base}/mise-${mise_version}-${mise_target}"
  curl -fsSL --retry 3 -o "$mise_tmp/SHASUMS256.txt" "${mise_base}/SHASUMS256.txt"
  mise_expected="$(grep -E " (\./)?mise-${mise_version}-${mise_target}\$" "$mise_tmp/SHASUMS256.txt" | awk '{print $1}')"
  mise_actual="$(sha256sum "$mise_tmp/mise" | awk '{print $1}')"
  if [ -z "$mise_expected" ] || [ "$mise_expected" != "$mise_actual" ]; then
    echo "mise checksum verification failed (expected='$mise_expected' actual='$mise_actual')" >&2
    rm -rf "$mise_tmp"
    exit 1
  fi
  mkdir -p "$HOME/.local/bin"
  install -m 0755 "$mise_tmp/mise" "$HOME/.local/bin/mise"
  rm -rf "$mise_tmp"
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
# Activate the exact pinned pnpm through Corepack so setup does not rely on a
# pre-existing global pnpm and always matches package.json "packageManager".
if command -v corepack >/dev/null 2>&1; then
  export COREPACK_ENABLE_DOWNLOAD_PROMPT=0
  corepack enable pnpm >/dev/null 2>&1 || true
  corepack prepare --activate >/dev/null 2>&1 || true
fi
pnpm install --frozen-lockfile

echo "Cloud Agent environment install complete."
