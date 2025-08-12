#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   👤 PROFILE CONFIGURATION MANAGER                                           #
#   --------------------------------                                          #
#   Manages profile-specific configurations and provides a unified interface  #
#   for loading and applying profile settings across the environment.         #
#                                                                              #
################################################################################

source $MY/core/utils/helper.zsh

################################################################################
# 🔍 PROFILE DETECTION AND VALIDATION
################################################################################

# Detect and validate the current OS profile
detect_and_validate_profile() {
    if [[ -z "$OS_PROFILE" ]]; then
        echo_warn "OS_PROFILE environment variable not set"
        echo_info "Available profiles:"
        ls -1 "$MY/profiles/" | grep -v "^\." | while read profile; do
            echo "  - $profile"
        done
        echo_fail "Please set OS_PROFILE environment variable"
    fi

    local profile_path="$MY/profiles/$OS_PROFILE"
    if [[ ! -d "$profile_path" ]]; then
        echo_fail "Profile '$OS_PROFILE' not found at $profile_path"
    fi

    echo_info "Using profile: $OS_PROFILE"
    return 0
}

# Check if profile has specific configuration type
profile_has_config() {
    local config_type="$1"  # e.g., "core", "packages", "apps"
    local profile_config_path="$MY/profiles/$OS_PROFILE/$config_type"

    [[ -d "$profile_config_path" ]]
}

# Get profile-specific configuration path
get_profile_config_path() {
    local config_type="$1"
    echo "$MY/profiles/$OS_PROFILE/$config_type"
}

################################################################################
# 📦 PROFILE PACKAGE MANAGEMENT
################################################################################

# Load profile-specific package configuration
load_profile_packages() {
    local package_manager="$1"  # "brew", "mas", "npm", etc.
    local profile_packages_file="$MY/profiles/$OS_PROFILE/core/packages.yml"

    if [[ -f "$profile_packages_file" ]]; then
        echo_info "Loading $package_manager packages for profile: $OS_PROFILE"
        yq eval ".$package_manager" "$profile_packages_file" 2>/dev/null
    else
        echo_info "No profile-specific packages found for $OS_PROFILE"
        echo "null"
    fi
}

# Get all profile-specific package files
get_profile_package_files() {
    local files=()

    # Main profile packages
    local main_packages="$MY/profiles/$OS_PROFILE/core/packages.yml"
    [[ -f "$main_packages" ]] && files+=("$main_packages")

    # Additional profile-specific package files (if any)
    if [[ -d "$MY/profiles/$OS_PROFILE/packages" ]]; then
        while IFS= read -r file; do
            files+=("$file")
        done < <(find "$MY/profiles/$OS_PROFILE/packages" -name "*.yml" -type f)
    fi

    printf '%s\n' "${files[@]}"
}

################################################################################
# 🚀 PROFILE EXECUTION UTILITIES
################################################################################

# Execute profile-specific setup scripts
execute_profile_setup() {
    local setup_type="$1"  # "core", "apps", "system"

    detect_and_validate_profile

    local profile_setup_path="$MY/profiles/$OS_PROFILE/$setup_type"

    if [[ ! -d "$profile_setup_path" ]]; then
        echo_info "No $setup_type setup found for profile $OS_PROFILE"
        return 0
    fi

    echo_task_start "Executing $setup_type setup for profile $OS_PROFILE"

    # Execute all setup scripts in the profile directory
    local script_count=0
    while IFS= read -r script; do
        if [[ -f "$script" && -x "$script" ]]; then
            local script_name=$(basename "$script")
            local script_dir=$(dirname "$script")

            # Skip Firefox from automatic execution - Firefox now uses YAML config in /config/firefox.yml
            if [[ "$script_name" == "firefox.zsh" ]]; then
                echo_info "Skipping $script_name (now uses YAML config: $MY/config/firefox.yml)"
                continue
            fi

            # Skip OS configuration from automatic execution - it should only run manually via £ run os
            if [[ "$script_name" == "main.zsh" && "$script_dir" == *"/os" ]]; then
                echo_info "Skipping $script_name (manual execution only via £ run os)"
                continue
            fi

            echo_info "Running $script_name"
            "$script"
            ((script_count++))
        fi
    done < <(find "$profile_setup_path" -name "*.zsh" -type f | sort)

    if [[ $script_count -eq 0 ]]; then
        echo_info "No executable scripts found in $profile_setup_path"
    else
        echo_task_done "$setup_type setup for profile $OS_PROFILE ($script_count scripts executed)"
    fi
}

# Apply profile-specific configurations
apply_profile_configurations() {
    local config_types=("$@")

    if [[ ${#config_types[@]} -eq 0 ]]; then
        config_types=("core" "apps" "system")
    fi

    detect_and_validate_profile

    echo_task_start "Applying configurations for profile: $OS_PROFILE"

    for config_type in "${config_types[@]}"; do
        if profile_has_config "$config_type"; then
            execute_profile_setup "$config_type"
        else
            echo_info "Skipping $config_type (not configured for $OS_PROFILE)"
        fi
    done

    echo_task_done "Profile configurations applied"
}

################################################################################
# 🔄 PROFILE PACKAGE INTEGRATION
################################################################################

# Merge core and profile package configurations
merge_package_configurations() {
    local package_manager="$1"

    # Core packages
    local core_packages_file="$MY/core/packages.yml"
    local core_config=""
    if [[ -f "$core_packages_file" ]]; then
        core_config=$(yq eval ".$package_manager" "$core_packages_file" 2>/dev/null)
    fi

    # Profile packages
    local profile_config=$(load_profile_packages "$package_manager")

    # Merge configurations (profile takes precedence)
    if [[ "$core_config" != "null" && "$profile_config" != "null" ]]; then
        echo "$core_config" | yq eval ". *= $profile_config" -
    elif [[ "$profile_config" != "null" ]]; then
        echo "$profile_config"
    elif [[ "$core_config" != "null" ]]; then
        echo "$core_config"
    else
        echo "null"
    fi
}

# Install packages using merged core and profile configurations
install_merged_packages() {
    local package_manager="$1"

    echo_task_start "Installing $package_manager packages (core + profile: $OS_PROFILE)"

    local merged_config=$(merge_package_configurations "$package_manager")

    if [[ "$merged_config" != "null" ]]; then
        # Use the unified package manager utilities
        source $MY/core/utils/package-manager.zsh

        case "$package_manager" in
            "brew")
                install_all_homebrew_packages
                ;;
            "mas")
                install_all_mas_packages
                ;;
            "npm")
                install_all_npm_packages
                ;;
            "pip")
                install_all_pip_packages
                ;;
            "gem")
                install_all_gem_packages
                ;;
            *)
                echo_warn "Unknown package manager: $package_manager"
                return 1
                ;;
        esac
    else
        echo_info "No $package_manager packages configured"
    fi

    echo_task_done "$package_manager packages installation"
}
