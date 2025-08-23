################################################################################
#                                                                              #
#   🐚 ZSH CONFIGURATION                                                       #
#   ------------------                                                         #
#   Main Zsh configuration file that loads all shell modules and settings.     #
#                                                                              #
################################################################################

export MY="$HOME/my"

# Enable profiling if requested (set ZPROF=1)
[[ -n "$ZPROF" ]] && zmodload zsh/zprof

# Load shell modules (order matters for dependencies)
for module in \
  globals.zsh \
  directory.zsh \
  editor.zsh \
  history.zsh \
  locale.zsh \
  limits.zsh \
  homebrew.zsh \
  path/homebrew.zsh \
  functions.zsh \
  completions.zsh \
  bindings.zsh \
  aliases.zsh \
  display.zsh \
  cursor.zsh \
  openssl.zsh \
  python.zsh \
  ruby.zsh \
  java.zsh \
  node.zsh \
  path/node.zsh \
  babel.zsh \
  android.zsh \
  antidote.zsh \
  syntax-highlighting.zsh \
  autosuggestions.zsh \
  history-substring-search.zsh \
  you-should-use.zsh \
  fzf.zsh \
  zoxide.zsh \
  local.zsh \
  path/console-ninja.zsh \
  path/android.zsh \
  path/my.zsh \
  starship.zsh

do
  [[ -f $MY/shell/$module ]] && source $MY/shell/$module
done

# Show profiling report if enabled
[[ -n "$ZPROF" ]] && zprof
