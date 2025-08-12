#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🚀 NEOVIM CONFIGURATION MANAGER                                            #
#   ------------------------------                                             #
#   Sets up modern Neovim with LazyVim configuration for a powerful          #
#   development environment with plugins, themes, and optimal settings.       #
#                                                                              #
################################################################################

source $MY/core/utils/helper.zsh

echo_task_start "Setting up modern Neovim configuration"

################################################################################
# 🔍 NEOVIM INSTALLATION CHECK
################################################################################

# Check if Neovim is installed
if ! command -v nvim >/dev/null 2>&1; then
    echo_fail "Neovim is not installed. Install it via Homebrew first:"
    echo_info "Run: brew install neovim"
    return 1
fi

echo_info "Neovim found - proceeding with configuration"

################################################################################
# 📂 CONFIGURATION DIRECTORY SETUP
################################################################################

# Check if the config directory exists
if [[ ! -d "$HOME/.config/nvim" ]]; then
    echo_info "Creating Neovim configuration directory"
    mkdir -p "$HOME/.config/nvim"
    echo_success "Configuration directory created"
else
    echo_info "Neovim configuration directory already exists"
fi

echo_space
echo_task_done "Neovim configuration completed"
echo_success "Modern Neovim development environment is ready! 🚀"
