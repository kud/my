#!/usr/bin/env node

import fs from "fs"
import os from "os"
import path from "path"
import Table from "cli-table3"
import plist from "simple-plist"

const systemPath = "/Library/LaunchAgents/"
const userPath = path.join(os.homedir(), "/Library/LaunchAgents/")

const lookupFolders = [
  { path: systemPath, source: "System" },
  { path: userPath, source: "User" },
]

const table = new Table({
  head: ["File", "Program", "Source"],
  colWidths: [40, 120, 20],
  wordWrap: true,
})

const allFiles = []

for (const folder of lookupFolders) {
  const files = fs
    .readdirSync(folder.path)
    .map((file) => ({ file, folderPath: folder.path, source: folder.source }))
  allFiles.push(...files)
}

allFiles.sort((a, b) => {
  return a.file.localeCompare(b.file)
})

for (const fileInfo of allFiles) {
  const filePath = path.join(fileInfo.folderPath, fileInfo.file)
  const parsedPlist = plist.readFileSync(filePath)

  let program = parsedPlist.Program
  if (parsedPlist.ProgramArguments) {
    program = parsedPlist.ProgramArguments.map((arg) => `${arg}`).join("\n")
  }

  if (program) {
    table.push([fileInfo.file, program, fileInfo.source])
  }
}

console.log(table.toString())
