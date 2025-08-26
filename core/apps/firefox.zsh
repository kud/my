#!/usr/bin/env zsh

# Source required utilities
source $MY/core/utils/ui-kit.zsh
source $MY/core/utils/helper.zsh
source $MY/core/utils/packages.zsh

REL_USER_JS="user.js"
REL_CONTAINERS="containers.json"
REL_EXTENSION_SETTINGS="extension-settings.json"
REL_USER_CHROME="chrome/userChrome.css"

# Ensure required commands are available
ensure_command_available "yq" "Install with: brew install yq"
ensure_command_available "jq" "Install with: brew install jq"

CONFIG_FILE="$CONFIG_DIR/apps/firefox.yml"
PROFILE_CONFIG_FILE="$PROFILE_APPS_CONFIG_DIR/firefox.yml"

if [[ ! -f "$CONFIG_FILE" ]]; then
    ui_error_simple "Missing config: $CONFIG_FILE"
    exit 1
fi

PROFILE_DIR=$(yq eval '.profile.directory' "$CONFIG_FILE" | envsubst)

if [[ ! -d "$PROFILE_DIR" ]]; then
    ui_error_simple "Profile dir not found: $PROFILE_DIR"
    exit 1
fi

DEFAULT_FOLDER_PATTERN=$(yq eval '.profile.default_folder_pattern' "$CONFIG_FILE")

if [[ -z "$PROFILE_DIR" || -z "$DEFAULT_FOLDER_PATTERN" ]]; then
    ui_error_simple "profile.directory/default_folder_pattern missing"
    exit 1
fi

DEFAULT_FOLDER=$(ls -1d "$PROFILE_DIR"/* 2>/dev/null | grep "$DEFAULT_FOLDER_PATTERN" | head -n1)

if [[ -z "$DEFAULT_FOLDER" ]]; then
    ui_error_simple "No profile folder matches: $DEFAULT_FOLDER_PATTERN"
    exit 1
fi

USER_JS_FILE="$DEFAULT_FOLDER/$REL_USER_JS"
CONTAINERS_FILE="$DEFAULT_FOLDER/$REL_CONTAINERS"
EXTENSION_SETTINGS_FILE="$DEFAULT_FOLDER/$REL_EXTENSION_SETTINGS"
USER_CHROME_FILE="$DEFAULT_FOLDER/$REL_USER_CHROME"
ADDONS_FILE="$DEFAULT_FOLDER/addons.json"

shorten_path() {
  local p="$1"
  p="${p/#$HOME/~}"
  # If inside profile root, show relative
  if [[ "$p" == $DEFAULT_FOLDER/* ]]; then
    echo "${p#${DEFAULT_FOLDER}/}"
  else
    echo "$p"
  fi
}

ui_title "Firefox Configuration"
ui_info_simple "Profile: $(echo "$DEFAULT_FOLDER" | sed "s|$HOME|~|")"
ui_spacer

ui_section "Preferences"
ui_subtle "  $(shorten_path "$USER_JS_FILE")"
mkdir -p "${USER_JS_FILE%/*}" 2>/dev/null
cat > "$USER_JS_FILE" <<'HDR'
/**
 * Firefox Configuration
 * Generated from YAML configuration
 */
HDR

# Merge preferences from main config and profile-specific config
MERGED_PREFS=$(merge_app_preferences "$CONFIG_FILE" "$PROFILE_CONFIG_FILE" "preferences")

echo "$MERGED_PREFS" | jq -r '
  def flatten:
    . as $in |
    if type == "object" then
      reduce keys_unsorted[] as $key ({};
        if ($in[$key] | type) == "object" then
          . + (($in[$key] | flatten) | with_entries(.key = ($key + "." + .key)))
        else
          . + {($key): $in[$key]}
        end
      )
    else . end;
  flatten | to_entries | map(
    if .value == true or .value == false then
      "user_pref(\"" + .key + "\", " + (.value | tostring) + ");"
    elif (.value | type) == "number" then
      "user_pref(\"" + .key + "\", " + (.value | tostring) + ");"
    else
      "user_pref(\"" + .key + "\", \"" + (.value | tostring) + "\");"
  end) | join("\n")' >> "$USER_JS_FILE"
ui_success_simple "Preferences updated"

ui_section "Interface styling"
ui_subtle "  $(shorten_path "$USER_CHROME_FILE")"
yq eval '.user_chrome_css' "$CONFIG_FILE" > "$USER_CHROME_FILE"
ui_success_simple "Interface styling updated"

ui_section "Container tabs"
ui_subtle "  $(shorten_path "$CONTAINERS_FILE")"
yq eval '.containers' "$CONFIG_FILE" --output-format=json > "$CONTAINERS_FILE"
ui_success_simple "Container tabs updated"

ui_section "Extension settings"
ui_subtle "  $(shorten_path "$EXTENSION_SETTINGS_FILE")"

# Create backup of current extension settings
if [[ -f "$EXTENSION_SETTINGS_FILE" ]]; then
  BACKUP_FILE="${EXTENSION_SETTINGS_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
  cp "$EXTENSION_SETTINGS_FILE" "$BACKUP_FILE"
  ui_info_simple "Backup created: $(shorten_path "$BACKUP_FILE")"
fi

# Create extension ID mapping from addons.json
EXTENSION_ID_MAP=$(jq -r '
  .addons | map({
    key: (.name | gsub("[^a-zA-Z0-9]"; "_") | ascii_downcase),
    value: .id
  }) | from_entries
' "$ADDONS_FILE" 2>/dev/null || echo '{}')

# Read current extension settings or create empty structure
CURRENT_EXTENSION_SETTINGS=$(cat "$EXTENSION_SETTINGS_FILE" 2>/dev/null || echo '{"version":3,"commands":{},"prefs":{},"url_overrides":{},"default_search":{}}')

# Process extension settings from YAML and convert to extension-settings format
EXTENSION_COMMANDS=$(yq eval '.extension_settings.commands // {}' "$CONFIG_FILE")

if [[ "$EXTENSION_COMMANDS" != "null" && "$EXTENSION_COMMANDS" != "{}" ]]; then
  # Generate commands section
  COMMANDS_JSON=$(echo "$EXTENSION_COMMANDS" | yq eval -o=json | jq -r --argjson id_map "$EXTENSION_ID_MAP" '
    def normalize_name: gsub("[^a-zA-Z0-9]"; "_") | ascii_downcase;
    def to_firefox_shortcut:
      gsub("⌘"; "MacCtrl+") |
      gsub("⇧"; "Shift+") |
      gsub("⌥"; "Alt+") |
      gsub("^"; "Ctrl+");
    
    to_entries | map(
      .key as $ext_name |
      ($ext_name | normalize_name) as $normalized |
      $id_map[$normalized] as $ext_id |
      if $ext_id then
        .value | to_entries | map({
          key: .key,
          value: {
            precedenceList: [{
              id: $ext_id,
              installDate: (now * 1000 | floor),
              value: {
                shortcut: (.value | to_firefox_shortcut),
                description: (.key | gsub("_"; " ") | split(" ") | map(. | ascii_upcase[0:1] + .[1:]) | join(" "))
              },
              enabled: true
            }]
          }
        })
      else
        empty
      end
    ) | flatten | from_entries
  ')
  
  # Merge with existing commands
  UPDATED_EXTENSION_SETTINGS=$(echo "$CURRENT_EXTENSION_SETTINGS" | jq --argjson new_commands "$COMMANDS_JSON" '
    .commands = (.commands // {}) * $new_commands
  ')
else
  UPDATED_EXTENSION_SETTINGS="$CURRENT_EXTENSION_SETTINGS"
fi

# Process other extension settings sections
EXTENSION_PREFS=$(yq eval '.extension_settings.prefs // {}' "$CONFIG_FILE")
EXTENSION_URL_OVERRIDES=$(yq eval '.extension_settings.url_overrides // {}' "$CONFIG_FILE")  
EXTENSION_DEFAULT_SEARCH=$(yq eval '.extension_settings.default_search // {}' "$CONFIG_FILE")

if [[ "$EXTENSION_PREFS" != "null" && "$EXTENSION_PREFS" != "{}" ]]; then
  PREFS_JSON=$(echo "$EXTENSION_PREFS" | yq eval -o=json)
  UPDATED_EXTENSION_SETTINGS=$(echo "$UPDATED_EXTENSION_SETTINGS" | jq --argjson new_prefs "$PREFS_JSON" '
    .prefs = (.prefs // {}) * $new_prefs
  ')
fi

if [[ "$EXTENSION_URL_OVERRIDES" != "null" && "$EXTENSION_URL_OVERRIDES" != "{}" ]]; then
  URL_OVERRIDES_JSON=$(echo "$EXTENSION_URL_OVERRIDES" | yq eval -o=json)
  UPDATED_EXTENSION_SETTINGS=$(echo "$UPDATED_EXTENSION_SETTINGS" | jq --argjson new_overrides "$URL_OVERRIDES_JSON" '
    .url_overrides = (.url_overrides // {}) * $new_overrides
  ')
fi

if [[ "$EXTENSION_DEFAULT_SEARCH" != "null" && "$EXTENSION_DEFAULT_SEARCH" != "{}" ]]; then
  DEFAULT_SEARCH_JSON=$(echo "$EXTENSION_DEFAULT_SEARCH" | yq eval -o=json)
  UPDATED_EXTENSION_SETTINGS=$(echo "$UPDATED_EXTENSION_SETTINGS" | jq --argjson new_search "$DEFAULT_SEARCH_JSON" '
    .default_search = (.default_search // {}) * $new_search
  ')
fi

echo "$UPDATED_EXTENSION_SETTINGS" | jq . > "$EXTENSION_SETTINGS_FILE"
ui_success_simple "Extension settings updated"

ui_spacer
ui_info_simple "Restarting Firefox..."

quit "Firefox Nightly" 2>/dev/null || true
sleep 2
open -a "Firefox Nightly" >/dev/null 2>&1 &

ui_success "Firefox configuration completed!"
