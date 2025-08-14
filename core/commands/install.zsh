#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🚀 DEVELOPMENT ENVIRONMENT SETUP                                           #
#   --------------------------------                                          #
#   Complete macOS development environment setup from scratch. Handles        #
#   Xcode installation, repository cloning, and full system configuration.    #
#                                                                              #
################################################################################



################################################################################
# 📱 DEVELOPMENT TOOLS SETUP
################################################################################

echo "Opening Xcode in App Store for installation"
open https://apps.apple.com/us/app/xcode/id497799835

echo "Please install Xcode from the App Store, then press Enter here to continue."
read pause

echo "Setting up development tools"
sudo xcodebuild -license accept
xcode-select --install
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
xcodebuild -runFirstLaunch


################################################################################
# 📦 PROJECT CONFIGURATION
################################################################################

echo "Configuring project"
PROJECT_DIR="$HOME/my"
GIT_REPO="git@github.com:kud/my.git"

if [[ ! -d "$PROJECT_DIR" ]]; then
    echo "Downloading project files"
    git clone "$GIT_REPO" "$PROJECT_DIR" || { echo "Failed to clone repository" >&2; exit 1; }
fi

if [[ -d "$PROJECT_DIR" ]]; then
    echo "Configuring secure connection"
    git -C "$PROJECT_DIR" remote set-url origin "$GIT_REPO"
fi

export MY=$HOME/my

################################################################################
# 🎯 ENVIRONMENT INSTALLATION
################################################################################

echo "Installing environment components"

$MY/core/utils/intro.zsh &&
$MY/core/main.zsh &&
$MY/core/system/ssh.zsh &&
$MY/core/system/symlink.zsh &&
$MY/core/os/main.zsh


################################################################################
# 📖 SETUP COMPLETION
################################################################################

echo "Opening setup guide"
open https://github.com/kud/my/blob/master/doc/post-install.md

echo "Environment setup completed successfully! 🎉"
echo "Activating new configuration"

source $HOME/.zshrc
