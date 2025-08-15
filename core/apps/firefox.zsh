#!/usr/bin/env zsh

# Source required utilities
source $MY/core/utils/package-manager-utils.zsh

REL_USER_JS="user.js"
REL_CONTAINERS="containers.json"
REL_EXTENSION_SETTINGS="extension-settings.json"
REL_USER_CHROME="chrome/userChrome.css"

ensure_command_available "yq" "Install with: brew install yq"
ensure_command_available "jq" "Install with: brew install jq"

CONFIG_FILE="$MY/config/apps/firefox.yml"
PROFILE_CONFIG_FILE="$MY/profiles/$OS_PROFILE/config/apps/firefox.yml"
[[ -f "$CONFIG_FILE" ]] || { echo "Missing config: $CONFIG_FILE"; exit 1; }

PROFILE_DIR=$(yq eval '.profile.directory' "$CONFIG_FILE" | envsubst)
[[ -d "$PROFILE_DIR" ]] || { echo "Profile dir not found: $PROFILE_DIR"; exit 1; }

DEFAULT_FOLDER_PATTERN=$(yq eval '.profile.default_folder_pattern' "$CONFIG_FILE")
[[ -n "$PROFILE_DIR" && -n "$DEFAULT_FOLDER_PATTERN" ]] || { echo "profile.directory/default_folder_pattern missing"; exit 1; }

DEFAULT_FOLDER=$(ls -1d "$PROFILE_DIR"/* 2>/dev/null | grep "$DEFAULT_FOLDER_PATTERN" | head -n1)
[[ -n "$DEFAULT_FOLDER" ]] || { echo "No profile folder matches: $DEFAULT_FOLDER_PATTERN"; exit 1; }

USER_JS_FILE="$DEFAULT_FOLDER/$REL_USER_JS"
CONTAINERS_FILE="$DEFAULT_FOLDER/$REL_CONTAINERS"
EXTENSION_SETTINGS_FILE="$DEFAULT_FOLDER/$REL_EXTENSION_SETTINGS"
USER_CHROME_FILE="$DEFAULT_FOLDER/$REL_USER_CHROME"

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

echo "Profile: $(echo "$DEFAULT_FOLDER" | sed "s|$HOME|~|")"

echo "Preferences"
echo "  $(shorten_path "$USER_JS_FILE")"
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
echo "Preferences updated"

echo "Interface styling"
echo "  $(shorten_path "$USER_CHROME_FILE")"
yq eval '.user_chrome_css' "$CONFIG_FILE" > "$USER_CHROME_FILE"
echo "Interface styling updated"

echo "Container tabs"
echo "  $(shorten_path "$CONTAINERS_FILE")"
yq eval '.containers' "$CONFIG_FILE" --output-format=json > "$CONTAINERS_FILE"
echo "Container tabs updated"

echo "Restarting Firefox..."

quit "Firefox Nightly" 2>/dev/null || true
sleep 2
open -a "Firefox Nightly" >/dev/null 2>&1 &

echo "Done"
