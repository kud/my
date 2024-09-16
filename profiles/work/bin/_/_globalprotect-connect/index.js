#!/usr/bin/env node
import { $, echo, chalk } from "zx"
$.verbose = false
import { config } from "dotenv"
config()

const maxRetries = 3

const main = async (attempt) => {
  echo`🔑 Enter password to unlock the database (Attempt ${attempt} of ${maxRetries}):`

  try {
    const { stdout: result } =
      await $`keepassxc-cli show ${process.env.DATABASE_PATH} ${process.env.ENTRY_TITLE} -a username -a password -t`
    // await $`keepassxc-cli show ${process.env.DATABASE_PATH} -k ${process.env.KEY_PATH} ${process.env.ENTRY_TITLE} -a username -a password -t`

    const [username, password, totp] = result.split("\n")

    console.log("")
    console.log(
      "It's the right password 🙌. Let's connect you to the VPN then 🚀.",
    )
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
    console.log("All good now, you're connected to the VPN. 🎉")
    return true // Indicate success
  } catch (error) {
    console.log(``)
    console.log(`🤭 Oops, there is an error:`)
    console.log(``)
    console.error(chalk.red(error.stderr))
    return false // Indicate failure
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
