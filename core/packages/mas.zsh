#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🍎 MAC APP STORE MANAGER                                                   #
#   -------------------------                                                  #
#   Installs applications from the Mac App Store using mas command.           #
#   Handles profile-specific app installations and updates.                   #
#                                                                              #
################################################################################

source $MY/core/utils/helper.zsh

echo_task_start "Setting up Mac App Store applications"

# Check if mas is available
if ! command -v mas >/dev/null 2>&1; then
    echo_fail "mas not found. Please install via Homebrew first."
    return 1
fi

# Check if yq is available for YAML parsing
if ! command -v yq >/dev/null 2>&1; then
    echo_info "Installing yq for YAML parsing"
    brew install yq
fi

PACKAGES_FILE="$MY/core/packages.yml"
PROFILE_PACKAGES_FILE="$MY/profiles/$OS_PROFILE/core/packages.yml"

collect_mas_packages_from_yaml() {
    local yaml_file="$1"
    local source_desc="$2"
    
    if [[ ! -f "$yaml_file" ]]; then
        return 0
    fi
    
    # Get packages as JSON to handle the id/name structure
    local packages=$(yq eval '.mas.packages[]?' "$yaml_file" 2>/dev/null)
    if [[ -n "$packages" ]]; then
        while IFS= read -r package_line; do
            if [[ -n "$package_line" ]]; then
                local id=$(echo "$package_line" | yq eval '.id' -)
                local name=$(echo "$package_line" | yq eval '.name' -)
                
                if [[ "$id" != "null" && "$name" != "null" ]]; then
                    echo_info "Installing $name (ID: $id)"
                    mas install "$id"
                fi
            fi
        done <<< "$packages"
    fi
}

# Install packages from base and profile configurations
collect_mas_packages_from_yaml "$PACKAGES_FILE" "base configuration"
collect_mas_packages_from_yaml "$PROFILE_PACKAGES_FILE" "$OS_PROFILE profile"

echo_space
echo_info "Updating Mac App Store applications"
mas upgrade

echo_space
echo_task_done "Mac App Store setup completed"
