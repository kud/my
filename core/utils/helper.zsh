#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🔧 HELPER UTILITIES                                                        #
#   ----------------                                                           #
#   Core utility functions for package management and system operations.      #
#   UI/display functions have been moved to ui-kit.zsh for better separation. #
#                                                                              #
################################################################################

# Package management utilities

# Homebrew package caching system for performance optimization
_BREW_FORMULAE_CACHE=""
_BREW_CASKS_CACHE=""
_BREW_OUTDATED_CACHE=""

# Node.js package queue for batch processing
_NPM_PACKAGES_TO_INSTALL=()

# Homebrew package queues for efficient installation
_BREW_PACKAGES_TO_INSTALL=()
_CASK_PACKAGES_TO_INSTALL=()

function init_brew_cache() {
  if command -v brew >/dev/null 2>&1; then
    _BREW_FORMULAE_CACHE=$(brew list --formula 2>/dev/null || echo "")
    _BREW_CASKS_CACHE=$(brew list --cask 2>/dev/null || echo "")
    _BREW_OUTDATED_CACHE=$(brew outdated 2>/dev/null || echo "")
  fi
}

function refresh_brew_cache() {
  if command -v brew >/dev/null 2>&1; then
    _BREW_FORMULAE_CACHE=$(brew list --formula 2>/dev/null || echo "")
    _BREW_CASKS_CACHE=$(brew list --cask 2>/dev/null || echo "")
    _BREW_OUTDATED_CACHE=$(brew outdated 2>/dev/null || echo "")
  fi
}

function brew_tap() {
  if ! brew tap | grep "${@}" > /dev/null; then
    brew tap "${@}"
  fi
}

function brew_install() {
  local package="${@}"

  # Extract actual package name (remove tap prefix if present)
  local package_name
  if [[ "$package" == */* ]]; then
    package_name="${package##*/}"  # Get everything after the last slash
  else
    package_name="$package"
  fi

  # Check if already installed and up-to-date using cached lists
  if echo "$_BREW_FORMULAE_CACHE" | grep -q "^${package_name}$" && ! echo "$_BREW_OUTDATED_CACHE" | grep -q "^${package_name}"; then
    return 0
  fi

  # Add to batch installation array
  _BREW_PACKAGES_TO_INSTALL+=("${package}")
}

function brew_install_run() {
  local start_time=$(date +%s.%N)
  ui_debug "brew_install_run: Starting with ${#_BREW_PACKAGES_TO_INSTALL[@]} packages"
  
  if [[ ${#_BREW_PACKAGES_TO_INSTALL[@]} -eq 0 ]]; then
    ui_debug "brew_install_run: No packages to install"
    return 0
  fi

  # Load UI functions if not already loaded
  if ! command -v ui_info_simple >/dev/null 2>&1; then
  fi

  ui_info_simple "Installing ${#_BREW_PACKAGES_TO_INSTALL[@]} formulae:"
  for package in "${_BREW_PACKAGES_TO_INSTALL[@]}"; do
    echo "  • $package"
    ui_debug "brew_install_run: Will install $package"
  done
  ui_space

  ui_debug_command "brew install ${_BREW_PACKAGES_TO_INSTALL[*]}"
  brew install "${_BREW_PACKAGES_TO_INSTALL[@]}"

  # Clear the array and refresh cache
  _BREW_PACKAGES_TO_INSTALL=()
  ui_debug "brew_install_run: Refreshing cache"
  refresh_brew_cache
  ui_debug_timing "$start_time" "brew_install_run"
}

function brew_uninstall() {
  brew uninstall "${@}"
}

function cask_install() {
  local package="${@}"

  # Extract actual package name (remove tap prefix if present)
  local package_name
  if [[ "$package" == */* ]]; then
    package_name="${package##*/}"  # Get everything after the last slash
  else
    package_name="$package"
  fi

  # Check if already installed using cached list
  if echo "$_BREW_CASKS_CACHE" | grep -q "^${package_name}$"; then
    return 0
  fi

  # Add to batch installation array
  _CASK_PACKAGES_TO_INSTALL+=("${package}")
}

function cask_install_run() {
  if [[ ${#_CASK_PACKAGES_TO_INSTALL[@]} -eq 0 ]]; then
    return 0
  fi

  # Load UI functions if not already loaded
  if ! command -v ui_info_simple >/dev/null 2>&1; then
  fi

  ui_info_simple "Installing ${#_CASK_PACKAGES_TO_INSTALL[@]} casks:"
  for package in "${_CASK_PACKAGES_TO_INSTALL[@]}"; do
    echo "  • $package"
  done
  ui_space

  if ! brew install --cask "${_CASK_PACKAGES_TO_INSTALL[@]}"; then
    ui_error_simple "Homebrew cask installation failed"
    ui_warning_simple "Please fix the conflict and run the script again"
    exit 1
  fi

  # Clear the array and refresh cache
  _CASK_PACKAGES_TO_INSTALL=()
  refresh_brew_cache
}

function cask_uninstall() {
  brew uninstall --cask "${@}"
}

function gem_install() {
  if ! type "${@}" > /dev/null; then
    gem install "${@}"
  fi
}

function npm_install() {
  local package="${@}"
  
  # Add to batch installation array
  _NPM_PACKAGES_TO_INSTALL+=("${package}")
}

function npm_install_run() {
  local start_time=$(date +%s.%N)
  ui_debug "npm_install_run: Starting with ${#_NPM_PACKAGES_TO_INSTALL[@]} packages"
  
  if [[ ${#_NPM_PACKAGES_TO_INSTALL[@]} -eq 0 ]]; then
    ui_debug "npm_install_run: No packages to install"
    return 0
  fi

  # Load UI functions if not already loaded
  if ! command -v ui_info_simple >/dev/null 2>&1; then
  fi

  # Get installed packages list once
  ui_debug "npm_install_run: Checking already installed packages"
  local installed_packages=$(npm list -g --depth=0 --parseable 2>/dev/null | xargs -n1 basename 2>/dev/null || echo "")
  ui_debug_vars installed_packages
  
  # Filter out already installed packages
  local packages_to_install=()
  ui_debug "npm_install_run: Filtering already installed packages"
  for package in "${_NPM_PACKAGES_TO_INSTALL[@]}"; do
    local package_name="${package%%@*}"
    if ! echo "$installed_packages" | grep -q "^${package_name}$"; then
      packages_to_install+=("$package")
      ui_debug "npm_install_run: Need to install $package"
    else
      ui_debug "npm_install_run: $package already installed, skipping"
    fi
  done

  # Skip if no packages need installation
  if [[ ${#packages_to_install[@]} -eq 0 ]]; then
    ui_info_simple "All npm packages already installed"
    _NPM_PACKAGES_TO_INSTALL=()
    ui_debug_timing "$start_time" "npm_install_run (no packages needed)"
    return 0
  fi

  ui_info_simple "Installing ${#packages_to_install[@]} npm packages:"
  for package in "${packages_to_install[@]}"; do
    echo "  • $package"
  done
  ui_space

  ui_debug_command "npm install -g ${packages_to_install[*]}"
  npm install -g "${packages_to_install[@]}"

  if [[ $? -ne 0 ]]; then
    # Fallback: try installing individually
    ui_debug "npm_install_run: Batch installation failed, trying individually"
    ui_warning_simple "Batch installation failed, trying individually..."
    for package in "${packages_to_install[@]}"; do
      ui_info_simple "Installing $package..."
      ui_debug_command "npm install -g $package"
      if ! npm install -g "$package"; then
        ui_debug "npm_install_run: Failed to install $package, attempting cleanup and retry"
        # Cleanup and retry
        npm uninstall -g "$package"
        local package_name=$(echo "$package" | cut -d'@' -f1)
        local npm_global_path=$(npm root -g)
        if [[ -n "$npm_global_path" && -d "$npm_global_path/$package_name" ]]; then
          ui_debug_command "rm -rf $npm_global_path/$package_name"
          rm -rf "$npm_global_path/$package_name"
        fi
        ui_debug_command "npm install -g $package (retry)"
        npm install -g "$package"
      fi
    done
  fi

  # Clear the array
  _NPM_PACKAGES_TO_INSTALL=()
  ui_debug_timing "$start_time" "npm_install_run"
}

function pip2install() {
  if ! type "${@}" > /dev/null; then
    pip2 install --upgrade "${@}"
  fi
}

function pip3install() {
  if ! type "${@}" > /dev/null; then
    pip3 install --upgrade "${@}"
  fi
}

function pip_install() {
  local package="${@}"

  # Load UI functions if not already loaded
  if ! command -v ui_subtle >/dev/null 2>&1; then
  fi

  # Check if command exists
  if command -v "$package" >/dev/null 2>&1; then
    ui_subtle "✓ ${package} (already installed)"
    return 0
  fi

  # Use pip3 by default (most common nowadays)
  pip3 install --upgrade "$package"
}

function mas_install() {
  local package="${@}"


  # Install via Mac App Store
  mas install "$package"
}

# Path constants to reduce hard-coding
export CONFIG_DIR="$MY/config"
export PACKAGES_CONFIG_DIR="$CONFIG_DIR/packages"
export PROFILE_DIR="$MY/profiles/$OS_PROFILE"
export PROFILE_CONFIG_DIR="$PROFILE_DIR/config"
export PROFILE_PACKAGES_CONFIG_DIR="$PROFILE_CONFIG_DIR/packages"
export PROFILE_APPS_CONFIG_DIR="$PROFILE_CONFIG_DIR/apps"
export HOME_CONFIG_DIR="$HOME/.config"
export HOME_LIBRARY_APP_SUPPORT="$HOME/Library/Application Support"

# Generic command availability checker
ensure_command_available() {
  local command_name="$1"
  local install_hint="${2:-}"
  local exit_on_fail="${3:-true}"

  if ! command -v "$command_name" >/dev/null 2>&1; then
    # Load UI functions if not already loaded
    if ! command -v ui_error_simple >/dev/null 2>&1; then
    fi
    
    local error_msg="$command_name is not installed."
    if [[ -n "$install_hint" ]]; then
      error_msg="$error_msg $install_hint"
    fi

    if [[ "$exit_on_fail" == "true" ]]; then
      ui_error_simple "$error_msg"
      exit 1
    else
      ui_warning_simple "$error_msg"
      return 1
    fi
  fi
  return 0
}

# Help framework for consistent command help display
show_command_help() {
  local script_name="$1"
  local description="$2"
  local usage="$3"
  shift 3
  local commands=("$@")

  # Load UI functions if not already loaded
  if ! command -v ui_space >/dev/null 2>&1; then
  fi

  ui_space
  ui_highlight "$script_name - $description"
  ui_space
  ui_bold_text "USAGE:"
  echo "  $usage"
  ui_spacex2

  if [[ ${#commands[@]} -gt 0 ]]; then
    ui_bold_text "COMMANDS:"
    for cmd_desc in "${commands[@]}"; do
      local cmd=$(echo "$cmd_desc" | cut -d: -f1)
      local desc=$(echo "$cmd_desc" | cut -d: -f2)
      printf "  %-12s %s\n" "$cmd" "$desc"
    done
    ui_space
  fi
}

# Automatic help flag handler
handle_help_flag() {
  if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    ${2:-show_help}
    exit 0
  fi
}

# Merge app preferences from main and profile configs
merge_app_preferences() {
  local main_config="$1"
  local profile_config="$2"
  local yaml_key="${3:-preferences}"

  # Start with main config preferences
  local merged_prefs=$(yq eval ".${yaml_key}" "$main_config" -o json)

  # Merge with profile config if it exists
  if [[ -f "$profile_config" ]]; then
    local profile_prefs=$(yq eval ".${yaml_key}" "$profile_config" -o json 2>/dev/null || echo '{}')
    merged_prefs=$(echo "$merged_prefs $profile_prefs" | jq -s '.[0] * .[1]')
  fi

  echo "$merged_prefs"
}

