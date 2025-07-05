################################################################################
#                                                                              #
#   🧪 ANTIDOTE PLUGIN MANAGER INITIALIZATION                                  #
#   ------------------------------------------                                 #
#   Loads and manages Zsh plugins using Antidote.                              #
#   https://getantidote.github.io/antidote/                                    #
#                                                                              #
################################################################################

# Load Antidote
source $(brew --prefix)/share/antidote/antidote.zsh

# Bundle plugins if not already bundled
if [[ ! -f ~/.zsh_plugins.zsh ]]; then
  antidote bundle < ~/.zsh_plugins.txt > ~/.zsh_plugins.zsh
fi

# Source bundled plugins
source ~/.zsh_plugins.zsh
