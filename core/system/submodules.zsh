#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   📦 GIT SUBMODULES MANAGER                                                  #
#   -----------------------                                                    #
#   Manages external Git repositories as submodules including git-diff-image  #
#   and themes. Handles both installation and updates automatically.          #
#                                                                              #
################################################################################

source $MY/core/utils/helper.zsh

echo_task_start "Managing Git submodules"

mkdir -p "$HOME/my/modules"

SUBMODULES_CONFIG="$MY/config/system/submodules.yml"

if [[ ! -f "$SUBMODULES_CONFIG" ]]; then
    echo_error "Submodules configuration file not found: $SUBMODULES_CONFIG"
    exit 1
fi

process_submodule() {
    local name="$1"
    local url="$2"
    local description="$3"
    local module_path="$HOME/my/modules/$name"

    echo_info "Processing $name submodule"
    echo_info "Description: $description"

    if [[ -d "$module_path" ]]; then
        echo_info "Updating existing $name submodule"
        if git --git-dir="$module_path/.git" --work-tree="$module_path/" pull; then
            echo_success "$name updated successfully"
        else
            echo_warn "Failed to update $name"
        fi
    else
        echo_info "Installing $name submodule"
        if git clone --recursive "$url" "$module_path"; then
            echo_success "$name installed successfully"
        else
            echo_warn "Failed to install $name"
        fi
    fi
    echo_space
}

# Parse YAML and process each submodule
while IFS= read -r line; do
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

    if [[ "$line" =~ ^([^[:space:]]+):[[:space:]]*$ ]]; then
        current_module="${match[1]}"
        url=""
        description=""
    elif [[ "$line" =~ ^[[:space:]]+url:[[:space:]]*(.+)$ ]]; then
        url="${match[1]}"
    elif [[ "$line" =~ ^[[:space:]]+description:[[:space:]]*(.+)$ ]]; then
        description="${match[1]}"

        if [[ -n "$current_module" && -n "$url" && -n "$description" ]]; then
            process_submodule "$current_module" "$url" "$description"
        fi
    fi
done < "$SUBMODULES_CONFIG"

echo_success "All external modules are up to date!"
