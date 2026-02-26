#!/usr/bin/env zsh

################################################################################
#                                                                              #
#   🤖 MISTRAL VIBE CONFIG WRITER                                               #
#   -----------------------------                                               #
#   Sets theme and MCP servers in ~/.vibe/config.toml                           #
#                                                                              #
################################################################################

source $MY/core/utils/helper.zsh
source $MY/core/utils/ui-kit.zsh

# Handle show-config subcommand
if [[ "$1" == "show-config" ]]; then
    ui_subtitle "Mistral Vibe Config:"

    config_file="$HOME/.vibe/config.toml"

    if [[ -f "$config_file" ]]; then
        ui_info_simple "$config_file" 0
    else
        ui_warning_simple "$config_file (not found)" 0
    fi
    ui_spacer
    return 0
fi

# Get current profile
PROFILE="${OS_PROFILE:-default}"

# Define config file paths
COMMON_CONFIG="$MY/config/cli/mistral-vibe.yml"
PROFILE_CONFIG="$MY/profiles/$PROFILE/config/cli/mistral-vibe.yml"
output_file="$HOME/.vibe/config.toml"

# Create .vibe directory if needed
vibe_dir="$HOME/.vibe"
mkdir -p "$vibe_dir"

ui_subsection "Configuring Mistral Vibe Theme and MCP Servers"

# Check if common config exists
if [[ ! -f "$COMMON_CONFIG" ]]; then
    ui_error_msg "Common config $COMMON_CONFIG is missing" 1
    exit 1
fi

# Read theme from YAML
if command -v yq >/dev/null 2>&1; then
    theme=$(yq -r '.theme' "$COMMON_CONFIG" 2>/dev/null || echo "tokyo-night")
    ui_info_simple "Setting theme to: $theme" 0
else
    theme="tokyo-night"
    ui_warning_simple "yq not found, using default theme: $theme" 0
fi

# Check if config.toml exists, if not create a basic one
if [[ ! -f "$output_file" ]]; then
    ui_info_simple "Creating new config.toml with basic settings" 0
    cat > "$output_file" << EOF
active_model = "devstral-2"
textual_theme = "$theme"
vim_keybindings = false
disable_welcome_banner_animation = false
context_warnings = false
include_commit_signature = true
include_model_info = true
include_project_context = true
include_prompt_detail = true
enable_update_checks = true
api_timeout = 720.0
system_prompt_id = "cli"
enabled_tools = []
disabled_tools = []

[project_context]
max_chars = 40000
default_commit_count = 5
max_doc_bytes = 32768
truncation_buffer = 1000
max_depth = 3
max_files = 1000
max_dirs_per_level = 20
timeout_seconds = 2.0

[session_logging]
save_dir = "~/.vibe/logs/session"
session_prefix = "session"
enabled = true

[[providers]]
name = "mistral"
api_base = "https://api.mistral.ai/v1"
api_key_env_var = "MISTRAL_API_KEY"
api_style = "openai"
backend = "mistral"

[[providers]]
name = "llamacpp"
api_base = "http://127.0.0.1:8080/v1"
api_key_env_var = ""
api_style = "openai"
backend = "generic"

[[models]]
name = "mistral-vibe-cli-latest"
provider = "mistral"
alias = "devstral-2"
temperature = 0.2
input_price = 0.4
output_price = 2.0

[[models]]
name = "devstral-small-latest"
provider = "mistral"
alias = "devstral-small"
temperature = 0.2
input_price = 0.1
output_price = 0.3

[[models]]
name = "devstral"
provider = "llamacpp"
alias = "local"
temperature = 0.2
input_price = 0.0
output_price = 0.0

[tools.search_replace]
permission = "ask"
max_content_size = 100000
create_backup = false
fuzzy_threshold = 0.9

[tools.read_file]
permission = "always"
max_read_bytes = 64000
max_state_history = 10

[tools.write_file]
permission = "ask"
max_write_bytes = 64000
create_parent_dirs = true

[tools.todo]
permission = "always"
max_todos = 100

[tools.bash]
permission = "ask"
allowlist = [
  "echo", "find", "git diff", "git log", "git status",
  "tree", "whoami", "cat", "file", "head", "ls",
  "pwd", "stat", "tail", "uname", "wc", "which"
]
denylist = [
  "gdb", "pdb", "passwd", "nano", "vim", "vi", "emacs",
  "bash -i", "sh -i", "zsh -i", "fish -i", "dash -i",
  "screen", "tmux", "python", "python3", "ipython", "nohup"
]
max_output_bytes = 16000
default_timeout = 30

[tools.grep]
permission = "always"
max_output_bytes = 64000
default_max_matches = 100
default_timeout = 60
EOF
    ui_success_simple "Created new config.toml with theme: $theme" 0
else
    # Update theme in existing config
    if [[ -f "$output_file" ]]; then
        # Use a temp file approach for better portability (works with both BSD and GNU sed)
        local temp_file=$(mktemp) || { ui_error_msg "Failed to create temp file" 0; return 1; }
        sed 's/textual_theme = ".*"/textual_theme = "'"$theme"'"/' "$output_file" >| "$temp_file"
        if [[ $? -eq 0 ]]; then
            mv "$temp_file" "$output_file"
            ui_success_simple "Updated theme to: $theme" 0
        else
            rm -f "$temp_file"
            ui_error_msg "Failed to update theme" 0
        fi
    fi
fi

# Add MCP servers section
ui_info_simple "Adding MCP servers configuration" 0

# Remove existing MCP servers section if it exists (from "# MCP Servers" to end of file)
# Also remove trailing empty lines to prevent accumulation
if command -v sed >/dev/null 2>&1; then
    local temp_file=$(mktemp)
    # Remove MCP servers section, then remove trailing blank lines
    sed '/^# MCP Servers/,$d' "$output_file" | awk '/^[[:space:]]*$/ {blank=blank"\n"; next} {printf "%s", blank; blank=""; print}' >| "$temp_file"
    if [[ $? -eq 0 ]]; then
        mv "$temp_file" "$output_file"
    else
        rm -f "$temp_file"
    fi
fi

# Add MCP servers section with proper spacing
echo "" >> "$output_file"
echo "# MCP Servers" >> "$output_file"
echo "" >> "$output_file"

# Add GitHub MCP server
echo "[[mcp_servers]]" >> "$output_file"
echo "name = \"github\"" >> "$output_file"
echo "transport = \"http\"" >> "$output_file"
echo "url = \"https://api.githubcopilot.com/mcp\"" >> "$output_file"
echo "headers = { Authorization = \"Bearer ${MCP_GITHUB_TOKEN}\" }" >> "$output_file"
echo "" >> "$output_file"

# Add Basic Memory MCP server
echo "[[mcp_servers]]" >> "$output_file"
echo "name = \"basic-memory\"" >> "$output_file"
echo "transport = \"stdio\"" >> "$output_file"
echo "command = [\"uvx\", \"basic-memory\", \"mcp\"]" >> "$output_file"
echo "" >> "$output_file"

# Add Notion MCP server
echo "[[mcp_servers]]" >> "$output_file"
echo "name = \"notion\"" >> "$output_file"
echo "transport = \"http\"" >> "$output_file"
echo "url = \"https://mcp.notion.com/mcp\"" >> "$output_file"
echo "" >> "$output_file"

ui_success_simple "Mistral Vibe configuration complete" 1
ui_info_simple "Config file: $output_file"
ui_spacer