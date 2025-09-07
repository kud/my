#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🧪 OPENCODE CONFIG WRITER                                                   #
#   -------------------------                                                  #
#   Generates ~/.config/opencode/opencode.jsonc from config/cli/opencode.yml.  #
#                                                                              #
################################################################################

source $MY/core/utils/helper.zsh
source $MY/core/utils/ui-kit.zsh

config_file="$MY/config/cli/opencode.yml"
config_dir="$HOME/.config/opencode"
output_file="$config_dir/opencode.jsonc"

mkdir -p "$config_dir"

ui_subsection "Generating opencode.jsonc"

theme=$(yq -r '.opencode.theme // "opencode"' "$config_file" 2>/dev/null)
model=$(yq -r '.opencode.model // "github-copilot/gpt-5"' "$config_file" 2>/dev/null)
autoupdate=$(yq -r '.opencode.autoupdate // true' "$config_file" 2>/dev/null)

cat > "$output_file" <<EOF
{
  "\$schema": "https://opencode.ai/config.json",
  "theme": "$theme",
  "model": "$model",
  "autoupdate": $autoupdate
}
EOF

ui_success_simple "Created $output_file" 1
