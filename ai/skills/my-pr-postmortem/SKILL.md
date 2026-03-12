---
name: my-pr-postmortem
description: "Runs a post-mortem on a merged PR: fetches all review comments (resolved and unresolved), categorizes the feedback, identifies patterns, and produces AI improvement suggestions. Use this after a PR is merged to learn from reviewer feedback."
---

You produce a retrospective analysis of a completed PR. The goal is not to re-implement anything — it's to understand what reviewers flagged and extract lessons that improve future AI-assisted work.

## Step 0 — Identify the PR

- If on a feature branch: run `gh pr view --json number,title,url,headRefName,mergedAt,state`
- If the PR is not found or not merged, ask the user for the PR number or URL
- Extract: owner, repo, PR number

## Step 1 — Fetch all feedback (do this yourself, not via pr-comments-fetcher)

Run all three sources in parallel:

**a) All review threads (resolved + unresolved):**
```
gh api graphql -f query='
  query($owner: String!, $repo: String!, $pr: Int!) {
    repository(owner: $owner, name: $repo) {
      pullRequest(number: $pr) {
        reviewThreads(first: 100) {
          nodes {
            id
            isResolved
            path
            line
            comments(first: 10) {
              nodes {
                author { login }
                body
                createdAt
              }
            }
          }
        }
      }
    }
  }
' -f owner=<owner> -f repo=<repo> -F pr=<number>
```

**b) General PR comments (issue-style):**
```
gh api repos/<owner>/<repo>/issues/<number>/comments \
  --jq '[.[] | select(.user.type != "Bot") | {author: .user.login, body: .body, url: .html_url}]'
```

**c) Top-level review summaries (review bodies):**
```
gh api repos/<owner>/<repo>/pulls/<number>/reviews \
  --jq '[.[] | select(.user.type != "Bot" and (.body | length > 0)) | {author: .user.login, state: .state, body: .body, submitted_at: .submitted_at}]'
```

Exclude all bot authors (login ends in `[bot]`).

## Step 2 — Analyze the feedback

Invoke a **general-purpose agent** with all the collected data and this analysis prompt:

```
You are analyzing PR review feedback to produce a post-mortem.

Given the following feedback from a PR (review threads, general comments, review summaries), produce a structured analysis:

1. **Categorize every comment** into one of:
   - Naming / clarity (variable names, function names, file names)
   - Logic / correctness (bugs, wrong behavior, edge cases)
   - Architecture / design (structure, coupling, abstractions)
   - Style / formatting (code style, consistency)
   - Tests (missing coverage, wrong assertions)
   - Scope creep / unnecessary changes
   - Documentation / comments
   - Other

2. **Identify recurring patterns** — same category appearing 3+ times, same reviewer concern repeated, same file/area flagged multiple times

3. **Root cause hypothesis** — for each pattern, was it:
   - AI-generated code tendency (e.g., AI over-engineers, adds unnecessary abstraction)
   - Missing rule in skill/CLAUDE.md (e.g., "always check for unused props")
   - Unclear spec / requirement
   - Genuine complexity / trade-off

4. **AI improvement suggestions** — for each root cause, propose a concrete rule:
   - If it's a coding pattern: write the rule as it would appear in CLAUDE.md
   - If it's a skill gap: describe what step to add to which skill
   - If it's a linting gap: name the ESLint/TS rule that would catch it

Data:
<feedback data>
```

## Step 3 — Output the post-mortem report

Present the analysis in this format:

```
## PR Post-Mortem — #<number>: <title>

### Feedback Overview
- **Total threads**: N (M resolved, K unresolved)
- **Reviewers**: <list of reviewer logins>
- **Merged**: <date>

---

### Feedback by Category

| Category | Count | Examples |
|----------|-------|---------|
| Naming / clarity | N | ... |
| Logic / correctness | N | ... |
| ... | | |

---

### Patterns & Themes

**[Pattern name]**
- Appeared N times across <files/areas>
- Example: "<reviewer quote>"
- Root cause: <hypothesis>

**[Pattern name]**
...

---

### AI Improvement Suggestions

**[Issue]** — <AI tendency / missing rule / unclear spec>

```
<exact rule text as it would appear in CLAUDE.md or skill>
```

**[Issue]** — ...

```
<rule text>
```
```

Then on a new line, append tips if there are PR-specific follow-ups (open threads, spec gaps, highest ROI callouts):

```
💡 **Tips & Notes**

- **<topic>**: <concise actionable tip>
- **<topic>**: <concise actionable tip>
```

## Constraints

- This is a retrospective — do NOT implement any code changes
- Do NOT post any comments to GitHub
- Do NOT re-open or interact with the PR
- If the PR has zero review comments, say so and stop
