#!/usr/bin/env node
import { $, echo, chalk } from "zx"
$.verbose = false
import { config } from "dotenv"
config({ quiet: true })

// Inherit stdin so keepassxc-cli can control TTY (hides password),
// but capture stdout and inherit stderr.
const $$ = $({ stdio: ["inherit", "pipe", "inherit"] })

const maxRetries = 3

const main = async (attempt) => {
  echo`🔑 Enter password to unlock the database (Attempt ${attempt} of ${maxRetries}):`

  try {
    const { stdout: result } =
      await $$`keepassxc-cli show ${process.env.DATABASE_PATH} ${process.env.ENTRY_TITLE} -a username -a password -t --quiet`

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
    console.log(``)
    console.log(`🤭 Oops, there is an error:`)
    console.log(``)
    console.error(chalk.red(error.stderr))

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
