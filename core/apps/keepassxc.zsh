#! /usr/bin/env zsh

source $MY/core/utils/helper.zsh

echo_space

echo_title_update "KeepassXC"

# KeePassXC configuration file path
CONFIG_FILE="$HOME/Library/Application Support/keepassxc/keepassxc.ini"

# Ensure the KeePassXC configuration file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "KeePassXC configuration file not found. Please launch KeePassXC at least once to generate it."
  exit 1
fi

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

# Update settings in various sections
update_setting "General" "AutoTypeEntryTitleMatch" "false"
update_setting "General" "AutoTypeEntryURLMatch" "false"
update_setting "General" "ConfigVersion" "2"
update_setting "General" "GlobalAutoTypeKey" "0"
update_setting "General" "GlobalAutoTypeModifiers" "0"
update_setting "General" "MinimizeAfterUnlock" "false"
update_setting "General" "MinimizeOnOpenUrl" "false"
update_setting "General" "UpdateCheckMessageShown" "true"

update_setting "GUI" "ApplicationTheme" "dark"
update_setting "GUI" "TrayIconAppearance" "monochrome"
update_setting "GUI" "CompactMode" "true"
update_setting "GUI" "MinimizeOnStartup" "true"
update_setting "GUI" "HidePasswords" "false"
update_setting "GUI" "HidePreviewPanel" "true"
update_setting "GUI" "HideToolbar" "false"
update_setting "GUI" "HideUsernames" "false"
update_setting "GUI" "ToolButtonStyle" "0"

update_setting "Browser" "Enabled" "true"
update_setting "Browser" "CustomProxyLocation" ""
update_setting "Browser" "BestMatchOnly" "true"

update_setting "PasswordGenerator" "AdditionalChars" "_-&@$%^"
update_setting "PasswordGenerator" "AdvancedMode" "true"
update_setting "PasswordGenerator" "ExcludedChars" ""
update_setting "PasswordGenerator" "Length" "26"
update_setting "PasswordGenerator" "Logograms" "false"
update_setting "PasswordGenerator" "SpecialChars" "true"
update_setting "PasswordGenerator" "Type" "0"
update_setting "PasswordGenerator" "WordCount" "4"
update_setting "PasswordGenerator" "WordSeparator" "-"
update_setting "PasswordGenerator" "WordCase" "2"

update_setting "Security" "IconDownloadFallback" "true"
update_setting "Security" "AutotypeAsk" "false"
update_setting "Security" "LockDatabaseIdle" "true"
update_setting "Security" "LockDatabaseIdleSeconds" "300"

# Confirm success
echo "Configuration updated successfully. Restart KeePassXC to apply changes."
