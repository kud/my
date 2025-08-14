#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🧪 ANTIDOTE ZSH PLUGIN MANAGER                                             #
#   -----------------------------                                              #
#   Updates and manages zsh plugins using the antidote plugin manager.        #
#   Keeps all shell extensions and enhancements up to date.                   #
#                                                                              #
################################################################################

# Source required utilities
source $MY/core/utils/ui-kit.zsh
source $MY/core/utils/helper.zsh

source ~/.zshrc

################################################################################
# 🔄 PLUGIN UPDATE PROCESS
################################################################################

# Generate plugins.txt from main config only
if command -v yq >/dev/null 2>&1; then
    
    # Remove existing file to avoid conflicts
    rm -f "$MY/shell/plugins.txt"
    
    # Generate from main config only (plugins should be consistent across profiles)
    yq eval '.plugins[]?' "$MY/config/packages/antidote.yml" 2>/dev/null > "$MY/shell/plugins.txt"
    
fi

# Check if antidote is available
if command -v antidote >/dev/null 2>&1; then
    antidote update
else
    return 1
fi

