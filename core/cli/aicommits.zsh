#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🤖 AI COMMIT MESSAGE TOOLS                                                 #
#   -------------------------                                                  #
#   Configures AI-powered commit message generators (aicommits & opencommit)  #
#   with conventional commit format and optimal settings for development.     #
#                                                                              #
################################################################################

source $MY/core/utils/helper.zsh

echo_task_start "Configuring AI commit message tools"

################################################################################
# 🎯 AICOMMITS CONFIGURATION
################################################################################

echo_info "Configuring aicommits with conventional commit format"

# Check if aicommits is available
if command -v aicommits >/dev/null 2>&1; then
    aicommits config set type=conventional     # Use conventional commit format
    aicommits config set max-length=100        # Limit commit message length
    aicommits config set model=gpt-4o-mini     # Use efficient GPT model

    echo_success "aicommits configured successfully"
else
    echo_warn "aicommits not found - install via npm if needed"
fi

################################################################################
# 🔄 OPENCOMMIT (OCO) CONFIGURATION
################################################################################

echo_space
echo_info "Configuring opencommit (oco) with emoji support"

# Check if oco is available
if command -v oco >/dev/null 2>&1; then
    oco config set OCO_PROMPT_MODULE=conventional-commit  # Conventional format
    oco config set OCO_EMOJI=true                         # Enable emojis
    oco config set OCO_MODEL=gpt-4o-mini                  # Use efficient model
    oco config set OCO_GITPUSH=false                      # Disable git push
    oco config set OCO_ONE_LINE_COMMIT=true               # Single line commits
    oco config set OCO_DESCRIPTION=false                  # Skip descriptions
    oco config set OCO_TOKENS_MAX_INPUT=4096              # Token limit
    oco config set OCO_TOKENS_MAX_OUTPUT=500              # Output limit

    echo_success "opencommit configured successfully"
else
    echo_warn "opencommit not found - install via npm if needed"
fi

echo_space
echo_task_done "AI commit tools configuration completed"
echo_success "Smart commit messages are now ready for your projects! 🚀"
