#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   📂 DOTFILES SYMLINK MANAGER                                                #
#   --------------------------                                                 #
#   Automatically discovers and symlinks all dotfiles from the repository     #
#   to the home directory, enabling seamless configuration management.        #
#                                                                              #
################################################################################

source "$MY/core/utils/helper.zsh"

echo_task_start "Setting up dotfiles symlinks"

################################################################################
# 🔍 DOTFILES DISCOVERY
################################################################################

echo_info "Scanning dotfiles directory for files to symlink..."

# Automatically discover all dotfiles (files starting with .)
dotfiles=()

for file in "$MY/dotfiles"/.* "$MY/dotfiles"/*; do
  # Skip directories, special entries, and .DS_Store
  base="$(basename "$file")"
  if [[ -f "$file" && "$base" != "." && "$base" != ".." && "$base" != ".DS_Store" ]]; then
    dotfiles+=("$base")
  fi
done

echo_info "Found ${#dotfiles[@]} dotfiles to process"

mkdir -p "${ZDOTDIR:-$HOME}/.config/nvim"

echo_info "Creating symbolic links..."
for file in "${dotfiles[@]}"; do
  source_path="$MY/dotfiles/$file"
  target_path="${ZDOTDIR:-$HOME}/$file"

  if ln -sf "$source_path" "$target_path" 2>/dev/null; then
    echo_success "  $file → $target_path"
  else
    echo_warn "  Failed to link $file"
  fi
done

############################################################
# 📁 Config directories
############################################################
echo_info "Setting up .config directory structure..."

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
    if ln -sf "$config_file" "$target_path" 2>/dev/null; then
      echo_success "  .config/$rel_path → $target_path"
    else
      echo_warn "  Failed to link .config/$rel_path"
    fi
  done
fi

############################################################
# 🧩 Zsh config directory setup
############################################################
echo_info "Setting up Zsh configuration directory..."
mkdir -p "$HOME/.config/zsh"
echo_success "  Created ~/.config/zsh directory"

echo_info "Checking SSH configuration..."
if [ ! -f "$HOME/.ssh/config" ]; then
  if cp "$MY/templates/ssh/config" "$HOME/.ssh/" 2>/dev/null; then
    echo_success "  SSH config → ~/.ssh/config"
  else
    echo_warn "  Failed to copy SSH config"
  fi
else
  echo_info "  SSH config already exists, skipping"
fi

echo_info "Checking Git local configuration..."

if [ ! -f "$HOME/.gitconfig_local" ]; then
  echo_info "  Creating Git local configuration..."
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

  echo_success "  Git local config → ~/.gitconfig_local"
else
  echo_info "  Git local config already exists, skipping"
fi

################################################################################
# 🔄 CONFIGURATION RELOAD
################################################################################

echo_space
echo_info "Reloading shell configuration to apply changes"
source "$HOME/.zshrc"
echo_success "Shell configuration reloaded successfully"

echo_space
echo_task_done "Dotfiles symlink setup completed"
echo_success "All configuration files are now managed via symlinks! ⚡"
