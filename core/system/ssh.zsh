#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🔐 SSH CONFIGURATION MANAGER                                               #
#   ----------------------------                                               #
#   Complete SSH setup including directory creation, key generation,          #
#   configuration templating, and GitHub integration.                         #
#                                                                              #
################################################################################

# Source UI Kit for beautiful output
source $MY/core/utils/ui-kit.zsh

SSH_DIR="$HOME/.ssh"
SSH_KEY="$SSH_DIR/id_ed25519"
SSH_CONFIG="$SSH_DIR/config"
GITHUB_URL="https://github.com/settings/keys"
GUIDE_URL="https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account"

# Welcome message
ui_spacer
ui_panel "SSH Configuration" "Setting up secure shell authentication" "info"
ui_spacer

setup_ssh_directory() {
    ui_info_msg "Creating SSH directory..."
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"
    ui_success_simple "SSH directory configured"
}

setup_ssh_config() {
    if [[ ! -f "$SSH_CONFIG" ]]; then
        ui_info_msg "Installing SSH configuration template..."
        cp "$MY/templates/ssh/config" "$SSH_CONFIG"
        chmod 600 "$SSH_CONFIG"
        ui_success_simple "SSH config installed"
    else
        ui_info_simple "SSH config already exists"
    fi
}

check_existing_ssh_key() {
    if [[ -f "$SSH_KEY" ]]; then
        ui_spacer
        ui_warning_msg "Existing SSH key detected"
        ui_muted "  Location: $SSH_KEY"
        ui_spacer
        
        if ui_confirm "Replace existing SSH key?"; then
            ui_warning_simple "Existing key will be overwritten"
            return 0
        else
            ui_info_simple "Keeping existing SSH key"
            return 1
        fi
    fi
    return 0
}

get_github_email() {
    ui_spacer
    ui_divider "─" 60 "$UI_PRIMARY"
    ui_primary "📧 GitHub Account Setup"
    ui_divider "─" 60 "$UI_PRIMARY"
    ui_spacer
    
    EMAIL=$(ui_input "Enter your GitHub email address")
    
    if [[ -z "$EMAIL" ]]; then
        ui_error_msg "Email address is required"
        return 1
    fi
    
    ui_success_simple "Email: $EMAIL"
    return 0
}

generate_ssh_key() {
    ui_spacer
    ui_info_msg "Generating ED25519 SSH key..."
    ui_muted "  Algorithm: ED25519 (recommended)"
    ui_muted "  Comment: $EMAIL"
    ui_spacer
    
    ssh-keygen -t ed25519 -C "$EMAIL" -f "$SSH_KEY" -N "" 2>&1 | while IFS= read -r line; do
        ui_muted "  $line"
    done
    
    if [[ ${PIPESTATUS[0]} -eq 0 ]]; then
        ui_success_msg "SSH key generated successfully"
        ui_muted "  Private key: $SSH_KEY"
        ui_muted "  Public key: $SSH_KEY.pub"
        return 0
    else
        ui_error_msg "Failed to generate SSH key"
        return 1
    fi
}

setup_ssh_agent() {
    ui_spacer
    ui_info_msg "Configuring SSH agent..."
    
    eval "$(ssh-agent -s)" > /dev/null 2>&1
    ssh-add "$SSH_KEY" 2>&1 | while IFS= read -r line; do
        ui_muted "  $line"
    done
    
    if [[ ${PIPESTATUS[0]} -eq 0 ]]; then
        ui_success_simple "SSH key added to agent"
        return 0
    else
        ui_error_msg "Failed to add key to SSH agent"
        return 1
    fi
}

display_public_key() {
    ui_spacer
    ui_divider "═" 60 "$UI_SUCCESS"
    ui_spacer
    ui_badge "success" " PUBLIC KEY GENERATED "
    ui_spacer
    
    ui_box "$(cat "$SSH_KEY.pub")" "Your SSH Public Key" 70
    ui_spacer
}

open_github_settings() {
    ui_panel "GitHub Integration" "Complete setup by adding your key to GitHub" "warning"
    ui_spacer
    
    ui_info_simple "Next steps:"
    ui_muted "  1. Copy the public key shown above"
    ui_muted "  2. Add it to GitHub (browser opening now)"
    ui_muted "  3. Give your key a descriptive title"
    ui_spacer
    
    ui_info_simple "Helpful resources:"
    ui_muted "  GitHub Settings: $GITHUB_URL"
    ui_muted "  Setup Guide: $GUIDE_URL"
    ui_spacer
    
    ui_info_msg "Opening GitHub SSH settings..."
    open "$GITHUB_URL"
    
    ui_spacer
    ui_success_msg "SSH setup complete! 🎉"
    ui_muted "  Test your connection: ssh -T git@github.com"
    ui_spacer
}

# Main execution
main() {
    setup_ssh_directory
    setup_ssh_config
    
    if ! check_existing_ssh_key; then
        ui_spacer
        ui_info_simple "SSH setup cancelled"
        ui_spacer
        exit 0
    fi
    
    if get_github_email && generate_ssh_key; then
        setup_ssh_agent
        display_public_key
        open_github_settings
    else
        ui_spacer
        ui_error_msg "SSH setup failed"
        ui_muted "  Check the error messages above for details"
        ui_spacer
        exit 1
    fi
}

# Execute main function
main