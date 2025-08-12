#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🤖 AI COMMIT MESSAGE TOOLS                                                 #
#   -------------------------                                                  #
#   Configures AI-powered commit message generators from config/cli/aicommits.yml #
#                                                                              #
################################################################################

source $MY/core/utils/helper.zsh

echo_task_start "Configuring AI commit message tools"

config_file="$MY/config/cli/aicommits.yml"

################################################################################
# 🎯 AICOMMITS CONFIGURATION
################################################################################

echo_info "Configuring aicommits"

if command -v aicommits >/dev/null 2>&1 && command -v yq >/dev/null 2>&1; then
    # Read all aicommits config and apply each setting
    yq eval '.aicommits | to_entries | .[] | .key + "=" + (.value | tostring)' "$config_file" | while read setting; do
        aicommits config set $setting
    done

    echo_success "aicommits configured successfully"
else
    echo_warn "aicommits or yq not found - install if needed"
fi

################################################################################
# 🔄 OPENCOMMIT (OCO) CONFIGURATION
################################################################################

echo_space
echo_info "Configuring opencommit"

if command -v oco >/dev/null 2>&1 && command -v yq >/dev/null 2>&1; then
    # Read all opencommit config, transform to OCO_ format and apply
    yq eval '.opencommit | to_entries | .[] | .key + "=" + (.value | tostring)' "$config_file" | while read setting; do
        key=$(echo $setting | cut -d'=' -f1 | tr '[:lower:]' '[:upper:]')
        value=$(echo $setting | cut -d'=' -f2-)
        oco config set OCO_$key=$value
    done

    echo_success "opencommit configured successfully"
else
    echo_warn "opencommit or yq not found - install if needed"
fi

echo_space
echo_task_done "AI commit tools configuration completed"
echo_success "Smart commit messages are now ready for your projects! 🚀"
