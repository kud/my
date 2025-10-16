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
typeset -a placeholders missing_env substitution_targets
typeset -A skip_placeholder_env
skip_placeholder_env=( [GITHUB_TOKEN]=1 )
if placeholders_raw="$(grep -o '\${[A-Za-z_][A-Za-z0-9_]*}' "$tmp_yaml" | sort -u 2>/dev/null)"; then
  while IFS= read -r placeholder; do
    [[ -z "$placeholder" ]] && continue
    var_name="${placeholder:2:${#placeholder}-3}"
    placeholders+=("$var_name")
    if (( ${+skip_placeholder_env[$var_name]} )); then
      continue
    fi
    if ! printenv "$var_name" >/dev/null 2>&1; then
      missing_env+=("$var_name")
      continue
    fi
    substitution_targets+=("$var_name")
  done <<< "$placeholders_raw"
fi

if (( ${#missing_env[@]} )); then
  ui_error_msg "Missing environment variables for Codex config: ${missing_env[*]}" 1
  exit 1
fi

if (( ${#substitution_targets[@]} )); then
  ensure_command_available "envsubst" "Install with: brew install gettext"
  tmp_expanded=$(mktemp -t codex-config-expanded) || {
    ui_error_msg "Failed to create temporary expanded Codex config" 1
    exit 1
  }
  _tmp_files+=("$tmp_expanded")
  substitution_vars=$(printf ' \\${%s}' "${substitution_targets[@]}")
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
from copy import deepcopy
from pathlib import Path

try:
    import tomllib
except ModuleNotFoundError:  # pragma: no cover
    tomllib = None


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


def is_inline_table(value):
    return isinstance(value, dict) and all(not isinstance(v, dict) for v in value.values())


def write_table(lines, table_name, table_dict, *, skip_if_empty=False, force_nested_inline=False):
    simple_items = []
    nested_items = []

    for key in sorted(table_dict):
        value = table_dict[key]
        if isinstance(value, dict):
            treat_as_nested = not is_inline_table(value) or (force_nested_inline and "." not in table_name)
            if treat_as_nested:
                nested_items.append((key, value))
                continue
        simple_items.append((key, value))

    if skip_if_empty and not simple_items and "." not in table_name:
        for nested_key, nested_val in nested_items:
            write_table(lines, f"{table_name}.{nested_key}", nested_val, skip_if_empty=False)
        return

    if lines and lines[-1] != "":
        lines.append("")
    lines.append(f"[{table_name}]")

    for key, value in simple_items:
        lines.append(f"{key} = {format_value(value)}")

    for nested_key, nested_val in nested_items:
        write_table(lines, f"{table_name}.{nested_key}", nested_val, skip_if_empty=False, force_nested_inline=False)


def load_existing(path):
    if tomllib is None:
        return {}
    file_path = Path(path)
    if not file_path.exists():
        return {}
    try:
        with file_path.open("rb") as fh:
            return tomllib.load(fh)
    except Exception:
        return {}


def merge_data(existing, fresh):
    if not isinstance(existing, dict):
        existing = {}
    result = deepcopy(existing)

    settings = fresh.get("settings") or {}
    for key, value in settings.items():
        result[key] = value

    servers_existing = result.get("mcp_servers")
    servers_merged = deepcopy(servers_existing) if isinstance(servers_existing, dict) else {}
    for server, config in (fresh.get("mcp_servers") or {}).items():
        existing_config = servers_merged.get(server)
        merged_config = deepcopy(existing_config) if isinstance(existing_config, dict) else {}
        merged_config.update(config or {})
        servers_merged[server] = merged_config
    if servers_merged:
        result["mcp_servers"] = servers_merged
    else:
        result.pop("mcp_servers", None)

    for key, value in fresh.items():
        if key in ("settings", "mcp_servers"):
            continue
        result[key] = value

    result.pop("settings", None)
    return result


def render(data):
    lines = []
    simple_items = []
    table_items = []

    for key in sorted(data):
        value = data[key]
        if isinstance(value, dict) and not is_inline_table(value):
            table_items.append((key, value))
        else:
            simple_items.append((key, value))

    for key, value in simple_items:
        lines.append(f"{key} = {format_value(value)}")

    for key, value in table_items:
        write_table(
            lines,
            key,
            value,
            skip_if_empty=True,
            force_nested_inline=(key == "mcp_servers"),
        )

    if not lines or lines[-1] != "":
        lines.append("")
    return "\n".join(lines)


def main():
    output_path = Path(sys.argv[1])
    existing_path = Path(sys.argv[2]) if len(sys.argv) > 2 else output_path
    fresh_data = json.load(sys.stdin)
    existing_data = load_existing(existing_path)
    merged = merge_data(existing_data, fresh_data)
    rendered = render(merged)
    with output_path.open("w", encoding="utf-8") as fh:
        fh.write(rendered)


if __name__ == "__main__":
    main()
PY

# Convert merged YAML to TOML
tmp_toml=$(mktemp -t codex-config) || {
  ui_error_msg "Failed to create temporary TOML file for Codex config" 1
  exit 1
}
_tmp_files+=("$tmp_toml")

if ! command yq eval -o=json '.' "$tmp_yaml" | command python3 "$tmp_py" "$tmp_toml" "$output_file"; then
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
