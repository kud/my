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

# Process packages from multiple YAML files
process_packages_from_files() {
    local package_type="$1"  # "formulae", "casks", "packages"
    local install_function="$2"  # Function to call for installation
    shift 2  # Remove first two arguments, remaining are yaml files
    local yaml_files=("$@")

    if [[ ${#yaml_files[@]} -eq 0 ]]; then
        return 0
    fi

    echo_info "Installing $package_type packages"

    for yaml_file in "${yaml_files[@]}"; do
        if [[ -f "$yaml_file" ]]; then
            echo_info "Processing $(basename "$yaml_file")"

            local packages
            case "$package_type" in
                "formulae")
                    packages=$(yq eval ".brew.formulae[]?" "$yaml_file" 2>/dev/null)
                    ;;
                "casks")
                    packages=$(yq eval ".brew.casks[]?" "$yaml_file" 2>/dev/null)
                    ;;
                "packages")
                    packages=$(yq eval ".mas.packages[].name" "$yaml_file" 2>/dev/null)
                    ;;
                *)
                    echo_warn "Unknown package type: $package_type"
                    continue
                    ;;
            esac

            if [[ -n "$packages" ]]; then
                while IFS= read -r package; do
                    if [[ -n "$package" ]]; then
                        $install_function "$package"
                    fi
                done <<< "$packages"
            fi
        fi
    done
}

# Execute post-installation commands from multiple YAML files
execute_post_install_from_files() {
    local service_type="$1"  # "brew", "mas", etc.
    shift  # Remove first argument, remaining are yaml files
    local yaml_files=("$@")

    for yaml_file in "${yaml_files[@]}"; do
        if [[ -f "$yaml_file" ]]; then
            local post_install_commands=$(yq eval ".$service_type.post_install[]?" "$yaml_file" 2>/dev/null)

            if [[ -n "$post_install_commands" ]]; then
                echo_info "Executing post-installation commands from $(basename "$yaml_file")"
                while IFS= read -r command; do
                    if [[ -n "$command" ]]; then
                        echo_info "Running: $command"
                        eval "$command"
                    fi
                done <<< "$post_install_commands"
            fi
        fi
    done
}

# Add repository taps from multiple YAML files
add_repositories_from_files() {
    local repo_function="$1"  # Function to call for adding repos
    shift  # Remove first argument, remaining are yaml files
    local yaml_files=("$@")

    for yaml_file in "${yaml_files[@]}"; do
        if [[ -f "$yaml_file" ]]; then
            local taps=$(yq eval '.brew.taps[]?' "$yaml_file" 2>/dev/null)

            if [[ -n "$taps" ]]; then
                echo_info "Adding repositories from $(basename "$yaml_file")"
                while IFS= read -r tap; do
                    if [[ -n "$tap" ]]; then
                        $repo_function "$tap"
                    fi
                done <<< "$taps"
            fi
        fi
    done
}

# Get all package configuration files
get_all_package_files() {
    local config_files=(
        "$MY/config/packages.yml"
        "$MY/profiles/$OS_PROFILE/config/packages.yml"
    )

    # Only return files that exist
    local existing_files=()
    for file in "${config_files[@]}"; do
        [[ -f "$file" ]] && existing_files+=("$file")
    done

    printf '%s\n' "${existing_files[@]}"
}

# Install all packages of a specific type from all sources
install_all_packages_of_type() {
    local package_manager="$1"  # "brew", "mas", "npm"
    local package_type="$2"     # "formulae", "casks", "packages"
    local install_function="$3" # Installation function
    local repo_function="$4"    # Repository function (optional)

    local config_files=($(get_all_package_files))

    if [[ ${#config_files[@]} -eq 0 ]]; then
        echo_info "No package configuration files found"
        return 0
    fi

    # Add repositories if function provided
    if [[ -n "$repo_function" ]]; then
        add_repositories_from_files "$repo_function" "${config_files[@]}"
    fi

    # Install packages
    process_packages_from_files "$package_type" "$install_function" "${config_files[@]}"

    # Execute post-install commands
    execute_post_install_from_files "$package_manager" "${config_files[@]}"
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
