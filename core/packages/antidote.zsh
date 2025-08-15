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

################################################################################
# 🔄 PLUGIN UPDATE PROCESS
################################################################################

# Source required utilities
source $MY/core/utils/helper.zsh

# Generate plugins.txt from main config only
if ensure_command_available "yq" "" "false"; then
    
    # Remove existing file to avoid conflicts
    rm -f "$MY/shell/plugins.txt"
    
    # Generate from main config only (plugins should be consistent across profiles)
    yq eval '.plugins[]?' "$PACKAGES_CONFIG_DIR/antidote.yml" 2>/dev/null > "$MY/shell/plugins.txt"
    
fi

# Check if antidote is available
if ensure_command_available "antidote" "" "false"; then
    antidote update
else
    return 1
fi

