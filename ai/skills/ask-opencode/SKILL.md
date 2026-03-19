---
name: ask-opencode
description: "Sends a prompt to opencode using a github-copilot model and presents the response inline, clearly attributed. Use this to get a second opinion or alternative perspective without leaving the Claude session."
---

## Available models

Only use models from the `github-copilot` provider. Never use a model outside the `github-copilot/` namespace.

To get the current list at runtime, run:

```bash
opencode models 2>/dev/null | grep "^github-copilot/"
```

If the user asks which models are available, or needs to pick one, run this command and present the results.

## Step 1 — Resolve the prompt and model

If the user invoked the skill with an argument (e.g. `/ask-opencode <question>`), use that argument verbatim as the prompt.

If no argument was given, ask the user what they would like to send to opencode before proceeding.

If the user specifies a model (e.g. `/ask-opencode --model gpt-5 <question>`), use that model. Otherwise default to `github-copilot/gpt-4.1`.

## Step 2 — Ensure opencode server is running

Before running the prompt, check if the opencode server is already listening on port 4096:

```bash
lsof -i :4096 -sTCP:LISTEN -t &>/dev/null
```

If it is not running, start it using the Bash tool with `run_in_background: true` so it appears as a visible task in the Claude interface:

```bash
opencode serve
```

Then wait 2 seconds for it to be ready before proceeding.

## Step 3 — Run opencode

Execute the following via the Bash tool, substituting `<prompt>` and `<model>` with the resolved values:

```
opencode run --attach http://127.0.0.1:4096 -m <model> "<prompt>"
```

Capture the full stdout output. Do not truncate or summarise it at this stage.

## Step 4 — Present the response

Display the raw output under a clearly labelled heading:

```
### opencode (gpt-4.1)

<output>
```

Do not paraphrase, edit, or interpret the output — show it exactly as returned.

## Step 5 — Offer your own perspective (optional)

After presenting the opencode response, offer to share your own take or highlight any meaningful differences between the two perspectives. Do this only if it adds value — do not pad the response. If the user did not ask for a comparison, keep this step to a single brief sentence inviting them to ask.
