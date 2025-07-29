# ################################################################################
#                                                                                #
#   � ANTIDOTE PLUGIN MANAGER INITIALISATION                                    #
#   ------------------------------------------                                   #
#   Loads and manages Zsh plugins using Antidote.                                #
#   https://getantidote.github.io/antidote/                                      #
#                                                                                #
# ################################################################################

# Ultra high performance Antidote plugin management
# -----------------------------------------------
# Uses static plugin files in $ZDOTDIR or $HOME for maximum speed and portability.

# Set plugin file paths (using shell/plugins.txt as the source)
zsh_plugins_txt="$MY/shell/plugins.txt"
zsh_plugins_zsh="$HOME/.zsh_plugins.zsh"

# Ensure the plugins.txt file exists
[[ -f "$zsh_plugins_txt" ]] || touch "$zsh_plugins_txt"

# Lazy-load Antidote from its functions directory (fastest method)
fpath=( $HOMEBREW_PREFIX/share/antidote/functions $fpath )
autoload -Uz antidote

# Generate a new static file whenever plugins.txt is updated
if [[ ! -f "$zsh_plugins_zsh" || "$zsh_plugins_txt" -nt "$zsh_plugins_zsh" ]]; then
  antidote bundle <"$zsh_plugins_txt" >! "$zsh_plugins_zsh"
fi

# Source your static plugins file
source "$zsh_plugins_zsh"
