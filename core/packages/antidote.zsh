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


################################################################################
# 🔄 PLUGIN UPDATE PROCESS
################################################################################

# Check if antidote is available
if command -v antidote >/dev/null 2>&1; then
    antidote update
else
    return 1
fi

