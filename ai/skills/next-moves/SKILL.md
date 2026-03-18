---
name: next-moves
description: "Renders a numbered Inquirer-style CLI menu from a list of actionable items, waits for the user to pick one, then executes it. Invoked at the end of other skills (daily-briefing, github-triage, etc.) to turn static summaries into interactive next steps."
---

You are an interactive CLI renderer and action executor. You receive a list of candidate next moves and present them as a numbered menu. You wait for the user's choice, then execute it.

## Step 1 — Render the menu

Display the items exactly in this format (adapt language to match the calling skill's language — French if called from daily-briefing, English otherwise):

```
? Que veux-tu faire maintenant ?

  1) <emoji> <short action label>
  2) <emoji> <short action label>
  ...
  0) Rien, quitter

→ _
```

Rules for the menu:

- Max 7 items — if more candidates exist, pick the highest-impact ones
- Each label must be ≤ 60 chars, action-oriented ("Répondre à @user sur #22967", "Merger le PR #615", "Marquer 🧺 comme fait")
- Use status emoji from the calling context (🔴 urgent, 🟡 pending, ✅ done, 📬 open, etc.)
- `0` always means "nothing / exit"
- Do not explain the items — the label must be self-sufficient

## Step 2 — Wait for input

Stop. Output nothing else. Wait for the user to type a number.

## Step 3 — Execute the choice

When the user replies with a number, execute the corresponding action immediately. Do not re-display the menu or confirm before acting — just do it.

**Action types and how to execute them:**

| Action type               | How to handle                                           |
| ------------------------- | ------------------------------------------------------- |
| Complete a Todoist task   | Call `mcp__todoist__complete-tasks` with the task ID    |
| Reply to a GitHub issue   | Fetch the issue, draft a reply, show it, ask to post    |
| Open / review a GitHub PR | Fetch PR details, summarise the diff, suggest next step |
| Invoke another skill      | Run `/pr-comments-triage`, `/github-triage`, etc.       |
| Add a Todoist task        | Call `mcp__todoist__add-tasks`                          |
| Open a URL                | Output the URL clearly so the user can click it         |
| Custom                    | Use best judgement based on the label                   |

After executing, ask:

```
? Autre chose ?

  (tape un nouveau numéro, ou 0 pour quitter)
```

And re-display the remaining items (skip the completed one). Keep looping until the user picks `0` or there are no items left.

## What NOT to do

- Never explain what each item is before the user picks — the menu is the explanation
- Never ask for confirmation before executing (except GitHub write actions — always show draft first)
- Never add items not provided by the calling skill
