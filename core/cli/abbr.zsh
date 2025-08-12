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

echo_task_start "Setting up shell abbreviations"

config_file="$MY/config/cli/abbr.yml"

# Only load if abbr command is available
if ! command -v abbr >/dev/null; then
  echo_fail "abbr command not found. Please install zsh-abbr plugin."
  return 1
fi

# Check if yq is available
if ! command -v yq >/dev/null; then
  echo_fail "yq command not found. Please install yq."
  return 1
fi

# Get current abbreviations and erase them all
echo_info "Clearing existing abbreviations"
for abbr_name in $(abbr list-abbreviations 2>/dev/null); do
    abbr erase "$abbr_name" 2>/dev/null
done

echo_space
echo_info "Loading abbreviations from $config_file"

# Read all abbreviations from YAML and apply them
yq eval '.abbreviations | to_entries | .[] | .key + "=" + .value' "$config_file" | while read setting; do
    key=$(echo $setting | cut -d'=' -f1)
    value=$(echo $setting | cut -d'=' -f2-)
    abbr "$key"="$value"
done

echo_space
echo_task_done "Shell abbreviations configured"
