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

echo_task_start "Setting up shell abbreviations"
echo_space

# Only load if abbr command is available
if ! command -v abbr >/dev/null; then
  echo_fail "abbr command not found. Please install zsh-abbr plugin."
  return 1
fi

# Get current abbreviations and erase them all
echo_info "Clearing existing abbreviations"
for abbr_name in $(abbr list-abbreviations 2>/dev/null); do
    abbr erase "$abbr_name" 2>/dev/null
done

echo_space
echo_info "Loading abbreviations"
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

echo_space
echo_task_done "Shell abbreviations configured"
