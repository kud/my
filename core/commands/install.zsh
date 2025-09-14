#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🚀 DEVELOPMENT ENVIRONMENT SETUP                                           #
#   --------------------------------                                          #
#   Complete macOS development environment setup from scratch. Handles        #
#   Xcode installation, repository cloning, and full system configuration.    #
#                                                                              #
################################################################################

# Source UI Kit for beautiful output
export MY=${MY:-$HOME/my}
[[ -f "$MY/core/utils/ui-kit.zsh" ]] && source "$MY/core/utils/ui-kit.zsh"

# Welcome message
ui_spacer 2
ui_center_text "🚀 DEVELOPMENT ENVIRONMENT INSTALLER"
ui_divider "═" 60 "$UI_PRIMARY"
ui_spacer

################################################################################
# 📱 DEVELOPMENT TOOLS SETUP
################################################################################

ui_panel "Step 1: Development Tools" "Installing Xcode and command line tools" "info"
ui_spacer

ui_info_msg "Opening Xcode in App Store..."
open https://apps.apple.com/us/app/xcode/id497799835

ui_spacer
ui_warning_simple "Manual action required"
ui_muted "  1. Install Xcode from the App Store"
ui_muted "  2. Launch Xcode once to complete setup"
ui_muted "  3. Return here and press Enter to continue"
ui_spacer

ui_input "Press Enter when Xcode installation is complete"

ui_spacer
ui_info_msg "Configuring development tools..."
ui_spacer

# Show progress for each step
ui_dots_loading 2 "Accepting Xcode license"
sudo xcodebuild -license accept

ui_dots_loading 2 "Installing command line tools"
xcode-select --install 2>/dev/null || ui_muted "  Command line tools already installed"

ui_dots_loading 2 "Setting developer directory"
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer

ui_dots_loading 2 "Running first launch setup"
xcodebuild -runFirstLaunch

ui_success_msg "Development tools configured successfully"

################################################################################
# 📦 PROJECT CONFIGURATION
################################################################################

ui_spacer 2
ui_panel "Step 2: Project Setup" "Downloading configuration files" "info"
ui_spacer

PROJECT_DIR="$HOME/my"
GIT_REPO="git@github.com:kud/my.git"

if [[ ! -d "$PROJECT_DIR" ]]; then
    ui_info_msg "Cloning repository..."
    ui_muted "  Source: $GIT_REPO"
    ui_muted "  Target: $PROJECT_DIR"
    ui_spacer

    # Clone with progress indicator
    git clone "$GIT_REPO" "$PROJECT_DIR" 2>&1 | while IFS= read -r line; do
        if [[ "$line" == *"Receiving objects"* ]] || [[ "$line" == *"Resolving deltas"* ]]; then
            ui_muted "  $line"
        fi
    done

    if [[ $? -eq 0 ]]; then
        ui_success_msg "Repository cloned successfully"
    else
        ui_error_msg "Failed to clone repository"
        ui_muted "  Check your SSH keys and network connection"
        exit 1
    fi
else
    ui_info_simple "Project already exists at $PROJECT_DIR"
fi

if [[ -d "$PROJECT_DIR" ]]; then
    ui_info_msg "Updating remote configuration..."
    git -C "$PROJECT_DIR" remote set-url origin "$GIT_REPO"
    ui_success_simple "Remote URL configured"
fi

export MY=$HOME/my

################################################################################
# 🎯 ENVIRONMENT INSTALLATION
################################################################################

ui_spacer 2
ui_panel "Step 3: Environment Setup" "Installing system components" "info"
ui_spacer

# Component installation with status tracking
components=(
    "intro:Animation & Branding"
    "main:Core System"
    "ssh:SSH Configuration"
    "symlink:Symbolic Links"
    "os:macOS Settings"
)

total_components=${#components[@]}
current_component=0

for component_info in "${components[@]}"; do
    ((current_component++))
    component_name="${component_info%%:*}"
    component_desc="${component_info#*:}"

    ui_info_msg "[$current_component/$total_components] Installing $component_desc..."
    ui_progress_bar $current_component $total_components 40 "█" "░"
    ui_spacer

    case "$component_name" in
        "intro")
            $MY/core/utils/intro.zsh || ui_warning_simple "Intro skipped"
            ;;
        "main")
            $MY/core/main.zsh || { ui_error_msg "Core installation failed"; exit 1; }
            ;;
        "ssh")
            $MY/core/system/ssh.zsh || ui_warning_simple "SSH setup skipped"
            ;;
        "symlink")
            $MY/core/system/symlink.zsh || ui_warning_simple "Symlinks skipped"
            ;;
        "os")
            $MY/core/os/main.zsh || ui_warning_simple "OS settings skipped"
            ;;
    esac

    ui_success_simple "$component_desc installed"
    ui_spacer
done

################################################################################
# 📖 SETUP COMPLETION
################################################################################

ui_spacer 2
ui_divider "═" 60 "$UI_SUCCESS"
ui_spacer

ui_badge "success" " INSTALLATION COMPLETE "
ui_spacer

ui_success_msg "Environment successfully configured!"
ui_spacer

ui_info_simple "Next steps:"
ui_muted "  1. Review post-installation guide (opening now)"
ui_muted "  2. Restart your terminal or run: source ~/.zshrc"
ui_muted "  3. Run 'doctor' to verify installation"

ui_spacer
open https://github.com/kud/my/blob/master/doc/post-install.md

ui_spacer
ui_primary "Thank you for setting up your development environment! "
ui_spacer 2

source $HOME/.zshrc 2>/dev/null || true
