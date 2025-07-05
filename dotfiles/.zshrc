# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Set homebrew prefix depending on Intel or Apple Silicon
HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-/usr/local}"

[[ -f $HOME/.config/zsh/zprezto.zsh ]] && source $HOME/.config/zsh/zprezto.zsh
[[ -f $HOME/.config/zsh/antidote.zsh ]] && source $HOME/.config/zsh/antidote.zsh

# autojump
[ -f ${HOMEBREW_PREFIX}/etc/profile.d/autojump.sh ] && . ${HOMEBREW_PREFIX}/etc/profile.d/autojump.sh
autoload -U compinit && compinit

# zmv
autoload zmv

# z
[ -f ${HOMEBREW_PREFIX}/etc/profile.d/z.sh ] && . ${HOMEBREW_PREFIX}/etc/profile.d/z.sh

for zsh_file in \
  functions.zsh \
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
  path.zsh
do
  [[ -f $HOME/.config/zsh/$zsh_file ]] && source $HOME/.config/zsh/$zsh_file
done

# local config migration and sourcing
if [[ -f $HOME/.zshrc_local ]]; then
  echo "[zshrc] Migrating ~/.zshrc_local to ~/.config/zsh/local.zsh..."
  mkdir -p $HOME/.config/zsh
  mv $HOME/.zshrc_local $HOME/.config/zsh/local.zsh
  echo "[zshrc] Migration complete. Please remove this migration block from your .zshrc."
fi
[[ -f $HOME/.config/zsh/local.zsh ]] && source $HOME/.config/zsh/local.zsh

# add or override commands by via profiled ones
export PATH=$MY/profiles/$OS_PROFILE/bin/_:$PATH

# fzf
source <(fzf --zsh)

# ruby
eval "$(frum init)"

# To customize prompt, run `p10k configure` or edit ~/.config/zsh/p10k.zsh.
# Should be always the last line
[[ ! -f ~/.config/zsh/p10k.zsh ]] || source ~/.config/zsh/p10k.zsh

# For some strange reason, `fnm` needs to be at the end in order to view the local version in the shell.
eval "$(fnm env --use-on-cd)" > /dev/null 2>&1
