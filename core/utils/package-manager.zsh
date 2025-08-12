#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   📦 PACKAGE MANAGER UTILITIES                                               #
#   ---------------------------                                               #
#   Centralized package management functions for DRY installation across      #
#   core and profile-specific configurations.                                 #
#                                                                              #
################################################################################

source $MY/core/utils/helper.zsh

################################################################################
# 🔧 PACKAGE INSTALLATION UTILITIES
################################################################################

# Load and merge YAML package configurations from multiple sources
load_package_configuration() {
    local config_type="$1"  # e.g., "brew", "mas", "npm"
    local yaml_files=("${@:2}")  # Array of YAML file paths

    local merged_config=""

    for yaml_file in "${yaml_files[@]}"; do
        if [[ -f "$yaml_file" ]]; then
            echo_info "Loading $config_type packages from $(basename "$yaml_file")"
            local config=$(yq eval ".$config_type" "$yaml_file" 2>/dev/null)
            if [[ "$config" != "null" && -n "$config" ]]; then
                merged_config+="$config"$'\n'
            fi
        fi
    done

    echo "$merged_config"
}

# Install packages from YAML configuration with proper error handling
install_packages_from_yaml() {
    local package_type="$1"  # "formulae", "casks", "packages"
    local yaml_config="$2"
    local install_function="$3"  # Function to call for installation

    if [[ -z "$yaml_config" ]]; then
        return 0
    fi

    echo_info "Installing $package_type packages"

    local packages
    case "$package_type" in
        "formulae"|"casks")
            packages=$(echo "$yaml_config" | yq eval ".brew.$package_type[]?" - 2>/dev/null)
            ;;
        "packages")
            packages=$(echo "$yaml_config" | yq eval ".mas.packages[].name" - 2>/dev/null)
            ;;
        *)
            echo_warn "Unknown package type: $package_type"
            return 1
            ;;
    esac

    if [[ -n "$packages" ]]; then
        while IFS= read -r package; do
            if [[ -n "$package" ]]; then
                $install_function "$package"
            fi
        done <<< "$packages"
    fi
}

# Execute post-installation commands from YAML configuration
execute_post_install_commands() {
    local yaml_config="$1"
    local service_type="$2"  # "brew", "mas", etc.

    local post_install_commands=$(echo "$yaml_config" | yq eval ".$service_type.post_install[]?" - 2>/dev/null)

    if [[ -n "$post_install_commands" ]]; then
        echo_info "Executing post-installation commands for $service_type"
        while IFS= read -r command; do
            if [[ -n "$command" ]]; then
                echo_info "Running: $command"
                eval "$command"
            fi
        done <<< "$post_install_commands"
    fi
}

# Add repository taps from YAML configuration
add_package_repositories() {
    local yaml_config="$1"
    local repo_function="$2"  # Function to call for adding repos

    local taps=$(echo "$yaml_config" | yq eval '.brew.taps[]?' - 2>/dev/null)

    if [[ -n "$taps" ]]; then
        echo_info "Adding package repositories"
        while IFS= read -r tap; do
            if [[ -n "$tap" ]]; then
                $repo_function "$tap"
            fi
        done <<< "$taps"
    fi
}

# Collect all package configurations from core and profile sources
collect_all_package_configs() {
    local config_type="$1"  # "brew", "mas", "npm", etc.

    local config_files=(
        "$MY/core/packages.yml"
        "$MY/profiles/$OS_PROFILE/core/packages.yml"
    )

    load_package_configuration "$config_type" "${config_files[@]}"
}

# Install all packages of a specific type from all sources
install_all_packages_of_type() {
    local package_manager="$1"  # "brew", "mas", "npm"
    local package_type="$2"     # "formulae", "casks", "packages"
    local install_function="$3" # Installation function
    local repo_function="$4"    # Repository function (optional)

    local config=$(collect_all_package_configs "$package_manager")

    # Add repositories if function provided
    if [[ -n "$repo_function" ]]; then
        add_package_repositories "$config" "$repo_function"
    fi

    # Install packages
    install_packages_from_yaml "$package_type" "$config" "$install_function"

    # Execute post-install commands
    execute_post_install_commands "$config" "$package_manager"
}

################################################################################
# 🎯 SPECIALIZED INSTALLATION FUNCTIONS
################################################################################

# Install all Homebrew packages (formulae, casks, taps)
install_all_homebrew_packages() {
    echo_task_start "Installing Homebrew packages from all sources"

    # Install formulae
    install_all_packages_of_type "brew" "formulae" "brewinstall" "brewtap"

    # Install casks
    install_all_packages_of_type "brew" "casks" "brewcaskinstall"

    echo_task_done "Homebrew packages installation"
}

# Install all Mac App Store packages
install_all_mas_packages() {
    echo_task_start "Installing Mac App Store packages from all sources"

    install_all_packages_of_type "mas" "packages" "masinstall"

    echo_task_done "Mac App Store packages installation"
}

# Install all Node.js packages
install_all_npm_packages() {
    echo_task_start "Installing npm packages from all sources"

    install_all_packages_of_type "npm" "packages" "npminstall"

    echo_task_done "npm packages installation"
}

# Install all Python packages
install_all_pip_packages() {
    echo_task_start "Installing pip packages from all sources"

    install_all_packages_of_type "pip" "packages" "pipinstall"

    echo_task_done "pip packages installation"
}

# Install all Ruby gems
install_all_gem_packages() {
    echo_task_start "Installing gem packages from all sources"

    install_all_packages_of_type "gem" "packages" "geminstall"

    echo_task_done "gem packages installation"
}
