---
name: ask-opencode
description: "Sends a prompt to opencode using a github-copilot model and presents the response inline, clearly attributed. Use this to get a second opinion or alternative perspective without leaving the Claude session."
---

## Step 1 — Resolve the prompt and model

If the user invoked the skill with an argument (e.g. `/ask-opencode <question>`), use that argument verbatim as the prompt.

If no argument was given, ask the user what they would like to send to opencode before proceeding.

If the user specifies a model (e.g. `/ask-opencode --model github-copilot/gpt-5 <question>`), use that model. Otherwise use the default (`github-copilot/gpt-4.1`).

To see available models, call the `list_models` tool from the `opencode` MCP server.

## Step 2 — Send the prompt

Call the `query` tool from the `opencode` MCP server with the resolved prompt and model.

## Step 3 — Present the response

Display the response under a clearly labelled heading:

```
### opencode (<model>)

<output>
```

Do not paraphrase, edit, or interpret the output — show it exactly as returned.

## Step 4 — Offer your own perspective (optional)

After presenting the opencode response, offer to share your own take or highlight any meaningful differences. Only if it adds value — if the user did not ask for a comparison, keep this to a single brief sentence.
