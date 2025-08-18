#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🤖 AI COMMIT MESSAGE TOOLS                                                 #
#   -------------------------                                                  #
#   Configures AI-powered commit message generators from config/cli/aicommits.yml #
#                                                                              #
################################################################################

source $MY/core/utils/helper.zsh
source $MY/core/utils/ui-kit.zsh

config_file="$MY/config/cli/aicommits.yml"

################################################################################
# 🎯 AICOMMITS CONFIGURATION
################################################################################

if ensure_command_available "aicommits" "" "false" && ensure_command_available "yq" "" "false"; then
    # Read all aicommits config and apply each setting
    ui_subsection "Configuring aicommits"
    yq eval '.aicommits | to_entries | .[] | .key + "=" + (.value | tostring)' "$config_file" | while read setting; do
        echo "  • $setting"
        aicommits config set $setting >/dev/null 2>&1
    done
    ui_success_simple "aicommits configured"
else
    ui_info_simple "aicommits not available, skipping configuration"
fi

ui_spacer

################################################################################
# 🔄 OPENCOMMIT (OCO) CONFIGURATION
################################################################################

if ensure_command_available "oco" "" "false" && ensure_command_available "yq" "" "false"; then
    # Read all opencommit config, transform to OCO_ format and apply
    ui_subsection "Configuring opencommit"
    yq eval '.opencommit | to_entries | .[] | .key + "=" + (.value | tostring)' "$config_file" | while read setting; do
        key=$(echo $setting | cut -d'=' -f1 | tr '[:lower:]' '[:upper:]')
        value=$(echo $setting | cut -d'=' -f2-)
        echo "  • OCO_$key=$value"
        oco config set OCO_$key=$value >/dev/null 2>&1
    done
    ui_success_simple "opencommit configured"
else
    ui_info_simple "oco not available, skipping configuration"
fi
