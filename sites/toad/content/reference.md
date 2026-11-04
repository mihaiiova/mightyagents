---
title: Reference
group: Reference
weight: 70
lead: Commands, MCP tools, the handoff and suite formats, where Toad keeps things, and the settings you can change.
---

## Commands

| Command | |
|---|---|
| `toad setup` | Prepare or repair everything Toad needs. Flags: `--yes`, `--no-register`, `--skip-browser`, `--skip-image`, `--force`, `--model`, `--lead-model`, `--tester-model` |
| `toad doctor` | Check the agent, model key, browser, CLI sandbox and coding agents |
| `toad update` | Install the latest version from GitHub and prepare it |
| `toad run` | Run the project's saved suites, e.g. in CI. Flags: `--project`, `--suite`, `--tag`, `--max-scenarios`, `--url`, `--workdir`, `--retries`, `--timeout`, `--model`, `--lead-model`, `--tester-model`, `--env`, `--sandbox`, `--max-cost`, `--allow-writes`, `--junit`, `--summary`, `--json`. See [Run on every deploy](/run-on-every-deploy/) |
| `toad mcp` | The MCP server; coding agents start it |
| `toad ui [--port <port>]` | The [run viewer](/viewer/) |
| `toad projects [forget <path>]` | The projects the viewer shows |

## MCP tools

| Tool | What it does |
|---|---|
| `get_toad_guide` | Returns the guide for coding agents |
| `setup_project` | Creates `.toad/` in a project, with `toad.yaml` and `suites/example.yaml` (never overwrites files), and adds it to the viewer's list |
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
  "limitations": ["Use test data only"],
  "title": "Sign-in smoke"
}
```

`title` (optional, at most 120 characters) names the run in the viewer.

For `"kind": "cli"`, the target is:

```json
{ "workdir": "/abs/path", "program": "node dist/cli.js", "image": "node:22-bookworm", "setup": ["npm ci --ignore-scripts"] }
```

For `"kind": "api"`, the target is:

```json
{ "url": "http://localhost:8080/api", "spec": "openapi.yaml", "workdir": "/abs/path", "image": "node:22-bookworm" }
```

Only `url` is required for API tests; `workdir` defaults to the project and
`spec` is relative to it. CLI and API `image` is optional. Fields left out of `target`, and the timeout, come from
`toad.yaml`; the handoff wins where both are set. Without scenarios, Toad
derives them from the goal.

For CLI and API handoffs, `target.setup` (at most 20 commands) runs once in
the sandbox before any scenario, and `"allow_installs": true` lets testers
install a missing prerequisite instead of reporting it. Web handoffs take
neither.

### Result

The result has the report as text and as structured content:

| Field | |
|---|---|
| `verdict` | `PASS`, `FAIL`, `ERROR`, or `UNKNOWN` when the report has none |
| `status` | How the run itself ended: `ok`, `timeout`, `blocked`, `cancelled`, `error`, `configuration_error`, `setup_failed`, `cost_limit` |
| `scenarios` | Each scenario's `name` and `result`; one the report left out is `ERROR` with `missing: true` |
| `runId` | The workflow's run ID |
| `run` | The run folder under `.toad/runs/` |
| `receipts` | The receipts folder |
| `files`, `screenshots` | Paths to what the run produced |
| `cost` | US dollars Pi recorded for the run, at its catalog prices |

The verdict never contradicts a scenario: any `FAIL` makes the run `FAIL`,
otherwise any `ERROR` makes it `ERROR`.

A run that could not complete is a tool error; a failing test is not.

## Suite

`.toad/suites/<name>.yaml`, for [`toad run`](/run-on-every-deploy/). The
handoff's fields at the top level, plus `tags` and `writes`:

| Field | |
|---|---|
| `kind` | `web`, `cli` or `api` (required) |
| `goal` | What to test (required) |
| `scenarios` | At least one, each with `name`, `steps`, `expected` and optional `tags`; names must be distinct |
| `title`, `target`, `credentials`, `limitations`, `allow_installs`, `timeout_minutes` | As in a handoff; `target` fields left out come from `toad.yaml` |
| `tags` | Tags for the whole suite; `--tag` matches a scenario's or its suite's |
| `writes` | `true` when it may create, change or delete data; such a suite needs `--allow-writes`, and one without it is told it is read-only |

## Where things live

Toad is installed once; everything about a project stays in that project.

| Where | What |
|---|---|
| `<project>/.toad/` | defaults, suites, secret values, runs |
| `~/.config/toad/` | `projects.json` (the viewer's list), `credentials.json` (model keys), `settings.json` (model choices) |
| `~/.local/share/toad/agent/<version>/` | the prepared agent; older versions are removed on update |
| `~/.local/share/toad/agent-variants/` | copies of the agent for runs on other models; rebuilt when the agent is |
| `~/.cache/toad/scenarios/` | CLI workspaces, removed after 7 days unused |
| `$XDG_RUNTIME_DIR/toad/` | run slots and per-run secret files (falls back to a private folder in the system temp directory) |

On Windows these are under `%APPDATA%\toad` and `%LOCALAPPDATA%\toad`.

## Settings

Environment variables, set where the MCP server is registered:

| Variable | Default | |
|---|---|---|
| Provider API key, e.g. `DEEPSEEK_API_KEY` | the saved key | The provider key; overrides the one `toad setup` saved |
| `TOAD_MAX_CONCURRENT_RUNS` | `2` | Runs at once across every Toad server on the machine; further calls wait |
| `TOAD_CLI_SANDBOX` | `auto` | `container`, `bwrap`, `none` (no isolation; only when set), or `auto` (a running container runtime, else Bubblewrap) |
| `TOAD_CONTAINER_RUNTIME` | first that answers | `docker` or `podman` |
| `TOAD_CLI_IMAGE` | `node:22-bookworm` | Image for CLI tests when the project does not set one |
| `TOAD_COMMAND_TIMEOUT_S` | `120` | Time limit for each CLI command |
| `TOAD_SETUP_TIMEOUT_S` | `900` | Time limit for each setup command |
| `TOAD_SCENARIO_TTL_DAYS` | `7` | When unused CLI workspaces are removed; `0` keeps them |
| `TOAD_CONFIG_DIR`, `TOAD_DATA_DIR`, `TOAD_CACHE_DIR`, `TOAD_RUNTIME_DIR` | see above | Move Toad's per-user folders |
| `TOAD_AGENT_DIR` | the prepared agent | Use an agent somewhere else |
