# =============================================================================
# ZSH Configuration
# =============================================================================
# Define MY variable early (needed for sourcing other files)
export MY="$HOME/my"

# Populate HOMEBREW_PREFIX if not already set
HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-/usr/local}"

# -----------------------------------------------------------------------------
# ZSH Profiling
# -----------------------------------------------------------------------------
# Set ZPROF=TRUE to enable zprof timing
if [[ "$ZPROF" == "TRUE" ]]; then
  zmodload zsh/zprof
fi

# -----------------------------------------------------------------------------
# Modular ZSH Files
# -----------------------------------------------------------------------------
# Source shell modules (order matters for dependencies)
for module in \
  globals.zsh \
  directory.zsh \
  editor.zsh \
  history.zsh \
  locale.zsh \
  limits.zsh \
  homebrew.zsh \
  path.zsh \
  zprezto.zsh \
  utility.zsh \
  functions.zsh \
  completions.zsh \
  bindings.zsh \
  aliases.zsh \
  display.zsh \
  openssl.zsh \
  python.zsh \
  ruby.zsh \
  java.zsh \
  node.zsh \
  babel.zsh \
  android.zsh \
  antidote.zsh \
  autosuggestions.zsh \
  history-substring-search.zsh \
  you-should-use.zsh \
  fzf.zsh \
  zoxide.zsh \
  local.zsh \
  profile.zsh \
  starship.zsh
do
  [[ -f $MY/shell/$module ]] && source $MY/shell/$module
done

# Critical dependencies:
# - completions.zsh must come before antidote.zsh (sets up compinit)
# - antidote.zsh must come before plugin configs (loads plugins first)
# - fzf.zsh and zoxide.zsh need plugins loaded first
# - local.zsh must come before profile.zsh (sets OS_PROFILE variable)

# -----------------------------------------------------------------------------
# ZSH Profiling Report
# -----------------------------------------------------------------------------
if [[ "$ZPROF" == "TRUE" ]]; then
  zprof
fi
