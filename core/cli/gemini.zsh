#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   GEMINI CLI CONFIGURATOR                                                    #
#   -----------------------                                                    #
#   Configures Gemini CLI with extensions from YAML config.                    #
#                                                                              #
################################################################################

source $MY/core/utils/helper.zsh
source $MY/core/utils/ui-kit.zsh

# Handle show-config subcommand
if [[ "$1" == "show-config" ]]; then
    ui_subtitle "Gemini Config:"
    config_dir="$HOME/.gemini"

    if [[ -d "$config_dir" ]]; then
        ui_info_simple "$config_dir/settings.json" 0
        ui_info_simple "Extensions:" 0
        gemini extensions list 2>/dev/null | tail -n +2
    else
        ui_warning_simple "$config_dir (not found)" 0
    fi
    ui_spacer
    return 0
fi

ui_subsection "Configuring Gemini CLI"

# Check if Gemini CLI is installed
if ! command -v gemini >/dev/null 2>&1; then
    ui_warning_simple "Gemini CLI not found in PATH (npm install -g @google/gemini-cli)" 1
    return 0
fi

# Get current profile
PROFILE="${OS_PROFILE:-default}"

# Define config file paths
COMMON_CONFIG="$MY/config/cli/gemini.yml"
PROFILE_CONFIG="$MY/profiles/$PROFILE/config/cli/gemini.yml"

# Cache installed extensions list once
INSTALLED_EXTENSIONS=$(gemini extensions list 2>/dev/null)

# Function to install an extension if not already installed
install_extension() {
    local source="$1"
    local name=$(basename "$source" .git)

    # Check if already installed
    if echo "$INSTALLED_EXTENSIONS" | grep -q "$name"; then
        ui_info_simple "Extension '$name' already installed" 0
        return 0
    fi

    ui_info_simple "Installing extension: $name" 0
    local output
    output=$(gemini extensions install "$source" 2>&1)
    if [[ $? -eq 0 ]]; then
        ui_success_simple "Installed extension: $name" 0
        return 0
    else
        ui_error_msg "Failed to install extension: $name" 0
        if [[ -n "$output" ]]; then
            ui_error_msg "  Gemini CLI: $output" 0
        fi
        return 1
    fi
}

# Process extensions from config files
for config_file in "$COMMON_CONFIG" "$PROFILE_CONFIG"; do
    if [[ -f "$config_file" ]]; then
        local extensions=($(yq -r '.extensions[]' "$config_file" 2>/dev/null))
        for ext in "${extensions[@]}"; do
            [[ -n "$ext" && "$ext" != "null" ]] && install_extension "$ext"
        done
    fi
done

ui_success_simple "Gemini CLI configuration complete" 1
