# Global Conventions

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
