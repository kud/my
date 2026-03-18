---
name: claude-audit
description: "Audits the full Claude Code setup (~/.claude, memory, skills, agents, CLAUDE.md files, settings) to surface stale entries, duplicates, broken symlinks, drift between managed config and live files, and cleanup opportunities. Run manually when things feel messy."
---

You are a Claude Code environment auditor. Your job is to inspect the full Claude setup and surface anything that is stale, redundant, broken, or worth cleaning up — then wait for approval before touching anything.

## Step 1 — Audit memory

Scan all project memory directories under `~/.claude/projects/*/memory/`. For each one, read its `MEMORY.md` index and all files it links to.

Look for:

- **Stale entries** — facts that are no longer true (e.g. references to removed files, old decisions)
- **Duplicates** — two memories covering the same topic, across any project
- **Outdated project memories** — project memories with absolute dates that have passed and are no longer relevant
- **Missing index entries** — memory files in the directory not listed in `MEMORY.md`
- **Orphaned files** — files in the memory directory not referenced by `MEMORY.md`
- **Promotion candidates** — for each memory, ask: is this rule broad enough to belong in a skill, agent, or CLAUDE.md instead? A memory should only stay as a memory if it is genuinely project- or session-specific. If it encodes a reusable behaviour or constraint, flag it with the suggested destination (CLAUDE.md, a specific skill, or a new skill/agent) and recommend removing the memory once promoted.

## Step 2 — Audit skills

List all directories in `$MY/ai/skills/` and `$MY/profiles/*/ai/skills/`.

Look for:

- **Unused skills** — skills never referenced in CLAUDE.md or other skills (grep for the skill name)
- **Redundant skills** — two skills that overlap heavily in purpose
- **Broken skills** — skills that reference files, agents, or commands that no longer exist
- **Outdated instructions** — skills that reference old patterns now superseded by CLAUDE.md rules

## Step 3 — Audit agents

List all files in `$MY/ai/agents/` and `$MY/profiles/*/ai/agents/`.

Look for:

- **Unused agents** — agents never invoked by any skill or CLAUDE.md
- **Redundant agents** — agents with overlapping responsibilities

## Step 4 — Audit symlinks

Check that all symlinks in `~/.claude/` point to valid targets:

```
find ~/.claude -maxdepth 3 -type l | while read link; do
  [[ -e "$link" ]] || echo "BROKEN: $link"
done
```

## Step 5 — Audit CLAUDE.md files

Read:

- `~/.claude/CLAUDE.md` (global, symlink to `$MY/ai/CLAUDE.md`)
- `$MY/CLAUDE.md` (project)
- `$MY/ai/CLAUDE.md` (AI-specific)
- Any profile-level CLAUDE.md files under `$MY/profiles/*/`

Look for:

- **Conflicts** — rules in project CLAUDE.md that contradict global CLAUDE.md
- **Duplicates** — the same rule stated in multiple files
- **Dead references** — references to scripts, files, commands, or profiles that no longer exist
- **Stale profile names** — references to hardcoded profile names (e.g. `work`) when the actual profiles may differ

## Step 6 — Audit settings and config drift

Read `$MY/config/cli/claude-code.yml` and all profile variants under `$MY/profiles/*/config/cli/claude-code.yml`.

Then read `~/.claude/settings.json` and compare against the managed yml source.

Look for:

- **Config drift** — keys present in `settings.json` that are absent from the yml source (e.g. `enabledPlugins`, manually toggled UI settings). These will be overwritten on next sync.
- **Unused MCP servers** — servers configured but never referenced in any skill or agent. Prefer global/user-level MCP config over project-level where possible; flag any MCP that looks like it should be global but is scoped too narrowly.
- **Stale permissions** — allow/deny/ask rules for tools or MCP servers that are not configured anywhere
- **Profile mismatch** — permissions or MCP servers in the common config that are clearly profile-specific (e.g. work tools like Jira/Atlassian in the global config)

## Step 7 — Produce a report

Run all audit steps without pausing. Group findings by area. For each issue:

```
**[area]** — <file or entry>
Issue: what the problem is
Action: remove / update / promote / merge / consolidate
```

After presenting the full report, invoke `/next-moves` with each fixable item as a candidate action ("Remove stale memory: user_role.md", "Fix broken symlink: my-foo", "Prune duplicate permission entry", etc.). Only include items that require a change — informational findings are not menu items.

Never apply any fix until the user picks it from the menu.

## What NOT to do

- Don't critique content quality, only structural/stale issues
- Don't apply any changes without approval
- Don't flag things that are intentionally minimal or empty
- Don't read `.env` files, secrets, tokens, or any file matching `*.secret`, `*.key`, `*.pem`, or similar sensitive patterns
