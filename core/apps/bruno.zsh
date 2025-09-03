#!/usr/bin/env zsh

# Configure Bruno app preferences (font only)

source $MY/core/utils/helper.zsh
source $MY/core/utils/ui-kit.zsh

ensure_command_available "yq" "Install with: brew install yq"
ensure_command_available "jq" "Install with: brew install jq"

CONFIG_YAML="$CONFIG_DIR/apps/bruno.yml"
PROFILE_CONFIG_YAML="$PROFILE_APPS_CONFIG_DIR/bruno.yml"
[[ -f "$CONFIG_YAML" ]] || exit 0

PREFS_FILE="$HOME_LIBRARY_APP_SUPPORT/bruno/preferences.json"

ui_section "Bruno Preferences"
ui_subtle "  ${PREFS_FILE/#$HOME/~}"

# Load current preferences or default structure
CURRENT=$(cat "$PREFS_FILE" 2>/dev/null || echo '{"preferences": {}}')

# Merge config with profile override
MAIN_CFG=$(yq eval '.font' "$CONFIG_YAML" -o json)
if [[ -f "$PROFILE_CONFIG_YAML" ]]; then
  PROFILE_CFG=$(yq eval '.font' "$PROFILE_CONFIG_YAML" -o json 2>/dev/null || echo '{}')
else
  PROFILE_CFG='{}'
fi
FONT_CFG=$(echo "$MAIN_CFG $PROFILE_CFG" | jq -s '.[0] * .[1]')

FONT_FAMILY=$(echo "$FONT_CFG" | jq -r '.family // empty')
FONT_SIZE=$(echo "$FONT_CFG" | jq -r '.size // empty')

# Update JSON: preferences.font.codeFont and preferences.font.codeFontSize
UPDATED=$(echo "$CURRENT" | jq \
  --arg family "$FONT_FAMILY" \
  --argjson size "${FONT_SIZE:-null}" \
  '.preferences.font = (.preferences.font // {}) \
   | .preferences.font.codeFont = (if ($family | length) > 0 then $family else .preferences.font.codeFont end) \
   | .preferences.font.codeFontSize = (if $size == null then .preferences.font.codeFontSize else $size end)')

# Write back (pretty)
mkdir -p "${PREFS_FILE%/*}"
echo "$UPDATED" | jq . > "$PREFS_FILE"

ui_success_simple "Updated Bruno font to '${FONT_FAMILY:-unchanged}' size '${FONT_SIZE:-unchanged}'"
