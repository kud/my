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

# Ensure modules directory exists
mkdir -p "$HOME/my/modules"

################################################################################
# 🖼️ GIT-DIFF-IMAGE MODULE
################################################################################

echo_info "Processing git-diff-image submodule"

if [[ -d "$HOME/my/modules/git-diff-image" ]]; then
    echo_info "Updating existing git-diff-image submodule"
    if git --git-dir="$HOME/my/modules/git-diff-image/.git" --work-tree="$HOME/my/modules/git-diff-image/" pull; then
        echo_success "git-diff-image updated successfully"
    else
        echo_warn "Failed to update git-diff-image"
    fi
else
    echo_info "Installing git-diff-image submodule"
    if git clone --recursive https://github.com/ewanmellor/git-diff-image.git "$HOME/my/modules/git-diff-image"; then
        echo_success "git-diff-image installed successfully"
    else
        echo_warn "Failed to install git-diff-image"
    fi
fi

################################################################################
# 🎨 THEMES MODULE
################################################################################

echo_space
echo_info "Processing themes submodule"

if [[ -d "$HOME/my/modules/themes" ]]; then
    echo_info "Updating existing themes submodule"
    if git --git-dir="$HOME/my/modules/themes/.git" --work-tree="$HOME/my/modules/themes/" pull; then
        echo_success "themes updated successfully"
    else
        echo_warn "Failed to update themes"
    fi
else
    echo_info "Installing themes submodule"
    if git clone --recursive https://github.com/kud/themes.git "$HOME/my/modules/themes"; then
        echo_success "themes installed successfully"
    else
        echo_warn "Failed to install themes"
    fi
fi

echo_space
echo_task_done "Git submodules management completed"
echo_success "All external modules are up to date! 📦"
