---
name: my-cli-creator
description: "Scaffolds a new @kud CLI project from scratch following established conventions: ESM+tsx, tsup build, bin structure, dev/build/typecheck/clean scripts, Ink for TUI, chalk+ora+inquirer for interactive CLIs. Use this when starting any new CLI tool."
---

You are scaffolding a new CLI project following @kud conventions. Follow every step exactly.

## Step 1 — Gather info

Ask the user:

1. **What does this CLI do?** (one-line description)
2. **CLI type**: TUI (Ink/React full-screen) or interactive (inquirer/ora prompts)?
3. **Binary name**: e.g. `my-tool` → package `@kud/my-tool-cli`, folder `~/Projects/my-tool-cli/`
4. **What subcommands or main flow** does it need?

Do not proceed until you have clear answers.

## Step 2 — Create project structure

```
~/Projects/<name>-cli/
  src/
    index.ts          ← entry point (or index.tsx for TUI)
  package.json
  tsconfig.json
```

For TUI projects, also add:

```
  src/
    app.tsx           ← root Ink component
    components/       ← UI components
    hooks/            ← custom hooks
```

For multi-command CLIs, add:

```
  src/
    commands/
      <cmd>.ts
```

## Step 3 — package.json

```json
{
  "name": "@kud/<name>-cli",
  "version": "0.1.0",
  "type": "module",
  "description": "<description>",
  "bin": {
    "<name>": "dist/index.js"
  },
  "scripts": {
    "dev": "tsx src/index.ts",
    "build": "tsup src/index.ts --format esm --dts",
    "build:watch": "tsup src/index.ts --format esm --dts --watch",
    "clean": "rm -rf dist",
    "typecheck": "tsc --noEmit",
    "prepublishOnly": "npm run build",
    "lint": "eslint .",
    "format": "prettier --write ."
  },
  "dependencies": {},
  "devDependencies": {
    "@types/node": "^20.0.0",
    "tsup": "^8.0.0",
    "tsx": "^4.0.0",
    "typescript": "^5.0.0"
  },
  "engines": {
    "node": ">=20.0.0"
  }
}
```

### Dependency choices by CLI type

**TUI (Ink):**

```json
"dependencies": {
  "ink": "^5.0.0",
  "ink-spinner": "^5.0.0",
  "react": "^18.2.0",
  "chalk": "^5.3.0"
},
"devDependencies": {
  "@types/react": "^18.2.0"
}
```

Also add `"dev": "tsx src/index.tsx"` and include `src/index.tsx` in tsup entry.

**Interactive CLI:**

```json
"dependencies": {
  "chalk": "^5.3.0",
  "ora": "^8.0.0",
  "inquirer": "^12.0.0"
}
```

**Data/API CLI (add as needed):**

```json
"dependencies": {
  "zod": "^3.22.0",
  "pathe": "^1.1.0",
  "execa": "^9.0.0"
}
```

### Multiple entry points (daemon, hook, etc.)

```json
"bin": {
  "<name>": "dist/index.js",
  "<name>-daemon": "dist/daemon/index.js",
  "<name>-install": "dist/install/index.js"
},
"scripts": {
  "build": "tsup src/index.ts src/daemon/index.ts src/install/index.ts --format esm --dts --no-splitting"
}
```

## Step 4 — tsconfig.json

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "outDir": "dist",
    "rootDir": "src",
    "declaration": true
  },
  "include": ["src"]
}
```

## Step 5 — Entry point conventions

### TUI entry (`src/index.tsx`)

```typescript
#!/usr/bin/env node
import { render } from "ink"
import React from "react"
import { App } from "./app.js"

render(<App />)
```

### Interactive CLI entry (`src/index.ts`)

```typescript
#!/usr/bin/env node
import chalk from "chalk"

const main = async (): Promise<void> => {
  // logic here
}

main().catch((err) => {
  process.stderr.write(`${chalk.red("error:")} ${err}\n`)
  process.exit(1)
})
```

### Install/hook-registration entry (`src/install/index.ts`)

Use this pattern when the CLI needs to register itself into an external config (e.g. Claude Code hooks, shell rc files):

```typescript
#!/usr/bin/env node
import fs from "node:fs"
import path from "node:path"

const CONFIG_PATH = path.join(
  process.env["HOME"] ?? "~",
  ".config",
  "app",
  "settings.json",
)

const readConfig = (): Record<string, unknown> => {
  if (!fs.existsSync(CONFIG_PATH)) return {}
  return JSON.parse(fs.readFileSync(CONFIG_PATH, "utf8")) as Record<
    string,
    unknown
  >
}

const install = (): void => {
  const config = readConfig()
  // patch config...
  fs.writeFileSync(CONFIG_PATH, JSON.stringify(config, null, 2) + "\n")
  process.stdout.write("installed\n")
}

install()
```

Add to `package.json` scripts: `"install:hooks": "tsx src/install/index.ts"`

## Step 6 — Coding conventions (enforced)

- **ESM only**: `import`/`export`, never `require`/`module.exports`
- **Top-level `await`**: use freely, no wrapping needed in entry points
- **`const` over `let`**: only reach for `let` if mutation is genuinely required
- **No inline comments**: extract well-named functions instead
- **Kebab-case** for all file and folder names
- **No `process.exit(0)`** at end of normal flow — let it exit naturally
- **Error exits**: always `process.exit(1)` with a message to `stderr`
- **Shebangs**: every entry file gets `#!/usr/bin/env node`

## Step 7 — Implement the CLI

Write the actual logic based on what the user described in Step 1. Follow the coding conventions above. Keep it minimal — only what was asked.

## Step 8 — Verify

Run in sequence:

1. `npm run typecheck` — must pass clean
2. `npm run build` — must succeed
3. `node dist/index.js` (or `tsx src/index.ts`) — must run correctly

Surface any errors and fix them before finishing.

## Step 9 — Output summary

Tell the user:

- Folder path
- How to run in dev: `npm run dev`
- How to build: `npm run build`
- How to use the binary: `node dist/index.js` or after `npm link`
- Any env vars or setup required
