#!/usr/bin/env zsh

# Configure Bruno app preferences (direct JSON-structure merge)

source $MY/core/utils/helper.zsh
source $MY/core/utils/ui-kit.zsh

ensure_command_available "yq" "Install with: brew install yq"
ensure_command_available "jq" "Install with: brew install jq"

CONFIG_YAML="$CONFIG_DIR/apps/bruno.yml"
PROFILE_CONFIG_YAML="$PROFILE_APPS_CONFIG_DIR/bruno.yml"
[[ -f "$CONFIG_YAML" ]] || exit 0

PREFS_FILE="$HOME_LIBRARY_APP_SUPPORT/bruno/preferences.json"

# If preferences file does not exist, do nothing (skip creating it)
[[ -f "$PREFS_FILE" ]] || exit 0

# Load current preferences JSON (fallback to empty object if invalid)
if CURRENT_RAW=$(cat "$PREFS_FILE" 2>/dev/null); then
  if echo "$CURRENT_RAW" | jq empty 2>/dev/null 1>&2; then
    CURRENT="$CURRENT_RAW"
  else
    CURRENT='{}'
  fi
else
  CURRENT='{}'
fi

# Load YAML (already mirrors JSON structure)
MAIN_CFG=$(yq -o=json eval '.' "$CONFIG_YAML")
if [[ -f "$PROFILE_CONFIG_YAML" ]]; then
  PROFILE_CFG=$(yq -o=json eval '.' "$PROFILE_CONFIG_YAML" 2>/dev/null || echo '{}')
else
  PROFILE_CFG='{}'
fi

# Robust merge of main + profile (ignore nulls / non-objects)
CFG=$(printf '%s\n%s\n' "$MAIN_CFG" "$PROFILE_CFG" | jq -s 'reduce .[] as $o ({}; if ($o|type)=="object" then . * $o else . end)')

# If CFG ended up empty, nothing to do
if [[ "$CFG" == '{}' ]]; then
  ui_info_simple "Nothing to update (no overrides)"
  exit 0
fi

# Merge CURRENT (may be {}) with CFG
UPDATED=$(printf '%s\n%s\n' "$CURRENT" "$CFG" | jq -s 'reduce .[] as $o ({}; if ($o|type)=="object" then . * $o else . end)')

# Extract font info for message if present
FONT_FAMILY=$(echo "$CFG" | jq -r '.preferences.font.codeFont // empty')
FONT_SIZE=$(echo "$CFG" | jq -r '.preferences.font.codeFontSize // empty')

# If no change, report and exit
if [[ "$UPDATED" == "$CURRENT" ]]; then
  ui_info_simple "Nothing to update (already in desired state)"
  exit 0
fi

# Write back (pretty)
echo "$UPDATED" | jq . > "$PREFS_FILE"

ui_success_simple "Updated Bruno preferences (font '${FONT_FAMILY:-unchanged}' size '${FONT_SIZE:-unchanged}')"

