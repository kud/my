#!/usr/bin/env node

import { $ } from "zx"
import chalk from "chalk"
import inquirer from "inquirer"
import simpleGit from "simple-git"

const git = simpleGit()

const main = async () => {
  try {
    const branchesList = (await $`git branch -vv | grep -v 'origin/HEAD'`)
      .stdout
    const goneBranches = branchesList
      .split("\n")
      .filter((branch) => branch.includes(": gone]"))
      .map((branch) => branch.trim().split(" ")[0])

    const currentBranch = (await git.revparse(["--abbrev-ref", "HEAD"])).trim()

    if (goneBranches.includes(currentBranch)) {
      console.log(
        chalk.red(
          `Error: The current branch ${currentBranch} is marked as gone on the remote.`,
        ),
      )
      console.log(
        chalk.yellow(
          `Switch to a different branch or fix the upstream reference before proceeding.`,
        ),
      )
      process.exit(1)
    }

    await git.fetch()
    await git.pull()

    if (goneBranches.length) {
      console.log("")

      const answers = await inquirer.prompt([
        {
          type: "checkbox",
          name: "branchesToDelete",
          message: "Select branches to delete:",
          choices: goneBranches,
          default: goneBranches,
        },
        {
          type: "confirm",
          name: "proceed",
          message: "Continue the deletion… or ctrl+c to stop.",
          default: false,
        },
      ])

      if (answers.proceed && answers.branchesToDelete.length) {
        for (let branch of answers.branchesToDelete) {
          if (branch !== currentBranch) {
            await git.branch(["-D", branch])
          } else {
            console.log(
              chalk.yellow(
                `Skipping deletion of currently checked-out branch: ${branch}`,
              ),
            )
          }
        }
      } else if (!answers.branchesToDelete.length) {
        console.log(chalk.yellow("No branches selected for deletion."))
      }
    } else {
      console.log(chalk.green("No branch to clean."))
    }
  } catch (error) {
    console.error(chalk.red(`Error: ${error.message}`))
    process.exit(1)
  }
}

main()
