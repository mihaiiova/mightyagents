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
| An API key for a [model provider Pi supports](https://pi.dev/models) | the models the agent uses |
| [Docker](https://docs.docker.com/get-docker/) or [Podman](https://podman.io), running | CLI and API tests; web tests work without it |

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
3. Lets you choose separate lead and tester models from supported providers,
   checks them and saves the keys in `~/.config/toad/credentials.json` and
   choices in `~/.config/toad/settings.json`, readable only by you.
4. Finds Docker or Podman for CLI tests and offers to download the default
   image (`node:22-bookworm`, about 1 GB; otherwise it downloads on the first
   CLI test).
5. Finds Claude Code, Codex and Pi on your machine and offers to register
   Toad with each.

`toad setup --yes` keeps the current models, or defaults both to DeepSeek's
`deepseek-flash` on a new install, and takes keys from provider environment
variables such as `DEEPSEEK_API_KEY`. Use `--lead-model` and `--tester-model`
to choose separately, or `--model` for both, using `provider/model` names.
Run setup again to change them. The lead plans and reports; testers run the
scenarios and typically account for most of the cost.

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

It installs the latest `main` from GitHub and prepares its agent. Your models,
keys and projects stay. Restart your coding agents afterwards.
