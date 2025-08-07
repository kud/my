#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🚀 ABBREVIATIONS MANAGER                                                   #
#   ---------------------                                                      #
#   Dynamically manages shell abbreviations with clean state management       #
#                                                                              #
################################################################################

source ~/.zshrc
source $MY/core/utils/helper.zsh


# Only load if abbr command is available
if ! command -v abbr >/dev/null; then
  return 1
fi

# Get current abbreviations and erase them all
for abbr_name in $(abbr list-abbreviations 2>/dev/null); do
    abbr erase "$abbr_name" 2>/dev/null
done

abbr ~="cd ~"
abbr gaa="git add --all"
abbr gbr="git branch"
abbr gcm="git commit -m"
abbr gco="git checkout"
abbr gl="git pull"
abbr glv="git lazy-version"
abbr gmg="git merge"
abbr gp="git push"
abbr gpo="git push origin"
abbr gsc="git switch -c"
abbr gst="git status"

