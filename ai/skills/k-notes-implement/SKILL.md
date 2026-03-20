---
name: k-notes-implement
description: "Reads a .notes.json file (created by a VSCode extension), implements all noted changes in the codebase, then deletes the file. Like addressing PR review comments but entirely local — no PR needed."
---

You are implementing inline code notes from a local `.notes.json` file. Your job is to read the notes, present them clearly, get confirmation, then implement each one using the implementer agent.

## Step 1 — Read .notes.json

- Read `.notes.json` from the current working directory using the Read tool
- If the file does not exist, tell the user and stop
- Parse the JSON — accept either a root array or an object with a `notes` key:
  - Root array: `[ { "file": "...", "line": 42, "note": "..." }, ... ]`
  - Object with key: `{ "notes": [ ... ] }`
- If the file is empty or malformed, tell the user and stop

## Step 2 — Display the checklist

Group notes by file and present a numbered TODO checklist to the user:

```
Files to update:

src/foo.ts
  [ ] 1. Line 42 — Extract this into a named function
  [ ] 2. Line 87 — Remove dead code

src/bar.ts
  [ ] 3. Line 12 — Rename variable for clarity
```

Show the total count: **N notes across M files**.

## Step 3 — Confirmation gate

Ask explicitly: **"Proceed to implement all N notes? (yes/no)"**

If the user does not say yes, stop and wait. Do not implement anything without explicit approval.

## Step 4 — Implement

For each file that has notes, invoke the **implementer** agent with:

- The file path
- Each note for that file (line number + note text)
- Instruction to implement exactly what the note describes — no unrelated changes

You may batch all notes for the same file into a single implementer call. Use separate calls per file.

Pass full context to each agent: file path, line number, and the note text verbatim.

## Step 5 — Delete .notes.json

Once all notes have been implemented, delete `.notes.json` from the current working directory using the Bash tool:

```
rm .notes.json
```

Confirm to the user that the file has been removed.

## Step 6 — Lint and test (optional)

Ask the user: **"Run lint and tests? (yes/no)"**

If yes, invoke `/k-lint-and-test`.

## Constraints

- **Never implement anything before explicit confirmation in step 3**
- Implement notes exactly as written — do not interpret loosely or add unrequested changes
- If a note is ambiguous, implement your best interpretation and flag it to the user afterwards
- Do not delete `.notes.json` unless all notes were processed without error
- If any implementer agent reports a failure, pause and ask the user how to proceed before continuing

## Final step — QA

Run `/k-qa-run` to review this execution for missed steps or wrong decisions. If issues are found, surface them and ask before applying fixes. If nothing is wrong, stay silent.
