---
name: my-update-mcp
description: "Audits an existing MCP server against the official API docs to ensure full coverage, then implements any missing or outdated tools. Use this when the upstream API may have changed or you want to verify completeness."
---

You are auditing and updating an existing TypeScript MCP server. Follow every step exactly.

## Step 1 — Identify the project

Ask the user which MCP project to audit (e.g. `mcp-trakt`, `mcp-raindrop-io`).

Resolve the project path: `~/Projects/<project-name>/`.

## Step 2 — Find the official API docs URL

Look for it in this priority order:

1. `CLAUDE.md` in the project root — look for an `## API Reference` section
2. `README.md` — look for a docs/API link
3. Ask the user if neither has it

Once found, save it for Step 3. If it wasn't in `CLAUDE.md`, add it now (see Step 7).

## Step 3 — Fetch the API docs

Use `WebFetch` or `WebSearch` to retrieve the official API reference.

Build a complete list of:

- All endpoints / resources / methods the API exposes
- Their parameters and response shapes
- Any auth scopes required per endpoint

## Step 4 — Audit existing tools

Read `src/index.ts` (and any sibling files if the project is split).

For each API endpoint found in Step 3, check whether:

- A matching tool exists → mark **COVERED**
- The tool exists but parameters/types are stale → mark **OUTDATED**
- No tool exists → mark **MISSING**

Produce a coverage table:

| Endpoint / Resource | Tool name | Status                       |
| ------------------- | --------- | ---------------------------- |
| ...                 | ...       | COVERED / OUTDATED / MISSING |

Show this table to the user and ask for confirmation before proceeding.

## Step 5 — Implement changes

For each MISSING or OUTDATED item approved by the user:

- Add or update the tool registration following the patterns already in `src/index.ts`
- Keep the same section grouping (`// ─── Resource Name ───`)
- Match the existing `apiFetch`, `ok`, `err` helpers — do not introduce new patterns
- Follow all design principles from `my-create-mcp`: no inline comments, `const` over `let`, typed generics, never `console.log`

## Step 6 — Build and verify

```bash
cd ~/Projects/<project-name>
npm run build
```

Build must succeed with zero errors. Fix any type errors before moving on.

## Step 7 — Ensure CLAUDE.md exists with API reference

The project root must have a `CLAUDE.md` containing at minimum:

```markdown
# <Project Name>

## API Reference

Official API docs: <url>
```

If the file is missing, create it. If it exists but lacks the `## API Reference` section, add it.

## Step 8 — Update README tools table

In `README.md`, update the **Available Tools** section to reflect the new tool count and any added tools. Keep the same table format as before.

## Step 9 — Bump patch version

In `package.json`, increment the patch version (e.g. `1.2.3` → `1.2.4`).

## Design principles (same as my-create-mcp)

- **Single file** (`src/index.ts`) unless tool count clearly exceeds ~25
- **No inline comments** — clear naming over explanation
- **`const` over `let`** everywhere
- **Typed generics on `apiFetch<T>`** — never `any` on response shapes
- **Always `console.error()`** for logging — never `console.log()` (corrupts STDIO)
- **Destructive tools** require a `confirm: z.boolean().default(false)` guard

## Final step — QA

Run `/my-run-qa` to review this execution for missed steps or wrong decisions.
