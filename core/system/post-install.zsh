#!/usr/bin/env zsh
# 📮 Post-install documentation opener (minimal by request)
# Usage:
#   my run postinstall          # open GitHub doc in browser
#   my run postinstall --offline # open local markdown file

# Known section files (basename without .md)
sections=(
  system-preferences dock firefox vscode keepassxc iterm2 raycast spotify slack earsafe pcloud dnscrypt-proxy
)

is_section() {
  local target="$1"; for s in "${sections[@]}"; do [[ "$s" == "$target" ]] && return 0; done; return 1;
}

open_local() {
  local file="$1"; if command -v glow >/dev/null 2>&1; then glow "$file"; elif command -v bat >/dev/null 2>&1; then bat --style=plain "$file"; else ${PAGER:-less} "$file"; fi
}

show_usage() {
  echo "Usage: my run postinstall [section] [--offline]" >&2
  echo "Sections: ${sections[*]}" >&2
}

SECTION=""; MODE="online"

# Parse args (order-agnostic: section then flag or vice versa)
for arg in "$@"; do
  case "$arg" in
    --offline) MODE="offline" ;;
    -h|--help) show_usage; exit 0 ;;
    *) if is_section "$arg"; then SECTION="$arg"; else echo "Unknown argument: $arg" >&2; show_usage; exit 1; fi ;;
  esac
done

if [[ -z "$SECTION" ]]; then
  # Index
  if [[ "$MODE" == offline ]]; then
    open_local "$MY/doc/post-install.md"
  else
    open "https://github.com/kud/my/blob/master/doc/post-install.md"
  fi
else
  FILE_PATH="$MY/doc/postinstall/$SECTION.md"
  if [[ ! -f "$FILE_PATH" ]]; then
    echo "Section file missing: $FILE_PATH" >&2; exit 1
  fi
  if [[ "$MODE" == offline ]]; then
    open_local "$FILE_PATH"
  else
    open "https://github.com/kud/my/blob/master/doc/postinstall/$SECTION.md"
  fi
fi
