---
name: my-create-mcp
description: "Scaffolds a complete TypeScript MCP server project from scratch. Covers project structure, package.json conventions, tsconfig, SDK patterns, tool registration, auth, README, and Claude Desktop config. Use this when creating a new MCP server."
---

You are scaffolding a new TypeScript MCP server. Follow every step exactly.

## Step 1 — Gather info

Ask the user:

1. **What API/service** is this MCP for?
2. **What tools** should it expose? (or should you infer from the API docs?)
3. **Auth method**: Bearer token? API key? OAuth? Which env var name?

Do not proceed until you have clear answers.

## Step 2 — Create project structure

Project lives at `~/Projects/mcp-<service-name>/`.

```
mcp-<service-name>/
  src/
    index.ts
  package.json
  tsconfig.json
```

## Step 3 — package.json

```json
{
  "name": "@kud/mcp-<service-name>",
  "version": "1.0.0",
  "type": "module",
  "description": "MCP server for <Service> — <one-line summary>.",
  "main": "dist/index.js",
  "types": "dist/index.d.ts",
  "bin": {
    "mcp-<service-name>": "./dist/index.js"
  },
  "scripts": {
    "build": "tsc -p tsconfig.json && chmod +x dist/index.js",
    "build:watch": "tsc -p tsconfig.json --watch",
    "dev": "tsx src/index.ts",
    "start": "node dist/index.js",
    "inspect": "npx @modelcontextprotocol/inspector node dist/index.js",
    "inspect:dev": "npx @modelcontextprotocol/inspector tsx src/index.ts",
    "typecheck": "tsc --noEmit",
    "clean": "rm -rf dist",
    "prepublishOnly": "npm run clean && npm run build"
  },
  "files": ["dist", "README.md", "LICENSE"],
  "keywords": ["mcp", "<service>", "model-context-protocol"],
  "author": "kud",
  "license": "MIT",
  "repository": {
    "type": "git",
    "url": "git+https://github.com/kud/mcp-<service-name>.git"
  },
  "bugs": {
    "url": "https://github.com/kud/mcp-<service-name>/issues"
  },
  "homepage": "https://github.com/kud/mcp-<service-name>#readme",
  "engines": {
    "node": ">=20.0.0"
  },
  "publishConfig": {
    "access": "public"
  },
  "dependencies": {
    "@modelcontextprotocol/sdk": "^1.10.2",
    "zod": "^3.22.4"
  },
  "devDependencies": {
    "@types/node": "^20.0.0",
    "tsx": "^4.7.0",
    "typescript": "^5.0.0"
  }
}
```

## Step 4 — tsconfig.json

```json
{
  "compilerOptions": {
    "target": "ES2023",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "lib": ["ES2023"],
    "outDir": "dist",
    "rootDir": "src",
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

## Step 5 — src/index.ts architecture

### Shebang + imports

```ts
#!/usr/bin/env node
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js"
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js"
import { z } from "zod"
```

### Auth — fail fast

Read the token at startup, exit immediately if missing:

```ts
const API_TOKEN = process.env.MY_API_TOKEN
if (!API_TOKEN) {
  console.error("MY_API_TOKEN env var is required")
  process.exit(1)
}
```

### Fetch helper

Typed, auth-injected, logs errors to stderr (never stdout):

```ts
const API_BASE = "https://api.example.com/v1"

async function apiFetch<T>(
  path: string,
  options: RequestInit = {},
): Promise<T | null> {
  try {
    const response = await fetch(`${API_BASE}${path}`, {
      ...options,
      headers: {
        Authorization: `Bearer ${API_TOKEN}`,
        "Content-Type": "application/json",
        ...options.headers,
      },
    })
    if (!response.ok) {
      console.error(`API error: ${response.status} ${path}`)
      return null
    }
    return (await response.json()) as T
  } catch (err) {
    console.error(`Fetch failed: ${path}`, err)
    return null
  }
}
```

### Response helpers

```ts
const ok = (data: unknown) => ({
  content: [{ type: "text" as const, text: JSON.stringify(data, null, 2) }],
})

const err = (msg: string) => ({
  content: [{ type: "text" as const, text: `Error: ${msg}` }],
})
```

### Server instance

```ts
const server = new McpServer({ name: "<service-name>", version: "1.0.0" })
```

### Tool registration pattern

```ts
server.registerTool(
  "tool_name",
  {
    description: "What this tool does",
    inputSchema: {
      param: z.string().describe("What this param is"),
      optional_param: z.number().optional(),
    },
  },
  async ({ param, optional_param }) => {
    const data = await apiFetch<{ item: unknown }>(`/endpoint/${param}`)
    if (!data) return err("failed to fetch item")
    return ok(data.item)
  },
)
```

Tool design rules:

- Group tools with section comments: `// ─── Resource Name ───`
- Destructive tools (delete, empty trash) require a `confirm: z.boolean().default(false)` guard
- Bulk operations use `operation: z.enum([...])` rather than separate tools
- Always `console.error()` for logging — never `console.log()` (corrupts STDIO)
- Cover the full API — check official docs and existing open-source MCP implementations on GitHub

### Main

```ts
async function main() {
  const transport = new StdioServerTransport()
  await server.connect(transport)
  console.error("mcp-<service-name> running")
}

main().catch((err) => {
  console.error("Fatal:", err)
  process.exit(1)
})
```

## Step 6 — Install and build

```bash
cd ~/Projects/mcp-<service-name>
npm install
npm run build
```

Build must succeed with zero errors before proceeding.

## Step 7 — Claude Desktop config

Snippet to add to `~/Library/Application Support/Claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "<ServiceName>": {
      "command": "node",
      "args": ["/Users/kud/Projects/mcp-<service-name>/dist/index.js"],
      "env": {
        "MY_API_TOKEN": "your-token-here"
      }
    }
  }
}
```

Remind the user to restart Claude Desktop after saving.

## Step 8 — CLAUDE.md

Create a `CLAUDE.md` in the project root containing the official API docs URL:

```markdown
# mcp-<service-name>

## API Reference

Official API docs: <url>
```

This is required so `my-update-mcp` can find the docs in future audits without asking.

## Step 9 — README

Create `README.md` following this exact structure and style (see `github.com/kud/mcp-raindrop-io` as the reference):

1. **ASCII art title** — generate block-letter ASCII art for `<SERVICE-NAME>.IO` (or just `<SERVICE-NAME>` if no TLD). Use the same box-drawing characters (`█`, `╗`, `╔`, `╝`, `╚`, `═`, `║`).

2. **Badges row** (centered):
   - TypeScript version
   - Node.js version
   - MCP 1.0
   - npm package (`@kud/mcp-<service-name>`)
   - License MIT

3. **One-line tagline** — bold, centered, e.g. `**A <Service> MCP server with N tools for <what it does>**`

4. **Nav links** — Features • Quick Start • Installation • Tools • Development

5. **Features section** — emoji bullet list of key capabilities

6. **Quick Start** — prerequisites, npm/local install, minimal config snippet for Claude Desktop

7. **Installation guides** — collapsible `<details>` blocks for: Claude Code CLI, Claude Desktop (macOS + Windows), Cursor, Windsurf, VSCode

8. **Available Tools** — grouped by resource with a markdown table per group (`Tool | Description`). End with **Total: N Tools**.

9. **Example Conversations** — 6–10 realistic natural-language exchanges showing what you can do

10. **Development section** — project structure tree, scripts table, dev workflow, inspector usage

11. **Authentication** — step-by-step on getting the API token/key, with a `curl` test snippet

12. **Troubleshooting** — server not showing, auth errors, log locations

13. **Security best practices** — bullet list

14. **Tech Stack** — Runtime, Language, Target, Protocol, HTTP Client, Module System

15. **Contributing, License, Acknowledgments, Support** — standard footers

16. **Footer** — centered, "Made with ❤️ for <audience>", star CTA, back-to-top link

## Step 10 — Local dev & inspection

```bash
# Run directly without building
npm run dev

# Inspect tools interactively in the browser
npm run inspect
npm run inspect:dev   # without build step
```

## Design principles

- **Single file** (`src/index.ts`) unless tool count clearly exceeds ~25
- **No inline comments** — clear naming over explanation; extract a named function if logic is complex
- **`const` over `let`** everywhere
- **Typed generics on `apiFetch<T>`** — never `any` on response shapes
- **`dist/` for output** — always, not `build/`
- **Kebab-case** for the project folder and package name

## Final step — QA

Run `/my-run-qa` to review this execution for missed steps or wrong decisions.
