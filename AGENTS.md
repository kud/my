# AGENTS

Guidelines for any automated agent (AI, bot, codegen) working in this repo.

These rules apply **to the entire repository**, unless a nested `AGENTS.md` overrides them.

---

## 1. Project Overview
- This repo is **`my` – a macOS environment manager**.
- Primary role: bootstrap, configure, and maintain a full dev environment on macOS.
- Main pieces:
  - `bin/my` – main CLI entrypoint (Zsh dispatcher only).
  - `core/` – Zsh orchestration (install, update, system, apps, packages, CLI tooling, UI kit).
  - `config/` – YAML config for apps, packages, system.
  - `dotfiles/` – user dotfiles and related configs.
  - `shell/` – shell startup and helpers.
  - `services/` – LaunchDaemon/LaunchAgent plists.
  - `themes/` – theme/config assets.
  - `package.json` – Node helpers (zx, etc.), **not** the primary runtime.

Primary language: **Zsh** (with some Node/JS helpers).

---

## 2. General Principles
- **Be surgical.** Touch the *fewest files and lines* needed for the task.
- **Preserve style.** Match surrounding indentation, spacing, quoting, and emoji/icon usage.
- **Avoid churn.** Do not mass‑reformat, reorder, or rename unless explicitly requested.
- **No surprise behavior changes.** Keep UX, prompts, and side effects stable unless the change is the goal.
- **Prefer composition over cleverness.** Reuse existing helpers instead of inventing new patterns.
- **No inline comments** by default – follow the global instructions for this environment.

---

## 3. Zsh / Shell Style
- All core scripts are **Zsh**. Do *not* convert files to bash.
- Shebang for new executable scripts: `#!/usr/bin/env zsh` (or `#! /usr/bin/env zsh` to match existing).
- Use Zsh features deliberately: `[[ .. ]]`, arrays, `setopt`, etc., but keep scripts readable.
- **Quoting**:
  - Prefer double quotes for variables and paths: `"$VAR"`.
  - Quote any argument that may contain spaces or glob characters.
- **Case statements**:
  - Always terminate branches with `;;` (only use `;&` or `;|` intentionally).
  - Keep patterns and bodies vertically aligned (see `bin/my`).
- **Functions**:
  - Define as `name() { ... }`.
  - Use descriptive names; avoid single‑letter function names.
- **Error handling**:
  - On failure, exit with a non‑zero status where it makes sense.
  - For user‑visible messages, prefer UI helpers (see below) instead of raw `echo`.

---

## 4. UI / Output Conventions
- Always use the **UI kit** in `core/utils/ui-kit.zsh` for new messaging:
  - Sections: `ui_section`, `ui_subtitle`, `ui_subsection`.
  - Status: `ui_success_simple`, `ui_error_simple`, `ui_warning_simple`, `ui_info_simple`.
  - Spacing: `ui_spacer` instead of manual blank `echo` lines.
- Reuse icon variables defined in `ui-kit.zsh` (e.g. `UI_ICON_*`). Avoid hard‑coding new glyphs when a semantic icon exists.
- Keep output structured, succinct, and consistent with existing commands.

---

## 5. CLI Entry (`bin/my`) Rules
- Treat `bin/my` as a **thin dispatcher only**:
  - It should route to scripts under `core/commands`, `core/system`, `core/apps`, `core/packages`, etc.
  - Do **not** embed heavy logic directly in `bin/my`; put it in the appropriate `core/` script.
- When adding new subcommands:
  - For `my <command>`: point to `core/commands/<name>.zsh` or `core/system/<name>.zsh` as appropriate.
  - For `my <module>`: add a new branch to the top-level `case "$1" in`.
  - Keep help text (`--help` output) in `bin/my` in sync with new commands.

---

## 6. Core Layout & Responsibilities
- `core/commands/` – top‑level orchestration commands (`install.zsh`, `update.zsh`, `uninstall.zsh`, `doctor.zsh`, cleaners, etc.). Keep them high‑level and readable.
- `core/main.zsh` – master environment orchestrator (setup_* functions). Add new cross‑cutting setup stages here.
- `core/system/` – system concerns (services, submodules, sync files, dotfiles, default folders, etc.). New system‑level behavior belongs here.
- `core/apps/` – per‑application configuration.
- `core/packages/` – package managers and language packages (brew, npm, uv, etc.).
- `core/cli/` – configuration for external CLIs (abbr, codex, opencode, GitHub Copilot, etc.).

Place new logic where its *primary responsibility* fits best, rather than where it is first needed.

---

## 7. Node / JS Helpers
- Node tooling (see `package.json`) is **secondary** to Zsh.
- If you add or modify Node scripts:
  - Respect the module type (`"type": "module"`) – use ES modules.
  - Prefer small, focused helpers that are invoked by Zsh orchestrators, not the other way around.
  - Avoid adding heavy new dependencies without a strong reason.

---

## 8. Configuration & Dotfiles
- `config/` YAML files describe desired state; do not hard‑code those values into scripts.
- `dotfiles/` mirrors real‑world dotfiles. Keep changes minimal and aligned with existing conventions.
- When updating configuration, prefer additive and backward‑compatible changes.

---

## 9. Testing & Validation
- When possible, validate changes by:
  - Running individual commands, e.g. `my update`, `my doctor`, or `my <module>`.
  - Using `zsh -n` to syntax‑check modified Zsh scripts.
- Do not introduce new global test frameworks unless explicitly requested.

---

## 10. Documentation
- Update `README.md` or existing docs under `doc/` when you add user‑visible features or flags.
- Keep docs concise and in the same tone as the existing README.

---

By following these rules, agents should produce changes that feel native to this project, are safe to apply, and are easy for humans to understand and maintain.
