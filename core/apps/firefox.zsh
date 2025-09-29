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

###############################################################################
# Helper functions
###############################################################################

json_is_empty() {
  # Args: JSON string (already evaluated / plain text) considered empty if null or {}
  [[ -z "$1" || "$1" == "null" || "$1" == "{}" ]]
}

shorten_path() {
  local p="$1"; p="${p/#$HOME/~}"; [[ $p == $DEFAULT_FOLDER/* ]] && echo "${p#${DEFAULT_FOLDER}/}" || echo "$p"
}

extension_id_map() {
  [[ -f "$ADDONS_FILE" ]] || { echo '{}'; return; }
  jq -r '.addons | map({ key: (.name | gsub("[^a-zA-Z0-9]"; "_") | ascii_downcase), value: .id }) | from_entries' "$ADDONS_FILE" 2>/dev/null || echo '{}'
}

extension_name_map() {
  [[ -f "$ADDONS_FILE" ]] || { echo '{}'; return; }
  jq -r '.addons | map({ key: (.name | gsub("[^a-zA-Z0-9]"; "_") | ascii_downcase), value: .name }) | from_entries' "$ADDONS_FILE" 2>/dev/null || echo '{}'
}

render_shortcuts_table() {
  local commands_json name_map
  commands_json="$1"   # raw yaml or json
  name_map="$(extension_name_map)"
  echo "$commands_json" | yq eval -o=json | jq -r --argjson name_map "$name_map" '
    def title_case: gsub("_"; " ") | split(" ") | map(. | ascii_upcase[0:1] + .[1:]) | join(" ");
    def fmt: gsub("Ctrl\\+"; "⌃") | gsub("MacCtrl\\+"; "⌃") | gsub("Shift\\+"; "⇧") | gsub("Alt\\+"; "⌥") | gsub("Command\\+"; "⌘");
    to_entries | map(
      .key as $k | ($name_map[$k] // ($k | title_case)) as $ext_name |
      "## " + $ext_name + "\n" + ( .value | to_entries | map("  " + (.key | title_case) + ": " + (.value | fmt)) | join("\n"))
    ) | join("\n\n")'
}

display_shortcuts() {
  ui_title "Firefox Extension Shortcuts"
  ui_info_simple "Profile: $(echo "$DEFAULT_FOLDER" | sed "s|$HOME|~|")"
  ui_spacer

  local EXTENSION_COMMANDS
  EXTENSION_COMMANDS=$(yq eval '.extension_settings.commands // {}' "$CONFIG_FILE")
  if json_is_empty "$EXTENSION_COMMANDS"; then
    ui_warning_simple "No shortcuts configured in firefox.yml"; return 0; fi
  render_shortcuts_table "$EXTENSION_COMMANDS"
  ui_spacer; ui_info_simple "Use 'my run firefox' to apply these shortcuts to Firefox"
}

# Argument parsing (supports multiple flags)
RESTART=false
SHOW_SHORTCUTS=false
ARGS=()
for arg in "$@"; do
  case "$arg" in
    --only-shortcuts|-sc|--shortcuts) SHOW_SHORTCUTS=true ;;
    --restart) RESTART=true ;;
    --help|-h)
      ui_title "Firefox Configuration Tool"
      echo "Usage: my run firefox [OPTIONS]"; echo; echo "Options:";
      echo "  --only-shortcuts, -sc    Display configured shortcuts only";
      echo "  --restart                Quit & reopen Firefox Nightly after applying";
      echo "  --help, -h               Show this help"; echo;
      echo "Without options: apply configuration only (no automatic restart)";
      exit 0 ;;
    *) ARGS+=("$arg") ;;
  esac
done

if $SHOW_SHORTCUTS; then
  display_shortcuts
  exit 0
fi

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
mkdir -p "${USER_CHROME_FILE%/*}" 2>/dev/null
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

EXTENSION_ID_MAP=$(extension_id_map)

# Read current extension settings or create empty structure
CURRENT_EXTENSION_SETTINGS=$(cat "$EXTENSION_SETTINGS_FILE" 2>/dev/null || echo '{"version":3,"commands":{},"prefs":{},"url_overrides":{},"default_search":{}}')

# Process extension settings from YAML and convert to extension-settings format
EXTENSION_COMMANDS=$(yq eval '.extension_settings.commands // {}' "$CONFIG_FILE")
if json_is_empty "$EXTENSION_COMMANDS"; then
  UPDATED_EXTENSION_SETTINGS="$CURRENT_EXTENSION_SETTINGS"
else
  COMMANDS_JSON=$(echo "$EXTENSION_COMMANDS" | yq eval -o=json | jq -r --argjson id_map "$EXTENSION_ID_MAP" '
    def norm: gsub("[^a-zA-Z0-9]"; "_") | ascii_downcase;
    def transform:
      gsub("⌘"; "MacCtrl+") |
      gsub("⇧"; "Shift+") |
      gsub("⌥"; "Alt+");
    to_entries | map(.key as $ext | ($ext | norm) as $n | $id_map[$n] as $id | select($id) | .value | to_entries | map({ key: .key, value: { precedenceList: [{ id: $id, installDate: (now*1000|floor), value: { shortcut: (.value|transform), description: (.key | gsub("_"; " ") | split(" ") | map(. | ascii_upcase[0:1]+.[1:]) | join(" ")) }, enabled: true }] } })) | flatten | from_entries')
  UPDATED_EXTENSION_SETTINGS=$(echo "$CURRENT_EXTENSION_SETTINGS" | jq --argjson new "$COMMANDS_JSON" '.commands = (.commands // {}) * $new')
fi

# Process other extension settings sections
EXTENSION_PREFS=$(yq eval '.extension_settings.prefs // {}' "$CONFIG_FILE")
EXTENSION_URL_OVERRIDES=$(yq eval '.extension_settings.url_overrides // {}' "$CONFIG_FILE")
EXTENSION_DEFAULT_SEARCH=$(yq eval '.extension_settings.default_search // {}' "$CONFIG_FILE")

if ! json_is_empty "$EXTENSION_PREFS"; then
  PREFS_JSON=$(echo "$EXTENSION_PREFS" | yq eval -o=json)
  UPDATED_EXTENSION_SETTINGS=$(echo "$UPDATED_EXTENSION_SETTINGS" | jq --argjson new_prefs "$PREFS_JSON" '
    .prefs = (.prefs // {}) * $new_prefs
  ')
fi

if ! json_is_empty "$EXTENSION_URL_OVERRIDES"; then
  URL_OVERRIDES_JSON=$(echo "$EXTENSION_URL_OVERRIDES" | yq eval -o=json)
  UPDATED_EXTENSION_SETTINGS=$(echo "$UPDATED_EXTENSION_SETTINGS" | jq --argjson new_overrides "$URL_OVERRIDES_JSON" '
    .url_overrides = (.url_overrides // {}) * $new_overrides
  ')
fi

if ! json_is_empty "$EXTENSION_DEFAULT_SEARCH"; then
  DEFAULT_SEARCH_JSON=$(echo "$EXTENSION_DEFAULT_SEARCH" | yq eval -o=json)
  UPDATED_EXTENSION_SETTINGS=$(echo "$UPDATED_EXTENSION_SETTINGS" | jq --argjson new_search "$DEFAULT_SEARCH_JSON" '
    .default_search = (.default_search // {}) * $new_search
  ')
fi

echo "$UPDATED_EXTENSION_SETTINGS" | jq . > "$EXTENSION_SETTINGS_FILE"
ui_success_simple "Extension settings updated"

# Verify that shortcuts from yaml were actually written (best-effort)
if ! json_is_empty "$EXTENSION_COMMANDS"; then
  ui_section "Shortcut verification"
  # Build a flat list: command -> {expectedShortcut, extId?}
  EXPECTED_CMDS_JSON=$(echo "$COMMANDS_JSON" | jq -r 'to_entries | map({key: .key, shortcut: .value.precedenceList[0].value.shortcut, extId: .value.precedenceList[0].id})')
  ACTUAL_FILE_CMDS=$(jq -r '.commands // {} | to_entries | map({key: .key, shortcut: (.value.precedenceList[0].value.shortcut // null), extId: (.value.precedenceList[0].id // null)})' "$EXTENSION_SETTINGS_FILE" 2>/dev/null || echo '[]')

  # Compare expected vs actual
  MISMATCHES=$(jq -n --argjson expected "$EXPECTED_CMDS_JSON" --argjson actual "$ACTUAL_FILE_CMDS" '
    [ $expected[] as $e | $actual[]? as $a | select($a.key == $e.key) | select($a.shortcut != $e.shortcut) | {command: $e.key, expected: $e.shortcut, actual: $a.shortcut} ]')
  MISSING=$(jq -n --argjson expected "$EXPECTED_CMDS_JSON" --argjson actual "$ACTUAL_FILE_CMDS" '
    [ $expected[] as $e | select([ $actual[].key ] | index($e.key) | not) | {command: $e.key, expected: $e.shortcut} ]')

  if [[ $(echo "$MISMATCHES" | jq 'length') -eq 0 && $(echo "$MISSING" | jq 'length') -eq 0 ]]; then
    ui_success_simple "All defined shortcuts present"
  else
    if [[ $(echo "$MISMATCHES" | jq 'length') -gt 0 ]]; then
      ui_warning_simple "Shortcut value mismatches detected:"
      echo "$MISMATCHES" | jq -r '.[] | "  - \(.command): expected=\(.expected) actual=\(.actual)"'
    fi
    if [[ $(echo "$MISSING" | jq 'length') -gt 0 ]]; then
      ui_warning_simple "Shortcuts missing (extension name likely not mapped to an installed add-on):"
      echo "$MISSING" | jq -r '.[] | "  - \(.command): expected=\(.expected)"'
      ui_subtle "Check addon names in addons.json match keys under extension_settings.commands (normalized to lowercase with non-alphanumerics as underscores)."
    fi
  fi
fi

ui_spacer
if $RESTART; then
  ui_info_simple "Restarting Firefox in 3s..."
  quit "Firefox Nightly" 2>/dev/null || true
  sleep 3
  open -a "Firefox Nightly" >/dev/null 2>&1 &
  ui_success_simple "Firefox restarted"
else
  ui_subtle "Skipping automatic restart (use --restart to force)."
fi

ui_success "Firefox configuration completed!"
