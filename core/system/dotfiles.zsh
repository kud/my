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

for file in "${dotfiles[@]}"; do
  source_path="$MY/dotfiles/$file"
  target_path="${ZDOTDIR:-$HOME}/$file"

  if ln -sf "$source_path" "$target_path" 2>/dev/null; then
    ui_success_simple "Linked $file"
  fi
done

############################################################
# 📁 Config directories
############################################################

# Handle .config subdirectories
if [[ -d "$MY/dotfiles/.config" ]]; then
  mkdir -p "$HOME_CONFIG_DIR"

  # Find all files in .config subdirectories
  find "$MY/dotfiles/.config" -type f | while read -r config_file; do
    # Get relative path from .config
    rel_path="${config_file#$MY/dotfiles/.config/}"
    target_path="$HOME_CONFIG_DIR/$rel_path"
    target_dir="$(dirname "$target_path")"

    # Create target directory if needed
    mkdir -p "$target_dir"

    # Create symlink
    if ln -sf "$config_file" "$target_path" 2>/dev/null; then
      ui_success_simple "Linked .config/$rel_path"
    fi
  done
fi

############################################################
# 🔔 Codex config directory setup
############################################################

if [[ -d "$MY/dotfiles/.codex" ]]; then
  mkdir -p "$HOME/.codex"

  find "$MY/dotfiles/.codex" -type f | while read -r codex_file; do
    rel_path="${codex_file#$MY/dotfiles/.codex/}"
    target_path="$HOME/.codex/$rel_path"
    target_dir="$(dirname "$target_path")"

    mkdir -p "$target_dir"

    if ln -sf "$codex_file" "$target_path" 2>/dev/null; then
      ui_success_simple "Linked .codex/$rel_path"
    fi
  done
fi

############################################################
# 🤖 AI assets (agents, skills)
############################################################

$MY/core/cli/ai.zsh sync

############################################################
# 🧩 Zsh config directory setup
############################################################
mkdir -p "$HOME_CONFIG_DIR/zsh"

if [ ! -f "$HOME/.ssh/config" ]; then
  cp "$MY/templates/ssh/config" "$HOME/.ssh/" 2>/dev/null
  ui_success_simple "Created SSH config from template"
fi

GIT_LOCAL_FILE="$HOME/.gitconfig_local"
if [ ! -f "$GIT_LOCAL_FILE" ]; then
  ui_info_simple "Initializing empty .gitconfig_local"
  : > "$GIT_LOCAL_FILE"
fi

ensure_git_prompt() {
  local key="$1" prompt="$2" value
  if git config --file "$GIT_LOCAL_FILE" --get "$key" >/dev/null 2>&1; then
    return 0
  fi
  read "?$prompt: " value </dev/tty
  git config --file "$GIT_LOCAL_FILE" "$key" "$value"
  ui_success_simple "Set $key"
}

ensure_git_value() {
  local key="$1" desired="$2" current
  current=$(git config --file "$GIT_LOCAL_FILE" --get "$key" 2>/dev/null || true)
  if [[ "$current" != "$desired" ]]; then
    git config --file "$GIT_LOCAL_FILE" "$key" "$desired"
    if [[ -z "$current" ]]; then
      ui_success_simple "Set $key"
    else
      ui_success_simple "Updated $key"
    fi
  fi
}

ensure_git_prompt github.user "Enter your GitHub username"
ensure_git_prompt user.name "Enter your full name"
ensure_git_prompt user.email "Enter your email"
ensure_git_value split-diffs.theme-directory "$HOME/my/themes/split-diffs"

if [[ "$OS_PROFILE" == "work" ]]; then
  if ! git config --file "$GIT_LOCAL_FILE" --get includeIf."gitdir:~/Projects/work/".path >/dev/null 2>&1; then
    git config --file "$GIT_LOCAL_FILE" includeIf."gitdir:~/Projects/work/".path .gitconfig_local_work
    ui_success_simple "Added work includeIf"
  fi
fi

source "$HOME/.zshrc"
