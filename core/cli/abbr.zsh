#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🚀 ABBREVIATIONS MANAGER                                                   #
#   ---------------------                                                      #
#   Dynamically manages shell abbreviations from config/cli/abbr.yml          #
#                                                                              #
################################################################################

source ~/.zshrc
source $MY/core/utils/helper.zsh

config_file="$MY/config/cli/abbr.yml"

# Only load if abbr command is available
if ! command -v abbr >/dev/null; then
  return 1
fi

# Check if yq is available
if ! command -v yq >/dev/null; then
  return 1
fi

# Get current abbreviations and erase them all
for abbr_name in $(abbr list-abbreviations 2>/dev/null); do
    abbr erase "$abbr_name"
done

# Read all abbreviations from YAML and apply them
yq eval '.abbreviations | to_entries | .[] | .key + "=" + .value' "$config_file" | while read setting; do
    key=$(echo $setting | cut -d'=' -f1)
    value=$(echo $setting | cut -d'=' -f2-)
    abbr "$key"="$value"
done
