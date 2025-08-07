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


################################################################################
# 🔍 NEOVIM INSTALLATION CHECK
################################################################################

# Check if Neovim is installed
if ! command -v nvim >/dev/null 2>&1; then
    return 1
fi

################################################################################
# 📂 CONFIGURATION DIRECTORY SETUP
################################################################################

# Check if the config directory exists
if [[ ! -d "$HOME/.config/nvim" ]]; then
    mkdir -p "$HOME/.config/nvim"
fi

# Clean up old vim-plug installation if it exists
if [[ -d "$HOME/.config/nvim/autoload" ]]; then
    rm -rf "$HOME/.config/nvim/autoload"
    rm -rf "$HOME/.config/nvim/plugged"
fi

