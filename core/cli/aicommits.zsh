#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🤖 AI COMMIT MESSAGE TOOLS                                                 #
#   -------------------------                                                  #
#   Configures AI-powered commit message generators from config/cli/aicommits.yml #
#                                                                              #
################################################################################

source $MY/core/utils/helper.zsh

config_file="$MY/config/cli/aicommits.yml"

################################################################################
# 🎯 AICOMMITS CONFIGURATION
################################################################################

if ensure_command_available "aicommits" "" "false" && ensure_command_available "yq" "" "false"; then
    # Read all aicommits config and apply each setting
    yq eval '.aicommits | to_entries | .[] | .key + "=" + (.value | tostring)' "$config_file" | while read setting; do
        aicommits config set $setting >/dev/null 2>&1
    done
fi

################################################################################
# 🔄 OPENCOMMIT (OCO) CONFIGURATION
################################################################################

if ensure_command_available "oco" "" "false" && ensure_command_available "yq" "" "false"; then
    # Read all opencommit config, transform to OCO_ format and apply
    yq eval '.opencommit | to_entries | .[] | .key + "=" + (.value | tostring)' "$config_file" | while read setting; do
        key=$(echo $setting | cut -d'=' -f1 | tr '[:lower:]' '[:upper:]')
        value=$(echo $setting | cut -d'=' -f2-)
        oco config set OCO_$key=$value >/dev/null 2>&1
    done
fi
