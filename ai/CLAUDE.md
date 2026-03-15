# Global Conventions

## Communication Style

- **Explain what you're doing** — always narrate your reasoning and actions so the user can learn from the process, not just the outcome
- Be explicit about _why_ you chose an approach, not just _what_ you did

---

## Tips & Notes

At the end of every response, automatically run `/my-tips-notes` to surface caveats, follow-up actions, missing setup steps, or anything the user should be aware of. If there is nothing worth noting, it stays silent.

---

## Post-skill QA

After every skill completes, automatically run `/my-run-qa` to review the execution for missed steps, wrong decisions, or instruction gaps. If issues are found, surface them and ask before applying fixes. If nothing is wrong, stay silent.

---

## AI Assets (Agents & Skills)

**Never create agents or skills directly in `~/.claude/`.** That directory is managed by `my ai sync` and only contains symlinks. Always work in the source directories:

- **Global** (not profile-specific): `$MY/ai/agents/`, `$MY/ai/skills/`, `$MY/ai/commands/`
- **Profile-specific**: `$MY/profiles/<profile>/ai/agents/`, `$MY/profiles/<profile>/ai/skills/`, `$MY/profiles/<profile>/ai/commands/`
  - Work assets are prefixed with `w-` (e.g. `my-w-weekly-wrapped`)

After creating or modifying agents/skills, run `my ai sync` to update the symlinks.

---

## AI vs Scripts

When solving a task, prefer a script over AI/MCP calls when:

- The task is repetitive or will be run more than once
- The data source is stable and machine-readable (APIs, files, CLI output)
- The logic is deterministic (filtering, formatting, aggregating)
- Speed and reliability matter more than natural-language interpretation

In those cases, proactively suggest writing a script (Zsh, Node, etc.) instead of reaching for an MCP tool or an agent. AI and MCP calls should be reserved for tasks that genuinely require reasoning, natural language, or access to live data that isn't easily scriptable.

If you catch yourself chaining multiple MCP calls to do something a one-liner could handle, flag it.

---

## Audits & Destructive Actions

- When auditing a project (pre-publish, security, file hygiene), run all independent scans in a single parallel batch — git status, secret grep, directory listing, and config reads can all be concurrent.
- When destructive actions (file deletions, overwrites) are identified during an audit, present the full list and ask once for confirmation before executing any of them.

---

## Git & Worktrees

- **Check the active branch before committing** — when working across multiple worktrees or repos, always run `git branch --show-current` before staging and committing. Never commit to a branch unrelated to the current task.
- **PR branch work** — when a PR skill or task involves a specific branch, locate that branch (via `git worktree list` or `git branch -a`) and work there directly. Don't assume the current worktree is on the right branch.

---

## Shell & Platform

- **sed**: GNU sed is installed via Homebrew but only available in login shells. Non-login shells (subprocesses, agents) may fall back to macOS BSD sed. Always use `sed -i ''` — it works on both. Prefer the `Edit` tool over `sed` entirely to avoid the issue.
- **gh PR bodies**: Always write to a temp file and use `--body-file /tmp/pr-body.md` — never pass `--body "$(cat <<'EOF'...)"` inline, as shell escaping corrupts backticks in rendered markdown.
- **Scripting language**: Prefer shell (Zsh) for system ops, file manipulation, and CLI pipelines. Use Node.js when shell gets awkward — especially for JSON parsing, complex data structures, or HTTP. Never use Python.
- **Modern JS only**: When writing Node, always use ESM (`import`/`export`), top-level `await`, `const`/`let`, optional chaining, nullish coalescing, etc. Never use `require()`, `module.exports`, or any CommonJS patterns. Assume a recent LTS Node version — use the latest language features freely.

---

## Coding Style

- **Explicit over implicit** — always prefer clarity over cleverness
- **Clear naming over comments** — function and variable names should explain intent; avoid comments entirely unless the logic is genuinely hard to understand even after refactoring
- **Split and name** — when something needs explaining, extract a well-named function instead of adding a comment
- **One-liners when possible** — prefer concise single-line functions if readability is preserved
- **`const` over `let`** — never use `let` + mutation when a `const` + ternary is possible; if a ternary is hard to read, extract a well-named intermediate `const` to clarify intent — never reach for `let`/`if` blocks
- **Boy Scout Rule (scoped)** — improve nearby code when touching a file, but keep it small; don't let cleanup bloat the PR
- **Kebab-case for files and folders** — unless the project already follows a different convention

---

## Commit Messages

Format:

```
<emoji> <type>(<scope>): <description>
```

Example: `✨ feat(auth): add JWT token validation`

### Emoji Mapping

| Emoji | Type     |
| ----- | -------- |
| ✨    | feat     |
| 🐛    | fix      |
| 📝    | docs     |
| 🎨    | style    |
| ♻️    | refactor |
| ✅    | test     |
| 🔧    | chore    |
| ⚡    | perf     |
| 👷    | ci       |
| 🔨    | build    |
| ⏪    | revert   |

### Rules

- Description: lowercase, imperative mood, under 50 chars, no trailing period
- Scope is optional but recommended — match existing scopes in the repo's git log
- For multi-line bodies, leave a blank line after the subject

---

## Branch Naming

### Default Convention (personal)

Format: `<type>/<description>`

Types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `ci`, `perf`, `style`

Rules:

- Description is kebab-case, 2-5 words max
- No ticket IDs in the default format

Examples: `feat/add-dark-mode`, `fix/login-redirect-loop`

---

## PR Comment Convention

### Conventional Comment Emojis

Every PR reply starts with exactly one emoji to clarify intent:

- 👍 — I like this / positive feedback
- 🔧 — This needs to be changed (blocker/concern)
- ❓ — I have a question (requires response)
- 💭 — Thinking out loud / alternative consideration
- 🌱 — Future consideration (not a change request)
- 📝 — Explanatory note (no action needed)
- ⛏ — Nitpick (no changes required)
- ♻️ — Refactoring suggestion
- 🏕 — Cleanup opportunity (boy scout rule)
- 📌 — Out of scope, follow up later
- 💀 — Dead code, should be removed

### Writing Style

- Always start with the appropriate emoji
- Write naturally like a real developer — use contractions, casual phrasing
- Be concise and direct — no fluff
- Vary sentence structure, use active voice
- Skip unnecessary pleasantries — get to the point

### Tone: Open Discussion

- Avoid congratulatory language ("Good catch", "Great point")
- Use exploratory language: "What if we...", "Would it make sense to..."
- Frame responses as conversation starters, not conclusions

### Reply Types

- **ACCEPT**: Brief confirmation + commit SHA reference, 1-2 sentences max
- **DECLINE**: Direct but respectful rationale + alternative perspective
- **QUESTION**: Kind, patient, pedagogical — gently ask for clarification without defensiveness

### Constraints

- One reply per thread
- Match emoji to actual intent, not decorative
- Never use more than one emoji per reply
