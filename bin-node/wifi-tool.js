#!/usr/bin/env node

import { $ } from "zx"
import yargs from "yargs"
import { hideBin } from "yargs/helpers"
import chalk from "chalk"

$.verbose = false

const startWifi = async () => {
  await $`networksetup -setairportpower en1 on`
  console.log("🚀 WiFi started.")
}

const stopWifi = async () => {
  await $`networksetup -setairportpower en1 off`
  console.log("🚫 WiFi stopped.")
}

const listSsid = async () => {
  const result =
    await $`/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -s`
  console.log(result.stdout)
}

yargs(hideBin(process.argv))
  .scriptName(chalk.cyan("wifi-tool"))
  .usage(chalk.white("Usage: $0 [<command>|--help]"))
  .command("start", chalk.black("Start WiFi"), {}, startWifi)
  .command("stop", chalk.black("Stop WiFi"), {}, stopWifi)
  .command(
    "list",
    chalk.black("List SSID (doesn't work when sharing ON)"),
    {},
    listSsid,
  )
  .demandCommand(1, chalk.red("Invalid command. Use --help for usage."))
  .help()
  .version("1.0.0")
  .epilogue(chalk.yellow("For more information, check out the documentation."))
  .fail((msg, err) => {
    if (err) throw err
    console.error(chalk.red("Error!"))
    console.error(chalk.red(msg))
    process.exit(1)
  }).argv
