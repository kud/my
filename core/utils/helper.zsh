#!/usr/bin/env zsh

# set colours
autoload colors
if [[ "$terminfo[colors]" -gt 8 ]]; then
  colors
fi

for COLOUR in RED GREEN YELLOW BLUE MAGENTA CYAN BLACK WHITE; do
  eval COLOUR_$COLOUR='$fg_no_bold[${(L)COLOUR}]'
  eval COLOUR_BOLD_$COLOUR='$fg_bold[${(L)COLOUR}]'
done
eval COLOUR_RESET='$reset_color'

# --- VISUAL FEEDBACK SYSTEM ---
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

# --- INSTALLATION PROGRESS ---
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

# --- USER MESSAGING ---

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

# --- SECTION HEADERS ---

function echo_title() { echo "${COLOUR_CYAN}${CHAR_STARTER} $@${COLOUR_RESET}" }
function echo_subtitle() { echo "${COLOUR_CYAN}${CHAR_STARTER}${COLOUR_RESET} $1" }
function echo_title_install() { echo_title "Installing" $1"..." }
function echo_title_update() { echo_title "Updating" $1"..." }

# --- TEXT FORMATTING ---

function echo_bold() { echo "${COLOUR_BOLD_WHITE}$1${COLOUR_RESET}" }
function echo_highlight() { echo "${COLOUR_MAGENTA}$1${COLOUR_RESET}" }
function echo_subtle() { echo "${COLOUR_BLACK}$1${COLOUR_RESET}" }

# --- LAYOUT SPACING ---

function echo_space() {
  printf "\n"
}
function echo_spacex2() {
  echo_space
  echo_space
}
function echo_spacex3() {
  echo_space
  echo_space
  echo_space
}

# --- VISUAL SEPARATORS ---

function echo_hr() {
  echo "${COLOUR_BOLD_CYAN}----------------------------------------${COLOUR_RESET}"
  echo "$1"
  echo "${COLOUR_BOLD_CYAN}----------------------------------------${COLOUR_RESET}"
}

# --- PACKAGE MANAGEMENT ---

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

function brewtap() {
  if ! brew tap | grep "${@}" > /dev/null; then
    brew tap "${@}"
  fi
}

function brewinstall() {
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
    echo_subtle "✓ ${package} (already installed and up-to-date)"
    return 0
  fi

  # Add to batch installation array
  _BREW_PACKAGES_TO_INSTALL+=("${package}")
  if echo "$_BREW_FORMULAE_CACHE" | grep -q "^${package_name}$"; then
    echo_info "🔄 ${package} (queued for upgrade)"
  else
    echo_info "🍺 ${package} (queued for installation)"
  fi
}

function brewinstall_run() {
  if [[ ${#_BREW_PACKAGES_TO_INSTALL[@]} -eq 0 ]]; then
    echo_subtle "No brew packages to install"
    return 0
  fi

  echo_task_start "Installing ${#_BREW_PACKAGES_TO_INSTALL[@]} brew packages"
  echo_info "Packages: ${_BREW_PACKAGES_TO_INSTALL[*]}"
  brew install "${_BREW_PACKAGES_TO_INSTALL[@]}"

  if [[ $? -eq 0 ]]; then
    echo_success "Successfully installed ${#_BREW_PACKAGES_TO_INSTALL[@]} brew packages"
  else
    echo_warn "Some brew packages may have failed to install"
  fi

  # Clear the array and refresh cache
  _BREW_PACKAGES_TO_INSTALL=()
  refresh_brew_cache
}

function brewuninstall() {
  brew uninstall "${@}"
}

function caskinstall() {
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
    echo_subtle "✓ ${package} (already installed)"
    return 0
  fi

  # Add to batch installation array
  _CASK_PACKAGES_TO_INSTALL+=("${package}")
  echo_info "📱 ${package} (queued for installation)"
}

function caskinstall_run() {
  if [[ ${#_CASK_PACKAGES_TO_INSTALL[@]} -eq 0 ]]; then
    echo_subtle "No cask packages to install"
    return 0
  fi

  echo_task_start "Installing ${#_CASK_PACKAGES_TO_INSTALL[@]} cask packages"
  echo_info "Packages: ${_CASK_PACKAGES_TO_INSTALL[*]}"
  brew install --cask "${_CASK_PACKAGES_TO_INSTALL[@]}"

  if [[ $? -eq 0 ]]; then
    echo_success "Successfully installed ${#_CASK_PACKAGES_TO_INSTALL[@]} cask packages"
  else
    echo_warn "Some cask packages may have failed to install"
  fi

  # Clear the array and refresh cache
  _CASK_PACKAGES_TO_INSTALL=()
  refresh_brew_cache
}

function caskuninstall() {
  brew uninstall --cask "${@}"
}

function geminstall() {
  if ! type "${@}" > /dev/null; then
    gem install "${@}"
  fi
}

function npminstall() {
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
    echo_subtle "✓ ${package} (already installed)"
    return 0
  fi

  # Add to batch installation array
  _NPM_PACKAGES_TO_INSTALL+=("${package}")
  echo_info "📦 ${package} (queued for installation)"
}

function npminstall_run() {
  if [[ ${#_NPM_PACKAGES_TO_INSTALL[@]} -eq 0 ]]; then
    echo_subtle "No npm packages to install"
    return 0
  fi

  echo_task_start "Installing ${#_NPM_PACKAGES_TO_INSTALL[@]} npm packages"
  echo_info "Packages: ${_NPM_PACKAGES_TO_INSTALL[*]}"
  npm install -g --quiet "${_NPM_PACKAGES_TO_INSTALL[@]}"

  if [[ $? -eq 0 ]]; then
    echo_success "Successfully installed ${#_NPM_PACKAGES_TO_INSTALL[@]} npm packages"
  else
    echo_warn "Some npm packages may have failed to install"
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
