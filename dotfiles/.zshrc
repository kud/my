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
[[ -f $HOME/.config/zsh/local.zsh ]] && source $HOME/.config/zsh/local.zsh

################################################################################
#   🛣️ PROFILED BIN OVERRIDES
################################################################################
export PATH=$MY/profiles/$OS_PROFILE/bin/_:$PATH


################################################################################
#   🕵️ ZSH PROFILING REPORT (zprof)
################################################################################
if [[ "$ZPROF" == "TRUE" ]]; then
  zprof
fi
