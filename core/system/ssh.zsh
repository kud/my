#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🔐 SSH CONFIGURATION MANAGER                                               #
#   ----------------------------                                               #
#   Complete SSH setup including directory creation, key generation,          #
#   configuration templating, and GitHub integration.                         #
#                                                                              #
################################################################################


SSH_DIR="$HOME/.ssh"
SSH_KEY="$SSH_DIR/id_ed25519"
SSH_CONFIG="$SSH_DIR/config"
GITHUB_URL="https://github.com/settings/keys"
GUIDE_URL="https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account"

setup_ssh_directory() {
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"
}

setup_ssh_config() {
    if [[ ! -f "$SSH_CONFIG" ]]; then
        cp "$MY/templates/ssh/config" "$SSH_CONFIG"
        chmod 600 "$SSH_CONFIG"
    fi
}

check_existing_ssh_key() {
    if [[ -f "$SSH_KEY" ]]; then
        read "overwrite?Do you want to overwrite the existing key? (yes/no): "
        if [[ "$overwrite" != "yes" ]]; then
            return 1
        fi
    fi
    return 0
}

get_github_email() {
    read "EMAIL?Enter your GitHub email address: "

    if [[ -z "$EMAIL" ]]; then
        return 1
    fi
    return 0
}

generate_ssh_key() {
    ssh-keygen -t ed25519 -C "$EMAIL" -f "$SSH_KEY" -N "" || {
        return 1
    }
}

setup_ssh_agent() {
    eval "$(ssh-agent -s)"
    ssh-add "$SSH_KEY" || {
        return 1
    }
}

display_public_key() {
    cat "$SSH_KEY.pub"
}

open_github_settings() {
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
    exit 0
fi

if get_github_email && generate_ssh_key; then
    setup_ssh_agent
    display_public_key
    open_github_settings
else
    exit 1
fi
