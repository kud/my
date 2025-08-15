#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   📦 PACKAGE MANAGER UTILITIES                                               #
#   ----------------------------                                               #
#   Shared utilities for all package managers to reduce code duplication.     #
#   Provides common YAML processing and package collection functions.         #
#                                                                              #
################################################################################

# Ensure yq is installed for YAML parsing
ensure_yq_installed() {
    if ! command -v yq >/dev/null 2>&1; then
        if command -v brew >/dev/null 2>&1; then
            brew install yq
        else
            echo "yq is required but not installed. Please install yq first." >&2
            exit 1
        fi
    fi
}

# Get profile-specific config path
get_profile_config_path() {
    local package_type="$1"  # e.g., "npm", "gem", "pip"
    echo "$PROFILE_PACKAGES_CONFIG_DIR/${package_type}.yml"
}

# Get main config path
get_main_config_path() {
    local package_type="$1"  # e.g., "npm", "gem", "pip"
    echo "$PACKAGES_CONFIG_DIR/${package_type}.yml"
}

# Generic function to collect packages from YAML
collect_packages_from_yaml() {
    local yaml_file="$1"
    local install_function="$2"  # Function to call for each package
    
    if [[ ! -f "$yaml_file" ]]; then
        return 0
    fi
    
    local packages=$(yq eval '.packages[]?' "$yaml_file" 2>/dev/null)
    if [[ -n "$packages" ]]; then
        while IFS= read -r package; do
            [[ -n "$package" ]] && $install_function "$package"
        done <<< "$packages"
    fi
}

# Generic function to run post-install commands from YAML
run_pre_install_from_yaml() {
    local yaml_file="$1"
    
    if [[ ! -f "$yaml_file" ]]; then
        return 0
    fi
    
    local pre_install=$(yq eval '.pre_install[]?' "$yaml_file" 2>/dev/null)
    if [[ -n "$pre_install" ]]; then
        while IFS= read -r command; do
            if [[ -n "$command" ]]; then
                eval "$command"
            fi
        done <<< "$pre_install"
    fi
}

run_post_install_from_yaml() {
    local yaml_file="$1"
    
    if [[ ! -f "$yaml_file" ]]; then
        return 0
    fi
    
    local post_install=$(yq eval '.post_install[]?' "$yaml_file" 2>/dev/null)
    if [[ -n "$post_install" ]]; then
        while IFS= read -r command; do
            if [[ -n "$command" ]]; then
                eval "$command"
            fi
        done <<< "$post_install"
    fi
}

# Process both main and profile configs for a package manager
process_package_configs() {
    local package_type="$1"      # e.g., "npm", "gem", "pip"
    local install_function="$2"  # Function to call for each package
    local batch_run_function="$3" # Optional batch run function
    
    local main_config=$(get_main_config_path "$package_type")
    local profile_config=$(get_profile_config_path "$package_type")
    
    # Run pre-install commands first
    run_pre_install_from_yaml "$main_config"
    run_pre_install_from_yaml "$profile_config"
    
    # Collect packages from both configs
    collect_packages_from_yaml "$main_config" "$install_function"
    collect_packages_from_yaml "$profile_config" "$install_function"
    
    # Run batch installation if function provided
    if [[ -n "$batch_run_function" ]]; then
        $batch_run_function
    fi
    
    # Run post-install commands
    run_post_install_from_yaml "$main_config"
    run_post_install_from_yaml "$profile_config"
}

# Merge and deduplicate items from main and profile configs
merge_yaml_items() {
    local main_config="$1"
    local profile_config="$2"
    local yaml_path="$3"  # e.g., '.packages[]', '.taps[]'
    
    local all_items=""
    [[ -f "$main_config" ]] && all_items+=$(yq eval "${yaml_path}?" "$main_config" 2>/dev/null)
    [[ -f "$profile_config" ]] && all_items+=$'\n'$(yq eval "${yaml_path}?" "$profile_config" 2>/dev/null)
    
    # Return unique sorted items
    if [[ -n "$all_items" ]]; then
        echo "$all_items" | sort -u | grep -v '^$'
    fi
}

# Generic merge-and-install function for package managers
merge_and_install_packages() {
    local package_type="$1"           # e.g., "brew", "mas"
    shift                              # Remove package_type from arguments
    local install_sections=("$@")     # All remaining arguments as array
    
    local main_config=$(get_main_config_path "$package_type")
    local profile_config=$(get_profile_config_path "$package_type")
    
    # Process each install section
    for section_config in "${install_sections[@]}"; do
        local yaml_path=$(echo "$section_config" | cut -d: -f1)
        local install_func=$(echo "$section_config" | cut -d: -f2)
        local batch_func=$(echo "$section_config" | cut -d: -f3)
        
        local items=$(merge_yaml_items "$main_config" "$profile_config" "$yaml_path")
        if [[ -n "$items" ]]; then
            echo "$items" | while IFS= read -r item; do
                [[ -n "$item" ]] && $install_func "$item"
            done
            
            # Run batch function if specified for this section
            if [[ -n "$batch_func" && "$batch_func" != "-" ]]; then
                $batch_func
            fi
        fi
    done
    
    # Run post-install commands
    run_post_install_from_yaml "$main_config"
    run_post_install_from_yaml "$profile_config"
}