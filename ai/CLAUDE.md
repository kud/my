# Global Conventions

## Communication Style

- **Explain what you're doing** — always narrate your reasoning and actions so the user can learn from the process, not just the outcome
- Be explicit about *why* you chose an approach, not just *what* you did

---

## Tips & Notes Callout Format

Whenever a skill or agent has advisory tips, follow-up suggestions, or flags for the user, render them as a styled callout at the very end of the output — never inline as prose:

```
### 💡 Tips & Notes

- **<topic>**: <concise actionable tip>
- **<topic>**: <concise actionable tip>
```

Use this for: caveats, missing setup steps, follow-up actions, or anything the user should be aware of but that isn't blocking.

---

## Post-skill QA

After every skill completes, automatically run `/my-run-qa` to review the execution for missed steps, wrong decisions, or instruction gaps. If issues are found, surface them and ask before applying fixes. If nothing is wrong, stay silent.

---

## AI Assets (Agents & Skills)

**Never create agents or skills directly in `~/.claude/`.** That directory is managed by `my ai sync` and only contains symlinks. Always work in the source directories:

- **Global** (not profile-specific): `$MY/ai/agents/`, `$MY/ai/skills/`, `$MY/ai/commands/`
- **Work-specific** (prefixed with `w-`): `$MY/profiles/work/ai/agents/`, `$MY/profiles/work/ai/skills/`, `$MY/profiles/work/ai/commands/`

After creating or modifying agents/skills, run `my ai sync` to update the symlinks.

---

## Coding Style

- **Explicit over implicit** — always prefer clarity over cleverness
- **Clear naming over comments** — function and variable names should explain intent; avoid comments entirely unless the logic is genuinely hard to understand even after refactoring
- **Split and name** — when something needs explaining, extract a well-named function instead of adding a comment
- **One-liners when possible** — prefer concise single-line functions if readability is preserved
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

| Emoji | Type |
|-------|------|
| ✨ | feat |
| 🐛 | fix |
| 📝 | docs |
| 🎨 | style |
| ♻️ | refactor |
| ✅ | test |
| 🔧 | chore |
| ⚡ | perf |
| 👷 | ci |
| 🔨 | build |
| ⏪ | revert |

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
