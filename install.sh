#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   curl -fsSL https://raw.githubusercontent.com/jim42xd/agent-kit/main/install.sh | bash
#   curl -fsSL .../install.sh | bash -s -- [profile] [project-dir]
#   ./install.sh [profile] [project-dir]        (from a clone)
#
# Env:
#   AGENT_KIT_REF   tag or commit to install (default: main)
#   AGENT_KIT_REPO  owner/repo to download from (default: jim42xd/agent-kit)

AGENT_KIT_REPO="${AGENT_KIT_REPO:-jim42xd/agent-kit}"
AGENT_KIT_REF="${AGENT_KIT_REF:-main}"
PROFILE="${1:-}"
TARGET_DIR="${2:-.}"

echo "==> Installing agent-kit"

# ------------------------------------------------------------
# Check dependencies
# ------------------------------------------------------------

for cmd in curl tar jq; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "ERROR: $cmd is not installed."
    echo "Install it first, e.g.: sudo pacman -S $cmd / sudo apt install $cmd / brew install $cmd"
    exit 1
  fi
done

# ------------------------------------------------------------
# Locate kit files (local clone, or download when piped)
# ------------------------------------------------------------

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"

if [ ! -d "$KIT_DIR/common" ]; then
  KIT_DIR="$(mktemp -d)"
  trap 'rm -rf "$KIT_DIR"' EXIT

  echo "==> Downloading $AGENT_KIT_REPO@$AGENT_KIT_REF"
  curl -fsSL "https://codeload.github.com/$AGENT_KIT_REPO/tar.gz/$AGENT_KIT_REF" \
    | tar -xz -C "$KIT_DIR" --strip-components=1
else
  echo "==> Using local kit at $KIT_DIR"
fi

# ------------------------------------------------------------
# Resolve target project
# ------------------------------------------------------------

if [ ! -d "$TARGET_DIR" ]; then
  echo "ERROR: Project directory not found: $TARGET_DIR"
  exit 1
fi

TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

if [ "$TARGET_DIR" = "$KIT_DIR" ]; then
  echo "ERROR: Run this from a project folder, not from agent-kit itself."
  exit 1
fi

if [ ! -d "$TARGET_DIR/.git" ]; then
  echo "WARNING: $TARGET_DIR is not a git repo; overwritten files can't be restored."
fi

echo "==> Target: $TARGET_DIR"

# ------------------------------------------------------------
# Resolve profile
# ------------------------------------------------------------

if [ -z "$PROFILE" ] && [ -f "$TARGET_DIR/ProjectSettings/ProjectVersion.txt" ]; then
  PROFILE="unity"
fi

if [ -n "$PROFILE" ] && [ ! -d "$KIT_DIR/$PROFILE" ]; then
  echo "ERROR: Unknown profile: $PROFILE"
  echo "Available: $(cd "$KIT_DIR" && ls -d */ | tr -d / | grep -vx common | tr '\n' ' ')"
  exit 1
fi

echo "==> Profile: ${PROFILE:-none (common only)}"

if [ "$PROFILE" = "unity" ] \
  && ! command -v dotnet >/dev/null 2>&1 \
  && [ ! -x "$HOME/.dotnet/dotnet" ]; then
  echo "WARNING: dotnet not found; the C# format hook will do nothing until it's installed."
fi

# ------------------------------------------------------------
# Install helpers
# ------------------------------------------------------------

# Deep merge; arrays are unioned so project-specific entries survive updates.
# shortcut: entries removed from the kit stay in projects, delete them by hand.
JQ_MERGE='def m($a; $b): if ($a|type) == "object" and ($b|type) == "object"
  then reduce ($b|keys_unsorted[]) as $k ($a; .[$k] = m(.[$k]; $b[$k]))
  elif ($a|type) == "array" and ($b|type) == "array" then $a + ($b - $a)
  else $b end;
  m(.[0]; .[1])'

merge_settings() {
  local src="$1" dst="$2"

  [ -f "$dst" ] || echo '{}' > "$dst"
  jq -s "$JQ_MERGE" "$dst" "$src" > "$dst.tmp"
  mv "$dst.tmp" "$dst"
}

# Project-owned: create from template, later only add missing @imports.
update_claude_md() {
  local src="$1" dst="$2"

  if [ ! -f "$dst" ]; then
    cp "$src" "$dst"
    return
  fi

  [ -z "$(tail -c1 "$dst")" ] || echo >> "$dst"

  grep '^@' "$src" | while read -r line; do
    grep -qxF "$line" "$dst" || echo "$line" >> "$dst"
  done
}

install_layer() {
  local layer_dir="$1"

  (cd "$layer_dir" && find . -type f) | while read -r file; do
    local src="$layer_dir/$file"
    local dst="$TARGET_DIR/$file"

    mkdir -p "$(dirname "$dst")"

    case "$file" in
      ./.claude/settings.json)
        merge_settings "$src" "$dst"
        echo "    merged      ${file#./}"
        ;;
      ./CLAUDE.md)
        update_claude_md "$src" "$dst"
        echo "    imports     ${file#./}"
        ;;
      *)
        cp "$src" "$dst"
        echo "    copied      ${file#./}"
        ;;
    esac
  done
}

# ------------------------------------------------------------
# Install layers
# ------------------------------------------------------------

echo "==> Installing common files"
install_layer "$KIT_DIR/common"

if [ -n "$PROFILE" ]; then
  echo "==> Installing $PROFILE files"
  install_layer "$KIT_DIR/$PROFILE"
fi

echo
echo "==> agent-kit installation complete"
echo "==> Review the changes with:"
echo "    git -C \"$TARGET_DIR\" status"
