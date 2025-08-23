#!/usr/bin/env node

import { $, cd } from "zx"
$.verbose = true
import simpleGit from "simple-git"
const git = simpleGit()

const upgradePackage = async ({ name, latest }) => {
  try {
    const branchName = `deps/${name}@${latest}`

    await git.checkout("master")
    await git.checkoutLocalBranch(branchName)

    await $`yarn add ${name}@${latest}`

    await git.add("./*")
    await git.commit(`📦️ Upgrade to ${name}@${latest}`)

    await git.checkout("master")
  } catch (error) {
    console.log(error)
  }
}

const main = async () => {
  try {
    await $`npm outdated --json`
  } catch (error) {
    const outdatedPackages = JSON.parse(error.stdout)

    const pkgs = Object.entries(outdatedPackages).map(([key, value]) => {
      return { name: key, ...value }
    })

    for (const pkg of pkgs) {
      await upgradePackage(pkg)
    }
  }
}

main()
