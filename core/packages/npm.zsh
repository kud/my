#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   📦 NODE.JS PACKAGE MANAGER                                                 #
#   -------------------------                                                  #
#   Manages global npm packages for development tools and CLI utilities.      #
#   Installs essential Node.js tools for modern web development workflow.     #
#                                                                              #
################################################################################

# Source required utilities
source $MY/core/utils/helper.zsh


# Check if Node.js and npm are available
if ! command -v npm >/dev/null 2>&1; then
    return 1
fi

# Check if yq is available for YAML parsing
if ! command -v yq >/dev/null 2>&1; then
    brew install yq
fi

PACKAGES_FILE="$MY/config/packages/npm.yml"
PROFILE_PACKAGES_FILE="$MY/profiles/$OS_PROFILE/config/packages/npm.yml"

################################################################################
# 🔄 NPM SYSTEM UPDATE
################################################################################

npm update -g

collect_npm_packages_from_yaml() {
    local yaml_file="$1"
    local source_desc="$2"

    if [[ ! -f "$yaml_file" ]]; then
        return 0
    fi

    local packages=$(yq eval '.packages[]?' "$yaml_file" 2>/dev/null)
    if [[ -n "$packages" ]]; then
        while IFS= read -r package; do
            [[ -n "$package" ]] && npm_install "$package"
        done <<< "$packages"
    fi
}

run_npm_post_install_from_yaml() {
    local yaml_file="$1"
    local source_desc="$2"

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

# Collect all npm packages (base + profile)
collect_npm_packages_from_yaml "$PACKAGES_FILE" "base configuration"
collect_npm_packages_from_yaml "$PROFILE_PACKAGES_FILE" "$OS_PROFILE profile"

# Execute batch npm installation
npm_install_run

run_npm_post_install_from_yaml "$PACKAGES_FILE" "base configuration"
run_npm_post_install_from_yaml "$PROFILE_PACKAGES_FILE" "$OS_PROFILE profile"

