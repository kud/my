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
# Source modular ZSH files from shell/ directory (optimized order)
for zsh_file in \
  globals.zsh \
  directory.zsh \
  editor.zsh \
  history.zsh \
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
  history-substring-search.zsh \
  you-should-use.zsh \
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

# Create local config if it doesn't exist
if [[ ! -f "$HOME/.config/zsh/local.zsh" ]]; then
  mkdir -p "$HOME/.config/zsh"
  echo "# Local machine configuration" > "$HOME/.config/zsh/local.zsh"
  echo "# Add machine-specific settings here" >> "$HOME/.config/zsh/local.zsh"
  echo "" >> "$HOME/.config/zsh/local.zsh"

  # Prompt for OS profile if not set
  if [[ -z "$OS_PROFILE" ]]; then
    echo "Setting up local configuration..."
    while true; do
      read "?Enter the profile of this computer (home/work): " OS_PROFILE
      if [[ "$OS_PROFILE" == "home" || "$OS_PROFILE" == "work" ]]; then
        echo "export OS_PROFILE=$OS_PROFILE" >> "$HOME/.config/zsh/local.zsh"
        break
      else
        echo "Invalid input, please enter either 'home' or 'work'"
      fi
    done
  fi
fi

# Include local configuration
[[ -f $HOME/.config/zsh/local.zsh ]] && source $HOME/.config/zsh/local.zsh

# Add profile bins to PATH
export PATH=$MY/profiles/$OS_PROFILE/bin/_:$PATH

# -----------------------------------------------------------------------------
# ZSH Profiling Report
# -----------------------------------------------------------------------------
if [[ "$ZPROF" == "TRUE" ]]; then
  zprof
fi
