#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🎨 SUBLIME MERGE CONFIGURATION                                             #
#   -----------------------------                                              #
#   Sets up Sublime Merge Git client with Meetio theme and JetBrains Mono    #
#   font for a beautiful and productive Git workflow experience.              #
#                                                                              #
################################################################################

# Source required utilities
source $MY/core/utils/helper.zsh

ensure_command_available "yq" "Install with: brew install yq"
ensure_command_available "jq" "Install with: brew install jq"

CONFIG_YAML="$MY/config/apps/sublime-merge.yml"
PROFILE_CONFIG_YAML="$MY/profiles/$OS_PROFILE/config/apps/sublime-merge.yml"
[[ -f "$CONFIG_YAML" ]] || exit 1

################################################################################
# 📂 DIRECTORY SETUP
################################################################################

DIR="$HOME/Library/Application Support/Sublime Merge/Packages"

# Ensure directory exists
if [[ ! -d "$DIR" ]]; then
    mkdir -p "$DIR/User"
fi

################################################################################
# 🎨 THEME INSTALLATION & CONFIGURATION
################################################################################

# Read theme configuration from YAML (with profile override support)
THEME_NAME=$(yq eval '.theme.name' "$CONFIG_YAML")
THEME_REPO=$(yq eval '.theme.repository' "$CONFIG_YAML")
SUBLIME_THEME=$(yq eval '.theme.sublime_theme' "$CONFIG_YAML")
COLOR_SCHEME=$(yq eval '.theme.color_scheme' "$CONFIG_YAML")

# Override with profile-specific theme settings if they exist
if [[ -f "$PROFILE_CONFIG_YAML" ]]; then
    PROFILE_THEME_NAME=$(yq eval '.theme.name // empty' "$PROFILE_CONFIG_YAML" 2>/dev/null)
    PROFILE_THEME_REPO=$(yq eval '.theme.repository // empty' "$PROFILE_CONFIG_YAML" 2>/dev/null)
    PROFILE_SUBLIME_THEME=$(yq eval '.theme.sublime_theme // empty' "$PROFILE_CONFIG_YAML" 2>/dev/null)
    PROFILE_COLOR_SCHEME=$(yq eval '.theme.color_scheme // empty' "$PROFILE_CONFIG_YAML" 2>/dev/null)

    [[ -n "$PROFILE_THEME_NAME" ]] && THEME_NAME="$PROFILE_THEME_NAME"
    [[ -n "$PROFILE_THEME_REPO" ]] && THEME_REPO="$PROFILE_THEME_REPO"
    [[ -n "$PROFILE_SUBLIME_THEME" ]] && SUBLIME_THEME="$PROFILE_SUBLIME_THEME"
    [[ -n "$PROFILE_COLOR_SCHEME" ]] && COLOR_SCHEME="$PROFILE_COLOR_SCHEME"
fi

if [[ ! -d "$DIR/$THEME_NAME" ]]; then
    cd "$DIR" || { echo "Failed to access Sublime Merge directory"; exit 1; }

    # Clone the theme repository
    git clone "$THEME_REPO" "$THEME_NAME"

else
    cd "$DIR/$THEME_NAME" || { echo "Failed to access theme directory"; exit 1; }
    git pull
fi

################################################################################
# ⚙️ PREFERENCES CONFIGURATION
################################################################################


# Merge preferences from main config and profile-specific config
MERGED_PREFS=$(yq eval '.preferences' "$CONFIG_YAML" -o json)
if [[ -f "$PROFILE_CONFIG_YAML" ]]; then
    PROFILE_PREFS=$(yq eval '.preferences' "$PROFILE_CONFIG_YAML" -o json 2>/dev/null || echo '{}')
    MERGED_PREFS=$(echo "$MERGED_PREFS $PROFILE_PREFS" | jq -s '.[0] * .[1]')
fi

# Add theme settings to preferences
FULL_PREFS=$(echo "$MERGED_PREFS" | jq --arg theme "$SUBLIME_THEME" --arg scheme "$COLOR_SCHEME" '. + {theme: $theme, color_scheme: $scheme}')

# Write preferences to file
echo "$FULL_PREFS" | jq . > "$DIR/User/Preferences.sublime-settings"

# Configuration complete
