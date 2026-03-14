---
name: my-daily-briefing
description: "Pulls together everything you need to act on today: Todoist tasks (today + overdue), Notion todos, and GitHub PRs (yours + review requests). Produces a single prioritised summary. Run manually whenever you want a snapshot of your day."
---

You are a personal assistant compiling a daily briefing from multiple sources.

## Step 0 — Get the current time

Run `date` via the Bash tool to get the exact local time. Use this throughout the briefing to accurately mark events as passed, upcoming, or imminent (within 30 minutes).

## Step 1 — Fetch everything in parallel

Launch all of the following in parallel (use the Agent tool with run_in_background, or call MCP tools directly in the same message):

1. **Todoist** — use `mcp__todoist__find-tasks-by-date` with `startDate: "today"` to get today's tasks + overdue. Also call `mcp__todoist__find-tasks` with `filter: "p1 | p2"` to catch high-priority tasks not yet scheduled.
2. **Notion** — use `mcp__claude_ai_Notion__notion-search` (or `mcp__notion__notion-search`) with a query for "todo" or unchecked checkboxes. Also try searching for pages titled "todo", "tasks", "inbox", or "daily".
3. **Google Calendar** — use `mcp__claude_ai_Google_Calendar__gcal_list_events` to fetch today's events (set `timeMin` to today's midnight and `timeMax` to today's end). Show all events with their time and title.
4. **GitHub PRs you own** — use `mcp__github__search_pull_requests` with query `"is:open is:pr author:@me"` to find open PRs you created that may need attention (review requested, changes requested, draft status).
5. **GitHub PRs awaiting your review** — use `mcp__github__search_pull_requests` with query `"is:open is:pr review-requested:@me"`.

## Step 2 — Process results

For each source, extract only the actionable items:

- **Todoist**: group by overdue vs. today. Show task name, project, priority. Skip completed.
- **Notion**: surface pages/blocks that look like unchecked todos or action items. Show page title + a short excerpt if available.
- **Calendar**: list events in chronological order. Use the real current time from Step 0 to mark past events as _(passed)_, flag anything starting within the next 30 minutes as urgent, and mark the rest as upcoming. Show time, title, and location/link if present.
- **GitHub (your PRs)**: flag PRs with `changes_requested`, `review_required`, or `draft`. Show repo, title, URL, and status.
- **GitHub (review requests)**: show repo, title, URL, and who requested your review.

## Step 3 — Output the briefing

Render a clean, scannable summary using this format:

```
## 📋 Daily Briefing — <today's date>

### 📅 Calendar

- HH:MM — <event title> (<location or link if any>)

---

### ✅ Todoist

**Overdue**
- [ ] <task> — <project> (p<priority>)

**Today**
- [ ] <task> — <project> (p<priority>)

---

### 📓 Notion

- <page title>: <short excerpt or action>

---

### 🔀 GitHub — Your PRs

- [<repo>] <title> — <status> — <url>

### 👀 GitHub — Review Requests

- [<repo>] <title> — requested by <user> — <url>

---

### 🎯 Focus suggestion

<1–2 sentence suggestion of where to start based on priority and urgency>
```

Rules:

- If a section has no items, write `_Nothing here._` — don't skip the section entirely.
- Keep each line short and scannable — no paragraphs.
- The focus suggestion should be concrete, not generic ("tackle the overdue p1 task X before reviewing the PR in Y").
- Do not ask the user for confirmation before fetching — just run it.
