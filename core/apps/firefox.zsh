#!/usr/bin/env zsh

source $MY/core/utils/helper.zsh

REL_USER_JS="user.js"
REL_CONTAINERS="containers.json"
REL_EXTENSION_SETTINGS="extension-settings.json"
REL_USER_CHROME="chrome/userChrome.css"

echo_title_update "Firefox Nightly"

command -v yq >/dev/null 2>&1 || echo_fail "Need yq (brew install yq)"
command -v jq >/dev/null 2>&1 || echo_fail "Need jq (brew install jq)"

CONFIG_FILE="$MY/config/firefox.yml"
PROFILE_CONFIG_FILE="$MY/profiles/$OS_PROFILE/config/firefox.yml"
[[ -f "$CONFIG_FILE" ]] || echo_fail "Missing config: $CONFIG_FILE"

PROFILE_DIR=$(yq eval '.profile.directory' "$CONFIG_FILE" | envsubst)
[[ -d "$PROFILE_DIR" ]] || echo_fail "Profile dir not found: $PROFILE_DIR"

DEFAULT_FOLDER_PATTERN=$(yq eval '.profile.default_folder_pattern' "$CONFIG_FILE")
[[ -n "$PROFILE_DIR" && -n "$DEFAULT_FOLDER_PATTERN" ]] || echo_fail "profile.directory/default_folder_pattern missing"

DEFAULT_FOLDER=$(ls -1d "$PROFILE_DIR"/* 2>/dev/null | grep "$DEFAULT_FOLDER_PATTERN" | head -n1)
[[ -n "$DEFAULT_FOLDER" ]] || echo_fail "No profile folder matches: $DEFAULT_FOLDER_PATTERN"

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

echo_info "Profile: $(echo "$DEFAULT_FOLDER" | sed "s|$HOME|~|")"
echo_space

echo_subtitle "Preferences"
echo "  $(shorten_path "$USER_JS_FILE")"
mkdir -p "${USER_JS_FILE%/*}" 2>/dev/null
cat > "$USER_JS_FILE" <<'HDR'
/**
 * Firefox Configuration
 * Generated from YAML configuration
 */
HDR

# Merge preferences from main config and profile-specific config
MERGED_PREFS=$(yq eval '.preferences' "$CONFIG_FILE" -o json)
if [[ -f "$PROFILE_CONFIG_FILE" ]]; then
    echo_info "Merging profile-specific Firefox config for: $OS_PROFILE"
    PROFILE_PREFS=$(yq eval '.preferences' "$PROFILE_CONFIG_FILE" -o json 2>/dev/null || echo '{}')
    MERGED_PREFS=$(echo "$MERGED_PREFS $PROFILE_PREFS" | jq -s '.[0] * .[1]')
fi

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
echo_success "Preferences updated"
echo_space

echo_subtitle "Interface styling"
echo "  $(shorten_path "$USER_CHROME_FILE")"
yq eval '.user_chrome_css' "$CONFIG_FILE" > "$USER_CHROME_FILE"
echo_success "Interface styling updated"
echo_space

echo_subtitle "Container tabs"
echo "  $(shorten_path "$CONTAINERS_FILE")"
yq eval '.containers' "$CONFIG_FILE" --output-format=json > "$CONTAINERS_FILE"
echo_success "Container tabs updated"
echo_space

echo_subtitle "Restarting Firefox..."

quit "Firefox Nightly" 2>/dev/null || true
sleep 2
open -a "Firefox Nightly" >/dev/null 2>&1 &

echo_success "Done"
