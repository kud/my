---
name: k-config-update
description: "Configure the Claude Code harness via the managed source files. Edits claude-code.yml for settings/MCP/hooks/permissions, or source ai/ dirs for agents/skills/CLAUDE.md, then runs the correct sync command. Use this instead of the built-in update-config skill."
---

You are configuring the Claude Code environment for this `my` repo. The `~/.claude/` directory is a **derived output** — never edit it directly. All configuration lives in source files under `$MY`.

## Source file map

| What to change                                      | Source file                                                                | Apply command              |
| --------------------------------------------------- | -------------------------------------------------------------------------- | -------------------------- |
| Settings, hooks, permissions, MCP servers (global)  | `$MY/config/cli/claude-code.yml`                                           | `my ai client claude-code` |
| Settings, hooks, permissions, MCP servers (profile) | `$MY/profiles/<profile>/config/cli/claude-code.yml`                        | `my ai client claude-code` |
| Agents, skills, commands, CLAUDE.md (global)        | `$MY/ai/agents/`, `$MY/ai/skills/`, `$MY/ai/commands/`, `$MY/ai/CLAUDE.md` | `my ai sync`               |
| Agents, skills, commands, CLAUDE.md (profile)       | `$MY/profiles/<profile>/ai/`                                               | `my ai sync`               |

## Detecting the active profile

Run `echo $MY_PROFILE` to find the active profile. If empty, only the global config applies.

## Workflow

1. **Identify** what needs changing (settings/MCP → yml; agents/skills → ai/ dirs)
2. **Check the profile** — run `echo $MY_PROFILE` to see if a profile yml is also relevant
3. **Read** the source file(s) before editing
4. **Edit** the correct source file(s) only
5. **Apply** — run `my ai client claude-code` and/or `my ai sync` as appropriate
6. **Confirm** what changed and which command was run

## yml settings block

Keys in the `settings:` block of `claude-code.yml` map 1:1 to `~/.claude/settings.json`. Add new settings there. Example:

```yaml
settings:
  outputStyle: Explanatory
  alwaysThinkingEnabled: true
```

## MCP servers

Add/remove under the `mcp:` block. If updating an existing entry (changing command or args), first run `claude mcp remove <name> --scope user`, then edit the yml, then run `my ai client claude-code`.

## Important constraints

- Never edit `~/.claude/settings.json`, `~/.claude/settings.local.json`, or any file directly under `~/.claude/` — those are generated
- Never use the built-in `update-config` skill — it edits the wrong file
- `my ai sync` handles agents/skills/CLAUDE.md symlinks only — it does NOT apply MCP or settings config
- `my ai client claude-code` handles settings/MCP/hooks/permissions only — it does NOT sync agents or skills
