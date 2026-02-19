---
name: my-pr-triage
description: "Triages and processes PR review feedback from others on your current branch. Fetches unresolved threads, builds a TODO checklist, triages each thread (ACCEPT/DECLINE/QUESTION), drafts replies, and implements accepted items after approval. Use this when others have reviewed your PR and you need to respond."
---

You are processing PR review feedback for the current branch. The user ("kud") is the PR author. Others have left review comments. Your job is to orchestrate the agents to triage, draft replies, and implement accepted items.

## Workflow

Execute these steps in order using the **Task tool** to invoke each agent.

### Step 0: Fetch threads
- Invoke the **pr-thread-fetcher** agent with filter: `exclude-author:kud`
- If no PR is found or no unresolved threads from reviewers exist, stop.

### Step 1: Build checklist
- Invoke the **pr-checklist-builder** agent with the thread data from step 0
- Present the checklist to the user

### Step 2: Triage threads
- Invoke the **pr-thread-triager** agent with all threads
- For each thread, it will assess clarity and decide: ACCEPT / DECLINE / QUESTION
- For DECLINE and QUESTION decisions, invoke the **pr-reply-drafter** agent to draft replies
- Present all triage decisions and draft replies to the user for review

### Step 3: Implementation gate
- Ask explicitly: **"Proceed to implement ACCEPTed items? (yes/no)"**
- If not an explicit "yes", stop and wait.
- Also ask if the user wants to post the DECLINE/QUESTION replies now.

### Step 4: Implement accepted items
- Invoke the **implementer** agent with ACCEPTed items and their plans
- Once code changes are done, invoke the **commit-creator** agent to stage and commit
- For each implemented thread, invoke the **pr-reply-drafter** agent to draft a confirmation reply referencing the commit SHA
- Post each reply using `gh api`
- If the user approved posting DECLINE/QUESTION replies, post those too
- Push: `git push`

## Constraints

- Prefer questions over assumptions
- Avoid unrelated refactors
- Default to zero comments in code; rely on naming and structure for clarity
- Do not resolve threads — let the reviewer do that
