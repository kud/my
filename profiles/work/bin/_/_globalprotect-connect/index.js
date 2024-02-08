#!/usr/bin/env node
import { $, echo, chalk } from "zx"
$.verbose = false
import { config } from "dotenv"
config()

echo`Enter password to unlock the database:`

try {
  const { stdout: result } =
    // await $`keepassxc-cli show ${process.env.DATABASE_PATH} -k ${process.env.KEY_PATH} ${process.env.ENTRY_TITLE} -a username -a password -t`
    await $`keepassxc-cli show ${process.env.DATABASE_PATH} ${process.env.ENTRY_TITLE} -a username -a password -t`

  const [username, password, totp] = result.split("\n")

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

const barTender = processes.byName("Bartender")
const globalProtect = processes.byName("GlobalProtect")

// Closing Bartender as it makes more difficult the situation
const bartender = Application("Bartender 4")
bartender.quit()

// Opening GlobalProtect
globalProtect.menuBars[1].menuBarItems[0].click()

const window = globalProtect.windows[0]
waitForButton(window, "Connect").click()

const signInButton = waitForButton(window, "Sign In")

window.textFields[0].value = "${username}"
window.textFields[1].value = "${password}"

signInButton.click()

const okButton = waitForButton(window, "OK")

window.textFields[0].value = "${totp}"

okButton.click()

// Open Bartender back
bartender.activate()
`

  await $`osascript -l JavaScript -e ${script}`
} catch (error) {
  console.log(``)
  console.log(`🤭 Oops, there is an error:`)
  console.log(``)
  console.error(chalk.red(error.stderr))
}
