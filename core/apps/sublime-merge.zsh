#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🎨 SUBLIME MERGE CONFIGURATION                                             #
#   -----------------------------                                              #
#   Sets up Sublime Merge Git client with Meetio theme and JetBrains Mono    #
#   font for a beautiful and productive Git workflow experience.              #
#                                                                              #
################################################################################

source $MY/core/utils/helper.zsh

echo_task_start "Configuring Sublime Merge Git client"

command -v yq >/dev/null 2>&1 || echo_fail "Need yq (brew install yq)"
command -v jq >/dev/null 2>&1 || echo_fail "Need jq (brew install jq)"

CONFIG_YAML="$MY/config/sublime-merge.yml"
PROFILE_CONFIG_YAML="$MY/profiles/$OS_PROFILE/config/sublime-merge.yml"
[[ -f "$CONFIG_YAML" ]] || echo_fail "Missing config: $CONFIG_YAML"

################################################################################
# 📂 DIRECTORY SETUP
################################################################################

DIR="$HOME/Library/Application Support/Sublime Merge/Packages"

# Ensure directory exists
if [[ ! -d "$DIR" ]]; then
    echo_info "Creating Sublime Merge packages directory"
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
    echo_info "Installing $THEME_NAME for Sublime Merge"

    cd "$DIR" || echo_fail "Failed to access Sublime Merge directory"

    # Clone the theme repository
    if git clone "$THEME_REPO" "$THEME_NAME"; then
        echo_success "$THEME_NAME installed successfully"
    else
        echo_warn "Failed to clone theme - check SSH access to GitHub"
    fi

else
    echo_info "$THEME_NAME already installed - updating to latest version"
    cd "$DIR/$THEME_NAME" || echo_fail "Failed to access theme directory"

    if git pull; then
        echo_success "$THEME_NAME updated successfully"
    else
        echo_warn "Failed to update theme - check internet connection"
    fi
fi

################################################################################
# ⚙️ PREFERENCES CONFIGURATION
################################################################################

echo_info "Configuring Sublime Merge preferences"

# Merge preferences from main config and profile-specific config
MERGED_PREFS=$(yq eval '.preferences' "$CONFIG_YAML" -o json)
if [[ -f "$PROFILE_CONFIG_YAML" ]]; then
    echo_info "Merging profile-specific Sublime Merge config for: $OS_PROFILE"
    PROFILE_PREFS=$(yq eval '.preferences' "$PROFILE_CONFIG_YAML" -o json 2>/dev/null || echo '{}')
    MERGED_PREFS=$(echo "$MERGED_PREFS $PROFILE_PREFS" | jq -s '.[0] * .[1]')
fi

# Add theme settings to preferences
FULL_PREFS=$(echo "$MERGED_PREFS" | jq --arg theme "$SUBLIME_THEME" --arg scheme "$COLOR_SCHEME" '. + {theme: $theme, color_scheme: $scheme}')

# Write preferences to file
echo "$FULL_PREFS" | jq . > "$DIR/User/Preferences.sublime-settings"

echo_success "Sublime Merge preferences configured"

echo_space
echo_task_done "Sublime Merge configuration completed"
echo_success "Beautiful Git client interface is ready! 🎨"
