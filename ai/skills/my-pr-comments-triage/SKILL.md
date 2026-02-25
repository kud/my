---
name: my-pr-comments-triage
description: "Triages and processes PR review feedback from others on your current branch. Fetches unresolved threads, builds a TODO checklist, triages each thread (ACCEPT/DECLINE/QUESTION), drafts replies, and implements accepted items after approval. Use this when others have reviewed your PR and you need to respond."
---

You are processing PR review feedback for the current branch. The user ("kud") is the PR author. Others have left review comments. Your job is to orchestrate the agents to triage, draft replies, and implement accepted items.

## Workflow

Execute these steps in order using the **Task tool** to invoke each agent.

### Step 0: Fetch comments
- Invoke the **pr-comments-fetcher** agent with filter: `exclude-author:kud`
- If no PR is found or no unresolved threads/comments from reviewers exist, stop.

### Step 1: Build checklist
- Invoke the **pr-checklist-builder** agent with the comment data from step 0
- Present the checklist to the user

### Step 2: Triage comments
- Invoke the **pr-comments-triager** agent with all threads and general comments
- For each thread, it will assess clarity and decide: ACCEPT / DECLINE / QUESTION
- For DECLINE and QUESTION decisions, invoke the **pr-reply-drafter** agent to draft replies
- Present all triage decisions and draft replies to the user for review

### Step 3: Approval gate
- Present all triage decisions, draft replies, and implementation plans to the user
- Ask explicitly: **"Do you want to adjust any decisions or replies before I proceed?"**
- Let the user debate, edit, or override any decision — this is a discussion, not a rubber stamp
- Only proceed when the user explicitly approves

### Step 4: Implement accepted items
- Invoke the **implementer** agent with ACCEPTed items and their plans
- Once code changes are done, invoke the **commit-creator** agent to stage and commit

### Step 5: Post replies (requires explicit approval)
- Show the user every reply that will be posted (ACCEPT confirmations with commit SHA, DECLINE rationales, QUESTION clarifications)
- Ask explicitly: **"Ready to post these replies? (yes/no)"**
- **NEVER post a reply to GitHub without the user's explicit approval**
- Post approved replies using `gh api`
- Push: `git push`

### Step 6: Re-request review (automatic)
- Run: `gh pr edit <number> --add-reviewer <reviewer1>,<reviewer2>,...` using the current reviewers on the PR (`gh pr view --json reviewRequests`)
- Output: ✅ **Review re-requested** from <reviewer logins>

## Constraints

- **NEVER post a comment or reply to GitHub without explicit user approval** — draft first, discuss, then post only when told to
- Prefer questions over assumptions
- Avoid unrelated refactors
- Default to zero comments in code; rely on naming and structure for clarity
- Do not resolve threads — let the reviewer do that
