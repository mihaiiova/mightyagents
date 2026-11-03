---
title: Install
group: Getting started
weight: 10
lead: One command installs Toad, and one more sets everything up. You can run setup again at any time.
---

## Requirements

| | Needed for |
|---|---|
| Node.js 22.19+ on Linux or macOS | everything (Windows: see below) |
| A [DeepSeek](https://platform.deepseek.com/api_keys) API key | the model the agent uses |
| [Docker](https://docs.docker.com/get-docker/) or [Podman](https://podman.io), running | CLI tests; web tests work without it |

On Linux without Docker or Podman, CLI tests can use
[Bubblewrap](https://github.com/containers/bubblewrap) 0.8 or later instead.

> **Windows:** Toad's code is written to run there, but it is not verified
> yet, and the Pi Forge workflow runner it builds on has not been tested on
> Windows. Use WSL until a release says otherwise.

## Install

```sh
npm install -g github:mihaiiova/toad
toad setup
```

Toad installs straight from GitHub for now; it is not on npm yet. Add
`#<tag-or-commit>` to the package name to install a specific version instead
of `main`.

## What setup does

`toad setup` walks through everything once:

1. Prepares the testing agent in `~/.local/share/toad/agent/<version>/`.
2. Downloads Chromium for web tests (about 150 MB the first time).
3. Asks for your DeepSeek key, checks it, and saves it in
   `~/.config/toad/credentials.json`, readable only by you.
4. Finds Docker or Podman for CLI tests and offers to download the default
   image (`node:22-bookworm`, about 1 GB; otherwise it downloads on the first
   CLI test).
5. Finds Claude Code, Codex and Pi on your machine and offers to register
   Toad with each.

`toad setup --yes` accepts every default without asking. It then takes the
key from `DEEPSEEK_API_KEY`.

## Check it

```sh
toad doctor
```

Doctor checks the agent, the model key, the browser, the CLI sandbox and the
coding agents, and tells you what is missing.

## Update

```sh
toad update
```

It installs the latest `main` from GitHub and prepares its agent. Your key and
projects stay. Restart your coding agents afterwards.
