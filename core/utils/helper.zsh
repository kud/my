#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🔧 HELPER UTILITIES                                                        #
#   ----------------                                                           #
#   Core utility functions for package management, user feedback, and system  #
#   operations. Provides consistent UI, logging, and installation functions.  #
#                                                                              #
################################################################################

# Terminal colors setup
autoload colors
if [[ "$terminfo[colors]" -gt 8 ]]; then
  colors
fi

for COLOUR in RED GREEN YELLOW BLUE MAGENTA CYAN BLACK WHITE; do
  eval COLOUR_$COLOUR='$fg_no_bold[${(L)COLOUR}]'
  eval COLOUR_BOLD_$COLOUR='$fg_bold[${(L)COLOUR}]'
done
eval COLOUR_RESET='$reset_color'

# Visual feedback characters
export CHAR_OK=✔
export CHAR_ERROR=✗
export CHAR_STARTER=❯
export CHAR_INFO="[i]"
export CHAR_USER="[?]"
export CHAR_WARN="[!]"
export CHAR_TASK_START="🚀"
export CHAR_INPUT="[>]"
export CHAR_FINAL_SUCCESS="👍"
export CHAR_FINAL_FAIL="🚫"

# Installation progress tracking
_CURRENT_STEP=0
_TOTAL_STEPS=0

function set_total_steps() {
  _TOTAL_STEPS=$1
  _CURRENT_STEP=0
}

function next_step() {
  ((_CURRENT_STEP++))
  echo_info "Step ${_CURRENT_STEP}/${_TOTAL_STEPS}: $1"
}

# User messaging functions
function echo_info() { echo "${COLOUR_BLUE}${CHAR_INFO}${COLOUR_RESET} $1" }
function echo_user() { echo "${COLOUR_YELLOW}${CHAR_USER}${COLOUR_RESET} $1" }
function echo_success() { echo "${COLOUR_GREEN}${CHAR_OK}${COLOUR_RESET} $1" }
function echo_fail() { echo "${COLOUR_RED}${CHAR_ERROR}${COLOUR_RESET} $1"; exit ${2:-1} }
function echo_warn() { echo "${COLOUR_BOLD_YELLOW}${CHAR_WARN}${COLOUR_RESET} $1" }
function echo_task_start() { echo "${COLOUR_CYAN}${CHAR_TASK_START} ${COLOUR_RESET}$1..." }
function echo_task_done() { echo "${COLOUR_GREEN}${CHAR_OK} ${COLOUR_RESET}$1 done!" }
function echo_input() { echo "${COLOUR_BOLD_CYAN}${CHAR_INPUT} ${COLOUR_RESET}$1" }
function echo_final_success() {
    echo "${COLOUR_GREEN}${CHAR_FINAL_SUCCESS} Process completed successfully!${COLOUR_RESET}"
}
function echo_final_fail() {
    echo "${COLOUR_RED}${CHAR_FINAL_FAIL} Process failed!${COLOUR_RESET}"
}

# Section headers - unified function with action parameter
function echo_title() { echo "${COLOUR_CYAN}${CHAR_STARTER} $@${COLOUR_RESET}" }
function echo_subtitle() { echo "${COLOUR_CYAN}${CHAR_STARTER}${COLOUR_RESET} $1" }
function echo_title_action() {
  local action="$1"
  local target="$2"
  echo_title "${action}" "${target}..."
}

# Backward compatibility aliases
function echo_title_install() { echo_title_action "Installing" "$1"; }
function echo_title_update() { echo_title_action "Updating" "$1"; }

# Text formatting - unified function with type parameter
function echo_styled() {
  local style="$1"
  local text="$2"
  case "$style" in
    "bold") echo "${COLOUR_BOLD_WHITE}${text}${COLOUR_RESET}" ;;
    "highlight") echo "${COLOUR_MAGENTA}${text}${COLOUR_RESET}" ;;
    "subtle") echo "${COLOUR_BLACK}${text}${COLOUR_RESET}" ;;
    *) echo "$text" ;;
  esac
}

# Backward compatibility aliases
function echo_bold() { echo_styled "bold" "$1"; }
function echo_highlight() { echo_styled "highlight" "$1"; }
function echo_subtle() { echo_styled "subtle" "$1"; }

# Layout spacing
function echo_space() {
  local count=${1:-1}
  for ((i=1; i<=count; i++)); do
    printf "\n"
  done
}

# Backward compatibility aliases
function echo_spacex2() { echo_space 2; }
function echo_spacex3() { echo_space 3; }

# Visual separators
function echo_hr() {
  echo "${COLOUR_BOLD_CYAN}----------------------------------------${COLOUR_RESET}"
  echo "$1"
  echo "${COLOUR_BOLD_CYAN}----------------------------------------${COLOUR_RESET}"
}

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
  if [[ ${#_BREW_PACKAGES_TO_INSTALL[@]} -eq 0 ]]; then
    return 0
  fi

  brew install "${_BREW_PACKAGES_TO_INSTALL[@]}"

  # Clear the array and refresh cache
  _BREW_PACKAGES_TO_INSTALL=()
  refresh_brew_cache
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

  brew install --cask "${_CASK_PACKAGES_TO_INSTALL[@]}"

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

  # Derive the likely command name by handling scoped packages, @version, and -cli/-cmd
  local cmd_name="$package"
  # Remove @scope/ prefix if present (e.g., @kud/soap-cli -> soap-cli)
  if [[ "$cmd_name" == @*/* ]]; then
    cmd_name="${cmd_name#*/}"
  fi
  # Remove everything after and including @ (e.g., typescript@next -> typescript)
  cmd_name="${cmd_name%%@*}"
  # Remove -cli or -cmd suffix if present
  if [[ "$cmd_name" == *-cli ]]; then
    cmd_name="${cmd_name%-cli}"
  elif [[ "$cmd_name" == *-cmd ]]; then
    cmd_name="${cmd_name%-cmd}"
  fi

  # Check if command exists (more reliable than type)
  if command -v "$cmd_name" >/dev/null 2>&1; then
    return 0
  fi

  # Add to batch installation array
  _NPM_PACKAGES_TO_INSTALL+=("${package}")
}

function npm_install_run() {
  if [[ ${#_NPM_PACKAGES_TO_INSTALL[@]} -eq 0 ]]; then
    return 0
  fi

  npm install -g "${_NPM_PACKAGES_TO_INSTALL[@]}"

  if [[ $? -ne 0 ]]; then
    # Fallback: try installing individually
    for package in "${_NPM_PACKAGES_TO_INSTALL[@]}"; do
      if ! npm install -g "$package"; then
        # Cleanup and retry
        npm uninstall -g "$package"
        local package_name=$(echo "$package" | cut -d'@' -f1)
        local npm_global_path=$(npm root -g)
        if [[ -n "$npm_global_path" && -d "$npm_global_path/$package_name" ]]; then
          rm -rf "$npm_global_path/$package_name"
        fi
        npm install -g "$package"
      fi
    done
  fi

  # Clear the array
  _NPM_PACKAGES_TO_INSTALL=()
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

  # Check if command exists
  if command -v "$package" >/dev/null 2>&1; then
    echo_subtle "✓ ${package} (already installed)"
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

# Generic command availability checker
ensure_command_available() {
  local command_name="$1"
  local install_hint="${2:-}"
  local exit_on_fail="${3:-true}"
  
  if ! command -v "$command_name" >/dev/null 2>&1; then
    local error_msg="$command_name is not installed."
    if [[ -n "$install_hint" ]]; then
      error_msg="$error_msg $install_hint"
    fi
    
    if [[ "$exit_on_fail" == "true" ]]; then
      echo_fail "$error_msg"
    else
      echo_warn "$error_msg"
      return 1
    fi
  fi
  return 0
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

