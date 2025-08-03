#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🚀 DEVELOPMENT ENVIRONMENT SETUP                                           #
#   --------------------------------                                          #
#   Complete macOS development environment setup from scratch. Handles        #
#   Xcode installation, repository cloning, and full system configuration.    #
#                                                                              #
################################################################################

# Load helper functions if available
[[ -f "$HOME/my/core/helper" ]] && source "$HOME/my/core/helper" || {
    # Basic fallback functions if helper not available yet
    echo_info() { echo "ℹ️  $1" }
    echo_success() { echo "✅ $1" }
    echo_fail() { echo "❌ $1"; exit ${2:-1} }
    echo_task_start() { echo "🚀 $1..." }
    echo_task_done() { echo "✅ $1 done!" }
    echo_space() { echo "" }
}

echo_task_start "Setting up your development environment"
echo_space

################################################################################
# 📱 DEVELOPMENT TOOLS SETUP
################################################################################

echo_info "Opening Xcode in App Store for installation"
open https://apps.apple.com/us/app/xcode/id497799835
echo_space

echo "Please install Xcode from the App Store, then press Enter here to continue."
read pause

echo_info "Setting up development tools"
sudo xcodebuild -license accept
xcode-select --install
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
xcodebuild -runFirstLaunch

echo_space
echo_success "Development tools ready"

################################################################################
# 📦 PROJECT CONFIGURATION
################################################################################

echo_info "Configuring project"
PROJECT_DIR="$HOME/my"
GIT_REPO="git@github.com:kud/my.git"

if [[ ! -d "$PROJECT_DIR" ]]; then
    echo_info "Downloading project files"
    git clone "$GIT_REPO" "$PROJECT_DIR" || echo_fail "Failed to clone repository"
fi

if [[ -d "$PROJECT_DIR" ]]; then
    echo_info "Configuring secure connection"
    git -C "$PROJECT_DIR" remote set-url origin "$GIT_REPO"
fi

export MY=$HOME/my
echo_space
echo_success "Project configuration complete"

################################################################################
# 🎯 ENVIRONMENT INSTALLATION
################################################################################

echo_info "Installing environment components"
echo_space

$MY/core/utils/intro.zsh &&
$MY/core/main.zsh &&
$MY/core/system/ssh.zsh &&
$MY/core/system/symlink.zsh &&
$MY/core/os/main.zsh

echo_space
echo_task_done "Environment installation complete"

################################################################################
# 📖 SETUP COMPLETION
################################################################################

echo_info "Opening setup guide"
open https://github.com/kud/my/blob/master/doc/postinstall.md

echo_space
echo_success "Environment setup completed successfully! 🎉"
echo_info "Activating new configuration"

source $HOME/.zshrc
