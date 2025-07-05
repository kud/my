
# Powerlevel10k instant prompt (must be at the very top)
[[ -f $HOME/.config/zsh/p10k-instant-prompt.zsh ]] && source $HOME/.config/zsh/p10k-instant-prompt.zsh

# Set homebrew prefix depending on Intel or Apple Silicon
HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-/usr/local}"

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
  path.zsh
do
  [[ -f $HOME/.config/zsh/$zsh_file ]] && source $HOME/.config/zsh/$zsh_file
done

autoload -U compinit && compinit
autoload zmv

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

# p10k (should be always the last line)
# fnm (for some strange reason, `fnm` needs to be at the end in order to view the local version in the shell)
for zsh_file in \
  p10k.zsh \
  fnm.zsh
do
  [[ -f $HOME/.config/zsh/$zsh_file ]] && source $HOME/.config/zsh/$zsh_file
done
