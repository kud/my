# =============================================================================
# ZSH Configuration
# =============================================================================
# Main shell initialization and modular sourcing

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
# Modular Zsh config sourcing (order matters)
for zsh_file in \
  zprezto.zsh \
  antidote.zsh \
  autojump.zsh \
  functions.zsh \
  z.zsh \
  globals.zsh \
  display.zsh \
  locale.zsh \
  limits.zsh \
  bindings.zsh \
  aliases.zsh \
  completions.zsh \
  openssl.zsh \
  homebrew.zsh \
  android.zsh \
  python.zsh \
  path.zsh \
  fzf.zsh \
  java.zsh \
  ruby.zsh \
  node.zsh \
  babel.zsh \
  autosuggestions.zsh \
  starship.zsh
do
  [[ -f $HOME/.config/zsh/$zsh_file ]] && source $HOME/.config/zsh/$zsh_file
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
