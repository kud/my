#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   📦 GIT SUBMODULES MANAGER                                                  #
#   -----------------------                                                    #
#   Manages external Git repositories as submodules including git-diff-image  #
#   and themes. Handles both installation and updates automatically.          #
#                                                                              #
################################################################################


mkdir -p "$HOME/my/modules"

SUBMODULES_CONFIG="$MY/config/system/submodules.yml"

if [[ ! -f "$SUBMODULES_CONFIG" ]]; then
    exit 1
fi

process_submodule() {
    local name="$1"
    local url="$2"
    local description="$3"
    local module_path="$HOME/my/modules/$name"

    if [[ -d "$module_path" ]]; then
        ui_subsection "$name"
        git --git-dir="$module_path/.git" --work-tree="$module_path/" pull
    else
        ui_subsection "$name"
        ui_info_simple "Installing from: $url"
        git clone --recursive "$url" "$module_path"
    fi
    echo
}

# Source required utilities
source $MY/core/utils/helper.zsh
source $MY/core/utils/ui-kit.zsh

# Check if yq is available
ensure_command_available "yq" "Install with: brew install yq"

# Parse YAML and process each submodule using yq
submodule_names=$(yq eval 'keys | .[]' "$SUBMODULES_CONFIG")

while IFS= read -r name; do
    if [[ -n "$name" ]]; then
        url=$(yq eval ".[\"$name\"].url" "$SUBMODULES_CONFIG")
        description=$(yq eval ".[\"$name\"].description" "$SUBMODULES_CONFIG")
        
        if [[ -n "$url" && -n "$description" ]]; then
            process_submodule "$name" "$url" "$description"
        fi
    fi
done <<< "$submodule_names"

