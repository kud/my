#!/usr/bin/env node

import { $ } from "zx"
$.verbose = true

import simpleGit from "simple-git"
const git = simpleGit()

const main = async () => {
  const branches = await git.branchLocal()

  const depsBranches = branches.all.filter((branch) =>
    branch.startsWith("deps/"),
  )

  for (const branch of depsBranches) {
    try {
      console.log(`Processing branch: ${branch}`)

      await $`git checkout ${branch}`

      await $`git push --set-upstream origin ${branch}`

      await $`gh pr create --title "📦 Upgrade to ${branch.replace(
        "deps/",
        "",
      )}" --body "Enjoy\!" --fill`
    } catch (error) {
      console.log(error)
    }
  }
}

main()
