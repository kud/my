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
source $MY/core/utils/ui-kit.zsh

config_file="$MY/config/cli/abbr.yml"


# Only load if abbr command is available
if ! ensure_command_available "abbr" "" "false"; then
  return 1
fi

# Check if yq is available
if ! ensure_command_available "yq" "Install with: brew install yq" "false"; then
  return 1
fi

# Build desired abbreviations map from YAML (key=value lines)
typeset -A desired_abbrs
while IFS='=' read -r key value; do
  [[ -z "$key" ]] && continue
  desired_abbrs[$key]="$value"
done < <(yq eval '.abbreviations | to_entries | .[] | .key + "=" + .value' "$config_file")

# Collect current abbreviation keys (strip quotes if any)
current_keys=()
while IFS= read -r line; do
  line=${line//\"/}
  [[ -n "$line" ]] && current_keys+=("$line")
done < <(abbr list-abbreviations 2>/dev/null)

# Remove stale abbreviations (keys present now but not in config)
stale_abbrs=()
for name in $current_keys; do
  if [[ -z ${desired_abbrs[$name]+_} ]]; then
    abbr erase "$name" >/dev/null 2>&1
    stale_abbrs+=("$name")
  fi
done

# Add new abbreviations (keys in config but not currently defined)
added_abbrs=()
for name value in ${(kv)desired_abbrs}; do
  if ! (( ${current_keys[(I)$name]} )); then
    if abbr "$name"="$value" >/dev/null 2>&1; then
      added_abbrs+=("$name")
    fi
  else
    # Key exists; redefine to ensure value matches config (cheap idempotent)
    abbr "$name"="$value" >/dev/null 2>&1
  fi
done

# Reporting
if [[ ${#stale_abbrs[@]} -gt 0 ]]; then
  count=${#stale_abbrs[@]}
  noun="abbreviation"
  [[ $count -ne 1 ]] && noun+="s"
  ui_info_simple "Removed $count stale $noun"
fi
if [[ ${#added_abbrs[@]} -gt 0 ]]; then
  count=${#added_abbrs[@]}
  noun="abbreviation"
  [[ $count -ne 1 ]] && noun+="s"
  ui_info_simple "Added $count new $noun"
  for n in $added_abbrs; do echo "  • $n"; done
fi
if [[ ${#stale_abbrs[@]} -eq 0 && ${#added_abbrs[@]} -eq 0 ]]; then
  ui_info_simple "Abbreviations already aligned with config"
fi
