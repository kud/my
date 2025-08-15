#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   📂 DOTFILES SYMLINK MANAGER                                                #
#   --------------------------                                                 #
#   Automatically discovers and symlinks all dotfiles from the repository     #
#   to the home directory, enabling seamless configuration management.        #
#                                                                              #
################################################################################

source $MY/core/utils/ui-kit.zsh

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

dotfiles_linked=0
for file in "${dotfiles[@]}"; do
  source_path="$MY/dotfiles/$file"
  target_path="${ZDOTDIR:-$HOME}/$file"

  if ln -sf "$source_path" "$target_path" 2>/dev/null; then
    ((dotfiles_linked++))
  fi
done

ui_success_simple "Linked ${#dotfiles[@]} dotfiles to home directory"

############################################################
# 📁 Config directories
############################################################

# Handle .config subdirectories
if [[ -d "$MY/dotfiles/.config" ]]; then
  mkdir -p "$HOME_CONFIG_DIR"

  config_files_count=$(find "$MY/dotfiles/.config" -type f | wc -l | tr -d ' ')
  # Find all files in .config subdirectories
  find "$MY/dotfiles/.config" -type f | while read -r config_file; do
    # Get relative path from .config
    rel_path="${config_file#$MY/dotfiles/.config/}"
    target_path="$HOME_CONFIG_DIR/$rel_path"
    target_dir="$(dirname "$target_path")"

    # Create target directory if needed
    mkdir -p "$target_dir"

    # Create symlink
    ln -sf "$config_file" "$target_path" 2>/dev/null
  done
  
  ui_success_simple "Linked $config_files_count config files to ~/.config/"
fi

############################################################
# 🧩 Zsh config directory setup
############################################################
mkdir -p "$HOME_CONFIG_DIR/zsh"

if [ ! -f "$HOME/.ssh/config" ]; then
  cp "$MY/templates/ssh/config" "$HOME/.ssh/" 2>/dev/null
  ui_success_simple "Created SSH config from template"
else
  ui_info_simple "SSH config already exists"
fi


if [ ! -f "$HOME/.gitconfig_local" ]; then
  ui_info_simple "Setting up Git configuration..."
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

  ui_success_simple "Created .gitconfig_local with user information"
else
  ui_info_simple "Git configuration already exists"
fi

################################################################################
# 🔄 CONFIGURATION RELOAD
################################################################################

ui_info_simple "Reloading shell configuration..."
source "$HOME/.zshrc"
ui_success_simple "Shell configuration reloaded"
