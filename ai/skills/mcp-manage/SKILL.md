---
name: mcp-manage
description: "Create or maintain a TypeScript MCP server. Auto-detects whether the project already exists and runs the full scaffold (create) or audit-and-update flow accordingly. Covers structure, tools, Vitest, README, CLAUDE.md, and Claude Desktop config."
---

You are creating or maintaining a TypeScript MCP server. Follow every step exactly.

## Step 1 — Detect mode

**Auto-detect the project name** from the current working directory if it looks like an MCP project (e.g. `mcp-jenkins`). Otherwise ask.

Then check whether `~/Projects/mcp-<service-name>/src/index.ts` already exists:

- **File does not exist** → **CREATE mode** — go to Step 2
- **File exists** → **UPDATE mode** — go to Step U1

---

# CREATE MODE

## Step 2 — Gather info

Ask the user:

1. **What API/service** is this MCP for?
2. **What tools** should it expose? (or should you infer from the API docs?)
3. **Auth method**: Bearer token? API key? OAuth? Which env var name?

Do not proceed until you have clear answers.

## Step 3 — Create project structure

Project lives at `~/Projects/mcp-<service-name>/`.

```
mcp-<service-name>/
  src/
    index.ts
    __tests__/
      tools.test.ts
  package.json
  tsconfig.json
```

## Step 4 — package.json

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
    "test": "vitest run",
    "test:watch": "vitest",
    "coverage": "vitest run --coverage",
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
    "zod": "^3.24.0"
  },
  "devDependencies": {
    "@types/node": "^20.0.0",
    "@vitest/coverage-v8": "^3.0.0",
    "tsx": "^4.7.0",
    "typescript": "^5.0.0",
    "vitest": "^3.0.0"
  }
}
```

## Step 5 — tsconfig.json

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

## Step 6 — src/index.ts architecture

### Shebang + imports

```ts
#!/usr/bin/env node
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js"
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js"
import { z } from "zod"
```

### Auth — fail fast

**Simple API key / bearer token:**

```ts
const API_TOKEN = process.env.MY_API_TOKEN
if (!API_TOKEN) {
  console.error("MY_API_TOKEN env var is required")
  process.exit(1)
}
```

**OAuth2** — tokens expire; read from `~/.config/<service>.json` written by a `setup.js` device flow script (see Step 7b):

```ts
import { readFileSync } from "fs"
import { homedir } from "os"
import { join } from "path"

const loadConfig = () => {
  try {
    return JSON.parse(
      readFileSync(join(homedir(), ".config", "<service>.json"), "utf8"),
    )
  } catch {
    return {}
  }
}

const config = loadConfig()
const API_TOKEN = process.env.MY_API_TOKEN ?? config.accessToken

if (!API_TOKEN) {
  console.error("MY_API_TOKEN env var or ~/.config/<service>.json required")
  process.exit(1)
}
```

### Fetch helper

```ts
const API_BASE = "https://api.example.com/v1"

export const apiFetch = async <T>(
  path: string,
  options: RequestInit = {},
): Promise<T | null> => {
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
  } catch (e) {
    console.error(`Fetch failed: ${path}`, e)
    return null
  }
}
```

### Response helpers

```ts
export const ok = (data: unknown) => ({
  content: [{ type: "text" as const, text: JSON.stringify(data, null, 2) }],
})

export const err = (msg: string) => ({
  content: [{ type: "text" as const, text: `Error: ${msg}` }],
})
```

### Tool handlers — extract for testability

Each tool handler must be an exported named arrow function so it can be tested in isolation:

```ts
export const getItem = async ({ id }: { id: string }) => {
  const data = await apiFetch<{ item: unknown }>(`/items/${id}`)
  return data ? ok(data.item) : err("failed to fetch item")
}
```

### Server instance + tool registration

```ts
const server = new McpServer({ name: "<service-name>", version: "1.0.0" })

// ─── Items ───
server.registerTool(
  "get_item",
  {
    description: "Fetch a single item by ID",
    inputSchema: { id: z.string().describe("Item ID") },
  },
  getItem,
)
```

Tool design rules:

- Group tools with section comments: `// ─── Resource Name ───`
- Destructive tools require a `confirm: z.boolean().default(false)` guard
- Bulk operations use `operation: z.enum([...])` rather than separate tools
- Always `console.error()` for logging — never `console.log()` (corrupts STDIO)
- Cover the full API — check official docs and existing open-source MCP implementations on GitHub

### Main

```ts
const main = async () => {
  const transport = new StdioServerTransport()
  await server.connect(transport)
  console.error("mcp-<service-name> running")
}

main().catch((e) => {
  console.error("Fatal:", e)
  process.exit(1)
})
```

## Step 7 — src/**tests**/tools.test.ts

Test every tool handler. Mock `apiFetch` at the module level with `vi.mock`:

```ts
import { describe, it, expect, vi, beforeEach } from "vitest"
import * as api from "../index.js"

vi.mock("../index.js", async (importOriginal) => {
  const mod = await importOriginal<typeof import("../index.js")>()
  return {
    ...mod,
    apiFetch: vi.fn(),
  }
})

const mockFetch = vi.mocked(api.apiFetch)

describe("get_item", () => {
  beforeEach(() => vi.clearAllMocks())

  it("returns item on success", async () => {
    mockFetch.mockResolvedValue({ item: { id: "1", name: "Test" } })
    const result = await api.getItem({ id: "1" })
    expect(result.content[0].text).toContain("Test")
    expect(mockFetch).toHaveBeenCalledWith("/items/1")
  })

  it("returns error when fetch fails", async () => {
    mockFetch.mockResolvedValue(null)
    const result = await api.getItem({ id: "1" })
    expect(result.content[0].text).toContain("Error:")
  })
})
```

Write at least one success and one failure test per tool handler.

## Step 8 — Install and build

```bash
cd ~/Projects/mcp-<service-name>
npm install
npm run build
npm test
```

All must pass with zero errors.

## Step 8b — Local MCP for development + setup script

Create `.mcp.json` in the project root:

```json
{
  "mcpServers": {
    "<service-name>": {
      "command": "node",
      "args": ["./dist/index.js"]
    }
  }
}
```

If the API uses OAuth, create `setup.js` — a device flow script that writes `~/.config/<service>.json`. Add `"setup": "node setup.js"` to package.json scripts.

Add `.mcp.json` and `.claude/` to `.gitignore`. Never commit `~/.config/<service>.json`.

## Step 9 — Register with Claude Desktop

Add to `~/my/config/apps/claude-desktop.yml` under the `mcp:` block:

```yaml
<ServiceName>:
  transport: stdio
  command: node
  args:
    - /Users/kud/Projects/mcp-<service-name>/dist/index.js
  env:
    MY_API_TOKEN: ${MCP_<SERVICE_NAME>_TOKEN}
```

Then apply it:

```bash
my apps claude-desktop
```

Remind the user to restart Claude Desktop.

## Step 10 — CLAUDE.md

Create `CLAUDE.md` in the project root:

```markdown
# mcp-<service-name>

## API Reference

Official API docs: <url>
```

## Step 11 — README

Create `README.md` following this exact structure (see `github.com/kud/mcp-raindrop-io` as the reference):

1. **ASCII art title** — block-letter art using `█`, `╗`, `╔`, `╝`, `╚`, `═`, `║`
2. **Badges row** (centered) — TypeScript, Node.js, MCP 1.0, npm package, MIT
3. **One-line tagline** — bold, centered
4. **Nav links** — Features • Quick Start • Installation • Tools • Development
5. **Features section** — emoji bullet list
6. **Quick Start** — prerequisites, install, minimal Claude Desktop config snippet
7. **Installation guides** — `<details>` blocks for Claude Code CLI, Claude Desktop (macOS + Windows), Cursor, Windsurf, VSCode
8. **Available Tools** — grouped tables per resource (`Tool | Description`), end with **Total: N Tools**
9. **Resources** — official API docs link:

   ```markdown
   ## Resources

   - [Official API docs](url)
   ```

10. **Example Conversations** — 6–10 realistic natural-language exchanges
11. **Development section** — project structure tree, scripts table, dev workflow, inspector usage
12. **Authentication** — step-by-step for getting the token, `curl` test snippet
13. **Troubleshooting** — server not showing, auth errors, log locations
14. **Security best practices** — bullet list
15. **Tech Stack** — Runtime, Language, Target, Protocol, HTTP Client, Module System
16. **Contributing, License, Acknowledgments, Support** — standard footers
17. **Footer** — centered, "Made with ❤️ for <audience>", star CTA, back-to-top link

---

# UPDATE MODE

## Step U1 — Find the API docs URL

Look in this order:

1. `CLAUDE.md` → `## API Reference` section
2. `README.md` → Resources or API link
3. Ask the user if neither has it

Save for Step U3. If it wasn't in `CLAUDE.md`, add it now (Step U5).

## Step U2 — Identify remote vs local

Check the entry in `$MY/profiles/*/config/cli/claude-code.yml` or `$MY/config/cli/claude-code.yml`:

- `transport: http` or `transport: sse` with a remote URL → **remote MCP** → go to Step U2b
- `transport: stdio` with a local command → **local MCP** → continue to Step U3

## Step U2b — Remote MCP: config update only

1. Fetch the official docs
2. Extract: endpoint URL, query params, auth method, new config options
3. Show a diff and ask for confirmation
4. Apply to the correct `claude-code.yml`
5. Run `my ai sync`
6. **Stop here** — no code changes for remote MCPs

## Step U3 — Fetch the API docs

Use `WebFetch` or `WebSearch`. Build a complete list of:

- All endpoints / resources / methods
- Their parameters and response shapes
- Any auth scopes required

## Step U4 — Audit existing tools

Read `src/index.ts` (and siblings). For each API endpoint:

- Tool exists and is current → **COVERED**
- Tool exists but params/types are stale → **OUTDATED**
- No tool exists → **MISSING**

Produce a coverage table:

| Endpoint / Resource | Tool name | Status                       |
| ------------------- | --------- | ---------------------------- |
| ...                 | ...       | COVERED / OUTDATED / MISSING |

Show the table and ask for confirmation before proceeding.

## Step U5 — Implement changes

For each MISSING or OUTDATED item approved by the user:

- Add or update the tool following the patterns in `src/index.ts`
- Keep the same section grouping (`// ─── Resource Name ───`)
- Match existing `apiFetch`, `ok`, `err` helpers — do not introduce new patterns
- **Extract the handler as an exported arrow function** (required for testability — see Step U6)

## Step U6 — Ensure Vitest is set up

Check whether `vitest` is already in `devDependencies`. If not:

1. Add `vitest` and `@vitest/coverage-v8` to devDependencies
2. Add test scripts to package.json: `"test": "vitest run"`, `"test:watch": "vitest"`, `"coverage": "vitest run --coverage"`
3. Create `src/__tests__/tools.test.ts` following the pattern in Step 7 (CREATE mode)
4. Write tests for any newly added or updated tool handlers

If tests already exist, add tests for new/updated handlers.

## Step U7 — Build and verify

```bash
npm run build
npm test
```

Both must pass with zero errors.

## Step U8 — Sync CLAUDE.md

Ensure `CLAUDE.md` contains:

```markdown
## API Reference

Official API docs: <url>
```

Create or update as needed.

## Step U9 — Sync README

1. Update the **Available Tools** section to reflect current tool count and any added tools
2. Ensure `## Resources` contains the official API docs URL — add it if missing

## Step U10 — Update dependencies

Run `npm outdated`. If packages are outdated:

1. Show the list to the user
2. Ask for confirmation before updating
3. Run `npm update` for minor/patch, `npm install <pkg>@latest` for major bumps
4. Re-run `npm run build` and `npm test` to verify

## Step U11 — Bump patch version

Increment the patch version in `package.json` (e.g. `1.2.3` → `1.2.4`).

---

# Design Principles

- **Single file** (`src/index.ts`) unless tool count clearly exceeds ~25
- **No inline comments** — clear naming over explanation; extract a named function if logic is complex
- **`const` over `let`** everywhere
- **Arrow functions** over `function` declarations
- **Typed generics on `apiFetch<T>`** — never `any` on response shapes
- **Export tool handlers** as named arrow functions — required for Vitest
- **`dist/` for output** — always, not `build/`
- **Kebab-case** for the project folder and package name
- **Always `console.error()`** — never `console.log()` (corrupts STDIO)
- **Destructive tools** require a `confirm: z.boolean().default(false)` guard

## Final step — QA

Run `/qa-run` to review this execution for missed steps or wrong decisions.
