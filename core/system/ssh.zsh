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

ui_spacer

setup_ssh_directory() {
    ui_primary "🔐 Setting up SSH"
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"
    ui_success_simple "SSH directory configured"
}

setup_ssh_config() {
    if [[ ! -f "$SSH_CONFIG" ]]; then
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
        ui_warning_simple "Existing SSH key detected at $SSH_KEY"

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
    ui_primary "📧 GitHub Account Setup"

    EMAIL=$(ui_input "Enter your GitHub email address")

    if [[ -z "$EMAIL" ]]; then
        ui_error_simple "Email address is required"
        return 1
    fi

    ui_success_simple "Email: $EMAIL"
    return 0
}

generate_ssh_key() {
    ui_spacer
    ui_info_simple "Generating ED25519 SSH key..."
    ui_muted "  Algorithm: ED25519 (recommended)"
    ui_muted "  Comment: $EMAIL"

    ssh-keygen -t ed25519 -C "$EMAIL" -f "$SSH_KEY" -N "" 2>&1 | while IFS= read -r line; do
        ui_muted "  $line"
    done

    local output
    output=$(ssh-keygen -t ed25519 -C "$EMAIL" -f "$SSH_KEY" -N "" 2>&1)
    local status=$?
    while IFS= read -r line; do
        ui_muted "  $line"
    done <<< "$output"

    if [[ $status -eq 0 ]]; then
        ui_success_simple "SSH key generated"
        ui_muted "  Private key: $SSH_KEY"
        ui_muted "  Public key: $SSH_KEY.pub"
        return 0
    else
        ui_error_simple "Failed to generate SSH key"
        return 1
    fi
}

setup_ssh_agent() {
    ui_spacer
    ui_info_simple "Configuring SSH agent..."

    eval "$(ssh-agent -s)" > /dev/null 2>&1
    ssh-add "$SSH_KEY" 2>&1 | while IFS= read -r line; do
        ui_muted "  $line"
    done

    if [[ ${PIPESTATUS[0]} -eq 0 ]]; then
        ui_success_simple "SSH key added to agent"
        return 0
    else
        ui_error_simple "Failed to add key to SSH agent"
        return 1
    fi
}

display_public_key() {
    ui_spacer
    ui_primary "📋 Your SSH Public Key"
    ui_spacer
    cat "$SSH_KEY.pub"
    ui_spacer
}

open_github_settings() {
    ui_primary "🔗 GitHub Integration"
    ui_spacer
    ui_info_simple "Next steps:"
    ui_muted "  1. Copy the public key shown above"
    ui_muted "  2. Add it to GitHub (browser opening now)"
    ui_muted "  3. Give your key a descriptive title"
    ui_spacer

    ui_info_simple "Opening GitHub SSH settings..."
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
        ui_error_simple "SSH setup failed"
        ui_muted "  Check the error messages above for details"
        ui_spacer
        exit 1
    fi
}

# Execute main function
main
