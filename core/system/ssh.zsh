#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🔐 SSH CONFIGURATION MANAGER                                               #
#   ----------------------------                                               #
#   Complete SSH setup including directory creation, key generation,          #
#   configuration templating, and GitHub integration.                         #
#                                                                              #
################################################################################

source $MY/core/utils/helper.zsh

echo_task_start "Setting up SSH configuration"

SSH_DIR="$HOME/.ssh"
SSH_KEY="$SSH_DIR/id_ed25519"
SSH_CONFIG="$SSH_DIR/config"
GITHUB_URL="https://github.com/settings/keys"
GUIDE_URL="https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account"

setup_ssh_directory() {
    echo_info "Creating SSH directory and setting permissions"
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"
    echo_success "SSH directory configured"
}

setup_ssh_config() {
    if [[ ! -f "$SSH_CONFIG" ]]; then
        echo_info "Setting up SSH configuration from template"
        cp "$MY/templates/ssh/config" "$SSH_CONFIG"
        chmod 600 "$SSH_CONFIG"
        echo_success "SSH config template applied"
    else
        echo_info "SSH config already exists, skipping template"
    fi
}

check_existing_ssh_key() {
    if [[ -f "$SSH_KEY" ]]; then
        echo_info "Existing SSH key found at $SSH_KEY"
        read "overwrite?Do you want to overwrite the existing key? (yes/no): "
        if [[ "$overwrite" != "yes" ]]; then
            echo_info "Preserving existing SSH key"
            return 1
        fi
        echo_info "Proceeding with key replacement"
    fi
    return 0
}

get_github_email() {
    echo_info "Configuring SSH key with your GitHub email"
    read "EMAIL?Enter your GitHub email address: "

    if [[ -z "$EMAIL" ]]; then
        echo_fail "Email address is required for SSH key generation"
        return 1
    fi
    return 0
}

generate_ssh_key() {
    echo_info "Generating Ed25519 SSH key pair"
    ssh-keygen -t ed25519 -C "$EMAIL" -f "$SSH_KEY" -N "" || {
        echo_fail "Failed to generate SSH key"
        return 1
    }
    echo_success "SSH key pair generated successfully"
}

setup_ssh_agent() {
    echo_info "Starting SSH agent and adding key"
    eval "$(ssh-agent -s)"
    ssh-add "$SSH_KEY" || {
        echo_fail "Failed to add SSH key to agent"
        return 1
    }
    echo_success "SSH key added to agent"
}

display_public_key() {
    echo_space
    echo_info "Your SSH public key (copy this to GitHub):"
    echo_space
    cat "$SSH_KEY.pub"
    echo_space
}

open_github_settings() {
    echo_info "Opening GitHub SSH settings for key registration"
    echo "To complete setup:"
    echo "1. Copy the public key above"
    echo "2. Add it to your GitHub account in the opened browser"
    echo "3. Follow the guide: $GUIDE_URL"

    open "$GITHUB_URL"
}

# Main execution
setup_ssh_directory
setup_ssh_config

if ! check_existing_ssh_key; then
    echo_task_done "SSH key configuration skipped"
    exit 0
fi

if get_github_email && generate_ssh_key; then
    setup_ssh_agent
    display_public_key
    open_github_settings

    echo_space
    echo_task_done "SSH setup completed"
    echo_success "SSH authentication is now configured for GitHub!"
else
    echo_fail "SSH setup failed"
    exit 1
fi
