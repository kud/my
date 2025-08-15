#! /usr/bin/env zsh

# Source required utilities
source $MY/core/utils/helper.zsh

ensure_command_available "yq" "Install with: brew install yq"

CONFIG_YAML="$MY/config/apps/keepassxc.yml"
PROFILE_CONFIG_YAML="$MY/profiles/$OS_PROFILE/config/apps/keepassxc.yml"
[[ -f "$CONFIG_YAML" ]] || exit 1

# KeePassXC configuration file path
CONFIG_FILE="$HOME/Library/Application Support/keepassxc/keepassxc.ini"

# Ensure the KeePassXC configuration file exists
[[ -f "$CONFIG_FILE" ]] || exit 1

# Function to update or add a key-value pair in a section
update_setting() {
  local section="$1"
  local key="$2"
  local value="$3"

  local escaped_value=$(echo "$value" | sed -e 's/[\/&]/\\&/g')

  if ! grep -q "^\[$section\]" "$CONFIG_FILE"; then
    echo -e "\n[$section]" >> "$CONFIG_FILE"
  fi

  if sed -n "/^\[$section\]/,/^\[.*\]/p" "$CONFIG_FILE" | grep -q "^$key="; then
    sed -i "/^\[$section\]/,/^\[.*\]/ s|^$key=.*|$key=$escaped_value|" "$CONFIG_FILE"
  else
    sed -i "/^\[$section\]/ a\\
$key=$escaped_value
" "$CONFIG_FILE"
  fi
}

# Function to convert camelCase to PascalCase (first letter uppercase)
camel_to_pascal() {
  echo "$1" | sed 's/^./\U&/'
}

# Function to apply settings from YAML configuration
apply_yaml_settings() {
  local section_name="$1"
  local yaml_path="$2"


  # Merge configurations: start with main config, then overlay profile-specific config
  local merged_config=$(yq eval ".$yaml_path // {}" "$CONFIG_YAML")

  if [[ -f "$PROFILE_CONFIG_YAML" ]]; then
    local profile_config=$(yq eval ".$yaml_path // {}" "$PROFILE_CONFIG_YAML" 2>/dev/null)
    if [[ "$profile_config" != "{}" && "$profile_config" != "null" ]]; then
      merged_config=$(echo "$merged_config $profile_config" | yq eval-all '. as $item ireduce ({}; . * $item)' -)
    fi
  fi

  # Get all keys from merged configuration
  local keys=$(echo "$merged_config" | yq eval 'keys | .[]' - 2>/dev/null)

  while IFS= read -r key; do
    if [[ -n "$key" && "$key" != "null" ]]; then
      local value=$(echo "$merged_config" | yq eval ".$key" -)
      local ini_key=$(camel_to_pascal "$key")

      # Convert boolean values to lowercase
      if [[ "$value" == "true" || "$value" == "false" ]]; then
        value=$(echo "$value" | tr '[:upper:]' '[:lower:]')
      fi

      update_setting "$section_name" "$ini_key" "$value"
    fi
  done <<< "$keys"
}

# Apply all sections from YAML configuration dynamically
SECTIONS=$(yq eval 'keys | .[]' "$CONFIG_YAML" 2>/dev/null)

while IFS= read -r section; do
    if [[ -n "$section" && "$section" != "null" ]]; then
        # Use section name directly from YAML (already in correct KeePassXC format)
        apply_yaml_settings "$section" "$section"
    fi
done <<< "$SECTIONS"

# Configuration complete
