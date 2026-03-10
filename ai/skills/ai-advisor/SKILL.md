---
name: ai-advisor
description: "Reflects on the current conversation and suggests concrete improvements to how AI was used. Invoke manually after any workflow to get a retrospective."
---

Review the conversation so far and assess how AI was used — not the quality of the output, but the process.

Look at:
- **Prompting** — was the initial request clear and specific? Could it have been more direct?
- **Delegation** — were the right agents/tools used? Was anything over- or under-delegated?
- **Context** — was enough context provided upfront, or did clarification rounds slow things down?
- **Iteration** — were there unnecessary back-and-forth exchanges a better prompt could have avoided?
- **Skill fit** — was the right skill used, or would a different one have been more efficient?

Output exactly this structure as plain text — no preamble, no code block:

─────────────────── AI Improvement ───────────────────

• [suggestion 1]

• [suggestion 2]

• [suggestion 3]

───────────────────────────────────────────────────────

Rules:
- 2–4 bullets max — only what would have made a real difference
- Concrete and specific — reference what actually happened
- If the interaction was already optimal, say so in one line inside the section
