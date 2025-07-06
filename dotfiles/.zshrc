

################################################################################
#                                                                              #
#   🚀 ZSHRC MAIN CONFIGURATION                                                #
#   -------------------------                                                  #
#   Main shell initialisation and modular sourcing.                            #
#                                                                              #
################################################################################

################################################################################
#   🕵️ ZSH PROFILING (zprof)
################################################################################
# Set ZPROF=TRUE at the top of this file to enable zprof timing
if [[ "$ZPROF" == "TRUE" ]]; then
  zmodload zsh/zprof
fi

################################################################################
#   ⚡ Powerlevel10k instant prompt (must be at the very top for best performance)
################################################################################
[[ -f $HOME/.config/zsh/p10k-instant-prompt.zsh ]] && source $HOME/.config/zsh/p10k-instant-prompt.zsh

################################################################################
#   🍺 HOMEBREW PREFIX SETUP (Apple Silicon or Intel)
################################################################################
HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-/usr/local}"

################################################################################
#   🧩 SOURCE MODULAR ZSH FILES (order matters)
################################################################################

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
  node.zsh \
  completions.zsh \
  java.zsh \
  python.zsh \
  android.zsh \
  openssl.zsh \
  homebrew.zsh \
  babel.zsh \
  fzf.zsh \
  ruby.zsh \
  path.zsh \
  autosuggestions.zsh
do
  [[ -f $HOME/.config/zsh/$zsh_file ]] && source $HOME/.config/zsh/$zsh_file
done


################################################################################
#   🧠 ZSH COMPLETION & ZMV AUTOLOAD
################################################################################

# Only rebuild completions if needed, otherwise use cached (from Scott Spence's guide)
autoload -Uz compinit

if [ "$(date +'%j')" != "$(stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null)" ]; then
    compinit
else
    compinit -C
fi

autoload zmv

################################################################################
#   🗃️ LOCAL CONFIGURATION SOURCING
################################################################################
if [[ -f $HOME/.zshrc_local ]]; then
  echo "[zshrc] Migrating ~/.zshrc_local to ~/.config/zsh/local.zsh..."
  mkdir -p $HOME/.config/zsh
  mv $HOME/.zshrc_local $HOME/.config/zsh/local.zsh
  echo "[zshrc] Migration complete. Please remove this migration block from your .zshrc."
fi
[[ -f $HOME/.config/zsh/local.zsh ]] && source $HOME/.config/zsh/local.zsh

################################################################################
#   🛣️ PROFILED BIN OVERRIDES
################################################################################
export PATH=$MY/profiles/$OS_PROFILE/bin/_:$PATH


################################################################################
#   💎 PROMPT & FNM FINALISATION
################################################################################
# Powerlevel10k prompt and fnm must be sourced at the end for correct behaviour. fnm should be sourced after p10k to ensure prompt integration works correctly.
for zsh_file in \
  p10k.zsh \
  fnm.zsh
do
  [[ -f $HOME/.config/zsh/$zsh_file ]] && source $HOME/.config/zsh/$zsh_file
done


################################################################################
#   🕵️ ZSH PROFILING REPORT (zprof)
################################################################################
if [[ "$ZPROF" == "TRUE" ]]; then
  zprof
fi
