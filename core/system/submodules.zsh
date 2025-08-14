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
        git --git-dir="$module_path/.git" --work-tree="$module_path/" pull
    else
        git clone --recursive "$url" "$module_path"
    fi
}

# Check if yq is available
if ! command -v yq >/dev/null 2>&1; then
    exit 1
fi

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

