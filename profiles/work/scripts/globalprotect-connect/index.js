#!/usr/bin/env node
import { $, echo, chalk } from "zx"
$.verbose = !!process.env.DEBUG
import { config, parse } from "dotenv"
import { fileURLToPath } from "url"
import path from "path"
import fs from "fs"

// Robust .env loading: prefer .env.local then .env located next to this script.
;(() => {
  const __dirname = path.dirname(fileURLToPath(import.meta.url))
  const candidates = [
    path.join(__dirname, ".env.local"),
    path.join(__dirname, ".env"),
  ]
  let loadedFrom = null
  for (const p of candidates) {
    if (fs.existsSync(p)) {
      try {
        // Use parse so we can show debug info even if DEBUG set after.
        const raw = fs.readFileSync(p)
        const parsed = parse(raw)
        for (const [k, v] of Object.entries(parsed)) {
          if (process.env[k] === undefined) process.env[k] = v
        }
        loadedFrom = p
        break
      } catch (e) {
        if (process.env.DEBUG) console.log("[DEBUG] Failed reading", p, e)
      }
    }
  }
  if (!loadedFrom) {
    // Fallback to cwd if nothing found (mirrors original behavior)
    config({ quiet: true })
  }
  if (process.env.DEBUG) {
    console.log("[DEBUG] Env loaded from:", loadedFrom || "<cwd .env or none>")
  }
})()

// Inherit stdin so keepassxc-cli can control TTY (hides password),
// but capture stdout and inherit stderr.
const $$ = $({ stdio: ["inherit", "pipe", "inherit"] })

const maxRetries = 3

const main = async (attempt) => {
  echo`🔑 Enter password to unlock the database (Attempt ${attempt} of ${maxRetries}):`

  try {
    // Validate required environment variables.
    const required = ["DATABASE_PATH", "ENTRY_TITLE"]
    const missing = required.filter(
      (k) => !process.env[k] || process.env[k].trim() === "",
    )
    if (missing.length) {
      console.log(
        "Missing required environment variable(s):",
        missing.join(", "),
      )
      if (process.env.DEBUG) {
        console.log("[DEBUG] Current env snapshot:")
        required.forEach((k) =>
          console.log(`  ${k}=${process.env[k] || "<undefined>"}`),
        )
      }
      return false
    }
    if (process.env.DEBUG) {
      console.log(
        chalk.yellow("[DEBUG] Running keepassxc-cli with:"),
        process.env.DATABASE_PATH,
        process.env.ENTRY_TITLE,
      )
    }
    const { stdout: result } =
      await $$`keepassxc-cli show ${process.env.DATABASE_PATH} ${process.env.ENTRY_TITLE} -a username -a password -t --quiet`

    if (process.env.DEBUG) {
      console.log(chalk.yellow("[DEBUG] keepassxc-cli result:"), result)
    }
    const [username, password, totp] = result.split("\n")

    console.log("")
    console.log("Password confirmed 🙌. Connecting to the VPN now 🚀.")
    console.log("(Please do not do anything on the computer in the meantime.)")

    const script = `
const waitForButton = (window, name) => {
  let button = null

  while (!button) {
    for (let i = 0; i < window.buttons.length; i++) {
      if (window.buttons[i].name() === name) {
        button = window.buttons[i]
        break
      }
    }
    delay(0.1)
  }
  return button
}

const { processes } = Application("System Events")
const globalProtect = processes.byName("GlobalProtect")

// Closing Ice as it makes more difficult the situation
const ice = Application("Ice")
ice.quit()

// Opening GlobalProtect
globalProtect.menuBars[1].menuBarItems[0].click()

const window = globalProtect.windows[0]
waitForButton(window, "Connect").click()

const connectButton = waitForButton(window, "Connect")

window.textFields[0].value = "${username}"
window.textFields[1].value = "${password}"

connectButton.click()

const verifyButton = waitForButton(window, "Verify")

window.textFields[0].value = "${totp}"

verifyButton.click()

// Open Ice back
ice.activate()
`

    await $`osascript -l JavaScript -e ${script}`

    console.log("")
    console.log("All good now, connected to the VPN. 🎉")

    return true
  } catch (error) {
    console.log("")
    console.log(`🤭 Oops, there is an error:`)
    console.log("")
    if (process.env.DEBUG) {
      console.error(chalk.red("[DEBUG] Error object:"), error)
    }
    console.error(chalk.red(error.stderr || error.message))

    return false
  }
}

const runWithRetries = async () => {
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    const success = await main(attempt)
    if (success) {
      break
    }
    if (attempt === maxRetries) {
      console.log(`Failed after ${maxRetries} attempts.`)
    }
  }
}

runWithRetries()
