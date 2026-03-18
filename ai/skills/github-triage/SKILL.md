---
name: github-triage
description: "GitHub situation recap: fetches open PRs (yours + review requests) and issues (assigned, mentioned, opened by you), then tells you exactly what your next move is on each. Run when you need to understand your GitHub workload and decide what to act on."
---

You are a GitHub triage assistant. Your goal is not just to list items — it's to give the user a clear picture of their GitHub situation and tell them exactly what to do next on each item. Every row in the output must answer: "what should I do with this right now?"

## Step 1 — Fetch everything in parallel

Run a **single** GraphQL call that fetches everything at once:

```bash
gh api graphql -f query='
{
  myPRs: search(query: "is:open is:pr author:@me", type: ISSUE, first: 50) {
    nodes {
      ... on PullRequest {
        number title url updatedAt isDraft reviewDecision
        repository { nameWithOwner }
        labels(first: 10) { nodes { name } }
        comments { totalCount }
        commits(last: 1) { nodes { commit { statusCheckRollup { state } } } }
      }
    }
  }
  reviewRequests: search(query: "is:open is:pr review-requested:@me", type: ISSUE, first: 50) {
    nodes {
      ... on PullRequest {
        number title url updatedAt isDraft reviewDecision
        repository { nameWithOwner }
        labels(first: 10) { nodes { name } }
        comments { totalCount }
        author { login }
      }
    }
  }
  assignedIssues: search(query: "is:open is:issue assignee:@me", type: ISSUE, first: 50) {
    nodes {
      ... on Issue {
        number title url updatedAt
        repository { nameWithOwner }
        labels(first: 10) { nodes { name } }
        comments { totalCount }
      }
    }
  }
  mentionedIssues: search(query: "is:open is:issue mentions:@me", type: ISSUE, first: 50) {
    nodes {
      ... on Issue {
        number title url updatedAt
        repository { nameWithOwner }
        labels(first: 10) { nodes { name } }
        comments { totalCount }
      }
    }
  }
  authoredIssues: search(query: "is:open is:issue author:@me", type: ISSUE, first: 50) {
    nodes {
      ... on Issue {
        number title url updatedAt
        repository { nameWithOwner }
        labels(first: 10) { nodes { name } }
        comments { totalCount }
      }
    }
  }
}
'
```

## Step 2 — Classify each item and write a next-action hint

For each item, assign a status **and** write a short, concrete next-action hint (1 sentence max) based on the actual content — title, labels, comment count, last activity. The hint should tell the user exactly what to do, not just restate the status.

**PRs — yours:**

| Status                     | Hint examples                                               |
| -------------------------- | ----------------------------------------------------------- |
| `needs rebase`             | "Rebase on main, conflicts likely in X"                     |
| `changes requested`        | "Address reviewer feedback from @user before re-requesting" |
| `waiting for review`       | "Ping maintainer — open X days with no response"            |
| `approved, ready to merge` | "Merge when ready — approved by @user"                      |
| `draft`                    | "Mark ready when done — or close if abandoned"              |
| `CI failing`               | "Fix failing check: <check name if known>"                  |

**PRs — review requests:**

| Status             | Hint examples                                             |
| ------------------ | --------------------------------------------------------- |
| `review needed`    | "Leave a review — author waiting since <date>"            |
| `re-review needed` | "Author pushed changes since your last review — re-check" |

**Issues:**

| Status           | Hint examples                                           |
| ---------------- | ------------------------------------------------------- |
| `needs response` | "Reply to @user's question about X"                     |
| `needs triage`   | "Add labels and decide if this is worth fixing"         |
| `stale`          | "Close if no longer relevant, or comment to keep alive" |
| `your turn`      | "Someone replied — check their response and follow up"  |
| `parked`         | "No action needed — keep an eye on it"                  |

## Step 3 — Output the triage

Render the output using tables for scannability. Each section gets its own table. Status badges use emoji for instant visual parsing.

**Status emoji legend:**

- 🔴 `changes requested` / `CI failing` / `needs response`
- 🟡 `waiting for review` / `your turn` / `needs triage`
- 🟢 `approved, ready to merge`
- ⚪ `draft` / `parked`
- 🔵 `review needed` / `re-review needed`
- 🟠 `stale`

```
## 🐙 GitHub Triage — <today's date>

### 🔀 Your PRs

| Repo | Title | Status | Next action | Updated |
|------|-------|--------|-------------|---------|
| [raycast/extensions](url) | [feat(ccusage): add progress bars…](url) | ⚪ draft | Mark ready when done — or close if abandoned | Mar 15 |
| [gnachman/iTerm2](url) | [perf(search): debounce filter inputs…](url) | 🟡 waiting for review | Ping maintainer — open 1 day with no response | Mar 14 |

---

### 👀 Review Requests

| Repo | Title | Requested by | Status | Next action | Updated |
|------|-------|-------------|--------|-------------|---------|

_Nothing here._

---

### 🐛 Issues

| # | Repo | Title | Source | Status | Next action | Updated |
|---|------|-------|--------|--------|-------------|---------|
| [#22967](url) | raycast/extensions | [Espanso] Edit Matches | assigned | 🔴 needs response | Reply to @grafst's feature request | Feb 28 |

---

```

Rules:

- Deduplicate issues: show each once in the highest-priority category (assigned > mentions > opened by you). Add a "Source" column to the issues table showing where it came from (`assigned` / `mention` / `author`).
- If a section has no items, write `_Nothing here._` — don't skip the section entirely.
- Truncate long titles to ~60 chars with `…` to keep the table readable.
- Do not ask the user for confirmation before fetching — just run it.

## Step 4 — Interactive next moves

After rendering the triage tables, invoke `/next-moves` with the top actionable items (max 7). Prioritise 🔴 items first, then 🟡, then 🟠. Each item label should be a concrete action ("Reply to @grafst on #22967", "Check comment on PR #26347", "Ping iTerm2 maintainer on #615").
