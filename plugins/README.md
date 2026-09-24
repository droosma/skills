# Plugins

Plugins add tool-specific behavior that a portable `SKILL.md` cannot provide,
such as lifecycle hooks, slash commands, and automatic prompt injection.

Each plugin directory contains a `plugin.json` manifest. The setup scripts
read its `targets` map and use the native installer for each selected tool.
Supported modes are:

- `marketplace-plugin`: install a Claude Code or Copilot CLI plugin
- `pi-package`: install a Pi extension package
- `opencode-plugin`: add an npm package to OpenCode's `plugin` configuration
- `skill-fallback`: use a portable skill from this repo when no native plugin
  exists

`testedVersion` records the upstream release used when the manifest was added.
Marketplace installers may resolve a newer compatible release.
