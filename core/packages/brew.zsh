#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🍺 HOMEBREW PACKAGE MANAGER                                                #
#   -------------------------                                                  #
#   Installs and configures Homebrew with essential packages, casks, and      #
#   development tools for a complete macOS development environment.           #
#                                                                              #
################################################################################

source $MY/core/utils/helper.zsh

echo_task_start "Setting up Homebrew package manager"

# Check if yq is available for YAML parsing
if ! command -v yq >/dev/null 2>&1; then
    echo_info "Installing yq for YAML parsing"
    brew install yq
fi

PACKAGES_FILE="$MY/core/packages.yml"
PROFILE_PACKAGES_FILE="$MY/profiles/$OS_PROFILE/core/packages.yml"

################################################################################
# 🍺 HOMEBREW INSTALLATION
################################################################################

if ! command -v brew >/dev/null 2>&1; then
    echo_info "Installing Homebrew package manager"
    sudo -v
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if command -v brew >/dev/null 2>&1; then
        echo_success "Homebrew installed successfully"
    else
        echo_fail "Failed to install Homebrew"
        return 1
    fi
fi

################################################################################
# 🐚 ZSH SHELL SETUP
################################################################################

if [[ $(which zsh) == "/bin/zsh" ]]; then
    echo_info "Installing modern zsh shell via Homebrew"
    brewinstall zsh
    echo "${HOMEBREW_PREFIX}/bin/zsh" | sudo tee -a /etc/shells
    chsh -s ${HOMEBREW_PREFIX}/bin/zsh
    echo_success "Homebrew zsh configured as default shell"
fi

## install bash
if [[ $(which bash) == "/bin/bash" ]]; then
  echo_space
  echo_title_install "bash"
  brewinstall bash
  echo "${HOMEBREW_PREFIX}/bin/bash" | sudo tee -a /etc/shells
fi

## update/upgrade brew
echo_space
echo_title_update "brew"
brew update && brew upgrade

# Initialize brew cache for faster package checking
init_brew_cache


###################################################################################################
# 🏗️  BREW PACKAGES (FORMULAE)
###################################################################################################

collect_packages_from_yaml() {
    local yaml_file="$1"
    local source_desc="$2"

    if [[ ! -f "$yaml_file" ]]; then
        return 0
    fi

    ################################################################################
    # 🔗 Tap Repositories
    ################################################################################
    local taps=$(yq eval '.brew.taps[]?' "$yaml_file" 2>/dev/null)
    if [[ -n "$taps" ]]; then
        while IFS= read -r tap; do
            [[ -n "$tap" ]] && brewtap "$tap"
        done <<< "$taps"
    fi

    ################################################################################
    # 📦 Formulae (CLI tools)
    ################################################################################
    local formulae=$(yq eval '.brew.formulae[]?' "$yaml_file" 2>/dev/null)
    if [[ -n "$formulae" ]]; then
        while IFS= read -r formula; do
            [[ -n "$formula" ]] && brewinstall "$formula"
        done <<< "$formulae"
    fi

    ################################################################################
    # 🖥️ Casks (GUI apps)
    ################################################################################
    local casks=$(yq eval '.brew.casks[]?' "$yaml_file" 2>/dev/null)
    if [[ -n "$casks" ]]; then
        while IFS= read -r cask; do
            [[ -n "$cask" ]] && caskinstall "$cask"
        done <<< "$casks"
    fi
}

run_post_install_from_yaml() {
    local yaml_file="$1"
    local source_desc="$2"

    if [[ ! -f "$yaml_file" ]]; then
        return 0
    fi

    local post_install=$(yq eval '.brew.post_install[]?' "$yaml_file" 2>/dev/null)
    if [[ -n "$post_install" ]]; then
        while IFS= read -r command; do
            if [[ -n "$command" ]]; then
                eval "$command" >/dev/null 2>&1
            fi
        done <<< "$post_install"
    fi
}

# Collect all packages (base + profile)
collect_packages_from_yaml "$PACKAGES_FILE" "base configuration"
collect_packages_from_yaml "$PROFILE_PACKAGES_FILE" "$OS_PROFILE profile"

brewinstall_run
caskinstall_run

echo_space
echo_title "Post-installation setup"
run_post_install_from_yaml "$PACKAGES_FILE" "base configuration"
run_post_install_from_yaml "$PROFILE_PACKAGES_FILE" "$OS_PROFILE profile"

echo_space
echo_task_done "Homebrew setup completed"
