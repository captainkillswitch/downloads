#!/bin/sh
# Install `cks` — the command-line Captain Kill Switch.
#
#   curl -fsSL https://captainkillswitch.github.io/downloads/cli/install.sh | sh
#
# Downloads the prebuilt binary for this machine (Linux x86_64 static musl, or
# the macOS universal binary), verifies its sha256 against the release
# manifest published in the same directory, and installs it as `cks`.
#
# Install location: $CKS_BIN_DIR if set; /usr/local/bin when run as root
# (e.g. `curl ... | sudo sh`); otherwise ~/.local/bin.
#
# This file lives at scripts/install-cli.sh in the app repo and is published
# to downloads/cli/install.sh by cli-release.yml — edit it there, not in the
# downloads repo (the publish overwrites it).

set -eu

BASE_URL="${CKS_BASE_URL:-https://captainkillswitch.github.io/downloads/cli}"

say() { printf '%s\n' "$*" >&2; }
fail() {
    say "❌ $*"
    exit 1
}

command -v curl >/dev/null 2>&1 || fail "curl is required."

os=$(uname -s)
arch=$(uname -m)
case "$os" in
Linux)
    # The Linux build is a fully static x86_64 musl binary — portable across
    # distros, but x86_64 only.
    [ "$arch" = "x86_64" ] || fail "Prebuilt cks supports x86_64 Linux only (this is $arch)."
    file="cks-linux"
    key="linux-x64"
    ;;
Darwin)
    # Universal binary (arm64 + x86_64) — any Mac. (Homebrew users:
    # `brew install captainkillswitch/tap/cks` is the nicer route.)
    file="cks-macos"
    key="macos-universal"
    ;;
*)
    fail "Unsupported OS: $os. Linux and macOS only — on Windows use: scoop install $BASE_URL/cks.json"
    ;;
esac

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT INT TERM

say "⬇️  Downloading $file ..."
curl -fsSL "$BASE_URL/$file" -o "$tmp/cks"
curl -fsSL "$BASE_URL/manifest.json" -o "$tmp/manifest.json"

# Expected digest from the manifest, extracted without jq (which may not be
# installed). Only the sha256 entries are 64-hex values, so the pattern can't
# match the "files" mapping for the same key.
expected=$(sed -n "s/.*\"$key\": *\"\([0-9a-f]\{64\}\)\".*/\1/p" "$tmp/manifest.json" | tail -1)
[ -n "$expected" ] || fail "Could not read the expected sha256 for $key from $BASE_URL/manifest.json."

if command -v sha256sum >/dev/null 2>&1; then
    actual=$(sha256sum "$tmp/cks" | awk '{print $1}')
else
    actual=$(shasum -a 256 "$tmp/cks" | awk '{print $1}')
fi
[ "$actual" = "$expected" ] || fail "Checksum mismatch for $file (expected $expected, got $actual). Try again in a minute — a release may be publishing right now."
say "🔒 Checksum verified."

if [ -n "${CKS_BIN_DIR:-}" ]; then
    bin_dir=$CKS_BIN_DIR
elif [ "$(id -u)" = "0" ]; then
    bin_dir=/usr/local/bin
else
    bin_dir="$HOME/.local/bin"
fi
mkdir -p "$bin_dir"
chmod +x "$tmp/cks"
mv "$tmp/cks" "$bin_dir/cks"

version=$("$bin_dir/cks" --version 2>/dev/null || echo cks)
say "✅ Installed $version to $bin_dir/cks"
case ":$PATH:" in
*":$bin_dir:"*) ;;
*) say "⚠️  $bin_dir is not on your PATH — add:  export PATH=\"$bin_dir:\$PATH\"" ;;
esac
say "   Try it:  cks --dry-run"
