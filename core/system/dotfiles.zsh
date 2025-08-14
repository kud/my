#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   📂 DOTFILES SYMLINK MANAGER                                                #
#   --------------------------                                                 #
#   Automatically discovers and symlinks all dotfiles from the repository     #
#   to the home directory, enabling seamless configuration management.        #
#                                                                              #
################################################################################


################################################################################
# 🔍 DOTFILES DISCOVERY
################################################################################


# Automatically discover all dotfiles (files starting with .)
dotfiles=()

for file in "$MY/dotfiles"/.* "$MY/dotfiles"/*; do
  # Skip directories, special entries, and .DS_Store
  base="$(basename "$file")"
  if [[ -f "$file" && "$base" != "." && "$base" != ".." && "$base" != ".DS_Store" ]]; then
    dotfiles+=("$base")
  fi
done


mkdir -p "${ZDOTDIR:-$HOME}/.config/nvim"

for file in "${dotfiles[@]}"; do
  source_path="$MY/dotfiles/$file"
  target_path="${ZDOTDIR:-$HOME}/$file"

  ln -sf "$source_path" "$target_path" 2>/dev/null
done

############################################################
# 📁 Config directories
############################################################

# Handle .config subdirectories
if [[ -d "$MY/dotfiles/.config" ]]; then
  mkdir -p "$HOME/.config"

  # Find all files in .config subdirectories
  find "$MY/dotfiles/.config" -type f | while read -r config_file; do
    # Get relative path from .config
    rel_path="${config_file#$MY/dotfiles/.config/}"
    target_path="$HOME/.config/$rel_path"
    target_dir="$(dirname "$target_path")"

    # Create target directory if needed
    mkdir -p "$target_dir"

    # Create symlink
    ln -sf "$config_file" "$target_path" 2>/dev/null
  done
fi

############################################################
# 🧩 Zsh config directory setup
############################################################
mkdir -p "$HOME/.config/zsh"

if [ ! -f "$HOME/.ssh/config" ]; then
  cp "$MY/templates/ssh/config" "$HOME/.ssh/" 2>/dev/null
else
fi


if [ ! -f "$HOME/.gitconfig_local" ]; then
  read "?Enter your GitHub username: " GITHUB_USERNAME </dev/tty
  read "?Enter your first name: " GITHUB_FIRSTNAME </dev/tty
  read "?Enter your last name: " GITHUB_LASTNAME </dev/tty
  read "?Enter your email: " GITHUB_EMAIL </dev/tty

  echo "[github]
  user = $GITHUB_USERNAME
[user]
  name = $GITHUB_FIRSTNAME $GITHUB_LASTNAME
  email = $GITHUB_EMAIL
[includeIf \"gitdir:~/Projects/work/\"]
  path = .gitconfig_local_work" >"$HOME/.gitconfig_local"

else
fi

################################################################################
# 🔄 CONFIGURATION RELOAD
################################################################################

source "$HOME/.zshrc"
