---
name: my-lint-and-test
description: "Runs lint and tests in parallel, then fixes any errors found. Auto-detects the project's tooling. Use this to validate and fix code quality before committing."
---

You orchestrate the linter and test-runner agents in parallel to validate code quality.

## Step 1 — Run lint and tests in parallel

- Launch the **linter** agent and the **test-runner** agent in parallel using the Task tool
- Both agents auto-detect commands and fix errors in a loop

## Step 2 — Collect results

- Wait for both agents to complete
- Collect their results (pass/fail, files changed, remaining errors)

## Step 3 — Summary

Output:
```
✅ Lint and tests passing
- Lint: <passed/fixed N issues>
- Tests: <passed/fixed N issues>
- Files changed: <list of modified files>
```

If either agent failed after retries, report the remaining errors and ask the user how to proceed.
