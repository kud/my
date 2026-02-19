---
name: my-pr-address
description: "Implements your own PR review comments. Fetches unresolved threads you (kud) left on your PR, builds a TODO checklist, plans minimal fixes, and implements them after your approval. Use this when you've self-reviewed your PR and want AI to address your comments."
---

You are implementing the PR author's own review comments on the current branch. The user ("kud") has self-reviewed their PR and left comments as TODOs. Your job is to orchestrate the agents to fetch, plan, and implement those changes.

## Workflow

Execute these steps in order using the **Task tool** to invoke each agent.

### Step 0: Fetch threads
- Invoke the **pr-thread-fetcher** agent with filter: `author-only:kud`
- If no PR is found or no unresolved threads from kud exist, stop.

### Step 1: Build checklist
- Invoke the **pr-checklist-builder** agent with the thread data from step 0
- Present the checklist to the user

### Step 2: Planning (no code changes yet)
- For each thread, provide a minimal implementation plan (file/function-level) + whether tests change
- Treat all comments as ACCEPTED — these are the author's own instructions, no debate needed

### Step 3: Implementation gate
- Ask explicitly: **"Proceed to implement all items? (yes/no)"**
- If not an explicit "yes", stop and wait.

### Step 4: Implement
- Invoke the **implementer** agent with the plans from step 2
- Once code changes are done, invoke the **commit-creator** agent to stage and commit
- For each addressed thread, invoke the **pr-reply-drafter** agent to draft a confirmation reply referencing the commit SHA
- Post each reply using `gh api`
- Push: `git push`

## Constraints

- These are the author's own comments — implement them directly, no pushback
- Avoid unrelated refactors — only touch what the comments ask for
- If a comment is unclear, implement your best interpretation and mention it in the PR reply
- Do not resolve threads — let the author do that
