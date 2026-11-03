---
title: Reference
group: Reference
weight: 70
lead: Commands, MCP tools, the handoff format, where TOaD keeps things, and the settings you can change.
---

## Commands

| Command | |
|---|---|
| `toad setup` | Prepare or repair everything TOaD needs. Flags: `--yes`, `--no-register`, `--skip-browser`, `--skip-image`, `--force` |
| `toad doctor` | Check the agent, model key, browser, CLI sandbox and coding agents |
| `toad update` | Install the latest version from GitHub and prepare it |
| `toad mcp` | The MCP server; coding agents start it |
| `toad ui [--port <port>]` | The [run viewer](/viewer/) |
| `toad projects [forget <path>]` | The projects the viewer shows |

## MCP tools

| Tool | What it does |
|---|---|
| `get_toad_guide` | Returns the guide for coding agents |
| `setup_project` | Creates `.toad/` in a project (never overwrites files) and adds it to the viewer's list |
| `run_project_test` | Runs a handoff in a set-up project; results go to `.toad/runs/<id>/` |
| `run_web_test`, `run_cli_test` | Legacy: tests without a project, using a shared secrets store |

## Handoff

`run_project_test` takes `project_path` (absolute, no symlinks), a `handoff`,
and optionally `timeout_minutes` and `screenshots`. With `inline`, the
default, it attaches up to 8 images; with `paths` it returns only file paths.

```json
{
  "version": 1,
  "kind": "web",
  "target": { "url": "http://localhost:3000" },
  "request": {
    "goal": "Check sign-in",
    "scenarios": [
      { "name": "Sign in", "steps": "Open sign-in, enter the test login", "expected": "The dashboard is shown" }
    ]
  },
  "credentials": {
    "email": { "env": "TOAD_TEST_EMAIL" },
    "password": { "env": "TOAD_TEST_PASSWORD" }
  },
  "limitations": ["Use test data only"]
}
```

For `"kind": "cli"`, the target is:

```json
{ "workdir": "/abs/path", "program": "node dist/cli.js", "image": "node:22-bookworm" }
```

`image` is optional. Fields left out of `target`, and the timeout, come from
`toad.yaml`; the handoff wins where both are set. Without scenarios, TOaD
derives them from the goal.

### Result

The result has the report as text and as structured content:

| Field | |
|---|---|
| `verdict` | `PASS`, `FAIL`, `ERROR`, or `UNKNOWN` when the report has none |
| `status` | How the run itself ended: `ok`, `timeout`, `blocked`, `cancelled`, `error`, `configuration_error` |
| `runId` | The run's folder name under `.toad/runs/` |
| `receipts` | The receipts folder |
| `files`, `screenshots` | Paths to what the run produced |

A run that could not complete is a tool error; a failing test is not.

## Where things live

TOaD is installed once; everything about a project stays in that project.

| Where | What |
|---|---|
| `<project>/.toad/` | defaults, secret values, runs |
| `~/.config/toad/` | `projects.json` (the viewer's list), `credentials.json` (the model key) |
| `~/.local/share/toad/agent/<version>/` | the prepared agent; older versions are removed on update |
| `~/.cache/toad/scenarios/` | CLI workspaces, removed after 7 days unused |
| `$XDG_RUNTIME_DIR/toad/` | run slots and per-run secret files (falls back to a private folder in the system temp directory) |

On Windows these are under `%APPDATA%\toad` and `%LOCALAPPDATA%\toad`.

## Settings

Environment variables, set where the MCP server is registered:

| Variable | Default | |
|---|---|---|
| `DEEPSEEK_API_KEY` | the saved key | The model key; overrides the one `toad setup` saved |
| `TOAD_MAX_CONCURRENT_RUNS` | `2` | Runs at once across every TOaD server on the machine; further calls wait |
| `TOAD_CLI_SANDBOX` | `auto` | `container`, `bwrap`, or `auto` (a running container runtime, else Bubblewrap) |
| `TOAD_CONTAINER_RUNTIME` | first that answers | `docker` or `podman` |
| `TOAD_CLI_IMAGE` | `node:22-bookworm` | Image for CLI tests when the project does not set one |
| `TOAD_COMMAND_TIMEOUT_S` | `120` | Time limit for each CLI command |
| `TOAD_SCENARIO_TTL_DAYS` | `7` | When unused CLI workspaces are removed; `0` keeps them |
| `TOAD_CONFIG_DIR`, `TOAD_DATA_DIR`, `TOAD_CACHE_DIR`, `TOAD_RUNTIME_DIR` | see above | Move TOaD's per-user folders |
| `TOAD_AGENT_DIR` | the prepared agent | Use an agent somewhere else |
