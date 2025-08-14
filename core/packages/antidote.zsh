#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🧪 ANTIDOTE ZSH PLUGIN MANAGER                                             #
#   -----------------------------                                              #
#   Updates and manages zsh plugins using the antidote plugin manager.        #
#   Keeps all shell extensions and enhancements up to date.                   #
#                                                                              #
################################################################################

source ~/.zshrc
source "$MY/core/utils/helper.zsh"

echo_task_start "Updating zsh plugins via antidote"

################################################################################
# 🔄 PLUGIN UPDATE PROCESS
################################################################################

# Generate plugins.txt from main config only
if command -v yq >/dev/null 2>&1; then
    echo_info "Generating plugins.txt from packages.yml"
    
    # Remove existing file to avoid conflicts
    rm -f "$MY/shell/plugins.txt"
    
    # Generate from main config only (plugins should be consistent across profiles)
    yq eval '.plugins[]?' "$MY/config/packages/antidote.yml" 2>/dev/null > "$MY/shell/plugins.txt"
    
    echo_success "Generated plugins.txt from packages.yml"
fi

# Check if antidote is available
if command -v antidote >/dev/null 2>&1; then
    echo_info "Updating all zsh plugins and dependencies"

    if antidote update; then
        echo_space
        echo_success "Zsh plugins updated successfully"
    else
        echo_space
        echo_warn "Some plugins may have failed to update"
    fi
else
    echo_fail "antidote plugin manager not found"
    return 1
fi

echo_space
echo_task_done "Zsh plugin update completed"
echo_success "Shell is now running the latest plugin versions! ⚡"
