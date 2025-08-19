#!/usr/bin/env node

import React, { useState } from 'react';
import { render, Text, Box, useInput, useApp } from 'ink';
import { spawn } from 'child_process';
import chalk from 'chalk';

const MenuItem = ({ label, isSelected, onSelect }) => {
	return React.createElement(Box, null,
		React.createElement(Text, { 
			color: isSelected ? "cyan" : "white" 
		}, `${isSelected ? "❯ " : "  "}${label}`)
	);
};

const MainMenu = () => {
	const { exit } = useApp();
	const [selectedIndex, setSelectedIndex] = useState(0);

	const commands = [
		{ label: "install - Set up complete development environment", action: "install" },
		{ label: "update - Refresh all components and packages", action: "update" },
		{ label: "uninstall - Remove the project", action: "uninstall" },
		{ label: "brew-clean - Remove unused Homebrew packages", action: "brew-clean" },
		{ label: "npm-clean - Clean up Node.js global packages", action: "npm-clean" },
		{ label: "doctor - Check system health and configuration", action: "doctor" },
		{ label: "run - Run a specific component", action: "run" },
		{ label: "Exit", action: "exit" }
	];

	useInput((input, key) => {
		if (key.upArrow) {
			setSelectedIndex((prev) => (prev > 0 ? prev - 1 : commands.length - 1));
		} else if (key.downArrow) {
			setSelectedIndex((prev) => (prev < commands.length - 1 ? prev + 1 : 0));
		} else if (key.return) {
			const selectedCommand = commands[selectedIndex];
			if (selectedCommand.action === "exit") {
				exit();
			} else {
				handleCommand(selectedCommand.action);
			}
		} else if (key.escape || (key.ctrl && input === 'c')) {
			exit();
		}
	});

	const handleCommand = async (action) => {
		// Clear the screen and show what we're executing
		console.clear();
		console.log(chalk.cyan(`🚀 Executing: ${action}\n`));
		
		exit();
		
		// Execute the shell command
		if (action === "run") {
			// For "run" command, we need to show sub-options
			console.log(chalk.yellow("Available modules:"));
			console.log("  Apps: firefox, keepassxc, pcloud, sublime-merge");
			console.log("  CLI: abbr, aicommits, neovim, ssh");
			console.log("  Packages: antidote, brew, gem, mas, npm, pip");
			console.log("  System: default-folders, doc, dotfiles, edit, open, os, shims, submodules, symlink");
			console.log("\nUsage: £ run <module>");
		} else {
			// Execute the actual command via the shell
			const myPath = process.env.MY;
			if (myPath) {
				const scriptPath = `${myPath}/core/commands/${action}.zsh`;
				console.log(chalk.gray(`Running: ${scriptPath}`));
				
				const child = spawn('zsh', [scriptPath], {
					stdio: 'inherit',
					env: process.env
				});
				
				child.on('close', (code) => {
					if (code === 0) {
						console.log(chalk.green(`\n✓ ${action} completed successfully!`));
					} else {
						console.log(chalk.red(`\n✗ ${action} failed with exit code ${code}`));
					}
				});
			} else {
				console.log(chalk.red("Error: $MY environment variable not set"));
				console.log(chalk.yellow("Please ensure the environment is properly configured"));
			}
		}
	};

	const asciiArt = `
    ███╗   ███╗██╗   ██╗
    ████╗ ████║╚██╗ ██╔╝
    ██╔████╔██║ ╚████╔╝ 
    ██║╚██╔╝██║  ╚██╔╝  
    ██║ ╚═╝ ██║   ██║   
    ╚═╝     ╚═╝   ╚═╝   
`;

	return React.createElement(Box, { flexDirection: "column" },
		React.createElement(Box, { marginBottom: 1 },
			React.createElement(Text, { color: "yellow", bold: true }, asciiArt)
		),
		React.createElement(Box, { marginBottom: 1 },
			React.createElement(Text, { color: "cyan", bold: true }, "My! Oh My! - Interactive CLI")
		),
		React.createElement(Box, { marginBottom: 1 },
			React.createElement(Text, { color: "gray" }, "Use ↑/↓ to navigate, Enter to select, Esc to exit")
		),
		React.createElement(Box, { flexDirection: "column" },
			...commands.map((command, index) =>
				React.createElement(MenuItem, {
					key: index,
					label: command.label,
					isSelected: index === selectedIndex,
					onSelect: () => handleCommand(command.action)
				})
			)
		)
	);
};

// Show help if --help is passed
if (process.argv.includes('--help') || process.argv.includes('-h')) {
	console.log(`
My! Oh My! - Interactive CLI

Usage:
  node cli.js                 Start interactive menu
  node cli.js --help          Show this help

Available commands:
  install           Set up complete development environment
  update            Refresh all components and packages  
  uninstall         Remove the project
  brew-clean        Remove unused Homebrew packages
  npm-clean         Clean up Node.js global packages
  doctor            Check system health and configuration
  run               Run a specific component

For the full shell-based CLI, use: £
`);
	process.exit(0);
}

render(React.createElement(MainMenu));