#!/usr/bin/env zsh

# Source required utilities
source $MY/core/utils/ui-kit.zsh
source $MY/core/utils/helper.zsh
source $MY/core/utils/packages.zsh

REL_USER_JS="user.js"
REL_CONTAINERS="containers.json"
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
USER_CHROME_FILE="$DEFAULT_FOLDER/$REL_USER_CHROME"

###############################################################################
# Helper functions
###############################################################################

shorten_path() {
  local p="$1"; p="${p/#$HOME/~}"; [[ $p == $DEFAULT_FOLDER/* ]] && echo "${p#${DEFAULT_FOLDER}/}" || echo "$p"
}

###############################################################################
# Argument parsing
###############################################################################
RESTART=false
ARGS=()
for arg in "$@"; do
  case "$arg" in
    --restart) RESTART=true ;;
    --help|-h)
      ui_title "Firefox Configuration Tool"
      echo "Usage: my firefox [OPTIONS]"; echo; echo "Options:";
      echo "  --restart               Quit & reopen Firefox Nightly after applying";
      echo "  --help, -h              Show this help"; echo;
      echo "Without options: preferences, containers, styling only (no restart)";
      exit 0 ;;
    *) ARGS+=("$arg") ;;
  esac
done

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
