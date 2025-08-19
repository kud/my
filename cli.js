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

const RunSubmenu = ({ onBack }) => {
	const { exit } = useApp();
	const [selectedIndex, setSelectedIndex] = useState(0);

	const modules = [
		{ label: "← Back to main menu", action: "back" },
		{ label: "Apps:", action: "separator" },
		{ label: "  firefox - Open Firefox browser", action: "run firefox" },
		{ label: "  keepassxc - Password manager", action: "run keepassxc" },
		{ label: "  pcloud - Cloud storage", action: "run pcloud" },
		{ label: "  sublime-merge - Git interface", action: "run sublime-merge" },
		{ label: "CLI Tools:", action: "separator" },
		{ label: "  abbr - Command shortcuts", action: "run abbr" },
		{ label: "  aicommits - Smart commit messages", action: "run aicommits" },
		{ label: "  neovim - Text editor setup", action: "run neovim" },
		{ label: "  ssh - SSH configuration", action: "run ssh" },
		{ label: "Packages:", action: "separator" },
		{ label: "  brew - Homebrew packages", action: "run brew" },
		{ label: "  npm - Node.js packages", action: "run npm" },
		{ label: "  pip - Python packages", action: "run pip" },
		{ label: "System:", action: "separator" },
		{ label: "  dotfiles - Personal configurations", action: "run dotfiles" },
		{ label: "  symlink - Create symlinks", action: "run symlink" }
	];

	useInput((input, key) => {
		if (key.upArrow) {
			let newIndex = selectedIndex;
			do {
				newIndex = newIndex > 0 ? newIndex - 1 : modules.length - 1;
			} while (modules[newIndex].action === "separator");
			setSelectedIndex(newIndex);
		} else if (key.downArrow) {
			let newIndex = selectedIndex;
			do {
				newIndex = newIndex < modules.length - 1 ? newIndex + 1 : 0;
			} while (modules[newIndex].action === "separator");
			setSelectedIndex(newIndex);
		} else if (key.return) {
			const selectedModule = modules[selectedIndex];
			if (selectedModule.action === "back") {
				onBack();
			} else if (selectedModule.action !== "separator") {
				handleRunCommand(selectedModule.action);
			}
		} else if (key.escape || (key.ctrl && input === 'c')) {
			onBack();
		}
	});

	const handleRunCommand = async (action) => {
		console.clear();
		console.log(chalk.cyan(`🚀 Executing: ${action}\n`));
		exit();

		const [cmd, module] = action.split(' ');
		const myPath = process.env.MY;
		if (myPath) {
			// Determine the correct path based on module type
			let scriptPath;
			if (['firefox', 'keepassxc', 'pcloud', 'sublime-merge'].includes(module)) {
				scriptPath = `${myPath}/core/apps/${module}.zsh`;
			} else if (['abbr', 'aicommits', 'neovim', 'ssh'].includes(module)) {
				scriptPath = `${myPath}/core/cli/${module}.zsh`;
			} else if (['brew', 'npm', 'pip', 'gem', 'mas', 'antidote'].includes(module)) {
				scriptPath = `${myPath}/core/packages/${module}.zsh`;
			} else {
				scriptPath = `${myPath}/core/system/${module}.zsh`;
			}

			console.log(chalk.gray(`Running: ${scriptPath}`));
			
			const child = spawn('zsh', [scriptPath], {
				stdio: 'inherit',
				env: process.env
			});
			
			child.on('close', (code) => {
				if (code === 0) {
					console.log(chalk.green(`\n✓ ${module} completed successfully!`));
				} else {
					console.log(chalk.red(`\n✗ ${module} failed with exit code ${code}`));
				}
			});
		} else {
			console.log(chalk.red("Error: $MY environment variable not set"));
			console.log(chalk.yellow("Please ensure the environment is properly configured"));
		}
	};

	return React.createElement(Box, { flexDirection: "column" },
		React.createElement(Box, { marginBottom: 1 },
			React.createElement(Text, { color: "cyan", bold: true }, "Run Component - Select a module:")
		),
		React.createElement(Box, { marginBottom: 1 },
			React.createElement(Text, { color: "gray" }, "Use ↑/↓ to navigate, Enter to select, Esc to go back")
		),
		React.createElement(Box, { flexDirection: "column" },
			...modules.map((module, index) => {
				if (module.action === "separator") {
					return React.createElement(Box, { key: index, marginTop: 1 },
						React.createElement(Text, { color: "yellow", bold: true }, module.label)
					);
				}
				return React.createElement(MenuItem, {
					key: index,
					label: module.label,
					isSelected: index === selectedIndex,
					onSelect: () => {}
				});
			})
		)
	);
};

const MainMenu = () => {
	const { exit } = useApp();
	const [selectedIndex, setSelectedIndex] = useState(0);
	const [showRunSubmenu, setShowRunSubmenu] = useState(false);

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
			} else if (selectedCommand.action === "run") {
				setShowRunSubmenu(true);
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
	};

	if (showRunSubmenu) {
		return React.createElement(RunSubmenu, {
			onBack: () => setShowRunSubmenu(false)
		});
	}

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