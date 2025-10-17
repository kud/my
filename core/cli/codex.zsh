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
ensure_command_available "jq" "Install with: brew install jq"

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

tmp_fresh_json=$(mktemp -t codex-fresh-json) || {
  ui_error_msg "Failed to create temporary JSON file for Codex config" 1
  exit 1
}
_tmp_files+=("$tmp_fresh_json")

if ! command yq eval -o=json '.' "$tmp_yaml" > "$tmp_fresh_json"; then
  ui_error_msg "Failed to convert merged Codex config to JSON" 1
  exit 1
fi

tmp_existing_json=$(mktemp -t codex-existing-json) || {
  ui_error_msg "Failed to create temporary JSON file for existing Codex config" 1
  exit 1
}
_tmp_files+=("$tmp_existing_json")

if [[ -f "$output_file" ]]; then
  if ! command yq eval --input-format=toml -o=json '.' "$output_file" > "$tmp_existing_json" 2>/dev/null; then
    printf '{}' > "$tmp_existing_json"
  fi
else
  printf '{}' > "$tmp_existing_json"
fi

tmp_merged_json=$(mktemp -t codex-merged-json) || {
  ui_error_msg "Failed to create temporary merged JSON file for Codex config" 1
  exit 1
}
_tmp_files+=("$tmp_merged_json")

jq_merge_program='
  def ensure_obj($x): if ($x | type) == "object" then $x else {} end;
  def merge_simple($base; $overrides):
    reduce (ensure_obj($overrides) | to_entries[]) as $entry (ensure_obj($base);
      .[$entry.key] = $entry.value
    );
  def merge_servers($existing; $fresh):
    reduce (ensure_obj($fresh) | to_entries[]) as $srv (
      ensure_obj($existing);
      .[$srv.key] = merge_simple(.[$srv.key]; $srv.value)
    );
  def merge_configs($existing; $fresh):
    (merge_simple($existing; $fresh.settings))
    | .mcp_servers = merge_servers(.mcp_servers; $fresh.mcp_servers)
    | (merge_simple(.; ($fresh | del(.settings, .mcp_servers))))
    | del(.settings)
    | if (.mcp_servers | type) == "object" and (.mcp_servers | length) == 0 then del(.mcp_servers) else . end;

  (.[0] // {}) as $existing
  | (.[1] // {}) as $fresh
  | merge_configs($existing; $fresh)
'

if ! command jq -s "$jq_merge_program" "$tmp_existing_json" "$tmp_fresh_json" > "$tmp_merged_json"; then
  ui_error_msg "Failed to merge Codex configs" 1
  exit 1
fi

tmp_render_jq=$(mktemp -t codex-render.jq) || {
  ui_error_msg "Failed to create temporary renderer for Codex config" 1
  exit 1
}
_tmp_files+=("$tmp_render_jq")

cat <<'JQ' > "$tmp_render_jq"
def key_to_string($k): ($k | if type=="string" then . else tostring end);
def bare_key($s): ($s | test("^[A-Za-z0-9_-]+$"));
def format_key:
  (key_to_string(.)) as $s
  | if bare_key($s) then $s
    else "\"" + ($s | gsub("\\\\";"\\\\") | gsub("\"";"\\\"")) + "\""
    end;
def format_value:
  if type=="string" then @json
  elif type=="boolean" then (if . then "true" else "false" end)
  elif type=="number" then tostring
  elif type=="array" then "[" + (map(format_value)|join(", ")) + "]"
  elif type=="object" then
    if length==0 then "{}"
    else "{ " + (to_entries | sort_by(.key|tostring) | map("\(.key|format_key) = \(.value|format_value)") | join(", ")) + " }"
    end
  else error("Unsupported TOML value type: " + (type|tostring))
  end;
def should_nest($path; $key; $value):
  ($value | type) == "object" and ($value | length) > 0 and (
    ($value | to_entries | any(.value|type=="object"))
    or (bare_key(key_to_string($key)) == false)
    or (($path|length) == 0)
    or (($path|length) == 1 and key_to_string($path[0]) == "mcp_servers")
  );
def sorted_entries($obj):
  $obj | to_entries | sort_by(.key|tostring);
def render($path; $obj):
  ( sorted_entries($obj) ) as $entries
  | ( $entries | map(select(should_nest($path; .key; .value) | not))) as $simple_entries
  | ( $entries | map(select(should_nest($path; .key; .value)))) as $nested_entries
  | ( $simple_entries | map("\(.key|format_key) = \(.value|format_value)")) as $simple_lines
  | (if ($path|length) == 0 then
       (if ($simple_lines|length) > 0 then ($simple_lines | join("\n")) + "\n\n" else "" end)
     else
       (if ($simple_lines|length) > 0 then
           "[" + ($path | map(format_key) | join(".")) + "]\n"
           + ($simple_lines | join("\n")) + "\n\n"
        else ""
        end)
     end) as $current
  | $current
    + ( $nested_entries
        | map(render($path + [ .key ]; .value))
        | join("")
      );

(render([]; .) | sub("\n+$"; "\n"))
JQ

tmp_toml=$(mktemp -t codex-config) || {
  ui_error_msg "Failed to create temporary TOML file for Codex config" 1
  exit 1
}
_tmp_files+=("$tmp_toml")

if ! command jq -r -f "$tmp_render_jq" "$tmp_merged_json" > "$tmp_toml"; then
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
