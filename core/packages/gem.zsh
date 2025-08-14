#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   💎 RUBY GEM MANAGER                                                        #
#   ------------------                                                         #
#   Manages Ruby gems installation and updates for development tools.         #
#   Installs essential gems for modern Ruby development workflow.              #
#                                                                              #
################################################################################

# Source required utilities
source $MY/core/utils/helper.zsh


# Check if Ruby and gem are available
if ! command -v gem >/dev/null 2>&1; then
    return 1
fi

# Check if yq is available for YAML parsing
if ! command -v yq >/dev/null 2>&1; then
    brew install yq
fi

PACKAGES_FILE="$MY/config/packages/gem.yml"
PROFILE_PACKAGES_FILE="$MY/profiles/$OS_PROFILE/config/packages/gem.yml"

collect_gem_packages_from_yaml() {
    local yaml_file="$1"
    local source_desc="$2"

    if [[ ! -f "$yaml_file" ]]; then
        return 0
    fi

    local packages=$(yq eval '.packages[]?' "$yaml_file" 2>/dev/null)
    if [[ -n "$packages" ]]; then
        while IFS= read -r package; do
            [[ -n "$package" ]] && gem_install "$package"
        done <<< "$packages"
    fi
}

run_gem_post_install_from_yaml() {
    local yaml_file="$1"
    local source_desc="$2"

    if [[ ! -f "$yaml_file" ]]; then
        return 0
    fi

    local post_install=$(yq eval '.post_install[]?' "$yaml_file" 2>/dev/null)
    if [[ -n "$post_install" ]]; then
        while IFS= read -r command; do
            if [[ -n "$command" ]]; then
                eval "$command" >/dev/null 2>&1
            fi
        done <<< "$post_install"
    fi
}

# Update gem system first
gem update --system >/dev/null 2>&1
gem update >/dev/null 2>&1

# Collect all gem packages (base + profile)
collect_gem_packages_from_yaml "$PACKAGES_FILE" "base configuration"
collect_gem_packages_from_yaml "$PROFILE_PACKAGES_FILE" "$OS_PROFILE profile"

run_gem_post_install_from_yaml "$PACKAGES_FILE" "base configuration"
run_gem_post_install_from_yaml "$PROFILE_PACKAGES_FILE" "$OS_PROFILE profile"

