---
name: my-security-audit
description: "Audits a project for security issues before publishing: leaked credentials, misconfigured .gitignore, hardcoded tokens in scripts or configs, and sensitive files that shouldn't be committed. Use this before pushing a repo public."
---

You are performing a pre-publish security audit. Run all scans in parallel, then present a single consolidated report.

## Step 1 — Parallel scans

Run ALL of the following simultaneously:

1. **Secret scan** — grep source files for tokens, secrets, API keys, passwords:

   ```
   grep -rn \
     -e "token\s*=\s*['\"][a-zA-Z0-9_\-]\{20,\}" \
     -e "secret\s*=\s*['\"][a-zA-Z0-9_\-]\{20,\}" \
     -e "password\s*=\s*['\"][^'\"]\{8,\}" \
     -e "api_key\s*=\s*['\"][a-zA-Z0-9_\-]\{20,\}" \
     --include="*.ts" --include="*.js" --include="*.mjs" \
     --include="*.json" --include="*.sh" --include="*.yml" --include="*.yaml" \
     --exclude-dir=node_modules --exclude-dir=dist --exclude-dir=.git
   ```

2. **Config file scan** — check MCP configs and CI configs for hardcoded credentials:
   - `.mcp.json` — should have no `env` block with real values
   - `claude_desktop_config.json` equivalent if present
   - `.env*` files — should not exist or be gitignored
   - Any `*.yml`/`*.yaml` CI files

3. **`.gitignore` coverage check** — verify these are present:
   - `node_modules/`
   - `dist/`
   - `.env` / `.env*`
   - `.mcp.json`
   - `.claude/`
   - Any `*.json` config files that store credentials (e.g. `~/.config/<service>.json` pattern)

4. **Scripts scan** — check shell scripts and utility scripts for hardcoded values:
   - Look for `CLIENT_ID=`, `ACCESS_TOKEN=`, `SECRET=` with literal values

5. **Git status** — check for untracked sensitive files that would be committed:

   ```
   git status --short
   ```

6. **Directory listing** — list all files in the project root to spot unexpected files

## Step 2 — Report

Present findings as a table:

```
🔒 Security Audit — <project name>

| # | Severity | File | Issue | Fix |
|---|----------|------|-------|-----|
| 1 | 🔴 HIGH  | ...  | ...   | ... |
| 2 | 🟡 WARN  | ...  | ...   | ... |
| 3 | 🔵 INFO  | ...  | ...   | ... |
```

Severity levels:

- 🔴 **HIGH** — actual credentials or tokens found in committed/committable files
- 🟡 **WARN** — missing `.gitignore` entries, risky patterns, files that could leak
- 🔵 **INFO** — non-blocking observations (unused scripts, stale configs)

If nothing is found, output: `✅ Security audit passed — no issues found.`

## Step 3 — Fix

List all recommended fixes and ask once for confirmation before applying any of them.

Apply fixes in parallel where possible (e.g. `.gitignore` additions + file deletions can be concurrent).

## Rules

- Never scan `node_modules/`, `dist/`, or `.git/`
- False positives (e.g. example tokens in README marked as `YOUR_TOKEN`) are INFO, not HIGH
- Placeholder values like `your-client-id` are WARN — they indicate the old env-var pattern, which should be replaced with a config file approach
- After fixes are applied, re-run the secret scan to confirm clean
