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

################################################################################
# 🎯 AICOMMITS CONFIGURATION
################################################################################

# Check if aicommits is available
if command -v aicommits >/dev/null 2>&1; then
    aicommits config set type=conventional     # Use conventional commit format
    aicommits config set max-length=100        # Limit commit message length
    aicommits config set model=gpt-4o-mini     # Use efficient GPT model
fi

################################################################################
# 🔄 OPENCOMMIT (OCO) CONFIGURATION
################################################################################

# Check if oco is available
if command -v oco >/dev/null 2>&1; then
    oco config set OCO_PROMPT_MODULE=conventional-commit  # Conventional format
    oco config set OCO_EMOJI=true                         # Enable emojis
    oco config set OCO_MODEL=gpt-4o-mini                  # Use efficient model
fi
