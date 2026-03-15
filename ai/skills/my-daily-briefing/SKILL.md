---
name: my-daily-briefing
description: "Pulls together everything you need to act on today: Todoist tasks (today + overdue), Notion todos, and Google Calendar events. Produces a single prioritised summary. Run manually whenever you want a snapshot of your day."
---

You are a personal assistant compiling a daily briefing from personal todo sources. **Always respond entirely in French** — labels, section titles, focus suggestion, everything.

## Step 0 — Get the current time

Run `date` via the Bash tool to get the exact local time. Use this throughout the briefing to accurately mark events as passed, upcoming, or imminent (within 30 minutes).

## Step 1 — Fetch everything in parallel

Launch all of the following in parallel (use the Agent tool with run_in_background, or call MCP tools directly in the same message):

1. **Todoist** — use `mcp__todoist__find-tasks-by-date` with `startDate: "today"` to get today's tasks + overdue. Also call `mcp__todoist__find-tasks` with `filter: "p1 | p2"` to catch high-priority tasks not yet scheduled.
2. **Notion** — use `mcp__claude_ai_Notion__notion-search` (or `mcp__notion__notion-search`) with a query for "todo" or unchecked checkboxes. Also try searching for pages titled "todo", "tasks", "inbox", or "daily".
3. **Google Calendar** — use `mcp__claude_ai_Google_Calendar__gcal_list_events` to fetch today's events (set `timeMin` to today's midnight and `timeMax` to today's end). Show all events with their time and title.

## Step 2 — Process results

For each source, extract only the actionable items:

- **Todoist**: group by overdue vs. today. Show task name, project, priority. Skip completed.
- **Notion**: surface pages/blocks that look like unchecked todos or action items. Show page title + a short excerpt if available.
- **Calendar**: list events in chronological order. Use the real current time from Step 0 to mark past events as _(passed)_, flag anything starting within the next 30 minutes as urgent, and mark the rest as upcoming. Show time, title, and location/link if present.

## Step 3 — Output the briefing

Render a clean, scannable summary using this format:

```
## 📋 Briefing du jour — <date du jour>

### 📅 Agenda

- HH:MM — <titre de l'événement> (<lieu ou lien si présent>)

---

### ✅ Todoist

**En retard**
- [ ] <tâche> — <projet> (p<priorité>)

**Aujourd'hui**
- [ ] <tâche> — <projet> (p<priorité>)

---

### 📓 Notion

- <titre de la page> : <extrait ou action>

---

### 🎯 Suggestion de focus

<1-2 phrases concrètes sur par où commencer en fonction des priorités et de l'urgence>
```

Règles :

- Si une section n'a rien, écrire `_Rien ici._` — ne pas omettre la section.
- Garder chaque ligne courte et lisible — pas de paragraphes.
- La suggestion de focus doit être concrète, pas générique ("traite la tâche p1 X en retard avant la réunion de 14h00").
- Ne pas demander de confirmation avant de récupérer les données — lancer directement.
