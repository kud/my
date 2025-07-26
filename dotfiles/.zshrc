# =============================================================================
# ZSH Configuration
# =============================================================================
# Main shell initialization and modular sourcing

# Define MY variable early (needed for sourcing other files)
export MY="$HOME/my"

# -----------------------------------------------------------------------------
# ZSH Profiling
# -----------------------------------------------------------------------------
# Set ZPROF=TRUE to enable zprof timing
if [[ "$ZPROF" == "TRUE" ]]; then
  zmodload zsh/zprof
fi

# -----------------------------------------------------------------------------
# Homebrew Setup
# -----------------------------------------------------------------------------
HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-/usr/local}"

# -----------------------------------------------------------------------------
# Modular ZSH Files
# -----------------------------------------------------------------------------
# Source modular ZSH files from shell/ directory (optimized order)
for zsh_file in \
  globals.zsh \
  locale.zsh \
  limits.zsh \
  homebrew.zsh \
  path.zsh \
  zprezto.zsh \
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
  fzf.zsh \
  z.zsh \
  autojump.zsh \
  antidote.zsh \
  autosuggestions.zsh \
  starship.zsh
do
  [[ -f $MY/shell/$zsh_file ]] && source $MY/shell/$zsh_file
done

# -----------------------------------------------------------------------------
# ZSH Completion & Autoload
# -----------------------------------------------------------------------------
# Only rebuild completions if needed, otherwise use cached (from Scott Spence's guide)
autoload -Uz compinit

if [ "$(date +'%j')" != "$(stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null)" ]; then
    compinit
else
    compinit -C
fi

autoload zmv

# -----------------------------------------------------------------------------
# Local Configuration
# -----------------------------------------------------------------------------
[[ -f $HOME/.config/zsh/local.zsh ]] && source $HOME/.config/zsh/local.zsh

# -----------------------------------------------------------------------------
# Path Setup
# -----------------------------------------------------------------------------
export PATH=$MY/profiles/$OS_PROFILE/bin/_:$PATH

# -----------------------------------------------------------------------------
# ZSH Profiling Report
# -----------------------------------------------------------------------------
if [[ "$ZPROF" == "TRUE" ]]; then
  zprof
fi
