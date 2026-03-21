# Global Conventions

## Communication Style

- **British English** — use British spelling in all prose (e.g. _colour_, _organise_, _behaviour_). Exception: reserved words, API names, and established technical terms where American spelling is standard (e.g. `color` in CSS).
- **Unpack agent results** — when a subagent returns a result, always present it directly in your response. Never leave it collapsed for the user to expand.

## AI Assets & Config

Use the `scaffolder` agent to create or modify agents and skills. Never touch `~/.claude/` directly — it only contains symlinks managed by `my ai sync`.

Use `/k-config-update` for any settings, MCP servers, hooks, or permissions changes. Never use the built-in `update-config` skill — it edits the wrong file.

Claude Desktop MCP servers live in `$MY/config/apps/claude-desktop.yml` (common) and `$MY/profiles/<profile>/config/apps/claude-desktop.yml` (profile). Apply with `my apps claude-desktop`. Never edit `~/Library/Application Support/Claude/claude_desktop_config.json` directly — it is generated and will be overwritten.

## opencode MCP

Never call `mcp__plugin_mcp-opencode_mcp-opencode__query` autonomously. Only invoke it when the user explicitly runs `/ask-opencode` or `/mcp-opencode:ask-opencode`.

## AI vs Scripts

Prefer a script over AI/MCP calls when the task is repetitive, the data is machine-readable, or the logic is deterministic. Suggest Zsh or Node instead of reaching for an MCP tool.

Always check for existing scripts and aliases first — git aliases, `bin/` scripts, Makefile targets, shell functions. AI should orchestrate; scripts should execute.

## Audits & Destructive Actions

- Run all independent scans in a single parallel batch.
- When destructive actions are identified, present the full list and ask once before executing any of them.

## Shell & Platform

- **File deletion**: Always use `trash` instead of `rm`. Never silently fall back to `rm -f` if `rm` is blocked — ask the user first.
- **sed**: Always use `sed -i ''` — works on both GNU and BSD. Prefer the `Edit` tool over `sed` entirely.
- **Temp files**: Always use a timestamped name (e.g. `/tmp/payload-$(date +%s).json`) — never hardcode a fixed path.
- **gh PR bodies**: Always write to a timestamped temp file and use `--body-file` — never pass inline `--body`.
- **Scripting language**: Prefer Zsh for system ops, Node.js for JSON/HTTP. Never use Python.
- **Modern JS**: Always use ESM (`import`/`export`), top-level `await`, `const`/`let`. Never use `require()` or CommonJS. Never use `.mjs` — use `.js` with `"type": "module"` in `package.json`.

## Coding Style

- **Explicit over implicit** — clarity over cleverness
- **Clear naming over comments** — names explain intent; avoid comments unless logic is genuinely opaque after refactoring
- **Split and name** — extract a well-named function instead of adding a comment
- **One-liners when possible** — prefer concise single-line functions if readability is preserved
- **`const` over `let`** — never use `let` + mutation when `const` + ternary works; extract a named `const` when the ternary gets hard to read
- **Boy Scout Rule (scoped)** — improve nearby code when touching a file, but keep it small
- **Kebab-case for files and folders** — unless the project already follows a different convention
