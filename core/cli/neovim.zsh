#!/usr/bin/env zsh

source $MY/core/utils/helper.zsh

check_neovim_installed() {
  command -v nvim >/dev/null 2>&1
}

ensure_config_directory_exists() {
  local config_dir="$HOME/.config/nvim"

  if [[ ! -d "$config_dir" ]]; then
    echo_info "Creating Neovim configuration directory"
    mkdir -p "$config_dir"
    echo_success "Configuration directory created"
  else
    echo_info "Neovim configuration directory already exists"
  fi
}

setup_neovim() {
  echo_task_start "Setting up modern Neovim configuration"

  if ! check_neovim_installed; then
    echo_fail "Neovim is not installed. Install it via Homebrew first:"
    echo_info "Run: brew install neovim"
    return 1
  fi

  echo_info "Neovim found - proceeding with configuration"

  ensure_config_directory_exists

  echo_space
  echo_task_done "Neovim configuration completed"
  echo_success "Modern Neovim development environment is ready! 🚀"
}

setup_neovim
