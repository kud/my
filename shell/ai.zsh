################################################################################
#                                                                              #
#   🤖 AI SHELL UTILITIES                                                      #
#   ---------------------                                                      #
#   Centralised AI helpers using the `opencode` CLI. Provides higher-level     #
#   convenience functions for common developer tasks.                          #
#                                                                              #
################################################################################

# Default model (overridable via $AI_MODEL or falls back to opencode config)
: ${AI_MODEL:="github-copilot/gpt-5"}

# Internal: choose first available markdown renderer, else fallback
_ai_markdown_renderer() {
  if command -v glow >/dev/null 2>&1; then
    echo glow
  elif command -v mdcat >/dev/null 2>&1; then
    echo mdcat
  else
    echo _ai_markdown_fallback
  fi
}

# Internal: simple markdown-ish pretty printer (headings, lists, code blocks)
_ai_markdown_fallback() {
  local line in_code=0
  while IFS= read -r line; do
    if [[ $line == '```'* ]]; then
      if (( in_code )); then
        echo
        in_code=0
      else
        echo
        in_code=1
      fi
      continue
    fi
    if (( in_code )); then
      printf '  %s\n' "$line"
      continue
    fi
    if [[ $line =~ ^#{1,6}\  ]]; then
      local stripped=${line#* }
      printf '\n\033[1m%s\033[0m\n' "$stripped"
      printf '%*s\n' ${#stripped} '' | tr ' ' '='
      continue
    fi
    if [[ $line =~ ^[*-]\  ]]; then
      printf ' • %s\n' "${line:2}"
      continue
    fi
    if [[ $line =~ ^[0-9]+\.\  ]]; then
      local num=${line%%.*}
      local rest=${line#*. }
      printf '\033[1m%s.\033[0m %s\n' "$num" "$rest"
      continue
    fi
    echo "$line"
  done
}

# Internal helper to call opencode with model fallback and capture clean output
_ai_call() {
  if ! command -v opencode >/dev/null 2>&1; then
    echo "Error: opencode CLI not found in PATH." >&2
    return 127
  fi
  local model=${AI_MODEL}
  local prompt=$1
  local raw
  if ! raw=$(opencode run --model "$model" "$prompt" 2>&1); then
    echo "$raw" >&2
    return 1
  fi
  # strip ANSI
  raw=$(print -r -- "$raw" | sed -E 's/\x1b\[[0-9;]*m//g')
  # normalise blank lines
  raw=$(echo "$raw" | sed -E '/^[[:space:]]*$/ {/./!d;:a;N;$!ba;}')
  raw=$(echo "$raw" | sed -E 's/^\[0m[[:space:]]*//')
  printf '%s' "$raw"
}

# explain (internal): explain a shell command with risk, alternatives, example
_ai_explain() {
  local plain=0
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --plain|-p) plain=1; shift ;;
      --model) shift; AI_MODEL=$1; shift ;;
      --) shift; break ;;
      --*) echo "Unknown flag: $1" >&2; return 2 ;;
      *) break ;;
    esac
  done
  if [[ $# -eq 0 ]]; then
    echo "Usage: explain [--plain] [--model <model>] <command...>" >&2
    return 1
  fi
  local input_command="$*"
  local prompt="Explain this shell command step by step, then provide: 1) concise plain English summary 2) potential risks 3) safer or common alternatives 4) a practical variant. Command:\n\n$input_command"
  local out
  if ! out=$(_ai_call "$prompt"); then
    return 1
  fi
  if (( plain )); then
    echo "$out"; return 0
  fi
  local renderer=$(_ai_markdown_renderer)
  echo "$out" | $renderer
}

# tldr (internal): quick what/why/how summary of a command or topic
_ai_tldr() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: aitldr <topic>" >&2
    return 1
  fi
  local prompt="Provide a terse TL;DR (max ~12 lines) for: $*\nFormat with: Heading, What, Why, Typical usage examples (2), Pitfalls."
  local out
  if ! out=$(_ai_call "$prompt"); then
    return 1
  fi
  local renderer=$(_ai_markdown_renderer)
  echo "$out" | $renderer
}

# summarize (internal): summarise stdin (pipe) or args
_ai_summarize() {
  local input
  if [[ -t 0 ]]; then
    if [[ $# -eq 0 ]]; then
      echo "Usage: aisummarize <text...> or pipe data" >&2
      return 1
    fi
    input="$*"
  else
    input=$(cat)
  fi
  local prompt="Summarize the following content into: 1) High-level summary 2) Key points 3) Risks / caveats 4) Action items (if any). Content:\n\n$input"
  local out
  if ! out=$(_ai_call "$prompt"); then
    return 1
  fi
  local renderer=$(_ai_markdown_renderer)
  echo "$out" | $renderer
}


# debug (internal): suggest next debugging steps for a failing command's stderr
_ai_debug() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: aidebug <command...>" >&2; return 1
  fi
  local cmd="$*"
  local output
  if ! output=$(eval "$cmd" 2>&1 >/dev/null); then
    :
  fi
  local prompt="Given this failing command: $cmd\nStderr / diagnostic output:\n\n$output\n\nSuggest structured next debugging steps: 1) Likely root causes 2) Commands to run to verify 3) Potential quick fixes (explicit)."
  local out
  if ! out=$(_ai_call "$prompt"); then
    return 1
  fi
  local renderer=$(_ai_markdown_renderer)
  echo "$out" | $renderer
}

# help (internal): list AI helpers
_ai_help() {
  local no_color=0
  if [[ -n $NO_COLOR || ! -t 1 ]]; then
    no_color=1
  fi
  if (( no_color )); then
    B="" R="" DIM="" CY="" MAG="" Y="" G="" BL="" GRY=""
  else
    B=$'\e[1m'; R=$'\e[0m'; DIM=$'\e[2m'; CY=$'\e[36m'; MAG=$'\e[35m'; Y=$'\e[33m'; G=$'\e[32m'; BL=$'\e[34m'; GRY=$'\e[90m'
  fi
  local model_disp=${AI_MODEL:-"(unset)"}
  local renderer=$(_ai_markdown_renderer)
  [[ $renderer == _ai_markdown_fallback ]] && renderer="internal"
  cat <<EOF
${B}🤖 AI Toolkit${R}  ${DIM}(model: ${model_disp}, render: ${renderer})${R}
${GRY}────────────────────────────────────────────────────────────${R}

${B}Usage:${R}
  ${CY}ai${R} ${MAG}<command>${R} [options]

${B}Core Commands:${R}
  ${CY}explain${R}    <cmd>          Explain a shell command with risks & alternatives
  ${CY}tldr${R}       <topic>        Ultra-short what / why / examples / pitfalls
  ${CY}summarize${R}  [text]|(pipe)  Summarize provided or piped content
  ${CY}debug${R}      <command>      Suggest structured debugging steps

${B}Model Management:${R}
  ${CY}model${R}                     Show current model
  ${CY}model set${R}  <model>        Change and export AI_MODEL for this session

${B}Help:${R}
  ${CY}help${R}                      Show this help

${B}Environment:${R}
  ${Y}AI_MODEL${R}     Current default model (now: ${model_disp})

${B}Examples:${R}
  ${G}ai explain${R} 'grep -R "TODO" -n src'
  ${G}ai summarize${R} < README.md
  ${G}ai model set github-copilot/gpt-4.1${R}
  ${G}ai debug${R} 'curl https://localhost:8443/health'

${DIM}Tip:${R} Set a persistent model in your shell profile: ${BL}export AI_MODEL=github-copilot/gpt-5${R}
EOF
}

# Dispatcher: unified entrypoint `ai <subcommand>`
ai() {
  if [[ $# -eq 0 ]]; then
    _ai_help
    return 0
  fi
  local sub=$1; shift || true
  case "$sub" in
    help|-h|--help) _ai_help ;;
    explain) _ai_explain "$@" ;;
    tldr) _ai_tldr "$@" ;;
  summarize|sum) _ai_summarize "$@" ;;
    debug) _ai_debug "$@" ;;
    model)
      if [[ $# -eq 0 ]]; then
        echo "Current AI_MODEL=$AI_MODEL"
      else
        if [[ $1 == set ]]; then
          shift
          if [[ -z $1 ]]; then
            echo "Usage: ai model set <model>" >&2; return 1
          fi
          AI_MODEL=$1; export AI_MODEL
          echo "AI_MODEL set to $AI_MODEL"
        else
          AI_MODEL=$1; export AI_MODEL
          echo "AI_MODEL set to $AI_MODEL"
        fi
      fi
      ;;
    *)
      echo "Unknown ai subcommand: $sub" >&2
      _ai_help >&2
      return 1
      ;;
  esac
}

