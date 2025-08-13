# ################################################################################
#                                                                                #
#   � ANTIDOTE PLUGIN MANAGER INITIALISATION                                    #
#   ------------------------------------------                                   #
#   Loads and manages Zsh plugins using Antidote.                                #
#   https://getantidote.github.io/antidote/                                      #
#                                                                                #
# ################################################################################

zsh_plugins_txt="$MY/shell/plugins.txt"
zsh_plugins_zsh="$HOME/.zsh_plugins.zsh"

[[ -f "$zsh_plugins_txt" ]] || touch "$zsh_plugins_txt"

fpath=( $HOMEBREW_PREFIX/share/antidote/functions $fpath )
autoload -Uz antidote

if [[ ! -f "$zsh_plugins_zsh" || "$zsh_plugins_txt" -nt "$zsh_plugins_zsh" ]]; then
  antidote bundle <"$zsh_plugins_txt" >! "$zsh_plugins_zsh"
fi

source "$zsh_plugins_zsh"
