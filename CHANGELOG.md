# Changelog

## [0.3.0](https://github.com/VinylStage/discord-mcp-alert/compare/v0.2.0...v0.3.0) (2026-03-03)


### Features

* add gitignore ([e557043](https://github.com/VinylStage/discord-mcp-alert/commit/e55704316c20e4acc97215145b5aa7650d5bf758))
* add portable setup and fix MCP connection issues ([2884e70](https://github.com/VinylStage/discord-mcp-alert/commit/2884e70a360c0e6563c19be1d5efd908d30e5c1f))
* add Windows support and cross-platform install script (v0.3.0) ([247baed](https://github.com/VinylStage/discord-mcp-alert/commit/247baed6d49669dbed34fbc9c53567254b40b39f))
* add Windows support and cross-platform install script (v0.3.0) ([92e8004](https://github.com/VinylStage/discord-mcp-alert/commit/92e80046f74291144255837aaff0cadc4e7ebf5a))
* enable global MCP registration for all projects ([a0b6a92](https://github.com/VinylStage/discord-mcp-alert/commit/a0b6a92411d0133c681c4addaeef8e6c815f2408))

## [0.3.0] (2026-03-03)

### Features

* add Windows native support with PowerShell setup scripts (setup.ps1, register_claude_cli.ps1, run_server.ps1)
* add cross-platform Python setup entry point (install.py) with automatic OS and package manager detection
* add cross-platform Discord hook (discord-notify.py) replacing bash-only hook for Windows support
* support pip + venv as alternative to Poetry (editable install)

### Bug Fixes

* fix MCP server registration command to use module syntax (-m discord_mcp_alert.server) instead of file path
* fix claude mcp add command to use poetry --directory flag instead of bash wrapper (cross-platform)
* fix scripts/register_mcp.py to auto-detect poetry vs pip/venv environment

## [0.2.0](https://github.com/VinylStage/discord-mcp-alert/compare/v0.1.1...v0.2.0) (2026-01-11)


### Features

* add Claude Code hooks for auto Discord notifications ([3529dc3](https://github.com/VinylStage/discord-mcp-alert/commit/3529dc3dddd562e9a2b9dd8b1b4c40575f31ff42))
* add Notification event support with per-event debounce ([6503ca6](https://github.com/VinylStage/discord-mcp-alert/commit/6503ca60b6d5a861b4d1bd56ea8b752756b12fc1))
* enhance hook with project context info ([9917668](https://github.com/VinylStage/discord-mcp-alert/commit/99176689e8fac7bcf51810386884c9974a42bccf))


### Bug Fixes

* add flock atomic locking to prevent duplicate notifications ([52fef01](https://github.com/VinylStage/discord-mcp-alert/commit/52fef01f392d5f4180c57586961445697783c9e9))
* remove duplicate project-level hook settings ([82b736b](https://github.com/VinylStage/discord-mcp-alert/commit/82b736b287d9ef4c741a6d934a6beadb03c39bb9))

## [0.1.1](https://github.com/VinylStage/discord-mcp-alert/compare/v0.1.0...v0.1.1) (2026-01-11)


### Documentation

* add PyPI trusted publishing setup guide ([df8bf50](https://github.com/VinylStage/discord-mcp-alert/commit/df8bf50a7682b279895f577d8edfe5c15cc6f325))

## 0.1.0 (2026-01-11)


### Features

* add registration script and enhanced documentation for Claude Code ([58a4cc8](https://github.com/VinylStage/discord-mcp-alert/commit/58a4cc8adaa2a30d5fc4eb08b5da37ba4a9b52d7))
* initial implementation of discord mcp alert server ([d128189](https://github.com/VinylStage/discord-mcp-alert/commit/d12818977141694884ea4e841537d97e215617ec))


### Bug Fixes

* regenerate poetry.lock to match pyproject.toml ([31afb8c](https://github.com/VinylStage/discord-mcp-alert/commit/31afb8c2a187920b0c8c48543478dab47caa6966))
* resolve ModuleNotFoundError by adding project root to sys.path in server.py ([518679e](https://github.com/VinylStage/discord-mcp-alert/commit/518679eedc6c11c74c51cee89f9cc738f7d35d1c))
* update license format and refresh lock file ([f045cfc](https://github.com/VinylStage/discord-mcp-alert/commit/f045cfceb03c5a8ec0845f2656a22d4003334802))
* update release-please to googleapis/release-please-action ([173bd23](https://github.com/VinylStage/discord-mcp-alert/commit/173bd2331599d25de177315edc013eaa865559a3))


### Documentation

* update repository URLs to match remote origin ([2e84c7d](https://github.com/VinylStage/discord-mcp-alert/commit/2e84c7dc23e816407644ffd8ab29fc37d77caa24))
