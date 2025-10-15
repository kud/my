#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🧠 CODEX CONFIG WRITER                                                     #
#   -----------------------                                                    #
#   Generates ~/.codex/config.toml by merging common/profile YAML configs and #
#   converting them to TOML for the Codex CLI.                                 #
#                                                                              #
################################################################################

set -euo pipefail

source $MY/core/utils/helper.zsh
source $MY/core/utils/ui-kit.zsh

ui_subsection "Configuring Codex CLI"

# Ensure prerequisites
ensure_command_available "yq" "Install with: brew install yq"
ensure_command_available "python3" "Install with: brew install python"

# Warn (non-fatal) if Codex CLI missing
if ! command -v codex >/dev/null 2>&1; then
  ui_warning_simple "Codex CLI not found in PATH (npm install -g @openai/codex)"
fi

# Determine config sources
PROFILE="${OS_PROFILE:-default}"
COMMON_CONFIG="$MY/config/cli/codex.yml"
PROFILE_CONFIG="$MY/profiles/$PROFILE/config/cli/codex.yml"
output_dir="$HOME/.codex"
output_file="$output_dir/config.toml"

if [[ ! -s "$COMMON_CONFIG" ]]; then
  ui_error_msg "Missing Codex config template: $COMMON_CONFIG" 1
  exit 1
fi

mkdir -p "$output_dir"

# Merge YAML configs
typeset -a _tmp_files=()

tmp_yaml=$(mktemp -t codex-config) || {
  ui_error_msg "Failed to create temporary file for Codex config" 1
  exit 1
}
_tmp_files+=("$tmp_yaml")

cleanup() {
  for file in "${_tmp_files[@]}"; do
    [[ -n "$file" ]] && rm -f "$file" 2>/dev/null || true
  done
}
trap cleanup EXIT

ui_info_simple "Merging Codex config layers"

if [[ -s "$PROFILE_CONFIG" ]]; then
  if ! command yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' \
      "$COMMON_CONFIG" "$PROFILE_CONFIG" > "$tmp_yaml"; then
    ui_error_msg "Failed to merge Codex configs from $COMMON_CONFIG and $PROFILE_CONFIG" 1
    exit 1
  fi
else
  cp "$COMMON_CONFIG" "$tmp_yaml"
fi

ui_info_simple "Checking for environment placeholders"

# Expand environment variables inside the merged YAML (if any)
typeset -a placeholders missing_env
if placeholders_raw="$(grep -o '\${[A-Za-z_][A-Za-z0-9_]*}' "$tmp_yaml" | sort -u 2>/dev/null)"; then
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
  ui_error_msg "Missing environment variables for Codex config: ${missing_env[*]}" 1
  exit 1
fi

if (( ${#placeholders[@]} )); then
  ensure_command_available "envsubst" "Install with: brew install gettext"
  tmp_expanded=$(mktemp -t codex-config-expanded) || {
    ui_error_msg "Failed to create temporary expanded Codex config" 1
    exit 1
  }
  _tmp_files+=("$tmp_expanded")
  substitution_vars=$(printf ' ${%s}' "${placeholders[@]}")
  if ! command envsubst "${substitution_vars# }" < "$tmp_yaml" > "$tmp_expanded"; then
    ui_error_msg "Failed to expand environment variables in Codex config" 1
    exit 1
  fi
  mv "$tmp_expanded" "$tmp_yaml"
  ui_info_simple "Expanded environment placeholders"
fi

ui_info_simple "Rendering Codex config to TOML"

# Prepare Python transformer for reliable TOML conversion
tmp_py=$(mktemp -t codex-toml.py) || {
  ui_error_msg "Failed to create temporary transformer script" 1
  exit 1
}
_tmp_files+=("$tmp_py")
cat <<'PY' > "$tmp_py"
import json
import sys

def format_value(value):
    if isinstance(value, str):
        return json.dumps(value)
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, (int, float)):
        return json.dumps(value)
    if isinstance(value, list):
        return "[" + ", ".join(format_value(v) for v in value) + "]"
    if isinstance(value, dict):
        if not value:
            return "{}"
        inner = ", ".join(f"{k} = {format_value(v)}" for k, v in value.items())
        return "{ " + inner + " }"
    if value is None:
        raise TypeError("null values not supported in Codex config")
    raise TypeError(f"Unsupported TOML value type: {type(value)}")

def main():
    output_path = sys.argv[1]
    data = json.load(sys.stdin)
    lines = []

    settings = data.get("settings") or {}
    for key, value in settings.items():
        lines.append(f"{key} = {format_value(value)}")

    mcp_servers = data.get("mcp_servers") or {}
    if settings and mcp_servers:
        lines.append("")
    for server, config in mcp_servers.items():
        lines.append(f"[mcp_servers.{server}]")
        for key, value in (config or {}).items():
            lines.append(f"{key} = {format_value(value)}")
        lines.append("")

    with open(output_path, "w", encoding="utf-8") as fh:
        fh.write("\n".join(lines))
        fh.write("\n")

if __name__ == "__main__":
    main()
PY

# Convert merged YAML to TOML
tmp_toml=$(mktemp -t codex-config) || {
  ui_error_msg "Failed to create temporary TOML file for Codex config" 1
  exit 1
}
_tmp_files+=("$tmp_toml")

if ! command yq eval -o=json '.' "$tmp_yaml" | command python3 "$tmp_py" "$tmp_toml"; then
  ui_error_msg "Failed to render Codex config as TOML" 1
  exit 1
fi

if [[ ! -s "$tmp_toml" ]]; then
  ui_error_msg "Rendered Codex config is empty" 1
  exit 1
fi

command mv -f "$tmp_toml" "$output_file"
_tmp_files[-1]=""
tmp_toml=""
ui_success_simple "Codex config written to $output_file" 1
