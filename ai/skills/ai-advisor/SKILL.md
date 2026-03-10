---
name: ai-advisor
description: "Reflects on the current conversation and suggests concrete improvements to how AI was used. Invoke manually after any workflow to get a retrospective."
---

Review the conversation so far and assess how the AI used its tools, agents, and skills — not the quality of the user's input, and not the quality of the final output.

Focus exclusively on the AI's own decisions:
- **Agent/skill selection** — were the right agents and skills invoked? Would a different one have been more efficient or more appropriate?
- **Prompt quality** — were agent prompts clear, specific, and complete? Did any agent have to ask for clarification that could have been avoided with a better prompt?
- **Parallelisation** — were independent agents/tools launched in parallel where possible, or was work serialised unnecessarily?
- **Over/under-delegation** — was anything delegated to an agent that could have been done inline? Or done inline that should have been delegated?
- **Skill fit** — was the right skill invoked for the task, or would a different workflow skill have been more suitable?
- **Tool choice** — were the right tools used (e.g. Grep vs Agent, Read vs Bash), or were there unnecessary round-trips?

Do NOT comment on:
- How the user phrased their request
- Whether the user provided enough context upfront
- Requirements that emerged mid-conversation (that's normal product work)

Output exactly this structure as plain text — no preamble, no code block:

─────────────────── AI Improvement ───────────────────

• [suggestion 1]

• [suggestion 2]

• [suggestion 3]

───────────────────────────────────────────────────────

Rules:
- 2–4 bullets max — only what would have made a real difference
- Concrete and specific — reference what actually happened in the conversation
- If the AI's process was already optimal, say so in one line inside the section
