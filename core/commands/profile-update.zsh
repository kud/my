#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   👤 PROFILE-SPECIFIC PACKAGE INSTALLER                                      #
#   ------------------------------------                                       #
#   Installs only profile-specific packages without updating main packages.   #
#                                                                              #
################################################################################

# Source required utilities
export MY=${MY:-$HOME/my}
source $MY/core/utils/ui-kit.zsh
source $MY/core/utils/helper.zsh

# Check if profile is set
if [[ -z "$OS_PROFILE" ]]; then
    ui_error_msg "No profile set (OS_PROFILE is empty)"
    ui_info_simple "Set your profile in ~/.config/zsh/local.zsh"
    exit 1
fi

# Display profile info
ui_section "👤 Installing $OS_PROFILE profile packages"
ui_info_simple "Profile: $OS_PROFILE"
ui_info_simple "Config: $PROFILE_PACKAGES_CONFIG_DIR"
ui_spacer

# Check if profile has package configs
if [[ ! -d "$PROFILE_PACKAGES_CONFIG_DIR" ]]; then
    ui_warning_msg "No package configs found for $OS_PROFILE profile"
    ui_info_simple "Expected path: $PROFILE_PACKAGES_CONFIG_DIR"
    exit 0
fi

# Find available package configs
profile_configs=($(find "$PROFILE_PACKAGES_CONFIG_DIR" -name "*.yml" -type f))

if [[ ${#profile_configs[@]} -eq 0 ]]; then
    ui_info_msg "No package configs found for $OS_PROFILE profile"
    exit 0
fi

# Install packages for each config type
for config_file in "${profile_configs[@]}"; do
    package_type=$(basename "$config_file" .yml)

    ui_subtitle "Installing $package_type packages"

    case "$package_type" in
        "brew")
            source $MY/core/utils/packages.zsh

            # Only process profile config (not main)
            profile_config="$config_file"

            # Process taps
            local taps=$(yq eval '.taps[]?' "$profile_config" 2>/dev/null)
            if [[ -n "$taps" ]]; then
                while IFS= read -r tap; do
                    [[ -n "$tap" ]] && brew tap "$tap" 2>/dev/null || true
                done <<< "$taps"
            fi

            # Process formulae
            local formulae=$(yq eval '.packages.formulae[]?' "$profile_config" 2>/dev/null)
            if [[ -n "$formulae" ]]; then
                while IFS= read -r formula; do
                    if [[ -n "$formula" ]]; then
                        if ! brew list "$formula" &>/dev/null; then
                            ui_info_simple "Installing $formula"
                            brew install "$formula"
                        else
                            ui_muted "  ✓ $formula already installed"
                        fi
                    fi
                done <<< "$formulae"
            fi

            # Process casks
            local casks=$(yq eval '.packages.casks[]?' "$profile_config" 2>/dev/null)
            if [[ -n "$casks" ]]; then
                while IFS= read -r cask; do
                    if [[ -n "$cask" ]]; then
                        if ! brew list --cask "$cask" &>/dev/null; then
                            ui_info_simple "Installing $cask"
                            brew install --cask "$cask"
                        else
                            ui_muted "  ✓ $cask already installed"
                        fi
                    fi
                done <<< "$casks"
            fi
            ;;

        "uv")
            # Process uv tools
            local tools=$(yq eval '.packages.tool[]?' "$config_file" 2>/dev/null)
            if [[ -n "$tools" ]]; then
                while IFS= read -r tool; do
                    if [[ -n "$tool" ]]; then
                        if ! uv tool list | grep -q "^$tool "; then
                            ui_info_simple "Installing $tool"
                            uv tool install "$tool"
                        else
                            ui_muted "  ✓ $tool already installed"
                        fi
                    fi
                done <<< "$tools"
            fi

            # Process pip packages
            local pip_packages=$(yq eval '.packages.pip[]?' "$config_file" 2>/dev/null)
            if [[ -n "$pip_packages" ]]; then
                while IFS= read -r package; do
                    if [[ -n "$package" ]]; then
                        ui_info_simple "Installing $package"
                        uv pip install "$package"
                    fi
                done <<< "$pip_packages"
            fi
            ;;

        "npm")
            source $MY/core/packages/npm.zsh
            # Only process profile config
            collect_packages_from_yaml "$config_file" "npm_install"
            npm_install_run
            ;;

        "gem")
            local gems=$(yq eval '.packages[]?' "$config_file" 2>/dev/null)
            if [[ -n "$gems" ]]; then
                while IFS= read -r gem; do
                    if [[ -n "$gem" ]]; then
                        if ! gem list -i "^${gem}$" &>/dev/null; then
                            ui_info_simple "Installing $gem"
                            gem install "$gem"
                        else
                            ui_muted "  ✓ $gem already installed"
                        fi
                    fi
                done <<< "$gems"
            fi
            ;;

        *)
            ui_warning_simple "Unknown package type: $package_type (skipping)"
            ;;
    esac

    ui_success_simple "$package_type packages installed"
    ui_spacer
done

ui_success_msg "$OS_PROFILE profile packages installed"
