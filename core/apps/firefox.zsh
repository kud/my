#!/usr/bin/env zsh

# Load helper functions
source $MY/core/utils/helper.zsh

# Load configuration
CONFIG_FILE="$MY/config/firefox.yml"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo_error "Firefox configuration file not found: $CONFIG_FILE"
    exit 1
fi

# Check for yq
if ! command -v yq &> /dev/null; then
    echo_error "yq is required to parse YAML configuration. Install it with: brew install yq"
    exit 1
fi

# Determine Firefox profile path from YAML configuration
PROFILE_DIR=$(yq eval '.profile.directory' "$CONFIG_FILE" | envsubst)
DEFAULT_FOLDER_PATTERN=$(yq eval '.profile.default_folder_pattern' "$CONFIG_FILE")
DEFAULT_FOLDER=$(ls "$PROFILE_DIR" | grep "$DEFAULT_FOLDER_PATTERN")

# Get file paths from YAML configuration
PREFS_FILE="$PROFILE_DIR/$DEFAULT_FOLDER/$(yq eval '.profile.files.preferences' "$CONFIG_FILE")"
CONTAINERS_FILE="$PROFILE_DIR/$DEFAULT_FOLDER/$(yq eval '.profile.files.containers' "$CONFIG_FILE")"
EXTENSION_SETTINGS_FILE="$PROFILE_DIR/$DEFAULT_FOLDER/$(yq eval '.profile.files.extension_settings' "$CONFIG_FILE")"
USER_CHROME_FILE="$PROFILE_DIR/$DEFAULT_FOLDER/$(yq eval '.profile.files.user_chrome' "$CONFIG_FILE")"

# Function to update Firefox preferences
update_pref() {
  local key="$1"
  local value="$2"
  echo "user_pref(\"$key\", $value);" >>"$PREFS_FILE"
}

# Recursive function to convert YAML hierarchy to dotted preferences
process_yaml_section() {
    local yaml_path="$1"
    local prefix="$2"

    # Get all keys at this level
    local keys=$(yq eval "${yaml_path} | keys | .[]" "$CONFIG_FILE" 2>/dev/null)

    while IFS= read -r key; do
        if [[ -n "$key" && "$key" != "null" ]]; then
            local current_path="${yaml_path}.\"${key}\""
            local dotted_name

            if [[ -n "$prefix" ]]; then
                dotted_name="${prefix}.${key}"
            else
                dotted_name="$key"
            fi

            # Check if this key has children (is an object)
            local has_children=$(yq eval "${current_path} | type" "$CONFIG_FILE" 2>/dev/null)

            if [[ "$has_children" == "!!map" ]]; then
                # Recursively process children
                process_yaml_section "$current_path" "$dotted_name"
            else
                # This is a leaf node, set the preference
                local value=$(yq eval "$current_path" "$CONFIG_FILE" 2>/dev/null)

                if [[ "$value" != "null" && -n "$value" ]]; then
                    if [[ "$value" == "true" || "$value" == "false" ]]; then
                        update_pref "$dotted_name" "$value"
                    elif [[ "$value" =~ ^[0-9]+$ ]]; then
                        update_pref "$dotted_name" "$value"
                    else
                        update_pref "$dotted_name" "\"$value\""
                    fi
                    echo_info "🔧 Firefox pref: $dotted_name = $value"
                fi
            fi
        fi
    done <<< "$keys"
}

echo_title_update "Firefox Nightly Configuration"

echo_info "📂 Profile Directory: $PROFILE_DIR"
echo_info "📁 Profile Folder: $DEFAULT_FOLDER"
echo_info "📄 Preferences File: $PREFS_FILE"
echo_info "📦 Containers File: $CONTAINERS_FILE"
echo_info "🎨 UserChrome CSS: $USER_CHROME_FILE"

# Close Firefox Nightly to safely apply changes
echo_info "🔄 Closing Firefox Nightly to apply configuration changes..."
quit "Firefox Nightly"
sleep 5

# Clear existing preferences file
echo_info "🧹 Clearing existing Firefox preferences..."
> "$PREFS_FILE"

echo_info "🔧 Converting YAML hierarchy to Firefox preferences..."

# Process main preferences section
process_yaml_section ".preferences" ""

echo_success "✅ Firefox preferences have been applied successfully"

# ╔═════════════════════════════════════════════╗
# ║          Firefox userChrome.css Setup      ║
# ╚═════════════════════════════════════════════╝

echo_info "🎨 Setting up Firefox userChrome.css..."

USER_CHROME_DIR=$(dirname "$USER_CHROME_FILE")

if [[ ! -d "$USER_CHROME_DIR" ]]; then
  mkdir -p "$USER_CHROME_DIR"
  echo_info "📁 Created Firefox chrome directory: $USER_CHROME_DIR"
fi

# Extract CSS from YAML and write to file
yq eval '.user_chrome_css' "$CONFIG_FILE" > "$USER_CHROME_FILE"

echo_success "✅ Firefox userChrome.css styles have been applied"

# ╔═════════════════════════════════════════════╗
# ║          Firefox Container Setup           ║
# ╚═════════════════════════════════════════════╝

echo_info "📦 Setting up Firefox Multi-Account Containers..."

# Extract containers configuration and write to JSON file
yq eval '.containers' "$CONFIG_FILE" --output-format=json > "$CONTAINERS_FILE"

echo_success "✅ Firefox containers have been configured"

# Launch Firefox Nightly
echo_info "🚀 Launching Firefox Nightly..."
sleep 2
open -a "Firefox Nightly"

echo_success "🎉 Firefox Nightly configuration complete!"
