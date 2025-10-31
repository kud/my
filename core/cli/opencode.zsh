#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🧪 OPENCODE CONFIG WRITER                                                   #
#   -------------------------                                                  #
#   Generates ~/.config/opencode/opencode.jsonc from config/cli/opencode.yml.  #
#   Also configures MCP servers for opencode.                                 #
#                                                                              #
################################################################################

source $MY/core/utils/helper.zsh
source $MY/core/utils/ui-kit.zsh

# Get current profile
PROFILE="${OS_PROFILE:-default}"


# Define config file paths
COMMON_CONFIG="$MY/config/cli/opencode.yml"
PROFILE_CONFIG="$MY/profiles/$PROFILE/config/cli/opencode.yml"
config_dir="$HOME/.config/opencode"
output_file="$config_dir/opencode.jsonc"

mkdir -p "$config_dir"

ui_subsection "Configuring OpenCode"

# Check if common config exists and is not empty
if [[ ! -s "$COMMON_CONFIG" ]]; then
    ui_error_msg "Common config $COMMON_CONFIG is missing or empty" 1
    exit 1
fi

# If profile config exists and is not empty, merge, else just use common
if ! tmp_file="$(mktemp "$config_dir/opencode.jsonc.XXXXXX")"; then
    ui_error_msg "Failed to create temporary file in $config_dir" 1
    exit 1
fi

if [[ -s "$PROFILE_CONFIG" ]]; then
    if ! yq eval-all -o=json 'select(fileIndex == 0) * select(fileIndex == 1)' \
        "$COMMON_CONFIG" "$PROFILE_CONFIG" > "$tmp_file"; then
        rm -f "$tmp_file"
        ui_error_msg "Failed to merge $COMMON_CONFIG with $PROFILE_CONFIG" 1
        exit 1
    fi
else
    if ! yq eval -o=json '.' "$COMMON_CONFIG" > "$tmp_file"; then
        rm -f "$tmp_file"
        ui_error_msg "Failed to render $COMMON_CONFIG as JSON" 1
        exit 1
    fi
fi

if [[ ! -s "$tmp_file" ]]; then
    rm -f "$tmp_file"
    ui_error_msg "Generated opencode config is empty" 1
    exit 1
fi

typeset -a placeholders missing_env
if placeholders_raw="$(grep -o '\${[A-Za-z_][A-Za-z0-9_]*}' "$tmp_file" | sort -u 2>/dev/null)"; then
    while IFS= read -r placeholder; do
        [[ -z "$placeholder" ]] && continue
        var_name="${placeholder:2:${#placeholder}-3}"
        placeholders+=("$var_name")
        if ! printenv "$var_name" >/dev/null 2>&1; then
            missing_env+=("$var_name")
        fi
    done <<< "$placeholders_raw"
fi

if (( ${#missing_env[@]} )); then
    rm -f "$tmp_file"
    ui_error_msg "Missing environment variables: ${missing_env[*]}" 1
    exit 1
fi

if (( ${#placeholders[@]} )); then
    if ! command -v envsubst >/dev/null 2>&1; then
        rm -f "$tmp_file"
        ui_error_msg "envsubst command not found; cannot expand environment variables" 1
        exit 1
    fi
    if ! tmp_env="$(mktemp "$config_dir/opencode.jsonc.env.XXXXXX")"; then
        rm -f "$tmp_file"
        ui_error_msg "Failed to create temporary file for env expansion in $config_dir" 1
        exit 1
    fi
    substitution_vars=$(printf ' ${%s}' "${placeholders[@]}")
    if ! envsubst "${substitution_vars# }" < "$tmp_file" > "$tmp_env"; then
        rm -f "$tmp_file" "$tmp_env"
        ui_error_msg "Failed to expand environment variables in generated config" 1
        exit 1
    fi
    mv "$tmp_env" "$tmp_file"
fi

mv "$tmp_file" "$output_file"

ui_success_simple "Opencode configuration complete" 1
ui_info_simple "Config file: $output_file" 1
